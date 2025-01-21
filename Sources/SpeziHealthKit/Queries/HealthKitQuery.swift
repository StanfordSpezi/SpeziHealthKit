//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI
import HealthKit
import SpeziFoundation
import Spezi


/// The time range for which data should be fetched from the health store.
public enum HealthKitQueryTimeRange: Hashable, Sendable {
    /// The time range containing the last hour.
    case hour
    /// The time range containing all of today.
    case today
    /// The time range encompassing the last 7 days, including today.
    case week
    /// The time range encompassing the last 31 days, including today.
    case month
    /// The time range encompassing the last 365 days, including today.
    case year
    /// The time range encompassing the entire current week.
    case currentWeek // TODO remove this?
    /// The time range encompassing the entire current month.
    case currentMonth // TODO remove this?
    /// The time range encompassing the entire current year.
    case currentYear // TODO remove this?
    /// The time range encompassing the last `N` hours, starting at the end of the current hour.
    case lastNHours(Int)
    /// The time range encompassing the last `N` days, starting at the end of the current day.
    /// - Note: the resulting effective time range of `lastNDays(1)` is equivalent to the one of `today`.
    case lastNDays(Int)
    /// The time range encompassing the last `N` weeks, starting at the end of the current day.
    case lastNWeeks(Int)
    /// The time range encompassing the last `N` months, starting at the end of the current day.
    case lastNMonths(Int)
    /// The time range encompassing the last `N` years, starting at the end of the current day.
    case lastNYears(Int)
    /// A time range over the specified closed range.
    case custom(ClosedRange<Date>)
}


/// Query the HealthKit database within SwiftUI views.
///
/// Queries are performed in the context of the ``HealthKit-swift.class`` module, which must be enabled via an app's `SpeziAppDelegate`.
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
public struct HealthKitQuery<Sample: _HKSampleWithSampleType>: DynamicProperty {
    private let input: SamplesQueryResults<Sample>.Input
    
    @Environment(HealthKit.self)
    private var healthKit
    
    @State
    private var results: SamplesQueryResults<Sample> = .uninitializedForSwiftUIStateObject()
    
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
    
    
    /// The individual query results.
    /// TODO fix this causing crashes in release builds! (see https://github.com/swiftlang/swift/issues/78405)
    public var wrappedValue: some RandomAccessCollection<Sample> {
        // Note that we're intentionally not returning `results` directly here (even though it also is a RandomAccessCollection),
        // the reason being that it would be auto-updating, which might be unexpected since it's not communicated via the return
        // type. Instead, we return `results.dataPoints`, i.e. essentially a snapshot of the current state of the results object.
        results.samples
    }
    
    /// The query's underlying auto-updating results object.
    /// This can be used e.g. to provide data to a ``HealthChart``.
    public var projectedValue: SamplesQueryResults<Sample> { // TODO why not `some HealthKitQueryResults<...>`?
        results
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
    
    /// Since the ``SamplesQueryResults`` type can be used both within SwiftUI-managed contexts (i.e., Views) and outside of SwiftUI (i.e., in "normal" code),
    /// we need to [...TODO TODO TODO]
    private enum Variant {
        /// The ``SamplesQueryResults`` object is used as a State Object in a SwiftUI-managed property wrapper (i.e., on a View).
        /// In this case, we allow deferred initialization of the object, since we need the ability to create the State Object without having access to the Environment.
        case swiftUI(HKHealthStore?)
        /// The ``SamplesQueryResults`` object is used in a standalone context, i.e. outside of SwiftUI.
        /// In this case, we require that all properties be fully defined when the object is instantiated.
        case standalone(HKHealthStore)
    }
    
    @ObservationIgnored
    private var variant: Variant {
        didSet {
            switch (oldValue, variant) {
            case (.swiftUI, .swiftUI), (.standalone, .standalone):
                // Fine: we simply updated the values but stayed within the variant
                break
            case (.swiftUI, .standalone), (.standalone, .swiftUI):
                // Based on the current implementation, this never happens, but we add the check to ensure that it stays this way.
                fatalError("Invalid variant transition: cannot transition from .swiftUI variant to .standalone, or vice versa.")
            }
        }
    }
    
    private var healthStore: HKHealthStore {
        switch variant {
        case .swiftUI(.some(let healthStore)), .standalone(let healthStore):
            return healthStore
        case .swiftUI(.none):
            fatalError("Accessed '\(#function)' of a SwiftUI-managed \(Self.self) outside of being installed on a View.")
        }
    }
    
    @ObservationIgnored
    private var input: Input?
    
    
    private(set) public var queryError: (any Error)?
    
    @ObservationIgnored
    private var queryTask: Task<Void, Never>?
    
    
    private init(variant: Variant) {
        self.variant = variant
    }
    
    /// Creates and returns a new, uninitialized ``SamplesQueryResults``, with its variant set to being used as a SwiftUI-managed State Object.
    fileprivate static func uninitializedForSwiftUIStateObject() -> Self {
        Self.init(variant: .swiftUI(nil))
    }
    
    /// Creates a new standalone (i.e., non-SwiftUI-managed) ``SamplesQueryResults`` object.
    /// - Note: This initializer will perform an initial fetch of the queried-for samples, and return only once that fetch has completed.
    ///     It will **not** initiate the auto-updating of the query results; you can start this via the ``startObservingChanges`` function.
    init(healthStore: HKHealthStore, input: Input) async {
        self.variant = .standalone(healthStore)
        self.input = input
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            self.startQuery {
                continuation.resume()
            }
        }
    }
    
