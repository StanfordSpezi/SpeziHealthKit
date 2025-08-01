//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import Spezi
import SpeziFoundation
import SpeziHealthKit
import SwiftUI


/// Query the HealthKit database within SwiftUI views.
///
/// Queries are performed in the context of the [`HealthKit`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkit/healthkit) module, which must be enabled via an app's `SpeziAppDelegate`.
///
/// A query exposes, via its wrapped value, the samples it received from the HealthKit database.
/// The actual type of the samples returned is dependent on the specific sample type being queried for.
///
/// Queries are auto-updating for the lifetime of the view they are attached to, and will automatically trigger view updates when used in the view's body.
///
/// Example: the following view uses the ``HealthKitQuery`` property wrapper to query
/// all heart rate measurements recorded today.
///
/// ```swift
/// struct ExampleView: View {
///     @HealthKitQuery(.heartRate, timeRange: .today)
///     private var heartRateSamples
///
///     @HealthKitQuery(.bloodPressure, timeRange: .week)
///     private var bloodPressureSamples
///
///     var body: some View {
///         ForEach(heartRateSamples) { sample in
///             // ...
///         }
///     }
/// }
/// ```
///
/// - Note: This property wrapper is intended for situations where you are interested in all individual samples.
///     If you are interested in pre-computed sumamary values for a certain sample type over a certain time range,
///     consider using ``HealthKitStatisticsQuery`` instead.
///
/// - Note: There is a known bug, where a query that uses a `SourceFilter` and initially doesn't match any samples
///     (e.g.: because no samples from a matching `HKSource` exist), will not auto-update when a source that matches the filter adds new samples.
///     Instead, these samples will only show up when the view appears the next time.
///     If this is a likely scenario for your app, use a ``HealthKitQuery`` without a `SourceFilter` and then perform manual filtering on the resulting samples.
@propertyWrapper @MainActor
public struct HealthKitQuery<Sample: _HKSampleWithSampleType>: DynamicProperty { // swiftlint:disable:this file_types_order
    private let input: SamplesQueryResults<Sample>.Input
    private let limit: Int?
    
    @Environment(HealthKit.self)
    private var healthKit
    
    @State
    private var results = SamplesQueryResults<Sample>()
    
    @HealthAccessAuthorizationObserver private var accessAuthObserver
    
    /// The individual query results.
    ///
    /// - Note: This property is a `RandomAccessCollection<Sample>`; the specific type is an implementation detail and may change.
    public var wrappedValue: Slice<OrderedArray<Sample>> {
        // until https://github.com/swiftlang/swift/issues/78405 https://github.com/swiftlang/swift/issues/81560
        // and https://github.com/swiftlang/swift/issues/81561 are fixed, we can't return `some RandomAccessCollection<Sample>` here,
        // which would arguably be vastly preferable, and sadly need to expose the `OrderedArray` implementation detail :/
        
        // Note that we're intentionally not returning `results` directly here (even though it also is a RandomAccessCollection),
        // the reason being that it would be auto-updating, which might be unexpected since it's not communicated via the return
        // type. Instead, we return `results.dataPoints`, i.e. essentially a snapshot of the current state of the results object.
        if let limit, limit > 0 {
            results.samples.suffix(limit)
        } else {
            results.samples[...]
        }
    }
    
    /// The query's underlying auto-updating results object.
    /// This can be used e.g. to provide data to a ``HealthChart``.
    public var projectedValue: SamplesQueryResults<Sample> {
        results
    }
    
    /// Creates a new query.
    /// - parameter sampleType: The sample type to query for
    /// - parameter timeRange: The interval for which the query should fetch samples.
    ///     Any new samples added to or removed from the health store that fall into this time range will be considered by the query.
    /// - parameter filterPredicate: An optional refining predicate for filtering the queried-for samples.
    ///     This predicate should be created using the utility methods on the `HKQuery` type: https://developer.apple.com/documentation/healthkit/hkquery#1664362
    /// - parameter limit: Optional. The maximum number of samples the query should return. If set to a value `N > 0`, the query will return the `N` most recent samples.
    ///     The limit is applied after the `timeRange` and `filterPredicate`.
    public init(
        _ sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        source sourceFilter: HealthKit.SourceFilter = .any,
        filter filterPredicate: NSPredicate? = nil,
        limit: Int? = nil
    ) {
        self.input = .init(
            sampleType: sampleType,
            timeRange: timeRange,
            sourceFilter: sourceFilter,
            filterPredicate: filterPredicate
        )
        self.limit = limit
    }
    
    @_documentation(visibility: internal)
    public nonisolated func update() {
        MainActor.assumeIsolated {
            results.initializeSwiftUIManagedQuery(
                healthKit: healthKit,
                input: input
            )
            let accessReqs = HealthKit.DataAccessRequirements(read: [input.sampleType.hkSampleType])
            accessAuthObserver.observeAuthorizationChanges(for: accessReqs) { [results, healthKit, input] in
                await results.initializeSwiftUIManagedQuery(healthKit: healthKit, input: input, forceUpdate: true)
            }
        }
    }
}


