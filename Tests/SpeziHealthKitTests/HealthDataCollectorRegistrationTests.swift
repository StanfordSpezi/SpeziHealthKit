//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import Spezi
@testable import SpeziHealthKit
import XCTest
import XCTSpezi


private actor TestStandard: Standard, HealthKitConstraint {
    func add(sample: HKSample) async {}
    func remove(sample: HKDeletedObject) async {}
}


final class HealthDataCollectorRegistrationTests: XCTestCase {
    func testCollectSamplesRegistration() async throws {
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
        
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 5)
        XCTAssertEqual(Set(healthKit.registeredDataCollectors.map { $0.typeErasedSampleType.displayTitle }), [SampleType.heartRate, .stepCount, .bloodGlucose, .dietaryPotassium, .pushCount].mapIntoSet(\.displayTitle))
        
        await healthKit.addHealthDataCollector(CollectSample(.bloodOxygen))
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 6)
        
        erasedCollectors = healthKit.registeredDataCollectors
        await healthKit.addHealthDataCollector(CollectSample(.bloodOxygen))
        XCTAssert(erasedCollectors.elementsEqual(healthKit.registeredDataCollectors, by: ===))
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 6)
        
        await healthKit.addHealthDataCollector(CollectSample(.walkingStepLength, continueInBackground: true))
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 7)
        erasedCollectors = healthKit.registeredDataCollectors
        await healthKit.addHealthDataCollector(CollectSample(.walkingStepLength, continueInBackground: true))
        // nothing should change, since the new collector is equal to an existing one.
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 7)
        XCTAssert(erasedCollectors.elementsEqual(healthKit.registeredDataCollectors, by: ===))
        await healthKit.addHealthDataCollector(CollectSample(.walkingStepLength, continueInBackground: false))
        // nothing should change, since the new (non-bg) collector will get subsumed into the existing (bg) one.
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 7)
        XCTAssert(erasedCollectors.elementsEqual(healthKit.registeredDataCollectors, by: ===))
        
        await healthKit.addHealthDataCollector(CollectSample(.height, continueInBackground: false))
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 8)
        erasedCollectors = healthKit.registeredDataCollectors
        await healthKit.addHealthDataCollector(CollectSample(.height, continueInBackground: true))
        // we expect the second height collector to replace the first (background vs non-background),
        // so the #collectors will remain the same, but they won't compare equal anymore
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 8)
        XCTAssertFalse(erasedCollectors.elementsEqual(healthKit.registeredDataCollectors, by: ===))
    }
}
