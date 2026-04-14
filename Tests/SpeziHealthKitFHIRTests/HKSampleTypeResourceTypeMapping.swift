//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziHealthKitFHIR
import ModelsR4
import Testing


@MainActor // to work around https://github.com/apple/FHIRModels/issues/36
struct HKSampleTypeResourceTypeMapping {
    @Test
    func hkSampleTypeMappingToObservation() throws {
        #expect(try HKQuantityType(.activeEnergyBurned).resourceType == .observation)
        #expect(try HKCorrelationType(.bloodPressure).resourceType == .observation)
        #expect(try HKCategoryType(.abdominalCramps).resourceType == .observation)

        #expect(throws: HealthKitOnFHIRError.self) {
            try HKSampleType.workoutType().resourceType
        }
    }
    
    @Test
    func hkClinicalTypeMappingToResourceType() throws {
        #expect(try HKClinicalType(.allergyRecord).resourceType == .allergyIntolerance)
        #expect(try HKClinicalType(.conditionRecord).resourceType == .condition)
        #expect(try HKClinicalType(.coverageRecord).resourceType == .coverage)
        #expect(try HKClinicalType(.immunizationRecord).resourceType == .immunization)
        #expect(try HKClinicalType(.labResultRecord).resourceType == .observation)
        #expect(try HKClinicalType(.medicationRecord).resourceType == .medication)
        #expect(try HKClinicalType(.procedureRecord).resourceType == .procedure)
        #expect(try HKClinicalType(.vitalSignRecord).resourceType == .observation)
    }
}
