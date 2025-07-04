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
    /// A filter that allows querying `HKSample`s based on their underlying `HKSource`.
    ///
    /// ## Topics
    /// ### Creating a SourceFilter
    /// - ``any``
    /// - ``currentApp``
    /// - ``healthApp``
    /// - ``bundleId(_:)``
    /// - ``named(_:)``
    /// - ``bundleId(beginsWith:)``
    /// - ``name(beginsWith:)``
    /// - ``name(endsWith:)``
    public struct SourceFilter: Hashable, Sendable {
        // SAFETY: this is @unchecked Sendable, bc of the NSPredicate,
        // but we (ie, this type) control which predicates get passed in,
        // and we only ever pass non-block-based predicates into the enum.
        private indirect enum Variant: Hashable, @unchecked Sendable {
            case any
            case currentApp
            case predicate(NSPredicate)
        }
        
        private let variant: Variant
        
        /// Whether this is the filter that always matches every `HKSource`.
        public var isAny: Bool {
            variant == .any
        }
        
        private init(variant: Variant) {
            self.variant = variant
        }
        
        private init(_ nsPredicate: NSPredicate) {
            variant = .predicate(nsPredicate)
        }
        
        func evaluate(against source: HKSource) -> Bool {
            switch variant {
            case .any:
                true
            case .currentApp:
                source == .default()
            case .predicate(let predicate):
                predicate.evaluate(with: source)
            }
        }
    }
}


extension HealthKit.SourceFilter {
    /// A source filter that always matches every `HKSource`.
    public static let any = Self(variant: .any)
    
    /// A source filter that always matches the `HKSource` representing the current app.
    public static let currentApp = Self(variant: .currentApp)
    
    /// A source filter matching the iOS Health App.
    public static let healthApp = Self.bundleId("com.apple.Health")
    
