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
    
    override func tearDown() {
        // Clean up UserDefaults
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.healthKitRequestedSampleTypes)
    }
    
    /// No authorizations for HealthKit data are given in the ``UserDefaults``
    func testSpeziHealthKitCollectionNotAuthorized1() {
        XCTAssert(!healthKitComponent.authorized)
    }
    
    /// Not enough authorizations for HealthKit data given in the ``UserDefaults``
    func testSpeziHealthKitCollectionNotAuthorized2() {
        // Set up UserDefaults
        UserDefaults.standard.set(
            Array(Self.collectedSamples.map { $0.identifier }.dropLast()),  // Drop one of the required authorizations
            forKey: UserDefaults.Keys.healthKitRequestedSampleTypes
        )
        
        XCTAssert(!healthKitComponent.authorized)
    }
    
    /// Authorization for HealthKit data are given in the ``UserDefaults``
    func testSpeziHealthKitCollectionAlreadyAuthorized() {
        // Set up UserDefaults
        UserDefaults.standard.set(
            Self.collectedSamples.map { $0.identifier },
            forKey: UserDefaults.Keys.healthKitRequestedSampleTypes
        )
        
        XCTAssert(healthKitComponent.authorized)
    }
}
