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


/// Perform statistical queries on the HealthKit database, within SwiftUI views.
///
/// Example: the following view uses the ``HealthKitStatisticsQuery`` property wrapper to query
/// all heart rate measurements recorded today.
///
/// ```swift
/// struct ExampleView: View {
///     // Fetch the sum of daily steps, for the last week
///     @HealthKitStatisticsQuery(.stepCount, aggregatedBy: [.sum], over: .day, timeRange: .week)
///     private var dailyStepCounts
///
///     var body: some View {
///         ForEach(dailyStepCounts) { stepCountStats in
///             let numSteps = stepCountStats.sumQuantity()!.doubleValue(for: .count())
///             // ...
///         }
///     }
/// }
/// ```
///
/// - Note: This property wrapper is intended for situations where you are interested in pre-computed sumamary values
///     for a certain sample type over a certain time range.
///     If you are interested in simply querying all individual samples for a certain sample type over a certain time range,
///     consider using ``HealthKitQuery`` instead.
///
/// - Note: There is a known bug, where a query that uses a `SourceFilter` and initially doesn't match any samples
///     (e.g.: because no samples from a matching `HKSource` exist), will not auto-update when a source that matches the filter adds new samples.
///     Instead, these samples will only show up when the view appears the next time.
///     If this is a likely scenario for your app, use a ``HealthKitQuery`` without a `SourceFilter` and then perform manual filtering on the resulting samples.
@propertyWrapper @MainActor
public struct HealthKitStatisticsQuery: DynamicProperty { // swiftlint:disable:this file_types_order
    public enum CumulativeAggregationOption: Hashable {
        case sum
        
        fileprivate var hkStatisticsOption: HKStatisticsOptions {
            switch self {
            case .sum:
                return .cumulativeSum
            }
        }
    }
    
    public enum DiscreteAggregationOption: Hashable {
        case average, min, max
        
        fileprivate var hkStatisticsOption: HKStatisticsOptions {
            switch self {
            case .average:
                return .discreteAverage
            case .min:
                return .discreteMin
            case .max:
                return .discreteMax
            }
        }
    }
    
    
    public struct AggregationInterval: Hashable, Sendable {
        public static let hour = Self(.init(hour: 1))
        public static let day = Self(.init(day: 1))
        public static let week = Self(.init(day: 7))
        public static let month = Self(.init(month: 1))
        public static let year = Self(.init(year: 1))
        
        /// The components defining the interval.
        /// See [here](https://developer.apple.com/documentation/healthkit/queries/executing_statistics_collection_queries) for some more documentation.
        public let intervalComponents: DateComponents
        
        public init(_ components: DateComponents) {
            self.intervalComponents = components
        }
    }
    
    
    @Environment(HealthKit.self) private var healthKit
    
    @State private var results = StatisticsQueryResults()
    
    @HealthAccessAuthorizationObserver private var accessAuthObserver
    
    private let input: StatisticsQueryResults.Input
    
    /// The query's resulting `HKStatistics` objects.
    public var wrappedValue: [HKStatistics] {
        // Note that we're intentionally not returning `results` directly here (even though it also is a RandomAccessCollection),
        // the reason being that it would be auto-updating, which might be unexpected since it's not communicated via the return
        // type. Instead, we return `results.statistics`, i.e. essentially a snapshot of the current state of the results object.
        results.statistics
    }
    
    /// The query's underlying auto-updating results object.
    /// This can be used e.g. to provide data to a ``HealthChart``.
    public var projectedValue: StatisticsQueryResults {
        results
    }
    
