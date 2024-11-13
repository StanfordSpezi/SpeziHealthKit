//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


public final class HealthKitDataProvider: DataProvider {
    private let healthStore = HKHealthStore()
    private let cache: NSCache<NSString, NSArray> = NSCache()
    
    
    /// Returns a unique cache key for a given `HKQuantityType` and `granularity`.
    private func cacheKey(for type: HKQuantityType, granularity: Calendar.Component) -> NSString {
        "\(type.identifier)_\(granularity)" as NSString
    }
    
    /// Queries an internal instance of a `HealthStore` for all past `HKQuantity`s of type `measurementType`, and stores the result in an `NSCache`.
    /// Returns an array of `HKQuantitySamples` whose timestamps fall in the given `ChartRange.domain`.
    ///
    /// If a previous query has already fetched the given type at the given granularity, returns that result from the cache.
    /// Passes a query to `HealthStore` that aggregates the resulting measurement by averaging over the given granularity.
    ///
    /// NOTE: `HKStatisticsCollectionQuery` can only be used with `HKQuantitySample`s. For `HKCorrelationSample`s, we'll need to aggregate/process
    /// the data ourselves. See https://developer.apple.com/documentation/healthkit/hkstatisticscollectionquery.
    public func fetchData(for measurementType: HKQuantityType, in chartRange: ChartRange) async throws -> [HKQuantitySample] {
        // First, check the cache to see if we've previously queried this type.
        let key = cacheKey(for: measurementType, granularity: chartRange.granularity)
        if let samples = cache.object(forKey: key) as? [HKQuantitySample] {
            // The cache contains samples, so we should return the samples in the domain of the given `ChartRange`.
            return samples.filter {
                // TODO: Think about what date to use.
                // $0.startDate = start of interval that $0 is the average of.
                // $0.endDate = end of interval that $0 is the average of.
                chartRange.domain.contains($0.startDate)
            }
        }
        
        // The cache does not contain any samples, so we need to query HealthStore.
        
        // Create date interval components based on granularity.
        let intervalComponents: DateComponents = {
            var components = DateComponents()
            switch chartRange.granularity {
            case .hour:
                components.hour = 1
            case .day:
                components.day = 1
            case .weekOfYear:
                components.weekOfYear = 1
            case .month:
                components.month = 1
            case .year:
                components.year = 1
            default:
                components.day = 1  // Default to daily if unsupported granularity
            }
            return components
        }()
        
        let query = HKStatisticsCollectionQuery(
            quantityType: measurementType,
            quantitySamplePredicate: nil,  // No predicate so that we query all the samples.
            options: .discreteAverage,  // Aggregate by averaging.
            anchorDate: .distantPast,  // Start at the oldest sample.
            intervalComponents: intervalComponents  // Aggregate over components determined by granularity of `chartRange`.
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            query.initialResultsHandler = { query, collection, error in
                // If there's been an error, throw the error on the query thread.
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // If the query results in no collection, there were no samples found, so return an empty array.
                guard let collection else {
                    continuation.resume(returning: [])
                    return
                }
                
                // Enumerate over the statistics collections and add the aggregated sample to our samples array.
                var samples: [HKQuantitySample] = []
                collection.enumerateStatistics(from: .distantPast, to: .now) { statistics, _ in  // TODO: Understand the 2nd arg
                    guard let average = statistics.averageQuantity() else {
                        return
                    }
                    
                    // Initialize a new `HKQuantitySample` representing the average of the samples from
                    // `statistics.startDate` to `statistics.endDate`.
                    let newSample = HKQuantitySample(
                        type: measurementType,
                        quantity: average,
                        start: statistics.startDate,
                        end: statistics.endDate
                    )
                    
                    samples.append(newSample)
                }
                
                // Add the samples to the cache.
                self.cache.setObject(samples as NSArray, forKey: key)
                
                // TODO: Enforce thread safety. Should we be returning on a potentially non-main actor isolated thread?
                continuation.resume(returning: samples)
            }
            
            healthStore.execute(query)
        }
    }
    
    // TODO: Add functionality for invalidating the cache?
    
    
    public init() {}
}
