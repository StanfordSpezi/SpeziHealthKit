//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import Spezi
@testable import SpeziHealthKit
import Testing
import SpeziTesting


private actor TestStandard: Standard, HealthKitConstraint {
    func handleNewSamples<Sample>(
        _ addedSamples: some Collection<Sample>,
        ofType sampleType: SampleType<Sample>
    ) async {}
    func handleDeletedObjects<Sample>(
        _ deletedObjects: some Collection<HKDeletedObject>,
        ofType sampleType: SampleType<Sample>
    ) async {}
}

extension SpeziHealthKitTests {
    @Test("Collect Samples Registration Deduplication")
    func collectSamplesRegistrationDeduplication() async throws {
        let healthKit = HealthKit {
            CollectSample(.stepCount, continueInBackground: false)
            CollectSample(.heartRate)
            CollectSample(.heartRate)
            CollectSample(.stepCount, continueInBackground: false)
            CollectSample(.stepCount, continueInBackground: true)
            CollectSample(.bloodGlucose, continueInBackground: false)
            CollectSample(.bloodGlucose, continueInBackground: true)
            CollectSample(.dietaryPotassium, continueInBackground: true)
            CollectSample(.dietaryPotassium, continueInBackground: false)
            CollectSample(.pushCount)
            CollectSample(.pushCount)
        }
        await withDependencyResolution(standard: TestStandard()) {
            healthKit
        }

        while healthKit.configurationState != .completed {
            try await Task.sleep(for: .seconds(1))
        }

        var erasedCollectors: [AnyObject] = healthKit.registeredDataCollectors

        #expect(healthKit.registeredDataCollectors.count == 5)
        #expect(
            Set(healthKit.registeredDataCollectors.map { $0.typeErasedSampleType.displayTitle }) ==
            [SampleType.heartRate, .stepCount, .bloodGlucose, .dietaryPotassium, .pushCount].mapIntoSet(\.displayTitle)
        )

        await healthKit.addHealthDataCollector(CollectSample(.bloodOxygen))
        #expect(healthKit.registeredDataCollectors.count == 6)

        erasedCollectors = healthKit.registeredDataCollectors
        await healthKit.addHealthDataCollector(CollectSample(.bloodOxygen))
        #expect(erasedCollectors.elementsEqual(healthKit.registeredDataCollectors, by: ===))
        #expect(healthKit.registeredDataCollectors.count == 6)

        await healthKit.addHealthDataCollector(CollectSample(.walkingStepLength, continueInBackground: true))
        #expect(healthKit.registeredDataCollectors.count == 7)
        erasedCollectors = healthKit.registeredDataCollectors
        await healthKit.addHealthDataCollector(CollectSample(.walkingStepLength, continueInBackground: true))
        // nothing should change, since the new collector is equal to an existing one.
        #expect(healthKit.registeredDataCollectors.count == 7)
        #expect(erasedCollectors.elementsEqual(healthKit.registeredDataCollectors, by: ===))
        await healthKit.addHealthDataCollector(CollectSample(.walkingStepLength, continueInBackground: false))
        // nothing should change, since the new (non-bg) collector will get subsumed into the existing (bg) one.
        #expect(healthKit.registeredDataCollectors.count == 7)
        #expect(erasedCollectors.elementsEqual(healthKit.registeredDataCollectors, by: ===))

        await healthKit.addHealthDataCollector(CollectSample(.height, continueInBackground: false))
        #expect(healthKit.registeredDataCollectors.count == 8)
        erasedCollectors = healthKit.registeredDataCollectors
        await healthKit.addHealthDataCollector(CollectSample(.height, continueInBackground: true))
        // we expect the second height collector to replace the first (background vs non-background),
        // so the #collectors will remain the same, but they won't compare equal anymore
        #expect(healthKit.registeredDataCollectors.count == 8)
        #expect(erasedCollectors.elementsEqual(healthKit.registeredDataCollectors, by: ===) == false)
    }
}
