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
            try await collector.processQueryResult(added: samples, deleted: [], newAnchor: newAnchor)
        }
        #expect(await standard.numFailedAttempts == 1)
        #expect(await standard.storedSampleIds.isEmpty)
        // the anchor must not have advanced, so that the samples get re-delivered.
        #expect(try collector.persistedAnchor == initialAnchor)
        #expect(try healthKit.queryAnchors.load(for: sampleType) == nil)

        // second attempt (re-delivery of the same batch): the standard succeeds.
        try await collector.processQueryResult(added: samples, deleted: [], newAnchor: newAnchor)
        #expect(await standard.storedSampleIds == samples.map(\.uuid))
        #expect(try collector.persistedAnchor == newAnchor)
        #expect(try healthKit.queryAnchors.load(for: sampleType) == newAnchor)
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
