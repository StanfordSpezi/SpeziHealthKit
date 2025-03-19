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
    /// - parameter filterPredicate: Optional refining predicate that allows you to filter which samples should be fetched.
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
        anchor = QueryAnchor(result.newAnchor)
        return (added: result.addedSamples, deleted: result.deletedObjects)
    }
}


extension HealthKit {
    /// An element produced by continuous HealthKit queries to inform about updates to the HealthKit database
    public struct ContinuousQueryElement<Sample: _HKSampleWithSampleType>: @unchecked Sendable {
        // ^^SAFETY: this is in fact safe, since all of the update's (i.e., the `HKAnchoredObjectQueryDescriptor<Sample>.Result` type's)
        // properties (i.e., deletedObjects, addedSamples, and newAnchor) are themselves Sendable. (rdar://16358485)
        
        typealias Update = HKAnchoredObjectQueryDescriptor<Sample>.Results.Element
        
        private let update: Update
        
        /// The samples which have been added since the last update.
        public var addedSamples: [Sample] {
            update.addedSamples
        }
        /// The objects which have been deleted since the last update.
        public var deletedObjects: [HKDeletedObject] {
            update.deletedObjects
        }
        /// The new query anchor, representing the state of the database as of directly after this update.
        public var newAnchor: QueryAnchor<Sample> {
            QueryAnchor(update.newAnchor)
        }
        
        fileprivate init(update: Update) {
            self.update = update
        }
    }
    
    
    /// Performs a long-running query of HealthKit data.
    ///
    /// Use this function to run a continuous, long-running HealthKit data query.
    /// This function returns an `AsyncSequence`, which will emit new elements whenever HealthKit informs us about changes to the database.
    ///
    /// - parameter sampleType: The ``SampleType`` that should be queried for.
    /// - parameter timeRange: The time range for which the query should return samples.
    /// - parameter anchor: A ``QueryAnchor``, which allows the caller to run a query that fetches only those objects which have been added since the last time the query was run.
    /// - parameter limit: The maximum number of samples the query will return.
    /// - parameter filterPredicate: Optional refining predicate that allows you to filter which samples should be fetched.
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, *)
    public func continuousQuery<Sample>(
        _ sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        anchor: QueryAnchor<Sample>,
        limit: Int? = nil,
        predicate filterPredicate: NSPredicate? = nil
    ) -> some AsyncSequence<ContinuousQueryElement<Sample>, any Error> {
        continuousQueryImp(sampleType, timeRange: timeRange, anchor: anchor, limit: limit, predicate: filterPredicate)
    }
    
    
    /// Performs a long-running query of HealthKit data.
    ///
    /// Use this function to run a continuous, long-running HealthKit data query.
    /// This function returns an `AsyncSequence`, which will emit new elements whenever HealthKit informs us about changes to the database.
    ///
    /// - parameter sampleType: The ``SampleType`` that should be queried for.
    /// - parameter timeRange: The time range for which the query should return samples.
    /// - parameter anchor: A ``QueryAnchor``, which allows the caller to run a query that fetches only those objects which have been added since the last time the query was run.
    /// - parameter limit: The maximum number of samples the query will return.
    /// - parameter filterPredicate: Optional refining predicate that allows you to filter which samples should be fetched.
    @available(iOS, deprecated: 18.0)
    @available(macOS, deprecated: 15.0)
    @available(watchOS, deprecated: 11.0)
    @_disfavoredOverload
    public func continuousQuery<Sample>(
        _ sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        anchor: QueryAnchor<Sample>,
        limit: Int? = nil,
        predicate filterPredicate: NSPredicate? = nil
    ) -> AsyncMapSequence<HKAnchoredObjectQueryDescriptor<Sample>.Results, ContinuousQueryElement<Sample>> {
        continuousQueryImp(sampleType, timeRange: timeRange, anchor: anchor, limit: limit, predicate: filterPredicate)
    }
    
    
    private func continuousQueryImp<Sample>(
        _ sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        anchor: QueryAnchor<Sample>,
        limit: Int? = nil,
        predicate filterPredicate: NSPredicate? = nil
    ) -> AsyncMapSequence<HKAnchoredObjectQueryDescriptor<Sample>.Results, ContinuousQueryElement<Sample>> {
        let predicate = sampleType._makeSamplePredicate(
            filter: NSCompoundPredicate(andPredicateWithSubpredicates: [timeRange.predicate, filterPredicate].compactMap(\.self))
        )
        let queryDescriptor = HKAnchoredObjectQueryDescriptor<Sample>(
            predicates: [predicate],
            anchor: anchor.hkAnchor,
            limit: limit
        )
        let results = queryDescriptor.results(for: healthStore)
        return results.map { ContinuousQueryElement(update: $0) }
    }
}