    private init(
        _ sampleType: SampleType<HKQuantitySample>,
        rawOptions options: HKStatisticsOptions,
        aggInterval: AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        sourceFilter: HealthKit.SourceFilter,
        filter filterPredicate: NSPredicate?
    ) {
        input = .init(
            sampleType: sampleType,
            options: options,
            aggInterval: aggInterval,
            timeRange: timeRange,
            sourceFilter: sourceFilter,
            filterPredicate: filterPredicate
        )
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


extension HealthKitStatisticsQuery { // swiftlint:disable:this file_types_order
    /// Create a new statistics query.
    public init(
        _ sampleType: SampleType<HKQuantitySample>,
        aggregatedBy options: Set<CumulativeAggregationOption>,
        over aggInterval: AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        source sourceFilter: HealthKit.SourceFilter = .any,
        filter filterPredicate: NSPredicate? = nil
    ) {
        self.init(
            sampleType,
            rawOptions: options.reduce(into: [.mostRecent], { $0.formUnion($1.hkStatisticsOption) }),
            aggInterval: aggInterval,
            timeRange: timeRange,
            sourceFilter: sourceFilter,
            filter: filterPredicate
        )
    }
    
    /// Create a new statistics query.
    public init(
        _ sampleType: SampleType<HKQuantitySample>,
        aggregatedBy options: Set<DiscreteAggregationOption>,
        over aggInterval: AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        source sourceFilter: HealthKit.SourceFilter = .any,
        filter filterPredicate: NSPredicate? = nil
    ) {
        self.init(
            sampleType,
            rawOptions: options.reduce(into: [.mostRecent], { $0.formUnion($1.hkStatisticsOption) }),
            aggInterval: aggInterval,
            timeRange: timeRange,
            sourceFilter: sourceFilter,
            filter: filterPredicate
        )
    }
}


/// An auto-updating HealthKit query over statistical computations.
///
/// This type is primarily intended to be used by the ``HealthKitStatisticsQuery`` property wrapper, but is also made available as part of the public API.
///
/// - Note: [Explain that the class is externally-immutable, but internally-mutable, bc of the StateObject usage!]
@Observable
public final class StatisticsQueryResults: @unchecked Sendable {
    public enum QueryError: Error {
        /// A `Predicate<HKQuantitySample>` provided to an initializer could not be converted into an equivalent `NSPredicate`.
        case invalidPredicate
    }
    
    struct Input: Hashable, @unchecked Sendable {
        let sampleType: SampleType<HKQuantitySample>
        let options: HKStatisticsOptions
        let aggInterval: HealthKitStatisticsQuery.AggregationInterval
        let timeRange: HealthKitQueryTimeRange
        let sourceFilter: HealthKit.SourceFilter
        let filterPredicate: NSPredicate?
    }
    
    
    /// The `HKHealthStore` to be used by this query.
    ///
    /// We intentionally require this object be externally-supplied,
    /// since the documentation says that apps should treat these as long-lived objects,
    /// with only a single instance shared across the entire app.
    /// In the context of this type specifically, this is safe, because the fileprivate `init()` is used only by the ``HealthKitStatisticsQuery``
    /// property wrapper, which assigns a non-nil health store prior to updating the `input` property.
    @ObservationIgnored
    private var healthKit: HealthKit?
    
    @ObservationIgnored private var input: Input?
    @ObservationIgnored private var task: Task<Void, Never>?
    
    public private(set) var isCurrentlyPerformingInitialFetch: Bool = false
    public private(set) var queryError: (any Error)?
    
    fileprivate private(set) var statistics: [HKStatistics] = []
    
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
    
    
    @MainActor
    private func startQuery() {
        guard let healthKit, let input else {
            return
        }
        self.isCurrentlyPerformingInitialFetch = true
        task?.cancel()
        task = Task.detached { [weak self] in // swiftlint:disable:this closure_body_length
            do {
                let basePredicate = NSCompoundPredicate(
                    andPredicateWithSubpredicates: [input.timeRange.predicate, input.filterPredicate].compactMap(\.self)
                )
                let sourcePredicate = try await healthKit.sourcePredicate(
                    for: input.sourceFilter,
                    predicate: input.sampleType._makeSamplePredicate(filter: basePredicate)
                )
                let queryDesc = HKStatisticsCollectionQueryDescriptor(
                    predicate: input.sampleType._makeSamplePredicate(
                        filter: NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicate, sourcePredicate].compactMap(\.self))
                    ),
                    options: input.options,
                    anchorDate: input.timeRange.range.lowerBound,
                    intervalComponents: input.aggInterval.intervalComponents
                )
                let results = try catchingNSException {
                    queryDesc.results(for: healthKit.healthStore)
                }
                for try await update in results {
                    guard let self = self else {
                        return
                    }
                    let statistics = update.statisticsCollection.statistics()
                    Task { @MainActor in
                        self.isCurrentlyPerformingInitialFetch = false
                        self.queryError = nil
                        self.statistics = statistics
                    }
                }
            } catch {
                // The `queryDesc.results(for:)` call raised an NSException.
                // This typically happens if you have an invalid value somewhere in the input.
                // E.g.: "Statistics option HKStatisticsOptionCumulativeSum is not compatible with discrete data type HKQuantityTypeIdentifierHeartRate"
                guard let self = self else {
                    return
                }
                Task { @MainActor in
                    self.isCurrentlyPerformingInitialFetch = false
                    self.queryError = error
                    self.statistics = []
                }
            }
        }
    }
    
    
    deinit {
        task?.cancel()
        task = nil
    }
}


extension StatisticsQueryResults: HealthKitQueryResults {
    public typealias Index = Int
    public typealias Element = HKStatistics
    
    public var startIndex: Int {
        statistics.startIndex
    }
    
    public var endIndex: Int {
        statistics.endIndex
    }
    
    public var count: Int {
        statistics.count
    }
    
    public var sampleType: SampleType<HKQuantitySample> {
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
    
    public subscript(position: Int) -> HKStatistics {
        statistics[position]
    }
}


extension HKStatistics: @retroactive Identifiable {}


// it's an OptionSet, the Hashable implementation is trivial, we should be fine here...
extension HKStatisticsOptions: @retroactive Hashable {}
