//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import OSLog
import Spezi
import SwiftUI


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
        case anchorQuery(Task<Void, any Error>)
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
    
    @MainActor private var anchor: QueryAnchor {
        get { healthKit.queryAnchors[sampleType] ?? QueryAnchor() }
        set { healthKit.queryAnchors[sampleType] = newValue }
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
                try await anchoredContinuousObjectQuery()
                isActive = true
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


    @MainActor
    private func anchoredSingleObjectQuery() async throws {
        var anchor = self.anchor
        nonisolated(unsafe) let predicate = self.predicate
        let (added, deleted) = try await healthKit.query(
            sampleType,
            timeRange: timeRange,
            anchor: &anchor,
            predicate: predicate
        )
        await handleQueryResult(added: added, deleted: deleted)
        self.anchor = anchor
    }

    
    @MainActor
    private func anchoredContinuousObjectQuery() async throws {
        let samplePredicate = sampleType._makeSamplePredicate(
            filter: NSCompoundPredicate(andPredicateWithSubpredicates: [timeRange.predicate, predicate].compactMap(\.self))
        )
        let queryDescriptor = HKAnchoredObjectQueryDescriptor(
            predicates: [samplePredicate],
            anchor: anchor.hkAnchor
        )
        let updateQueue = queryDescriptor.results(for: healthStore)
        let task = Task {
            for try await update in updateQueue {
                guard isActive else {
                    return
                }
                await handleQueryResult(added: update.addedSamples, deleted: update.deletedObjects)
                self.anchor = QueryAnchor(update.newAnchor)
            }
        }
        queryVariant = .anchorQuery(task)
    }
    
    
    @MainActor
    private func handleQueryResult(added: some Collection<Sample> & Sendable, deleted: some Collection<HKDeletedObject> & Sendable) async {
        if !deleted.isEmpty {
            await standard.handleDeletedObjects(deleted, ofType: sampleType)
        }
        if !added.isEmpty {
            await standard.handleNewSamples(added, ofType: sampleType)
        }
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
