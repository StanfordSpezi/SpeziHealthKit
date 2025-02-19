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
    @MainActor
    func testCollectSamplesRegistration() async throws {
        let healthKit = HealthKit {
            CollectSample(.heartRate)
            CollectSample(.heartRate)
            CollectSample(.stepCount, continueInBackground: false)
            CollectSample(.stepCount, continueInBackground: true)
            CollectSample(.bloodOxygen, continueInBackground: false)
            CollectSample(.bloodOxygen, continueInBackground: true)
            CollectSample(.height, continueInBackground: true)
            CollectSample(.height, continueInBackground: false)
        }
        withDependencyResolution(standard: TestStandard()) {
            healthKit
        }
        
        var erasedCollectors: [AnyObject] = healthKit.registeredDataCollectors
        
        try await Task.sleep(for: .seconds(1))
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 2)
        XCTAssertEqual(Set(healthKit.registeredDataCollectors.map { $0.typeErasedSampleType.displayTitle }), ["Heart Rate", "Step Count"])
        XCTAssertEqual(1, healthKit.registeredDataCollectors.count { $0.typeErasedSampleType == .heartRate })
        XCTAssertEqual(1, healthKit.registeredDataCollectors.count { $0.typeErasedSampleType == .stepCount })
        
        await healthKit.addHealthDataCollector(CollectSample(.bloodOxygen))
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 3)
        
        erasedCollectors = healthKit.registeredDataCollectors
        await healthKit.addHealthDataCollector(CollectSample(.bloodOxygen))
        XCTAssert(erasedCollectors.elementsEqual(healthKit.registeredDataCollectors, by: ===))
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 3)
        
        await healthKit.addHealthDataCollector(CollectSample(.walkingStepLength, continueInBackground: true))
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 4)
        erasedCollectors = healthKit.registeredDataCollectors
        await healthKit.addHealthDataCollector(CollectSample(.walkingStepLength, continueInBackground: true))
        // nothing should change, since the new collector is equal to an existing one.
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 4)
        XCTAssert(erasedCollectors.elementsEqual(healthKit.registeredDataCollectors, by: ===))
        await healthKit.addHealthDataCollector(CollectSample(.walkingStepLength, continueInBackground: false))
        // nothing should change, since the new (non-bg) collector will get subsumed into the existing (bg) one.
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 4)
        XCTAssert(erasedCollectors.elementsEqual(healthKit.registeredDataCollectors, by: ===))
        
        await healthKit.addHealthDataCollector(CollectSample(.height, continueInBackground: false))
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 5)
        erasedCollectors = healthKit.registeredDataCollectors
        await healthKit.addHealthDataCollector(CollectSample(.height, continueInBackground: true))
        // we expect the second height collector to replace the first (background vs non-background),
        // so the #collectors will remain the same, but they won't compare equal anymore
        XCTAssertEqual(healthKit.registeredDataCollectors.count, 5)
        XCTAssertFalse(erasedCollectors.elementsEqual(healthKit.registeredDataCollectors, by: ===))
    }
}
