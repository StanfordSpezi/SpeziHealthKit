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
@propertyWrapper @MainActor
public struct HealthKitQuery<Sample: _HKSampleWithSampleType>: DynamicProperty { // swiftlint:disable:this file_types_order
    private let input: SamplesQueryResults<Sample>.Input
    
    @Environment(HealthKit.self)
    private var healthKit
    
    @State
    private var results = SamplesQueryResults<Sample>()
    
    /// The individual query results.
    public var wrappedValue: OrderedArray<Sample> {
        // until https://github.com/swiftlang/swift/issues/78405 is fixed, we can't return `some RandomAccessCollection<Sample>` here,
        // which would arguably be vastly preferable, and sadly need to expose the `OrderedArray` implementation detail :/
        
        // Note that we're intentionally not returning `results` directly here (even though it also is a RandomAccessCollection),
        // the reason being that it would be auto-updating, which might be unexpected since it's not communicated via the return
        // type. Instead, we return `results.dataPoints`, i.e. essentially a snapshot of the current state of the results object.
        results.samples
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
    public init(
        _ sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        filter filterPredicate: NSPredicate? = nil
    ) {
        input = .init(
            sampleType: sampleType,
            timeRange: timeRange,
            filterPredicate: filterPredicate
        )
    }
    
    @_documentation(visibility: internal)
    public nonisolated func update() {
        runOrScheduleOnMainActor {
            results.initializeSwiftUIManagedQuery(
                healthStore: healthKit.healthStore,
                input: input
            )
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
    private var healthStore: HKHealthStore! // swiftlint:disable:this implicitly_unwrapped_optional
    
    @ObservationIgnored
    private var input: Input?
    
    @ObservationIgnored
    private var queryTask: Task<Void, Never>?
    
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
    fileprivate func initializeSwiftUIManagedQuery(healthStore: HKHealthStore, input: Input) {
        guard self.input != input else {
            return
        }
        self.healthStore = healthStore
        self.input = input
        startQuery()
    }
    
    
    /// Starts the auto-updating query.
    /// - Note: it might take a bit until the first results arrive and the query gets populated.
    @MainActor
    private func startQuery() {
        guard let input, let healthStore else {
            return
        }
        self.isCurrentlyPerformingInitialFetch = true
        queryTask?.cancel()
        queryTask = Task.detached { [weak self] in // swiftlint:disable:this closure_body_length
            let predicate = HKSamplePredicate<Sample>.sample(
                type: input.sampleType.hkSampleType,
                predicate: { () -> NSPredicate? in
                    let preds = [
                        input.timeRange.predicate,
                        input.filterPredicate
                    ].compactMap { $0 }
                    return preds.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: preds)
                }()
            )
            let query = HKAnchoredObjectQueryDescriptor(
                predicates: [predicate],
                // we intentionally specify a nil anchor; this way the query will first fetch all existing data matching the descriptor,
                // and then start emit update events for new/deleted data.
                anchor: nil,
                limit: nil
            )
            do {
                let updates = query.results(for: healthStore)
                for try await update in updates {
                    guard let self = self else {
                        break
                    }
                    // SAFETY: this is in fact safe, since all of the update's (i.e., the `HKAnchoredObjectQueryDescriptor<Sample>.Result` type's)
                    // properties (i.e., deletedObjects, addedSamples, and newAnchor) are themselves Sendable. (rdar://16358485)
                    nonisolated(unsafe) let update = update
                    Task { @MainActor in
                        var samples = self.samples
                        nonisolated(unsafe) let update = update
                        let deletedUUIDs = update.deletedObjects.mapIntoSet { $0.uuid }
                        samples.removeAll(where: { deletedUUIDs.contains($0.uuid) })
                        if let addedSamples = update.addedSamples as? [Sample] {
                            // ^^This cast will practically always be true; the issue simply is that the type system doesn't know about it.
                            samples.insert(contentsOf: addedSamples)
                        }
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
