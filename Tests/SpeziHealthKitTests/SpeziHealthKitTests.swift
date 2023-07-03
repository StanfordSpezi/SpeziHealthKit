//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
@testable import SpeziHealthKit
import XCTest
import XCTSpezi

final class SpeziHealthKitTests: XCTestCase {
    static let collectedSamples: Set<HKSampleType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.distanceWalkingRunning)
    ]
    
    let healthKitComponent: HealthKit<TestAppStandard> = HealthKit {
            CollectSamples(
                collectedSamples,
                deliverySetting: .anchorQuery(.afterAuthorizationAndApplicationWillLaunch)
            )
        } adapter: {
            MockAdapterActor()
    }
    
    override func setUp() {
        super.setUp()
        healthKitComponent.healthStore = HKHealthStoreSpy()
    }
    
    /// No authorizations for HealthKit data are given in the ``UserDefaults``
    func testSpeziHealthKitCollectionNotAuthorized1() async {
        let authorization = await healthKitComponent.checkAuthorizations()
        XCTAssert(!authorization)
    }
    
    /// Not enough authorizations for HealthKit data given in the ``UserDefaults``
    func testSpeziHealthKitCollectionNotAuthorized2() async {
        (healthKitComponent.healthStore as? HKHealthStoreSpy)?.configuredTypesToRead = [HKQuantityType(.stepCount)]
        
        let authorization = await healthKitComponent.checkAuthorizations()
        XCTAssert(!authorization)
    }
    
    /// Authorization for HealthKit data are given in the ``UserDefaults``
    func testSpeziHealthKitCollectionAlreadyAuthorized() async {
        (healthKitComponent.healthStore as? HKHealthStoreSpy)?.configuredTypesToRead = [
            HKQuantityType(.stepCount),
            HKQuantityType(.distanceWalkingRunning)
        ]
        
        let authorization = await healthKitComponent.checkAuthorizations()
        XCTAssert(authorization)
    }
}