/// An auto-updating HealthKit query over samples in the HealthKit database.
///
/// This type is primarily intended to be used by the ``HealthKitStatisticsQuery`` property wrapper, but is also made available as part of the public API.
@Observable
public final class SamplesQueryResults<Sample: _HKSampleWithSampleType>: @unchecked Sendable {
    /// The query input, defining what should be fetched from the HealthKit database.
    struct Input: Hashable, @unchecked Sendable {
        let sampleType: SampleType<Sample>
        let timeRange: HealthKitQueryTimeRange
        let sourceFilter: HealthKit.SourceFilter
        let filterPredicate: NSPredicate?
    }
    
    /// The `HKHealthStore` to be used by this query.
    ///
    /// We intentionally require this object be externally-supplied,
    /// since the documentation says that apps should treat these as long-lived objects,
    /// with only a single instance shared across the entire app.
    /// In the context of this type specifically, this is safe, because the fileprivate `init()` is used only by the ``HealthKitQuery``
    /// property wrapper, which assigns a non-nil health store prior to updating the `input` property.
    @ObservationIgnored
    private var healthKit: HealthKit! // swiftlint:disable:this implicitly_unwrapped_optional
    
    @ObservationIgnored
    private var input: Input?
    
    @ObservationIgnored
    private var queryTask: Task<Void, Never>?
    
    @ObservationIgnored
    private var authorizationObserverTask: Task<Void, Never>?
    
    public private(set) var isCurrentlyPerformingInitialFetch: Bool = false
    public private(set) var queryError: (any Error)?
    
    fileprivate private(set) var samples = OrderedArray<Sample> { lhs, rhs in
        if lhs.startDate < rhs.startDate {
            return true
        } else if lhs.startDate > rhs.startDate {
            return false
        } else {
            return lhs.uuid < rhs.uuid
        }
    }
    
    
    /// Creates an empty, uninitialized ``StatisticsQueryResults`` object.
    ///
    /// The purpose of this initializer is to allow this type to be used as a state object in SwiftUI,
    /// for which we need to be able to initialize it without passing in any context.
    fileprivate init() {}
    
    
    @MainActor
    fileprivate func initializeSwiftUIManagedQuery(healthKit: HealthKit, input: Input, forceUpdate: Bool = false) {
        guard forceUpdate || self.input != input else {
            return
        }
        self.healthKit = healthKit
        self.input = input
        startQuery()
    }
    
    
    /// Starts the auto-updating query.
    /// - Note: it might take a bit until the first results arrive and the query gets populated.
    @MainActor
    private func startQuery() {
        guard let input, let healthKit else {
            return
        }
        samples.removeAll()
        self.isCurrentlyPerformingInitialFetch = true
        queryTask?.cancel()
        queryTask = Task.detached { [weak self] in
            do {
                let query = try await healthKit.continuousQuery(
                    input.sampleType,
                    timeRange: input.timeRange,
                    anchor: QueryAnchor(),
                    source: input.sourceFilter,
                    limit: nil,
                    predicate: input.filterPredicate
                )
                for try await update in query {
                    guard let self = self else {
                        break
                    }
                    Task { @MainActor in
                        var samples = self.samples
                        let deletedUUIDs = update.deletedObjects.mapIntoSet { $0.uuid }
                        samples.removeAll(where: { deletedUUIDs.contains($0.uuid) })
                        samples.insert(contentsOf: update.addedSamples)
                        self.isCurrentlyPerformingInitialFetch = false
                        self.samples = samples
                    }
                }
            } catch {
                guard let self else {
                    return
                }
                Task { @MainActor in
                    self.isCurrentlyPerformingInitialFetch = false
                    self.queryError = error
                }
            }
        }
    }
    
    deinit {
        queryTask?.cancel()
        queryTask = nil
    }
}


extension SamplesQueryResults: HealthKitQueryResults {
    public typealias Index = OrderedArray<Sample>.Index
    public typealias Element = Sample
    
    public var count: Int {
        samples.count
    }
    
    public var startIndex: Index {
        samples.startIndex
    }
    
    public var endIndex: Index {
        samples.endIndex
    }
    
    public var sampleType: SampleType<Sample> {
        guard let input else {
            preconditionFailure("Cannot access \(#function) of \(Self.self) outside of being installed on a SwiftUI view")
        }
        return input.sampleType
    }
    
    public var timeRange: HealthKitQueryTimeRange {
        guard let input else {
            preconditionFailure("Cannot access \(#function) of \(Self.self) outside of being installed on a SwiftUI view")
        }
        return input.timeRange
    }
    
    public subscript(position: Index) -> Element {
        samples[position]
    }
}