    /// Creates a new standalone (i.e., non-SwiftUI-managed) ``SamplesQueryResults`` object.
    /// - Note: This initializer will perform an initial fetch of the queried-for samples, and return only once that fetch has completed.
    ///     It will **not** initiate the auto-updating of the query results; you can start this via the ``startObservingChanges`` function.
    public convenience init(
        healthStore: HKHealthStore,
        sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        filter predicate: NSPredicate? = nil
    ) async {
        await self.init(
            healthStore: healthStore,
            input: .init(
                sampleType: sampleType,
                timeRange: timeRange,
                filterPredicate: predicate
            )
        )
    }
    
    
    fileprivate private(set) var samples = OrderedArray<Sample> { lhs, rhs in
        if lhs.startDate < rhs.startDate {
            return true
        } else if lhs.startDate > rhs.startDate {
            return false
        } else {
            return lhs.uuid < rhs.uuid
        }
    }
    
    
    deinit {
        queryTask?.cancel()
        queryTask = nil
    }
    
    fileprivate func initializeSwiftUIManagedQuery(healthStore: HKHealthStore, input: Input) {
        self.variant = .swiftUI(healthStore)
        guard self.input != input else {
            return
        }
        self.input = input
        startQuery()
    }
    
    
    /// Starts the auto-updating query.
    /// - Note: it might take a bit until the first results arrive and the query gets populated.
    private func startQuery(initialFetchCompletionHandler: @escaping @Sendable () -> Void = {}) {
        guard let input else {
            return
        }
        
//        Task {
//            let initialFetch = HKSampleQueryDescriptor(
//                predicates: [HKSamplePredicate<Sample>.sample(
//                    type: input.sampleType.hkSampleType,
//                    predicate: { () -> NSPredicate? in
//                        let preds = [
//                            input.timeRange.queryPredicate,
//                            input.filterPredicate
//                        ].compactMap({ $0 })
//                        return preds.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: preds)
//                    }()
//                )],
//                sortDescriptors: [SortDescriptor<HKSample>.init(\.startDate)],
//                limit: nil // input.limit
//            )
//            let startTS = CACurrentMediaTime()
//            let results = try await initialFetch.result(for: self.healthStore)
//            let endTS = CACurrentMediaTime()
//            print("[\(sampleType.displayTitle)] initial fetch (#=\(results.count)) took \(endTS - startTS)")
//        }
        
        let query = HKAnchoredObjectQueryDescriptor(
            predicates: [HKSamplePredicate<Sample>.sample(
                type: input.sampleType.hkSampleType,
                predicate: { () -> NSPredicate? in
                    let preds = [
                        input.timeRange.queryPredicate,
                        input.filterPredicate
                    ].compactMap({ $0 })
                    return preds.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: preds)
                }()
            )],
            // we intentionally specify a nil anchor; this way the query will first fetch all existing data matching the descriptor,
            // and then start emit update events for new/deleted data.
            anchor: nil,
            limit: nil
        )
        
        let healthStore = self.healthStore
        
