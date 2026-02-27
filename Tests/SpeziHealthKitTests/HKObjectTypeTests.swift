//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable identical_operands

import Foundation
@testable import SpeziHealthKit
import Testing


@Suite
struct HKObjectTypeTests {
    @Test
    func equality() {
        #expect(HKQuantityType(.heartRate) == HKQuantityType(.heartRate))
        #expect(HKCategoryType(.sleepAnalysis) == HKCategoryType(.sleepAnalysis))
        #expect(HKCorrelationType(.bloodPressure) == HKCorrelationType(.bloodPressure))
        #expect(HKWorkoutType.workoutType() == HKWorkoutType.workoutType())
        #expect(HKClinicalType(.labResultRecord) == HKClinicalType(.labResultRecord))
        #expect(HKQuantityType(.heartRate) != HKCategoryType(.sleepAnalysis))
    }
    
    
    @Test
    func hashing() {
        let heartRate = HKQuantityType(.heartRate)
        let stepCount = HKQuantityType(.stepCount)
        #expect(Set([heartRate, heartRate]).count == 1)
        #expect(Set([heartRate, stepCount]).count == 2)
        #expect(HKQuantityType(.appleMoveTime).hashValue == HKQuantityType(.appleMoveTime).hashValue)
    }
}
