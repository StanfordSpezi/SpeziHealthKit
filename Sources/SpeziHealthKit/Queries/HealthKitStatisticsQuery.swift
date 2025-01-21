//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import SwiftUI
import Spezi
import SpeziFoundation


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
@propertyWrapper @MainActor
public struct HealthKitStatisticsQuery: DynamicProperty {
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
        /// The components defining the interval.
        /// See [here](https://developer.apple.com/documentation/healthkit/queries/executing_statistics_collection_queries) for some more documentation.
        fileprivate let intervalComponents: DateComponents
        
        public init(_ components: DateComponents) {
            self.intervalComponents = components
        }
        
        public static let hour = Self(.init(hour: 1))
        public static let day = Self(.init(day: 1))
        public static let week = Self(.init(day: 7)) // TODO also try .init(weekOfYear: 1)?
        public static let month = Self(.init(month: 1))
        public static let year = Self(.init(year: 1))
    }
    
    
    @Environment(HealthKit.self) private var healthKit
    
    @State private var results = StatisticsQueryResults()
    private let input: StatisticsQueryResults.Input
    
    public init(
        _ sampleType: SampleType<HKQuantitySample>,
        aggregatedBy options: Set<CumulativeAggregationOption>,
        over aggInterval: AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        filter filterPredicate: NSPredicate? = nil
    ) {
        self.init(
            sampleType,
            rawOptions: options.reduce([.mostRecent], { $0.union($1.hkStatisticsOption) }),
            aggInterval: aggInterval,
            timeRange: timeRange,
            filter: filterPredicate
        )
    }
    
    public init(
        _ sampleType: SampleType<HKQuantitySample>,
        aggregatedBy options: Set<DiscreteAggregationOption>,
        over aggInterval: AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        filter filterPredicate: NSPredicate? = nil
    ) {
        self.init(
            sampleType,
            rawOptions: options.reduce([.mostRecent], { $0.union($1.hkStatisticsOption) }),
            aggInterval: aggInterval,
            timeRange: timeRange,
            filter: filterPredicate
        )
    }
    
    private init(
        _ sampleType: SampleType<HKQuantitySample>,
        rawOptions options: HKStatisticsOptions,
        aggInterval: AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        filter filterPredicate: NSPredicate?
    ) {
        input = .init(
            sampleType: sampleType,
            options: options,
            aggInterval: aggInterval,
            timeRange: timeRange,
            filterPredicate: filterPredicate
        )
    }
    
    @_documentation(visibility: internal)
    public nonisolated func update() {
        runOrScheduleOnMainActor {
            results.healthStore = healthKit.healthStore
            // will trigger an update of the query, but only if the input is actually different
            results.input = input
        }
    }
    
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
    
    struct Input: Hashable {
        let sampleType: SampleType<HKQuantitySample>
        let options: HKStatisticsOptions
        let aggInterval: HealthKitStatisticsQuery.AggregationInterval
        let timeRange: HealthKitQueryTimeRange
        let filterPredicate: NSPredicate?
    }
    
    
    /// The healthStore to be used by this query.
    /// - Note: We intentionally require this object be externally-supplied,
    ///     since the documentation says that apps should treat these as long-lived objects,
    ///     with only a single instance shared across the entire app.
    ///     In the context of this type specifically, this is safe, because the public `init`s all require a `HKHealthStore`
    ///     be provided by the caller, and the fileprivate `init()` is used only by the ``HealthKitStatisticsQuery``
    ///     property wrapper, which assigns a non-nil health store prior to updating the `input` property.
    @ObservationIgnored
    fileprivate var healthStore: HKHealthStore!
    
    private(set) public var queryError: (any Error)?
    
    
    @ObservationIgnored
    fileprivate(set) var input: Input? {
        didSet {
            if input != oldValue {
                update()
            }
        }
    }
    
    @ObservationIgnored
    private var task: Task<Void, Never>?
    
    fileprivate private(set) var statistics: [HKStatistics] = []
    
    /// We need the ability to initialise a e
    fileprivate init() {
    }
    
    // TODO Do we really still want this? (No.)
    public init(
        healthStore: HKHealthStore,
        sampleType: SampleType<HKQuantitySample>,
        options: HKStatisticsOptions,
        aggregationInterval: HealthKitStatisticsQuery.AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        filter predicate: Predicate<HKStatistics>? = nil
    ) throws(QueryError) {
        self.healthStore = healthStore
        let filterPredicate: NSPredicate?
        if let predicate {
            guard let predicate = NSPredicate(predicate) else {
                throw .invalidPredicate
            }
            filterPredicate = predicate
        } else {
            filterPredicate = nil
        }
        self.input = .init(
            sampleType: sampleType,
            options: options,
            aggInterval: aggregationInterval,
            timeRange: timeRange,
            filterPredicate: filterPredicate
        )
        update()
    }
    
    
    deinit {
        task?.cancel()
        task = nil
    }
    
    
    func update() {
        guard let healthStore, let input else {
            print("[\(Self.self) -update]: healthStore and/or input missing")
            return
        }
        print("[\(self.self) -update]")
        let sampleType = input.sampleType.hkSampleType
        var predicate = input.timeRange.queryPredicate
        if let filterPredicate = input.filterPredicate {
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, filterPredicate])
        }
        let queryDesc = HKStatisticsCollectionQueryDescriptor(
            predicate: HKSamplePredicate<HKQuantitySample>.quantitySample(type: sampleType, predicate: predicate),
            options: input.options,
            anchorDate: input.timeRange.range.upperBound,
            intervalComponents: input.aggInterval.intervalComponents
        )
        
        task?.cancel()
        task = Task.detached { [weak self] in
            do {
                print("[\(self) -update] fetching results")
                let results = try catchingNSException {
                    queryDesc.results(for: healthStore)
                }
                for try await update in results {
                    guard let self = self else { return }
                    print("[\(self) -update] new update")
                    let statistics = update.statisticsCollection.statistics()
                    let timeRange = input.timeRange
                    Task { @MainActor in
                        self.queryError = nil
                        self.statistics = statistics
                    }
                }
            } catch {
                // The `queryDesc.results(for:)` call raised an NSException.
                // This typically happens if you have an invalid value somewhere in the input.
                // E.g.: "Statistics option HKStatisticsOptionCumulativeSum is not compatible with discrete data type HKQuantityTypeIdentifierHeartRate"
                guard let self = self else { return }
                Task { @MainActor in
                    self.queryError = error
                    self.statistics = []
                }
            }
        }
    }
}



