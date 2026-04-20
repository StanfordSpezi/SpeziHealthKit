//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

import ModelsR4
import SpeziHealthKit
@testable import SpeziHealthKitFHIR
import Testing


@Suite
struct SampleTypeFHIRMappingTests {
    @Test
    func completeness() {
        let mapping = SampleTypesFHIRMapping.default
        
        let missingQuantities = HKQuantityType.allKnownQuantities.subtracting(mapping.quantityTypesMapping.keys.map(\.hkSampleType))
        #expect(missingQuantities.isEmpty, "Missing entries in Quantity Type FHIR Mapping: \(missingQuantities.map(\.identifier).sorted())")
        
        let missingCorrelations = HKCorrelationType.allKnownCorrelations.subtracting(mapping.correlationTypesMapping.keys.map(\.hkSampleType))
        #expect(missingCorrelations.isEmpty, "Missing entries in Correlation Type FHIR Mapping: \(missingCorrelations.map(\.identifier).sorted())")
        
        let missingCategories = HKCategoryType.allKnownCategories.subtracting(mapping.categoryTypesMapping.keys.map(\.hkSampleType))
        #expect(missingCategories.isEmpty, "Missing entries in Category Type FHIR Mapping: \(missingCategories.map(\.identifier).sorted())")
    }
}

#endif
