//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

import SpeziHealthKit
import SpeziHealthKitFHIR
import Testing


@Suite
struct SampleTypeFHIRResourceTypeMapping {
    @Test
    func regular() {
        func imp(_ sampleTypes: some Sequence<SampleType<some Any>>) {
            for sampleType in sampleTypes {
                #expect(sampleType.fhirResourceType == .observation, "\(sampleType)")
            }
        }
        imp(SampleType.allKnownQuantities)
        imp(SampleType.allKnownCategories)
        imp(SampleType.allKnownCorrelations)
        imp(CollectionOfOne(SampleType.workout))
        imp(CollectionOfOne(SampleType.electrocardiogram))
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            imp(CollectionOfOne(SampleType.stateOfMind))
        }
        #expect(SampleType.workoutRoute.fhirResourceType == nil)
        #expect(SampleType.visionPrescription.fhirResourceType == nil)
    }
    
    
    @available(watchOS, unavailable)
    @Test
    func hkClinicalType() throws {
        #expect(SampleType.allergyRecord.fhirResourceType == .allergyIntolerance)
        #expect(SampleType.conditionRecord.fhirResourceType == .condition)
        #expect(SampleType.coverageRecord.fhirResourceType == .coverage)
        #expect(SampleType.immunizationRecord.fhirResourceType == .immunization)
        #expect(SampleType.labResultRecord.fhirResourceType == .observation)
        #expect(SampleType.medicationRecord.fhirResourceType == .medication)
        #expect(SampleType.procedureRecord.fhirResourceType == .procedure)
        #expect(SampleType.vitalSignRecord.fhirResourceType == .observation)
    }
}

#endif
