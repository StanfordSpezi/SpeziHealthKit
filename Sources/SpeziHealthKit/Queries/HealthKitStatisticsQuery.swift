//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import SpeziFoundation

extension HealthKit {
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
}

extension HealthKit {
    private func statisticsQuery(
        _ sampleType: SampleType<HKQuantitySample>,
        rawOptions options: HKStatisticsOptions,
        aggInterval: HealthKit.AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        source sourceFilter: SourceFilter = .any,
        filterPredicate: NSPredicate? = nil
    ) async throws -> [HKStatistics] {
        let basePredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [timeRange.predicate, filterPredicate].compactMap(\.self)
        )
        let sourcePredicate = try await sourcePredicate(
            for: sourceFilter,
            predicate: sampleType._makeSamplePredicate(filter: basePredicate)
        )
        let queryDescriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: sampleType._makeSamplePredicate(
                filter: NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicate, sourcePredicate].compactMap(\.self))
            ),
            options: options,
            anchorDate: timeRange.range.lowerBound,
            intervalComponents: aggInterval.intervalComponents
        )
        
        return try await queryDescriptor.result(for: healthStore).statistics()
    }
    
    /// Performs a one-off statistical query of HealthKit data, using cumulative aggregations.
    ///
    /// Use this function to perform a single HealthKit statistics query
    ///
    /// - Parameters:
    ///   - sampleType: The ``SampleType`` you want to fetch statistics for.
    ///   - options: The set of cumulative aggregation options to use (e.g., ``HealthKit/CumulativeAggregationOption/sum``).
    ///   - aggInterval: The interval over which the results should be aggregated (e.g., `.day`, `.week`).
    ///   - timeRange: The time range you want to fetch statistics for.
    ///   - sourceFilter: Allows filtering based on the samples' `HKSource`. Defaults to ``HealthKit/SourceFilter/any``.
    ///   - filterPredicate: Optional refining predicate that allows you to further filter which samples should be included.
    public func statisticsQuery(
        _ sampleType: SampleType<HKQuantitySample>,
        aggregatedBy options: Set<HealthKit.CumulativeAggregationOption>,
        over aggInterval: HealthKit.AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        source sourceFilter: SourceFilter = .any,
        filterPredicate: NSPredicate? = nil
    ) async throws -> [HKStatistics] {
        try await statisticsQuery(
            sampleType,
            rawOptions: options.reduce(into: [.mostRecent], { partialResult, option in
                switch option {
                case .sum:
                    partialResult.formUnion(.cumulativeSum)
                }
            }),
            aggInterval: aggInterval,
            timeRange: timeRange,
            source: sourceFilter,
            filterPredicate: filterPredicate
        )
    }
    
    /// Performs a one-off statistical query of HealthKit data, using discrete aggregations.
    ///
    /// Use this function to perform a single HealthKit statistics query
    ///
    /// - Parameters:
    ///   - sampleType: The ``SampleType`` you want to fetch statistics for.
    ///   - options: The set of cumulative aggregation options to use (e.g., ``HealthKit/CumulativeAggregationOption/sum``).
    ///   - aggInterval: The interval over which the results should be aggregated (e.g., `.day`, `.week`).
    ///   - timeRange: The time range you want to fetch statistics for.
    ///   - sourceFilter: Allows filtering based on the samples' `HKSource`. Defaults to ``HealthKit/SourceFilter/any``.
    ///   - filterPredicate: Optional refining predicate that allows you to further filter which samples should be included.
    public func statisticsQuery(
        _ sampleType: SampleType<HKQuantitySample>,
        aggregatedBy options: Set<HealthKit.DiscreteAggregationOption>,
        over aggInterval: HealthKit.AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        source sourceFilter: SourceFilter = .any,
        filterPredicate: NSPredicate? = nil
    ) async throws -> [HKStatistics] {
        try await statisticsQuery(
            sampleType,
            rawOptions: options.reduce(into: [.mostRecent], { partialResult, option in
                switch option {
                case .average:
                    partialResult.formUnion(.discreteAverage)
                case .min:
                    partialResult.formUnion(.discreteMin)
                case .max:
                    partialResult.formUnion(.discreteMax)
                }
            }),
            aggInterval: aggInterval,
            timeRange: timeRange,
            source: sourceFilter,
            filterPredicate: filterPredicate
        )
    }
}


