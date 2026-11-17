//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

import HealthKit
import Spezi
@testable import SpeziHealthKit
import SpeziTesting
import Testing


/// A standard whose storage fails for the first `numFailures` batches it receives.
private actor FlakyStorageStandard: Standard, HealthKitConstraint {
    struct StorageError: Error {}

    private var remainingFailures: Int
    private(set) var storedSampleIds: [UUID] = []
    private(set) var numFailedAttempts = 0

    init(numFailures: Int) {
        self.remainingFailures = numFailures
    }

    func handleNewSamples<Sample>(
        _ addedSamples: some Collection<Sample> & Sendable,
        ofType sampleType: SampleType<Sample>
    ) async throws {
        if remainingFailures > 0 {
            remainingFailures -= 1
            numFailedAttempts += 1
            throw StorageError()
        }
        storedSampleIds.append(contentsOf: addedSamples.map(\.uuid))
    }

    func handleDeletedObjects<Sample>(
        _ deletedObjects: some Collection<HKDeletedObject> & Sendable,
        ofType sampleType: SampleType<Sample>
    ) async throws {}
}


/// A standard that can be told to suspend the next batch it receives, until the test explicitly resumes it.
///
/// Used to simulate a batch whose handling takes a while, during which something else changes the persisted anchor.
private actor SuspendingStandard: Standard, HealthKitConstraint {
    private var suspendNextBatch = false
    private var suspendedBatch: CheckedContinuation<Void, Never>?
    private var suspensionWaiter: CheckedContinuation<Void, Never>?
    private(set) var handledBatches: [[UUID]] = []

    /// Makes the next call to `handleNewSamples` suspend until ``resumeSuspendedBatch()`` is called.
    func suspendNext() {
        suspendNextBatch = true
    }

    /// Waits until a batch is suspended in `handleNewSamples`.
    func waitForSuspendedBatch() async {
        guard suspendedBatch == nil else {
            return
        }
        await withCheckedContinuation { continuation in
            suspensionWaiter = continuation
        }
    }

    /// Lets the currently-suspended batch finish.
    func resumeSuspendedBatch() {
        suspendedBatch?.resume()
        suspendedBatch = nil
    }

    func handleNewSamples<Sample>(
        _ addedSamples: some Collection<Sample> & Sendable,
        ofType sampleType: SampleType<Sample>
    ) async throws {
        if suspendNextBatch {
            suspendNextBatch = false
            await withCheckedContinuation { continuation in
                suspendedBatch = continuation
                suspensionWaiter?.resume()
                suspensionWaiter = nil
            }
        }
        handledBatches.append(addedSamples.map(\.uuid))
    }

    func handleDeletedObjects<Sample>(
        _ deletedObjects: some Collection<HKDeletedObject> & Sendable,
        ofType sampleType: SampleType<Sample>
    ) async throws {}
}


@Suite("Anchor Advancement", .serialized)
@MainActor
struct AnchorAdvancementTests {
    private func makeSamples(count: Int) -> [HKQuantitySample] {
        (0..<count).map { idx in
            let date = Date(timeIntervalSince1970: 1_700_000_000 + Double(idx) * 60)
            return HKQuantitySample(
                type: SampleType.stepCount.hkSampleType,
                quantity: HKQuantity(unit: .count(), doubleValue: Double(idx + 1)),
                start: date,
                end: date.addingTimeInterval(30)
            )
        }
    }

    @Test("Anchor only advances once the standard successfully handled a batch")
    func anchorNotAdvancedOnHandlerFailure() async throws {
        let standard = FlakyStorageStandard(numFailures: 1)
        let healthKit = HealthKit()
        withDependencyResolution(standard: standard) {
            healthKit
        }
        let sampleType = SampleType.stepCount
        try healthKit.queryAnchors.store(nil, for: sampleType)
        defer {
            try? healthKit.queryAnchors.store(nil, for: sampleType)
        }
        let collector = HealthKitSampleCollector(
            source: .collectSamples,
            healthKit: healthKit,
            standard: standard,
            sampleType: sampleType,
            timeRange: .ever,
            predicate: nil,
            deliverySetting: .init(startSetting: .manual, continueInBackground: false)
        )
        let initialAnchor = try collector.persistedAnchor
        let newAnchor = QueryAnchor(HKQueryAnchor(fromValue: 42))
        let samples = makeSamples(count: 3)

        // first attempt: the standard fails to store the samples.
        await #expect(throws: FlakyStorageStandard.StorageError.self) {
            try await collector.processQueryResult(added: samples, deleted: [], previousAnchor: initialAnchor, newAnchor: newAnchor)
        }
        #expect(await standard.numFailedAttempts == 1)
        #expect(await standard.storedSampleIds.isEmpty)
        // the anchor must not have advanced, so that the samples get re-delivered.
        #expect(try collector.persistedAnchor == initialAnchor)
        #expect(try healthKit.queryAnchors.load(for: sampleType) == nil)

