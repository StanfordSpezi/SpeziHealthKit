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


@Suite
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
        
        var hkSampleMapping = SampleTypesFHIRMapping.default
        hkSampleMapping.quantityTypesMapping = [
            .bodyMass: QuantityTypeFHIRMapping(
                codings: [
                    Coding(
                        code: "SU-01",
                        display: "Stanford University",
                        system: stanfordURL.asFHIRURIPrimitive()
                    )
                ],
                unit: QuantityTypeFHIRMapping.Unit(
                    hkUnit: .ounce(),
                    unit: "oz",
                    system: ucumSystem.asFHIRURIPrimitive(),
                    code: "[oz_av]"
                )
            )
        ]
        
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
                code: "27113001",
                display: "Body weight",
                system: .snomedCT
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