        queryTask?.cancel()
        queryTask = Task.detached { [weak self] in
            do {
                var isFirstUpdate = true
                let startTS = CACurrentMediaTime()
                let updates = query.results(for: healthStore)
                for try await update in updates {
                    guard let self = self else { break }
                    print("[\(self.sampleType.displayTitle)] got an update (#new: \(update.addedSamples.count), #del: \(update.deletedObjects.count))")
                    if isFirstUpdate {
                        let endTS = CACurrentMediaTime()
                        print("[\(self.sampleType.displayTitle)] initial update took: \(endTS - startTS)")
                    }
                    defer {
                        isFirstUpdate = false
                    }
                    // SAFETY: this is in fact safe, since all of the update's (i.e., the `HKAnchoredObjectQueryDescriptor<Sample>.Result` type's)
                    // properties (i.e., deletedObjects, addedSamples, and newAnchor) are themselves Sendable.
                    nonisolated(unsafe) let update = update
                    let isFirstUpdate = isFirstUpdate
                    Task { @MainActor in
                        var samples = self.samples
                        nonisolated(unsafe) let update = update
                        let deletedUUIDs = update.deletedObjects.mapIntoSet { $0.uuid }
                        samples.removeAll(where: { deletedUUIDs.contains($0.uuid) })
                        samples.insert(contentsOf: update.addedSamples as! [Sample])
                        precondition(samples.mapIntoSet(\.uuid).count == samples.count)
                        self.samples = samples
                        if isFirstUpdate {
                            initialFetchCompletionHandler()
                        }
                    }
                }
            } catch {
                guard let self else { return }
                Task { @MainActor in
                    // TODO QUESTION: under which circumstances do we want to set self.samples to an empty array?
                    self.queryError = error
                }
            }
        }
    }
}


extension SamplesQueryResults: HealthKitQueryResults {
    public typealias Index = OrderedArray<Sample>.Index
    public typealias Element = Sample
    
    public subscript(position: Index) -> Element {
        samples[position]
    }
    
    public var count: Int {
        samples.count
    }
    
    public var startIndex: Index {
        samples.startIndex
    }
    
    public var endIndex: Index {
        samples.endIndex
    }
    
    
    public var timeRange: HealthKitQueryTimeRange {
        input!.timeRange
    }
    
    public var sampleType: SampleType<Sample> {
        input!.sampleType
    }
}




extension HealthKitQueryTimeRange {
    public var range: ClosedRange<Date> {
        let now = Date()
        let cal = Calendar.current
        let range: Range<Date>
        switch self {
        case .hour:
            // TODO should "last hour" mean the whole current hour (current behaviour), or should it mean "60 minutes ago until right now"?
            range = cal.rangeOfHour(for: now)
        case .today:
            range = cal.rangeOfDay(for: now)
        case .week:
            let end = cal.startOfNextDay(for: now)
            let start = cal.date(byAdding: .weekOfYear, value: -1, to: end)!
            return start...end
        case .month:
            let end = cal.startOfNextDay(for: now)
            let start = cal.date(byAdding: .month, value: -1, to: end)!
            return start...end
        case .year:
            let end = cal.startOfNextDay(for: now)
            let start = cal.date(byAdding: .year, value: -1, to: end)!
            return start...end
        case .currentWeek:
            range = cal.rangeOfWeek(for: now)
        case .currentMonth:
            range = cal.rangeOfMonth(for: now)
        case .currentYear:
            range = cal.rangeOfYear(for: now)
        case .lastNHours(let numHours):
            let end = cal.startOfNextHour(for: now)
            let start = cal.date(byAdding: .hour, value: -numHours, to: end)!
            return start...end
        case .lastNDays(let numDays):
            let end = cal.startOfNextDay(for: now)
            let start = cal.date(byAdding: .day, value: -numDays, to: end)!
            return start...end
        case .lastNWeeks(let numWeeks):
            let end = cal.startOfNextDay(for: now)
            let start = cal.date(byAdding: .weekOfYear, value: -numWeeks, to: end)!
            return start...end
        case .lastNMonths(let numMonths):
            let end = cal.startOfNextDay(for: now)
            let start = cal.date(byAdding: .month, value: -numMonths, to: end)!
            return start...end
        case .lastNYears(let numYears):
            let end = cal.startOfNextDay(for: now)
            let start = cal.date(byAdding: .year, value: -numYears, to: end)!
            return start...end
        case .custom(let range):
            return range
        }
        return range.lowerBound...range.upperBound.advanced(by: -1)
    }
    
    
    var queryPredicate: NSPredicate {
        let range = self.range
        return HKQuery.predicateForSamples(
            withStart: range.lowerBound,
            end: range.upperBound,
            options: [.strictStartDate, .strictEndDate]
        )
    }
}



// TODO remove these before opening a PR!

// @inline(__always)???
func measure<T>(_ name: String, _ block: () throws -> T) rethrows -> T {
    let startTime = CACurrentMediaTime()
    let retval: T = try block()
    let endTime = CACurrentMediaTime()
    print("[MEASURE] \(name): \(String(endTime - startTime)) sec")
    return retval
}



// @inline(__always)???
func measure<T>(_ name: String, _ block: () async throws -> T) async rethrows -> T {
    let startTime = CACurrentMediaTime()
    let retval: T = try await block()
    let endTime = CACurrentMediaTime()
    print("[MEASURE] \(name): \(String(endTime - startTime)) sec")
    return retval
}