extension StatisticsQueryResults: HealthKitQueryResults {
    public typealias Index = Int
    public typealias Element = HKStatistics
    
    public subscript(position: Int) -> HKStatistics {
        statistics[position]
    }
    
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
        input!.sampleType
    }
    
    public var timeRange: HealthKitQueryTimeRange {
        input!.timeRange
    }
}



extension HKStatistics: @retroactive Identifiable {}


// it's an OptionSet, the Hashable implementation is trivial, we should be fine here...
extension HKStatisticsOptions: @retroactive Hashable {}




extension HealthKitStatisticsQuery.AggregationInterval {
    /// Determines an hopefully sensible aggregation interval for the specifid query range.
    public init(_ timeRange: HealthKitQueryTimeRange) {
        switch timeRange {
        case .hour:
            self = .hour
        case .today:
            self = .hour
        case .week, .currentWeek:
            self = .day
        case .month, .currentMonth:
            self = .day
        case .year, .currentYear:
            self = .month
        case .lastNHours(let numHours):
            // TODO make this different based on the #hours (like we do with #daye below!)
            self.init(DateComponents(minute: 15))
        case .lastNDays(let numDays):
            // TODO better mapping here!!! (and for the others below!)
            switch numDays {
            case ...2:
                self = .hour
            case 3...31:
                self = .day
            case 32...183:
                self = .week
            default:
                self = .month
            }
        case .lastNWeeks(let numWeeks):
            self = .init(.lastNDays(numWeeks * 7))
        case .lastNMonths(let numMonths):
            // TODO what about leap years?
            // TODO take into account the fact that not all months have the same #days
            self.init(.lastNDays(numMonths * 31))
        case .lastNYears(let numYears):
            self.init(.lastNMonths(numYears * 12))
        case .custom(let range):
            // TODO instead of calculating it here, have it be specified as an associated value?
            self.init(.lastNDays(
                Calendar.current.countDistinctDays(from: range.lowerBound, to: range.upperBound)
            ))
        }
    }
}
