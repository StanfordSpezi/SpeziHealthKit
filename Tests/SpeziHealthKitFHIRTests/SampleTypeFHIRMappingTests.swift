//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziFoundation
import SpeziHealthKit
@testable import SpeziHealthKitFHIR
import ModelsR4
import Testing


@Suite
struct SampleTypeFHIRMappingTests {
    @Test
    func quantityTypes() {
        let oldMapping = HKSampleMapping.default.quantitySampleMapping
        let newMapping = QuantityTypesFHIRMapping.default
        #expect(oldMapping.count == newMapping.count)
        do {
            let oldKeys: Set<HKQuantityType> = Set(oldMapping.keys)
            let newKeys: Set<HKQuantityType> = newMapping.keys.mapIntoSet(\.hkSampleType)
            #expect(oldKeys == newKeys, { () -> Comment in
                let missingKeys = Set(oldKeys).subtracting(newKeys)
                let extraKeys = Set(newKeys).subtracting(oldKeys)
                return """
                    missing: \(missingKeys.map(\.identifier).sorted())
                    extra: \(extraKeys.map(\.identifier).sorted())
                    """
            }())
        }
        for (hkType, oldMapping) in oldMapping {
            guard let sampleType = hkType.sampleType as? SampleType<HKQuantitySample> else {
                Issue.record("Unable to obtain SampleType for \(hkType)")
                continue
            }
            guard let newMapping = newMapping[sampleType] else {
                Issue.record("Unable to obtain mapping for \(sampleType)")
                continue
            }
            let oldCodings = oldMapping.codings.mapIntoSet(\.coding)
            #expect(oldCodings == Set(newMapping.codings), "Non-matching codings for \(hkType)")
            #expect(oldMapping.unit.hkunit == newMapping.unit.hkUnit, "Non-matching unit for \(hkType)")
            #expect(oldMapping.unit.code == newMapping.unit.code?.value?.string, "Non-matching unit for \(hkType)")
            #expect(oldMapping.unit.system == newMapping.unit.system?.value?.url, "Non-matching unit for \(hkType)")
            #expect(oldMapping.unit.unit == newMapping.unit.unit, "Non-matching unit for \(hkType)")
        }
    }
}
