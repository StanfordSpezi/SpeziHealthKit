//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

import HealthKit
import OSLog
import Spezi
import SwiftUI


/// Exponential backoff used when restarting a failed sample collection query.
struct RetryBackoff {
    let initialDelay: Duration
    let maxDelay: Duration
    private var numAttempts = 0
    
    init(initialDelay: Duration = .seconds(5), maxDelay: Duration = .seconds(5 * 60)) {
        self.initialDelay = initialDelay
        self.maxDelay = maxDelay
    }
    
    /// Returns the delay to wait before the next attempt, and increments the attempt counter.
    mutating func nextDelay() -> Duration {
        defer {
            numAttempts += 1
        }
        // cap the exponent to avoid overflowing; the result is clamped to `maxDelay` anyway.
        return min(initialDelay * (1 << min(numAttempts, 16)), maxDelay)
    }
    
    /// Resets the backoff, e.g. after a successful attempt.
    mutating func reset() {
        numAttempts = 0
    }
}


final class HealthKitSampleCollector<Sample: _HKSampleWithSampleType>: HealthDataCollector {
    /// How this ``HealthKitSampleCollector`` was created, i.e. what it was created for.
    ///
    /// The reason why this type exists is that in the case of the ``CollectSamples`` API specifically,
    /// we want to offer the ability to reset the underlying anchor and start date, which requires us to have the ability to stop a collector.
    /// Should SpeziHealthKit, at some point in the future, start registering additional sample collectors, we'd end up accidentally disabling those as well
    /// when we really just want to disable the ``CollectSamples``-associated ones.
    enum Source {
        /// This instance of the ``HealthKitSampleCollector`` was created by a ``CollectSamples`` instance.
        case collectSamples
    }
    
    private enum QueryVariant {
        case anchorQuery(Task<Void, Never>)
        case backgroundDelivery(HKHealthStore.BackgroundObserverQueryInvalidator)
    }
    
    let source: Source
    // This needs to be unowned since the HealthKit module will establish a strong reference to the data source.
    private unowned let healthKit: HealthKit
    private let standard: any HealthKitConstraint
    
    let sampleType: SampleType<Sample>
    private let timeRange: HealthKitQueryTimeRange
    private let predicate: NSPredicate?
    let deliverySetting: HealthDataCollectorDeliverySetting
    @MainActor private(set) var isActive = false
    private var queryVariant: QueryVariant?
    
    /// The last successfully-processed query anchor, as persisted in the ``HealthKit-swift.class`` module's anchor storage.
    ///
    /// - throws: if the anchor exists but could not be read. We intentionally don't fall back to an empty anchor in this case.
    @MainActor var persistedAnchor: QueryAnchor {
        get throws {
            try healthKit.queryAnchors.load(for: sampleType) ?? QueryAnchor()
        }
    }
    
    private var healthStore: HKHealthStore { healthKit.healthStore }
    

    required init(
        source: Source,
        healthKit: HealthKit,
        standard: any HealthKitConstraint,
        sampleType: SampleType<Sample>,
        timeRange: HealthKitQueryTimeRange,
        predicate: NSPredicate?,
        deliverySetting: HealthDataCollectorDeliverySetting
    ) {
        self.source = source
        self.healthKit = healthKit
        self.standard = standard
        self.sampleType = sampleType
        self.deliverySetting = deliverySetting
        self.timeRange = timeRange.adjustedToWholeMinute()
        self.predicate = predicate
    }
    

    @MainActor
    func startDataCollection() async {
        guard !isActive else {
            return
        }
        let logger = healthKit.logger
        do {
            if deliverySetting.continueInBackground {
                // set up a background query
                let queryInvalidator = try await healthStore.startBackgroundDelivery(for: [sampleType.hkSampleType]) { [weak self] result in
                    guard let self, self.isActive else {
                        // if the sample collector has been turned off, we don't want to process these.
                        return
                    }
                    switch result {
                    case .failure(let error):
                        logger.error("Error in background delivery: \(error)")
                    case let .success((sampleTypes, completionHandler)):
                        defer {
                            // Inform to HealthKit that the data has been processed:
                            // https://developer.apple.com/documentation/healthkit/hkobserverquerycompletionhandler
                            completionHandler()
                        }
                        guard !sampleTypes.isEmpty else {
                            return
                        }
                        let expectedSampleTypes = self.sampleType.effectiveSampleTypesForAuthentication.compactMapIntoSet { $0.hkSampleType }
                        guard !sampleTypes.isDisjoint(with: expectedSampleTypes) else {
                            logger.warning("Received Observation query types (\(sampleTypes)) are not corresponding to the CollectSamples type \(self.sampleType.hkSampleType)")
                            return
                        }
                        do {
                            try await self.anchoredSingleObjectQuery()
                        } catch {
                            logger.error("Could not query samples in a background update for \(self.sampleType.hkSampleType): \(error)")
                        }
                    }
                }
                isActive = true
                queryVariant = .backgroundDelivery(queryInvalidator)
            } else {
                // set up a non-background query
                isActive = true
                startAnchoredContinuousObjectQuery()
            }
        } catch {
            logger.error("Could not Process HealthKit data collection: \(error.localizedDescription)")
        }
    }
    
    
    @MainActor
    func stopDataCollection() async {
        guard isActive else {
            return
        }
        isActive = false
        switch exchange(&queryVariant, with: nil) {
        case nil:
            break
        case .anchorQuery(let task):
            task.cancel()
        case .backgroundDelivery(let invalidator):
            invalidator.invalidate()
            healthStore.disableBackgroundDelivery(for: [sampleType.hkSampleType])
        }
    }


