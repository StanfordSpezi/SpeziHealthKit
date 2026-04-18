//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
@testable import SpeziHealthKitFHIR
import ModelsR4
import Testing


@MainActor // to work around https://github.com/apple/FHIRModels/issues/36
struct CustomMappingsTests {
    @Test
    func customMappings() throws {
        // swiftlint:disable:previous function_body_length
        // We disable the function body length as this is a test case
        let quantitySample = HKQuantitySample(
            type: HKQuantityType(.bodyMass),
            quantity: HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: 60),
            start: Date(),
            end: Date()
        )

        let ucumSystem = try #require(URL(string: "http://unitsofmeasure.org"))
        let stanfordURL = try #require(URL(string: "http://stanford.edu"))

        var customMapping = [
            HKQuantityType(.bodyMass):
            HKQuantitySampleMapping(
                codings: [
                    MappedCode(
                        code: "SU-01",
                        display: "Stanford University",
                        system: stanfordURL
                    )
                ],
                unit: MappedUnit(
                    hkunit: .ounce(),
                    unit: "oz",
                    system: ucumSystem,
                    code: "[oz_av]"
                )
            )
        ]
        customMapping[HKQuantityType(.bodyMass)]?.unit.removeSystemAndCode()
        #expect(customMapping[HKQuantityType(.bodyMass)]?.unit.system == nil)
        #expect(customMapping[HKQuantityType(.bodyMass)]?.unit.code == nil)
        
        customMapping[HKQuantityType(.bodyMass)]?.unit.update(system: ucumSystem, code: "[oz_av]")
        #expect(customMapping[HKQuantityType(.bodyMass)]?.unit.system == ucumSystem)
        #expect(customMapping[HKQuantityType(.bodyMass)]?.unit.code == "[oz_av]")

        let hkSampleMapping = HKSampleMapping(quantitySampleMapping: customMapping)
        
        let observation = try quantitySample
            .resource(withMapping: hkSampleMapping)
            .get(if: Observation.self)
        
        #expect(quantitySample.quantityType.codes() == [
            Coding(
                code: "29463-7",
                display: "Body weight",
                system: FHIRPrimitive(FHIRURI(stringLiteral: "http://loinc.org"))
            ),
            Coding(
                code: "HKQuantityTypeIdentifierBodyMass",
                display: "Body Mass",
                system: FHIRPrimitive(FHIRURI(stringLiteral: "http://developer.apple.com/documentation/healthkit"))
            )
        ])
        
        #expect(observation?.code.coding == [
            Coding(
                code: "SU-01",
                display: "Stanford University",
                system: FHIRPrimitive(FHIRURI(stanfordURL))
            )
        ])
        
        #expect(observation?.value == .quantity(Quantity(
            code: "[oz_av]",
            system: "http://unitsofmeasure.org",
            unit: "oz",
            value: 2116.43771697482496.asFHIRDecimalPrimitive()
        )))
    }
}
