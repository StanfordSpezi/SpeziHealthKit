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
        /// The components defining the interval.
        /// See [here](https://developer.apple.com/documentation/healthkit/queries/executing_statistics_collection_queries) for some more documentation.
        fileprivate let intervalComponents: DateComponents
        
        public init(_ components: DateComponents) {
            self.intervalComponents = components
        }
        
        public static let hour = Self(.init(hour: 1))
        public static let day = Self(.init(day: 1))
        public static let week = Self(.init(day: 7))
        public static let month = Self(.init(month: 1))
        public static let year = Self(.init(year: 1))
    }
    
    
    @Environment(HealthKit.self) private var healthKit
    
    @State private var results = StatisticsQueryResults()
    
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
}


extension HealthKitStatisticsQuery { // swiftlint:disable:this file_types_order
    /// Create a new statistics query.
    public init(
        _ sampleType: SampleType<HKQuantitySample>,
        aggregatedBy options: Set<CumulativeAggregationOption>,
        over aggInterval: AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        filter filterPredicate: NSPredicate? = nil
    ) {
        self.init(
            sampleType,
            rawOptions: options.reduce(into: [.mostRecent], { $0.formUnion($1.hkStatisticsOption) }),
            aggInterval: aggInterval,
            timeRange: timeRange,
            filter: filterPredicate
        )
    }
    
    /// Create a new statistics query.
    public init(
        _ sampleType: SampleType<HKQuantitySample>,
        aggregatedBy options: Set<DiscreteAggregationOption>,
        over aggInterval: AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        filter filterPredicate: NSPredicate? = nil
    ) {
        self.init(
            sampleType,
            rawOptions: options.reduce(into: [.mostRecent], { $0.formUnion($1.hkStatisticsOption) }),
            aggInterval: aggInterval,
            timeRange: timeRange,
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
    
    struct Input: Hashable {
        let sampleType: SampleType<HKQuantitySample>
        let options: HKStatisticsOptions
        let aggInterval: HealthKitStatisticsQuery.AggregationInterval
        let timeRange: HealthKitQueryTimeRange
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
    fileprivate var healthStore: HKHealthStore! // swiftlint:disable:this implicitly_unwrapped_optional
    
    public private(set) var queryError: (any Error)?
    
    
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
    
    /// Creates an empty, uninitialized ``StatisticsQueryResults`` object.
    ///
    /// The purpose of this initializer is to allow this type to be used as a state object in SwiftUI,
    /// for which we need to be able to initialize it without passing in any context.
    fileprivate init() {}
    
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
                let results = try catchingNSException {
                    queryDesc.results(for: healthStore)
                }
                for try await update in results {
                    guard let self = self else {
                        return
                    }
                    let statistics = update.statisticsCollection.statistics()
                    Task { @MainActor in
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