extension HealthKit {
    /// Performs a long-running query of HealthKit data using statistical aggregations.
    ///
    /// Use this function to run a continuous, long-running HealthKit statistics query.
    /// This function returns an `AsyncSequence`, which will emit new elements whenever HealthKit informs us about changes to the database.
    ///
    /// - parameter sampleType: The ``SampleType`` that should be queried for.
    /// - parameter options: The aggregation options used to compute statistics, such as `.cumulativeSum` or `.discreteAverage`.
    /// - parameter aggInterval: The interval over which the statistics should be aggregated (e.g., `.day`, `.week`).
    /// - parameter timeRange: The time range for which the query should return results.
    /// - parameter filterPredicate: Optional refining predicate that allows you to filter which samples should be included.
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, *)
    public func continuousStatisticsQuery(
        _ sampleType: SampleType<HKQuantitySample>,
        options: HKStatisticsOptions,
        aggInterval: HealthKit.AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        filterPredicate: NSPredicate?
    ) throws -> some AsyncSequence<[HKStatistics], any Error> {
        try continuousStatisticsQueryImp(
            sampleType,
            options: options,
            aggInterval: aggInterval,
            timeRange: timeRange,
            filterPredicate: filterPredicate
        )
    }
    
    
    /// Performs a long-running query of HealthKit data using statistical aggregations.
    ///
    /// Use this function to run a continuous, long-running HealthKit statistics query.
    /// This function returns an `AsyncSequence`, which will emit new elements whenever HealthKit informs us about changes to the database.
    ///
    /// - parameter sampleType: The ``SampleType`` that should be queried for.
    /// - parameter options: The aggregation options used to compute statistics, such as `.cumulativeSum` or `.discreteAverage`.
    /// - parameter aggInterval: The interval over which the statistics should be aggregated (e.g., `.day`, `.week`).
    /// - parameter timeRange: The time range for which the query should return results.
    /// - parameter sourceFilter: Allows filtering based on the samples' `HKSource`.
    /// - parameter filterPredicate: Optional refining predicate that allows you to filter which samples should be included.
    ///
    /// - Note: There is a known bug, where a query that uses a `SourceFilter` and initially doesn't match any samples
    ///     (e.g.: because no samples from a matching `HKSource` exist), will not auto-update when a source that matches the filter adds new samples.
    ///     Instead, these samples will only be returned when the function is called again.
    ///     If this is a likely scenario for your app, use ``continuousStatisticsQuery`` without a `SourceFilter` and perform filtering on the resulting samples.
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, *)
    public func continuousStatisticsQuery( // swiftlint:disable:this function_parameter_count
        _ sampleType: SampleType<HKQuantitySample>,
        options: HKStatisticsOptions,
        aggInterval: HealthKit.AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        source sourceFilter: SourceFilter,
        filterPredicate: NSPredicate?
    ) async throws -> some AsyncSequence<[HKStatistics], any Error> {
        try await continuousStatisticsQueryImp(
            sampleType,
            options: options,
            aggInterval: aggInterval,
            timeRange: timeRange,
            source: sourceFilter,
            filterPredicate: filterPredicate
        )
    }
    
    /// Performs a long-running query of HealthKit data using statistical aggregations.
    ///
    /// Use this function to run a continuous, long-running HealthKit statistics query.
    /// This function returns an `AsyncSequence`, which will emit new elements whenever HealthKit informs us about changes to the database.
    ///
    ///
    /// - parameter sampleType: The ``SampleType`` that should be queried for.
    /// - parameter options: The aggregation options used to compute statistics, such as `.cumulativeSum` or `.discreteAverage`.
    /// - parameter aggInterval: The interval over which the statistics should be aggregated (e.g., `.day`, `.week`).
    /// - parameter timeRange: The time range for which the query should return results.
    /// - parameter filterPredicate: Optional refining predicate that allows you to filter which samples should be included.
    @available(iOS, deprecated: 18.0)
    @available(macOS, deprecated: 15.0)
    @available(watchOS, deprecated: 11.0)
    @_disfavoredOverload
    public func continuousStatisticsQuery(
        _ sampleType: SampleType<HKQuantitySample>,
        options: HKStatisticsOptions,
        aggInterval: HealthKit.AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        filterPredicate: NSPredicate?
    ) throws -> AsyncMapSequence<HKStatisticsCollectionQueryDescriptor.Results, [HKStatistics]> {
        try continuousStatisticsQueryImp(
            sampleType,
            options: options,
            aggInterval: aggInterval,
            timeRange: timeRange,
            filterPredicate: filterPredicate
        )
    }
    
    /// Performs a long-running query of HealthKit data using statistical aggregations.
    ///
    /// Use this function to run a continuous, long-running HealthKit statistics query.
    /// This function returns an `AsyncSequence`, which will emit new elements whenever HealthKit informs us about changes to the database.
    ///
    /// - parameter sampleType: The ``SampleType`` that should be queried for.
    /// - parameter options: The aggregation options used to compute statistics, such as `.cumulativeSum` or `.discreteAverage`.
    /// - parameter aggInterval: The interval over which the statistics should be aggregated (e.g., `.day`, `.week`).
    /// - parameter timeRange: The time range for which the query should return results.
    /// - parameter sourceFilter: Allows filtering based on the samples' `HKSource`.
    /// - parameter filterPredicate: Optional refining predicate that allows you to filter which samples should be included.
    ///
    /// - Note: There is a known bug, where a query that uses a `SourceFilter` and initially doesn't match any samples
    ///     (e.g.: because no samples from a matching `HKSource` exist), will not auto-update when a source that matches the filter adds new samples.
    ///     Instead, these samples will only be returned when the function is called again.
    ///     If this is a likely scenario for your app, use ``continuousStatisticsQuery`` without a `SourceFilter` and perform filtering on the resulting samples.
    @available(iOS, deprecated: 18.0)
    @available(macOS, deprecated: 15.0)
    @available(watchOS, deprecated: 11.0)
    @_disfavoredOverload
    public func continuousStatisticsQuery( // swiftlint:disable:this function_parameter_count
        _ sampleType: SampleType<HKQuantitySample>,
        options: HKStatisticsOptions,
        aggInterval: HealthKit.AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        source sourceFilter: SourceFilter,
        filterPredicate: NSPredicate?
    ) async throws -> AsyncMapSequence<HKStatisticsCollectionQueryDescriptor.Results, [HKStatistics]> {
        try await continuousStatisticsQueryImp(
            sampleType,
            options: options,
            aggInterval: aggInterval,
            timeRange: timeRange,
            source: sourceFilter,
            filterPredicate: filterPredicate
        )
    }
    
    private func continuousStatisticsQueryImp( // swiftlint:disable:this function_parameter_count
        _ sampleType: SampleType<HKQuantitySample>,
        options: HKStatisticsOptions,
        aggInterval: HealthKit.AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        source sourceFilter: SourceFilter,
        filterPredicate: NSPredicate?
    ) async throws -> AsyncMapSequence<HKStatisticsCollectionQueryDescriptor.Results, [HKStatistics]> {
        let basePredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [timeRange.predicate, filterPredicate].compactMap(\.self)
        )
        let sourcePredicate = try await sourcePredicate(
            for: sourceFilter,
            predicate: sampleType._makeSamplePredicate(filter: basePredicate)
        )
        let queryDescriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: sampleType._makeSamplePredicate(
                filter: NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicate, sourcePredicate].compactMap(\.self))
            ),
            options: options,
            anchorDate: timeRange.range.lowerBound,
            intervalComponents: aggInterval.intervalComponents
        )
        let results = try catchingNSException {
            queryDescriptor.results(for: healthStore)
        }
        
        return results.map { $0.statisticsCollection.statistics() }
    }
    
    private func continuousStatisticsQueryImp(
        _ sampleType: SampleType<HKQuantitySample>,
        options: HKStatisticsOptions,
        aggInterval: HealthKit.AggregationInterval,
        timeRange: HealthKitQueryTimeRange,
        filterPredicate: NSPredicate?
    ) throws -> AsyncMapSequence<HKStatisticsCollectionQueryDescriptor.Results, [HKStatistics]> {
        let basePredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [timeRange.predicate, filterPredicate].compactMap(\.self)
        )
        let queryDescriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: sampleType._makeSamplePredicate(
                filter: NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicate].compactMap(\.self))
            ),
            options: options,
            anchorDate: timeRange.range.lowerBound,
            intervalComponents: aggInterval.intervalComponents
        )
        let results = try catchingNSException {
            queryDescriptor.results(for: healthStore)
        }
        
        return results.map { $0.statisticsCollection.statistics() }
    }
}