    /// A source filter matching all `HKSource`s whose name matches `name`.
    public static func named(_ name: String) -> Self {
        .init(NSPredicate(format: "%K = %@", #keyPath(HKSource.name), name))
    }
    
    /// A source filter matching all `HKSource`s whose name begins with `name`.
    public static func name(beginsWith name: String) -> Self {
        .init(NSPredicate(format: "%K BEGINSSWITH %@", #keyPath(HKSource.name), name))
    }
    
    /// A source filter matching all `HKSource`s whose name ends with `name`.
    public static func name(endsWith name: String) -> Self {
        .init(NSPredicate(format: "%K ENDSWITH %@", #keyPath(HKSource.name), name))
    }
    
    /// A source filter matching all `HKSource`s whose bundle identifier matches `bundleId`.
    public static func bundleId(_ bundleId: String) -> Self {
        .init(NSPredicate(format: "%K = %@", #keyPath(HKSource.bundleIdentifier), bundleId))
    }
    
    /// A source filter matching all `HKSource`s whose bundle identifier begins with `bundleId`.
    public static func bundleId(beginsWith bundleId: String) -> Self {
        .init(NSPredicate(format: "%K BEGINSSWITH %@", #keyPath(HKSource.bundleIdentifier), bundleId))
    }
}


extension HealthKit {
    /// Run a one-off query.
    ///
    /// Use this function to perform a simple query of HealthKit samples.
    ///
    /// - parameter sampleType: The ``SampleType`` you want to fetch samples for
    /// - parameter timeRange: The time range you want to fetch samples for.
    /// - parameter sourceFilter: Allows filtering based on the samples' `HKSource`.
    /// - parameter limit: The number of objects that should be fetched. `nil` indicates that no limit should be applied.
    /// - parameter sortDescriptors: The sort descriptors used to sort the fetched samples. Defaults to a sorting the samples by their start date, in ascending order.
    /// - parameter filterPredicate: Optional refining predicate that allows you to filter which samples should be fetched.
    public func query<Sample>(
        _ sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        source sourceFilter: SourceFilter = .any,
        limit: Int? = nil,
        sortedBy sortDescriptors: [SortDescriptor<Sample>] = [SortDescriptor<Sample>(\.startDate, order: .forward)],
        predicate filterPredicate: NSPredicate? = nil
    ) async throws -> [Sample] {
        let basePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [timeRange.predicate, filterPredicate].compactMap(\.self))
        let sourcePredicate = try await sourcePredicate(for: sourceFilter, predicate: sampleType._makeSamplePredicate(filter: basePredicate))
        let predicate = sampleType._makeSamplePredicate(
            filter: NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicate, sourcePredicate].compactMap(\.self))
        )
        let queryDescriptor = HKSampleQueryDescriptor<Sample>(
            predicates: [predicate],
            sortDescriptors: sortDescriptors,
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
    ///     let samples = try await query(
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
    /// - parameter sourceFilter: Allows filtering based on the samples' `HKSource`.
    /// - parameter limit: The number of objects that should be fetched. `nil` indicates that no limit should be applied.
    /// - parameter filterPredicate: Optional refining predicate that allows you to filter which samples should be fetched.
    public func query<Sample>(
        _ sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        anchor: inout QueryAnchor,
        source sourceFilter: SourceFilter = .any,
        limit: Int? = nil,
        predicate filterPredicate: NSPredicate? = nil
    ) async throws -> (added: [Sample], deleted: [HKDeletedObject]) {
        let descriptor = try await constructAnchoredQueryDescriptor(
            sampleType,
            timeRange: timeRange,
            anchor: anchor,
            source: sourceFilter,
            limit: limit,
            predicate: filterPredicate
        )
        let result = try await descriptor.result(for: healthStore)
        anchor = QueryAnchor(result.newAnchor)
        return (added: result.addedSamples, deleted: result.deletedObjects)
    }
    
    
    func constructAnchoredQueryDescriptor<Sample>(
        _ sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        anchor: QueryAnchor,
        limit: Int?,
        predicate filterPredicate: NSPredicate?
    ) -> HKAnchoredObjectQueryDescriptor<Sample> {
        let predicate = sampleType._makeSamplePredicate(
            filter: NSCompoundPredicate(andPredicateWithSubpredicates: [timeRange.predicate, filterPredicate].compactMap(\.self))
        )
        return HKAnchoredObjectQueryDescriptor<Sample>(
            predicates: [predicate],
            anchor: anchor.hkAnchor,
            limit: limit
        )
    }
    
    func constructAnchoredQueryDescriptor<Sample>( // swiftlint:disable:this function_parameter_count
        _ sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        anchor: QueryAnchor,
        source sourceFilter: SourceFilter,
        limit: Int?,
        predicate filterPredicate: NSPredicate?
    ) async throws -> HKAnchoredObjectQueryDescriptor<Sample> {
        let basePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [timeRange.predicate, filterPredicate].compactMap(\.self))
        let sourcePredicate = try await sourcePredicate(for: sourceFilter, predicate: sampleType._makeSamplePredicate(filter: basePredicate))
        let predicate = sampleType._makeSamplePredicate(
            filter: NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicate, sourcePredicate].compactMap(\.self))
        )
        return HKAnchoredObjectQueryDescriptor<Sample>(
            predicates: [predicate],
            anchor: anchor.hkAnchor,
            limit: limit
        )
    }
    
    
    package func sourcePredicate<Sample>(for sourceFilter: SourceFilter, predicate: HKSamplePredicate<Sample>) async throws -> NSPredicate? {
        if sourceFilter.isAny {
            return nil
        } else {
            let descriptor = HKSourceQueryDescriptor(predicate: predicate)
            let allSources = try await descriptor.result(for: healthStore)
            let matchingSources = allSources.filter { sourceFilter.evaluate(against: $0) }
            return HKQuery.predicateForObjects(from: Set(matchingSources))
        }
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
        public var newAnchor: QueryAnchor {
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
        anchor: QueryAnchor,
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
    /// - parameter sourceFilter: Allows filtering based on the samples' `HKSource`.
    /// - parameter limit: The maximum number of samples the query will return.
    /// - parameter filterPredicate: Optional refining predicate that allows you to filter which samples should be fetched.
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, *)
    public func continuousQuery<Sample>(
        _ sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        anchor: QueryAnchor,
        source sourceFilter: SourceFilter,
        limit: Int? = nil,
        predicate filterPredicate: NSPredicate? = nil
    ) async throws -> some AsyncSequence<ContinuousQueryElement<Sample>, any Error> {
        try await continuousQueryImp(sampleType, timeRange: timeRange, anchor: anchor, source: sourceFilter, limit: limit, predicate: filterPredicate)
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
        anchor: QueryAnchor,
        limit: Int? = nil,
        predicate filterPredicate: NSPredicate? = nil
    ) -> AsyncMapSequence<HKAnchoredObjectQueryDescriptor<Sample>.Results, ContinuousQueryElement<Sample>> {
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
    /// - parameter sourceFilter: Allows filtering based on the samples' `HKSource`.
    /// - parameter limit: The maximum number of samples the query will return.
    /// - parameter filterPredicate: Optional refining predicate that allows you to filter which samples should be fetched.
    @available(iOS, deprecated: 18.0)
    @available(macOS, deprecated: 15.0)
    @available(watchOS, deprecated: 11.0)
    @_disfavoredOverload
    public func continuousQuery<Sample>(
        _ sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        anchor: QueryAnchor,
        source sourceFilter: SourceFilter,
        limit: Int? = nil,
        predicate filterPredicate: NSPredicate? = nil
    ) async throws -> AsyncMapSequence<HKAnchoredObjectQueryDescriptor<Sample>.Results, ContinuousQueryElement<Sample>> {
        try await continuousQueryImp(sampleType, timeRange: timeRange, anchor: anchor, source: sourceFilter, limit: limit, predicate: filterPredicate)
    }
    
    
    private func continuousQueryImp<Sample>(
        _ sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        anchor: QueryAnchor,
        limit: Int?,
        predicate filterPredicate: NSPredicate?
    ) -> AsyncMapSequence<HKAnchoredObjectQueryDescriptor<Sample>.Results, ContinuousQueryElement<Sample>> {
        let descriptor = constructAnchoredQueryDescriptor(
            sampleType,
            timeRange: timeRange,
            anchor: anchor,
            limit: limit,
            predicate: filterPredicate
        )
        let results = descriptor.results(for: healthStore)
        return results.map { ContinuousQueryElement(update: $0) }
    }
    
    
    private func continuousQueryImp<Sample>( // swiftlint:disable:this function_parameter_count
        _ sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        anchor: QueryAnchor,
        source sourceFilter: SourceFilter,
        limit: Int?,
        predicate filterPredicate: NSPredicate?
    ) async throws -> AsyncMapSequence<HKAnchoredObjectQueryDescriptor<Sample>.Results, ContinuousQueryElement<Sample>> {
        let descriptor = try await constructAnchoredQueryDescriptor(
            sampleType,
            timeRange: timeRange,
            anchor: anchor,
            source: sourceFilter,
            limit: limit,
            predicate: filterPredicate
        )
        let results = descriptor.results(for: healthStore)
        return results.map { ContinuousQueryElement(update: $0) }
    }
}


extension HealthKit {
    /// Fetches the `startDate` of the oldest sample in the HealthKit database, for the specified sample type.
    public func oldestSampleDate(for sampleType: SampleType<some Any>) async throws -> Date? {
        try await query(
            sampleType,
            timeRange: .ever,
            limit: 1,
            sortedBy: [SortDescriptor(\.startDate, order: .forward)]
        ).first?.startDate
    }
}
