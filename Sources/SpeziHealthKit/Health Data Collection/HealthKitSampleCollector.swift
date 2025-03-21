//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import HealthKit
import OSLog
import Spezi
import SwiftUI


final class HealthKitSampleCollector<Sample: _HKSampleWithSampleType>: HealthDataCollector {
    private enum QueryVariant {
        case anchorQuery(Task<Void, any Error>)
        case backgroundDelivery(HKHealthStore.BackgroundObserverQueryInvalidator)
    }
    
    // This needs to be unowned since the HealthKit module will establish a strong reference to the data source.
    private unowned let healthKit: HealthKit
    private let standard: any HealthKitConstraint
    
    let sampleType: SampleType<Sample>
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
        healthKit: HealthKit,
        standard: any HealthKitConstraint,
        sampleType: SampleType<Sample>,
        predicate: NSPredicate? = nil, // swiftlint:disable:this function_default_parameter_at_end
        deliverySetting: HealthDataCollectorDeliverySetting
    ) {
        self.healthKit = healthKit
        self.standard = standard
        self.sampleType = sampleType
        self.deliverySetting = deliverySetting

        if let predicate {
            self.predicate = predicate
        } else {
            self.predicate = HKQuery.predicateForSamples(
                withStart: Self.loadDefaultQueryDate(for: sampleType, in: healthKit),
                end: nil,
                options: .strictEndDate
            )
        }
    }
    
    
    private static func loadDefaultQueryDate(for sampleType: SampleType<Sample>, in healthKit: HealthKit) -> Date {
        if let date = healthKit.sampleCollectorPredicateStartDates[sampleType] {
            return date
        } else {
            // We start date collection at the previous full minute mark to make the
            // data collection deterministic to manually entered data in HealthKit.
            let cal = Calendar.current
            var components = cal.dateComponents(in: .current, from: .now)
            components.setValue(0, for: .second)
            components.setValue(0, for: .nanosecond)
            let defaultQueryDate = cal.date(from: components) ?? .now
            healthKit.sampleCollectorPredicateStartDates[sampleType] = defaultQueryDate
            return defaultQueryDate
        }
    }
    

    @MainActor
    func startDataCollection() async {
        guard !isActive else {
            return
        }
        do {
            if deliverySetting.continueInBackground {
                // set up a background query
                let queryInvalidator = try await healthStore.startBackgroundDelivery(for: [sampleType.hkSampleType]) { result in
                    guard self.isActive else {
                        // if the sample collector has been turned off, we don't want to process these.
                        return
                    }
                    switch result {
                    case .failure(let error):
                        self.healthKit.logger.error("Error in background delivery: \(error)")
                    case let .success((sampleTypes, completionHandler)):
                        defer {
                            // Inform to HealthKit that the data has been processed:
                            // https://developer.apple.com/documentation/healthkit/hkobserverquerycompletionhandler
                            completionHandler()
                        }
                        guard !sampleTypes.isEmpty else {
                            return
                        }
                        guard sampleTypes.contains(self.sampleType.hkSampleType) else {
                            self.healthKit.logger.warning("Received Observation query types (\(sampleTypes)) are not corresponding to the CollectSample type \(self.sampleType.hkSampleType)")
                            return
                        }
                        do {
                            try await self.anchoredSingleObjectQuery()
                            self.healthKit.logger.debug("Successfully processed background update for \(self.sampleType.hkSampleType)")
                        } catch {
                            self.healthKit.logger.error("Could not query samples in a background update for \(self.sampleType.hkSampleType): \(error)")
                        }
                    }
                }
                isActive = true
                queryVariant = .backgroundDelivery(queryInvalidator)
            } else {
                // set up a non-background query
                healthKit.logger.notice("Starting anchor query")
                try await anchoredContinuousObjectQuery()
                isActive = true
            }
        } catch {
            healthKit.logger.error("Could not Process HealthKit data collection: \(error.localizedDescription)")
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
            timeRange: .ever,
            anchor: &anchor,
            predicate: predicate
        )
        await handleQueryResult(added: added, deleted: deleted)
        self.anchor = anchor
    }

    
    @MainActor
    private func anchoredContinuousObjectQuery() async throws {
        let queryDescriptor = HKAnchoredObjectQueryDescriptor(
            predicates: [sampleType._makeSamplePredicate(filter: predicate)],
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