    /// Fetches all changes since the last persisted anchor, and hands them to the standard.
    ///
    /// If the standard fails to handle the changes, the anchor is not advanced and this function throws;
    /// the changes will be delivered again the next time this function is called.
    @MainActor
    private func anchoredSingleObjectQuery() async throws {
        var anchor = try persistedAnchor
        nonisolated(unsafe) let predicate = self.predicate
        let (added, deleted) = try await healthKit.query(
            sampleType,
            timeRange: timeRange,
            anchor: &anchor,
            predicate: predicate
        )
        try await processQueryResult(added: added, deleted: deleted, newAnchor: anchor)
    }

    
    /// Starts a long-running anchored object query, which delivers all changes since the last persisted anchor, and then continues to deliver new changes.
    ///
    /// The results stream of a long-running anchored object query cannot re-deliver a batch.
    /// Therefore, if processing a batch fails, we stop the query and, after a backoff delay,
    /// start a new one from the last successfully persisted anchor, which re-delivers the failed batch.
    /// Stopping the data collection cancels the task, including any pending restart.
    @MainActor
    private func startAnchoredContinuousObjectQuery() {
        let logger = healthKit.logger
        let task = Task { @MainActor in
            var backoff = RetryBackoff()
            while isActive && !Task.isCancelled {
                do {
                    try await runAnchoredContinuousObjectQuery {
                        backoff.reset()
                    }
                    return
                } catch {
                    guard isActive && !Task.isCancelled else {
                        return
                    }
                    let delay = backoff.nextDelay()
                    logger.error(
                        "Failed to process HealthKit samples for \(self.sampleType.hkSampleType). Restarting from last persisted anchor in \(delay). Error: \(error)"
                    )
                    do {
                        try await Task.sleep(for: delay)
                    } catch {
                        return
                    }
                }
            }
        }
        queryVariant = .anchorQuery(task)
    }
    
    
    @MainActor
    private func runAnchoredContinuousObjectQuery(onBatchProcessed: () -> Void) async throws {
        let samplePredicate = sampleType._makeSamplePredicate(
            filter: NSCompoundPredicate(andPredicateWithSubpredicates: [timeRange.predicate, predicate].compactMap(\.self))
        )
        let queryDescriptor = HKAnchoredObjectQueryDescriptor(
            predicates: [samplePredicate],
            anchor: try persistedAnchor.hkAnchor
        )
        for try await update in queryDescriptor.results(for: healthStore) {
            guard isActive && !Task.isCancelled else {
                return
            }
            try await processQueryResult(
                added: update.addedSamples,
                deleted: update.deletedObjects,
                newAnchor: QueryAnchor(update.newAnchor)
            )
            onBatchProcessed()
        }
    }
    
    
    /// Hands a batch of query results to the standard, and advances the persisted anchor to `newAnchor` only if the standard successfully handled the batch.
    ///
    /// - throws: if either of the standard's handlers throws, or if the new anchor could not be persisted.
    ///     In both cases, the persisted anchor is left unchanged (or, if persisting failed, may not reflect `newAnchor`),
    ///     meaning that the batch will be delivered again by the next query.
    @MainActor
    func processQueryResult(
        added: some Collection<Sample> & Sendable,
        deleted: some Collection<HKDeletedObject> & Sendable,
        newAnchor: QueryAnchor
    ) async throws {
        if !deleted.isEmpty {
            try await standard.handleDeletedObjects(deleted, ofType: sampleType)
        }
        if !added.isEmpty {
            try await standard.handleNewSamples(added, ofType: sampleType)
        }
        try healthKit.queryAnchors.store(newAnchor, for: sampleType)
    }
}


extension HealthKitQueryTimeRange {
    /// Returns a new ``HealthKitQueryTimeRange``, with all components from the second down set to 0, and the minute rounded away from the current date.
    ///
    /// The purpose here is that we want to start the data collection at the previous full minute mark,
    /// to make it deterministic to manually entered data in HealthKit.
    func adjustedToWholeMinute() -> Self {
        let cal = Calendar.current
        func imp(_ date: Date) -> Date {
            var components = cal.dateComponents(in: .current, from: date)
            components.second = 0
            components.nanosecond = 0
            if date > .now {
                components.minute = (components.minute ?? 0) + 1
            }
            if let date = cal.date(from: components) {
                return date
            } else {
                preconditionFailure("Unable to compute date")
            }
        }
        return Self(imp(range.lowerBound)...imp(range.upperBound))
    }
}

#endif
