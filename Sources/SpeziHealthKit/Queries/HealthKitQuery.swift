//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


extension HealthKit {
    /// Run a one-off query.
    ///
    /// Use this function to perform a simple query of HealthKit samples.
    ///
    /// - parameter sampleType: The ``SampleType`` you want to fetch samples for
    /// - parameter timeRange: The time range you want to fetch samples for.
    /// - parameter limit: The number of objects that should be fetched. `nil` indicates that no limit should be applied.
    /// - parameter filterPredicate: Optional refining predicate that allows you to filter which samples should be fetched.
    public func query<Sample>(
        _ sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        limit: Int? = nil,
        predicate filterPredicate: NSPredicate? = nil
    ) async throws -> [Sample] {
        let predicate = sampleType._makeSamplePredicate(
            filter: NSCompoundPredicate(andPredicateWithSubpredicates: [timeRange.predicate, filterPredicate].compactMap(\.self))
        )
        let queryDescriptor = HKSampleQueryDescriptor<Sample>(
            predicates: [predicate],
            sortDescriptors: [SortDescriptor<Sample>(\.startDate, order: .forward)],
            limit: limit
        )
        return try await queryDescriptor.result(for: healthStore)
    }
    
    
    /// Run an anchor query.
    ///
    /// Use this function to perform a one-off anchor query.
    ///
    /// You can use the `limit` parameter to implement a batched query:
    /// ```swift
    /// // This example fetches all heart rate samples
    /// // of the past half year, 5000 samples at a time
    /// var anchor = QueryAnchor<HKQuantitySample>()
    /// while true {
    ///     let samples = try await anchorQuery(
    ///         .heartRate,
    ///         timeRange: .last(months: 6),
    ///         anchor: &anchor,
    ///         limit: 5000
    ///     ).added
    ///     await process(samples) // do smth with the samples
    ///     if samples.isEmpty {
    ///         break
    ///     }
    /// }
    /// ```
    ///
    /// - parameter sampleType: The ``SampleType`` you want to fetch samples for
    /// - parameter timeRange: The time range you want to fetch samples for.
    /// - parameter anchor: The query anchor; this allows you to run a query that fetches only those samples which have been added to / removed from the HealthKit database since the last query.
    ///     This parameter is `inout`; the function will update its value to a new anchor, which represents the state of the HealthKit database as of after the query has run.
    /// - parameter limit: The number of objects that should be fetched. `nil` indicates that no limit should be applied.
    public func anchorQuery<Sample>(
        _ sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        anchor: inout QueryAnchor<Sample>,
        limit: Int? = nil,
        predicate filterPredicate: NSPredicate? = nil
    ) async throws -> (added: [Sample], deleted: [HKDeletedObject]) {
        let predicate = sampleType._makeSamplePredicate(
            filter: NSCompoundPredicate(andPredicateWithSubpredicates: [timeRange.predicate, filterPredicate].compactMap(\.self))
        )
        let queryDescriptor = HKAnchoredObjectQueryDescriptor<Sample>(
            predicates: [predicate],
            anchor: anchor.hkAnchor,
            limit: limit
        )
        let result = try await queryDescriptor.result(for: healthStore)
        anchor = .init(hkAnchor: result.newAnchor)
        return (added: result.addedSamples, deleted: result.deletedObjects)
    }
}


extension HealthKit {
    public struct ContinuousQueryElement<Sample: _HKSampleWithSampleType> {
        typealias Update = HKAnchoredObjectQueryDescriptor<Sample>.Results.Element
        
        private let update: Update
        
        public var addedSamples: [Sample] {
            update.addedSamples
        }
        public var deletedObjects: [HKDeletedObject] {
            update.deletedObjects
        }
        public var newAnchor: QueryAnchor<Sample> {
            QueryAnchor(hkAnchor: update.newAnchor)
        }
        
        fileprivate init(update: Update) {
            self.update = update
        }
    }
    
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    public func continuousQuery<Sample>(
        _ sampleType: SampleType<Sample>,
        startTime: HealthKitQueryTimeRange,
        anchor: QueryAnchor<Sample>,
        limit: Int? = nil,
        predicate filterPredicate: NSPredicate? = nil
    ) async throws -> some AsyncSequence<ContinuousQueryElement<Sample>, any Error> {
        let predicate = sampleType._makeSamplePredicate(
            filter: NSCompoundPredicate(andPredicateWithSubpredicates: [startTime.lowerBoundPredicate, filterPredicate].compactMap(\.self))
        )
        let queryDescriptor = HKAnchoredObjectQueryDescriptor<Sample>(
            predicates: [predicate],
            anchor: anchor.hkAnchor
        )
        let results = queryDescriptor.results(for: healthStore)
        return results.map { ContinuousQueryElement(update: $0) }
    }
}