        // second attempt (re-delivery of the same batch): the standard succeeds.
        try await collector.processQueryResult(added: samples, deleted: [], previousAnchor: initialAnchor, newAnchor: newAnchor)
        #expect(await standard.storedSampleIds == samples.map(\.uuid))
        #expect(try collector.persistedAnchor == newAnchor)
        #expect(try healthKit.queryAnchors.load(for: sampleType) == newAnchor)
    }

    private func makeCollector(
        healthKit: HealthKit,
        standard: some HealthKitConstraint,
        sampleType: SampleType<HKQuantitySample>
    ) -> HealthKitSampleCollector<HKQuantitySample> {
        HealthKitSampleCollector(
            source: .collectSamples,
            healthKit: healthKit,
            standard: standard,
            sampleType: sampleType,
            timeRange: .ever,
            predicate: nil,
            deliverySetting: .init(startSetting: .manual, continueInBackground: false)
        )
    }

    @Test("A batch that finishes after the sample collection was reset does not restore its anchor")
    func staleBatchDoesNotUndoReset() async throws {
        let standard = SuspendingStandard()
        let healthKit = HealthKit()
        withDependencyResolution(standard: standard) {
            healthKit
        }
        let sampleType = SampleType.stepCount
        defer {
            try? healthKit.queryAnchors.store(nil, for: sampleType)
        }
        let startAnchor = QueryAnchor(HKQueryAnchor(fromValue: 10))
        let batchAnchor = QueryAnchor(HKQueryAnchor(fromValue: 20))
        try healthKit.queryAnchors.store(startAnchor, for: sampleType)
        let collector = makeCollector(healthKit: healthKit, standard: standard, sampleType: sampleType)
        let samples = makeSamples(count: 3)

        // a batch, queried from `startAnchor`, is being handled by the standard...
        await standard.suspendNext()
        let batch = Task { @MainActor in
            try await collector.processQueryResult(added: samples, deleted: [], previousAnchor: startAnchor, newAnchor: batchAnchor)
        }
        await standard.waitForSuspendedBatch()
        // ... when the app resets the sample collection.
        await healthKit.resetSampleCollection(for: sampleType)
        #expect(try healthKit.queryAnchors.load(for: sampleType) == nil)

        // the batch then finishes.
        await standard.resumeSuspendedBatch()
        #expect(try await batch.value == .superseded)
        #expect(await standard.handledBatches == [samples.map(\.uuid)])
        // the reset must survive: the next query has to start from scratch, not from the stale batch's anchor.
        #expect(try healthKit.queryAnchors.load(for: sampleType) == nil)
    }

    @Test("An older overlapping batch that finishes last does not move the anchor backwards")
    func overlappingBatchesDoNotMoveAnchorBackwards() async throws {
        let standard = SuspendingStandard()
        let healthKit = HealthKit()
        withDependencyResolution(standard: standard) {
            healthKit
        }
        let sampleType = SampleType.stepCount
        defer {
            try? healthKit.queryAnchors.store(nil, for: sampleType)
        }
        let startAnchor = QueryAnchor(HKQueryAnchor(fromValue: 10))
        let olderBatchAnchor = QueryAnchor(HKQueryAnchor(fromValue: 20))
        let newerBatchAnchor = QueryAnchor(HKQueryAnchor(fromValue: 30))
        try healthKit.queryAnchors.store(startAnchor, for: sampleType)
        let collector = makeCollector(healthKit: healthKit, standard: standard, sampleType: sampleType)
        let olderSamples = makeSamples(count: 2)
        let newerSamples = olderSamples + makeSamples(count: 1)

        // two overlapping queries (e.g., two background deliveries) both start from `startAnchor`.
        // the first one is still being handled...
        await standard.suspendNext()
        let olderBatch = Task { @MainActor in
            try await collector.processQueryResult(added: olderSamples, deleted: [], previousAnchor: startAnchor, newAnchor: olderBatchAnchor)
        }
        await standard.waitForSuspendedBatch()
        // ... when the second one completes and advances the anchor.
        let newerOutcome = try await collector.processQueryResult(
            added: newerSamples,
            deleted: [],
            previousAnchor: startAnchor,
            newAnchor: newerBatchAnchor
        )
        #expect(newerOutcome == .anchorAdvanced)
        #expect(try healthKit.queryAnchors.load(for: sampleType) == newerBatchAnchor)

        // the first one finishing afterwards must not move the anchor back.
        await standard.resumeSuspendedBatch()
        #expect(try await olderBatch.value == .superseded)
        #expect(await standard.handledBatches.count == 2)
        #expect(try healthKit.queryAnchors.load(for: sampleType) == newerBatchAnchor)
    }

    @Test("Retry backoff is exponential, bounded, and resettable")
    func retryBackoff() {
        var backoff = RetryBackoff(initialDelay: .seconds(5), maxDelay: .seconds(60))
        #expect((0..<6).map { _ in backoff.nextDelay() } == [5, 10, 20, 40, 60, 60].map { Duration.seconds($0) })
        for _ in 0..<100 {
            _ = backoff.nextDelay()
        }
        #expect(backoff.nextDelay() == .seconds(60))
        backoff.reset()
        #expect(backoff.nextDelay() == .seconds(5))
    }
}

#endif
