//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_length

import FHIRModelsExtensions
import HealthKit
import ModelsR4
import SpeziFoundation
@testable import SpeziHealthKitFHIR
import Testing


@Suite
struct HKQuantitySampleTests {
    // swiftlint:disable:previous type_body_length
    // We disable the type body length as this is a test class
    var startDate: Date {
        get throws {
            let dateComponents = DateComponents(year: 1891, month: 10, day: 1, hour: 12, minute: 0, second: 0) // Date Stanford University opened (https://www.stanford.edu/about/history/)
            return try #require(Calendar.current.date(from: dateComponents))
        }
    }
    
    var endDate: Date {
        get throws {
            let dateComponents = DateComponents(year: 1891, month: 10, day: 1, hour: 12, minute: 0, second: 42)
            return try #require(Calendar.current.date(from: dateComponents))
        }
    }
    
    func createObservationFrom(
        type quantityType: HKQuantityType,
        quantity: HKQuantity,
        timeRange: Swift.Range<Date>? = nil,
        device: HKDevice? = nil,
        metadata: [String: Any] = [:],
        extensions: [any FHIRExtensionBuilderProtocol] = []
    ) throws -> Observation {
        let quantitySample = HKQuantitySample(
            type: quantityType,
            quantity: quantity,
            start: try timeRange?.lowerBound ?? startDate,
            end: try timeRange?.upperBound ?? endDate,
            device: device,
            metadata: metadata
        )
        return try #require(quantitySample.resource(extensions: extensions).get(if: Observation.self))
    }
    
    func createCoding(
        code: String,
        display: String,
        system: SupportedCodeSystem
    ) -> Coding {
        Coding(
            code: FHIRPrimitive(stringLiteral: code),
            display: FHIRPrimitive(stringLiteral: display),
            system: FHIRPrimitive(FHIRURI(stringLiteral: system.rawValue))
        )
    }
    
    @Test
    func bloodGlucose() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.bloodGlucose),
            quantity: HKQuantity(unit: HKUnit(from: "mg/dL"), doubleValue: 99)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "41653-7",
                display: "Glucose Glucometer (BldC) [Mass/Vol]",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierBloodGlucose",
                display: "Blood Glucose",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg/dL",
                system: "http://unitsofmeasure.org",
                unit: "mg/dL",
                value: 99.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryBiotin() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryBiotin),
            quantity: HKQuantity(unit: .gramUnit(with: .micro), doubleValue: 100)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryBiotin",
                display: "Dietary Biotin Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "ug",
                system: "http://unitsofmeasure.org",
                unit: "ug",
                value: 100.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryCaffeine() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryCaffeine),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 100)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryCaffeine",
                display: "Dietary Caffeine Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 100.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryCalcium() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryCalcium),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 1000)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryCalcium",
                display: "Dietary Calcium Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 1000.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryCarbohydrates() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryCarbohydrates),
            quantity: HKQuantity(unit: .gram(), doubleValue: 1000)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryCarbohydrates",
                display: "Dietary Carbohydrates Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "g",
                system: "http://unitsofmeasure.org",
                unit: "g",
                value: 1000.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryChloride() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryChloride),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 2300)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryChloride",
                display: "Dietary Chloride Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 2300.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryCholesterol() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryCholesterol),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 100)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryCholesterol",
                display: "Dietary Cholesterol Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 100.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryChromium() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryChromium),
            quantity: HKQuantity(unit: .gramUnit(with: .micro), doubleValue: 25)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryChromium",
                display: "Dietary Chromium Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "ug",
                system: "http://unitsofmeasure.org",
                unit: "ug",
                value: 25.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryCopper() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryCopper),
            quantity: HKQuantity(unit: .gramUnit(with: .micro), doubleValue: 900)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryCopper",
                display: "Dietary Copper Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "ug",
                system: "http://unitsofmeasure.org",
                unit: "ug",
                value: 900.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryFatMonounsaturated() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryFatMonounsaturated),
            quantity: HKQuantity(unit: .gram(), doubleValue: 22)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryFatMonounsaturated",
                display: "Dietary Monounsaturated Fat Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "g",
                system: "http://unitsofmeasure.org",
                unit: "g",
                value: 22.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryFatPolyunsaturated() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryFatPolyunsaturated),
            quantity: HKQuantity(unit: .gram(), doubleValue: 30)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryFatPolyunsaturated",
                display: "Dietary Polyunsaturated Fat Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "g",
                system: "http://unitsofmeasure.org",
                unit: "g",
                value: 30.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryFatSaturated() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryFatSaturated),
            quantity: HKQuantity(unit: .gram(), doubleValue: 30)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryFatSaturated",
                display: "Dietary Saturated Fat Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "g",
                system: "http://unitsofmeasure.org",
                unit: "g",
                value: 30.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryFatTotal() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryFatTotal),
            quantity: HKQuantity(unit: .gram(), doubleValue: 66)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryFatTotal",
                display: "Dietary Total Fat Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "g",
                system: "http://unitsofmeasure.org",
                unit: "g",
                value: 66.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryFiber() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryFiber),
            quantity: HKQuantity(unit: .gram(), doubleValue: 30)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "LP203183-1",
                display: "Fiber intake",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryFiber",
                display: "Dietary Fiber Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "g",
                system: "http://unitsofmeasure.org",
                unit: "g",
                value: 30.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryFolate() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryFolate),
            quantity: HKQuantity(unit: .gramUnit(with: .micro), doubleValue: 400)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryFolate",
                display: "Dietary Folate Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "ug",
                system: "http://unitsofmeasure.org",
                unit: "ug",
                value: 400.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryIodine() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryIodine),
            quantity: HKQuantity(unit: .gramUnit(with: .micro), doubleValue: 140)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryIodine",
                display: "Dietary Iodine Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "ug",
                system: "http://unitsofmeasure.org",
                unit: "ug",
                value: 140.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryIron() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryIron),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 16)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryIron",
                display: "Dietary Iron Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 16.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryMagnesium() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryMagnesium),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 400)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryMagnesium",
                display: "Dietary Magnesium Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 400.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryManganese() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryManganese),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 2.3)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryManganese",
                display: "Dietary Manganese Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 2.3.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryMolybdenum() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryMolybdenum),
            quantity: HKQuantity(unit: .gramUnit(with: .micro), doubleValue: 45)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryMolybdenum",
                display: "Dietary Molybdenum Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "ug",
                system: "http://unitsofmeasure.org",
                unit: "ug",
                value: 45.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryPhosphorus() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryPhosphorus),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 1000)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryPhosphorus",
                display: "Dietary Phosphorus Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 1000.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryPotassium() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryPotassium),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 1000)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryPotassium",
                display: "Dietary Potassium Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 1000.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietarySodium() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietarySodium),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 1000)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietarySodium",
                display: "Dietary Sodium Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 1000.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryNiacin() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryNiacin),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 16)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryNiacin",
                display: "Dietary Niacin Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 16.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryPantothenicAcid() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryPantothenicAcid),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 5)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryPantothenicAcid",
                display: "Dietary Pantothenic Acid Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 5.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryProtein() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryProtein),
            quantity: HKQuantity(unit: .gram(), doubleValue: 40)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryProtein",
                display: "Dietary Protein Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "g",
                system: "http://unitsofmeasure.org",
                unit: "g",
                value: 40.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryRiboflavin() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryRiboflavin),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 1.3)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryRiboflavin",
                display: "Dietary Riboflavin Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 1.3.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietarySelenium() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietarySelenium),
            quantity: HKQuantity(unit: .gramUnit(with: .micro), doubleValue: 55)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietarySelenium",
                display: "Dietary Selenium Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "ug",
                system: "http://unitsofmeasure.org",
                unit: "ug",
                value: 55.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietarySugar() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietarySugar),
            quantity: HKQuantity(unit: .gram(), doubleValue: 30)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietarySugar",
                display: "Dietary Sugar Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "g",
                system: "http://unitsofmeasure.org",
                unit: "g",
                value: 30.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryThiamin() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryThiamin),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 1.2)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryThiamin",
                display: "Dietary Thiamin Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 1.2.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryVitaminA() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryVitaminA),
            quantity: HKQuantity(unit: .gramUnit(with: .micro), doubleValue: 900)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryVitaminA",
                display: "Dietary Vitamin A Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "ug",
                system: "http://unitsofmeasure.org",
                unit: "ug",
                value: 900.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryVitaminB12() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryVitaminB12),
            quantity: HKQuantity(unit: .gramUnit(with: .micro), doubleValue: 2.4)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryVitaminB12",
                display: "Dietary Vitamin B12 Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "ug",
                system: "http://unitsofmeasure.org",
                unit: "ug",
                value: 2.4.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryVitaminB6() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryVitaminB6),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 1.5)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryVitaminB6",
                display: "Dietary Vitamin B6 Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 1.5.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryVitaminC() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryVitaminC),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 90)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryVitaminC",
                display: "Dietary Vitamin C Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 90.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryVitaminD() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryVitaminD),
            quantity: HKQuantity(unit: .gramUnit(with: .micro), doubleValue: 20)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryVitaminD",
                display: "Dietary Vitamin D Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "ug",
                system: "http://unitsofmeasure.org",
                unit: "ug",
                value: 20.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryVitaminE() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryVitaminE),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 15)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryVitaminE",
                display: "Dietary Vitamin E Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 15.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryVitaminK() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryVitaminK),
            quantity: HKQuantity(unit: .gramUnit(with: .micro), doubleValue: 15)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryVitaminK",
                display: "Dietary Vitamin K Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "ug",
                system: "http://unitsofmeasure.org",
                unit: "ug",
                value: 15.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryWater() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryWater),
            quantity: HKQuantity(unit: .liter(), doubleValue: 2)
        )
        #expect(observation.code.coding == [
            Coding(
                code: "8999-5",
                display: "Fluid intake oral Estimated",
                system: .loincSystem
            ),
            Coding(
                code: "226354008",
                display: "Water intake",
                system: .snomedCT
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryWater",
                display: "Dietary Water Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "l",
                system: "http://unitsofmeasure.org",
                unit: "l",
                value: 2.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryWater2() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryWater),
            quantity: HKQuantity(unit: .literUnit(with: .milli), doubleValue: 2500)
        )
        #expect(observation.code.coding == [
            Coding(
                code: "8999-5",
                display: "Fluid intake oral Estimated",
                system: .loincSystem
            ),
            Coding(
                code: "226354008",
                display: "Water intake",
                system: .snomedCT
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryWater",
                display: "Dietary Water Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "l",
                system: "http://unitsofmeasure.org",
                unit: "l",
                value: 2.5.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func dietaryZinc() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.dietaryZinc),
            quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: 11)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDietaryZinc",
                display: "Dietary Zinc Intake",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mg",
                system: "http://unitsofmeasure.org",
                unit: "mg",
                value: 11.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func electrodermalActivity() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.electrodermalActivity),
            quantity: HKQuantity(unit: .siemen(), doubleValue: 0.000001)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierElectrodermalActivity",
                display: "Electrodermal Activity",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mcS",
                system: "http://unitsofmeasure.org",
                unit: "microsiemens",
                value: 1.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func forcedExpiratoryVolume1() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.forcedExpiratoryVolume1),
            quantity: HKQuantity(unit: .liter(), doubleValue: 3.5)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "20150-9",
                display: "FEV1",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierForcedExpiratoryVolume1",
                display: "Forced Expiratory Volume (1 sec)",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "L",
                system: "http://unitsofmeasure.org",
                unit: "L",
                value: 3.5.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func forcedVitalCapacity() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.forcedVitalCapacity),
            quantity: HKQuantity(unit: .liter(), doubleValue: 5.5)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "19870-5",
                display: "Forced vital capacity [Volume] Respiratory system",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierForcedVitalCapacity",
                display: "Forced Vital Capacity",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "L",
                system: "http://unitsofmeasure.org",
                unit: "L",
                value: 5.5.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func inhalerUsage() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.inhalerUsage),
            quantity: HKQuantity(unit: .count(), doubleValue: 3)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierInhalerUsage",
                display: "Inhaler Usage",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                unit: "count",
                value: 3.asFHIRDecimalPrimitive()
            )
        ))
    }

    @Test
    func stepCount() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 42)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "55423-8",
                display: "Number of steps in unspecified time Pedometer",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierStepCount",
                display: "Step Count",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                unit: "steps",
                value: 42.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func flightsClimbed() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.flightsClimbed),
            quantity: HKQuantity(unit: .count(), doubleValue: 10)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "100304-5",
                display: "Flights climbed [#] Reporting Period",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierFlightsClimbed",
                display: "Flights Climbed",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                unit: "flights",
                value: 10.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func heartRate() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.heartRate),
            quantity: HKQuantity(unit: .count().unitDivided(by: .minute()), doubleValue: 84)
        )
        #expect(observation.code.coding == [
            Coding(
                code: "8867-4",
                display: "Heart rate",
                system: .loincSystem
            ),
            Coding(
                code: "364075005",
                display: "Heart rate",
                system: .snomedCT
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierHeartRate",
                display: "Heart Rate",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "/min",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "beats/minute",
                value: 84.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func restingHeartRate() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.restingHeartRate),
            quantity: HKQuantity(unit: .count().unitDivided(by: .minute()), doubleValue: 84)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "40443-4",
                display: "Heart rate --resting",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierRestingHeartRate",
                display: "Resting Heart Rate",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "/min",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "beats/minute",
                value: 84.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func walkingHeartRateAverage() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.walkingHeartRateAverage),
            quantity: HKQuantity(unit: .count().unitDivided(by: .minute()), doubleValue: 84)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierWalkingHeartRateAverage",
                display: "Walking Heart Rate Average",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "/min",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "beats/minute",
                value: 84.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func walkingAsymmetryPercentage() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.walkingAsymmetryPercentage),
            quantity: HKQuantity(unit: .percent(), doubleValue: 50)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierWalkingAsymmetryPercentage",
                display: "Walking Asymmetry Percentage",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "%",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "%",
                value: 50.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func walkingSpeed() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.walkingSpeed),
            quantity: HKQuantity(unit: HKUnit.meter().unitDivided(by: HKUnit.second()), doubleValue: 1.5)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierWalkingSpeed",
                display: "Walking Speed",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "m/s",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "m/s",
                value: 1.5.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func heartRateVariabilitySDNN() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.heartRateVariabilitySDNN),
            quantity: HKQuantity(unit: .secondUnit(with: .milli), doubleValue: 100)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "80404-7",
                display: "R-R interval.standard deviation (Heart rate variability)",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierHeartRateVariabilitySDNN",
                display: "Heart Rate Variability SDNN",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "ms",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "ms",
                value: 100.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func oxygenSaturation() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.oxygenSaturation),
            quantity: HKQuantity(unit: .percent(), doubleValue: 99)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "59408-5",
                display: "Oxygen saturation in Arterial blood by Pulse oximetry",
                system: .loinc
            ),
            Coding(
                code: "431314004",
                display: "Peripheral oxygen saturation",
                system: .snomedCT
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierOxygenSaturation",
                display: "Oxygen Saturation",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "%",
                system: "http://unitsofmeasure.org",
                unit: "%",
                value: 99.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func peakExpiratoryFlowRate() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.peakExpiratoryFlowRate),
            quantity: HKQuantity(unit: .liter().unitDivided(by: .minute()), doubleValue: 600)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "19935-6",
                display: "Maximum expiratory gas flow Respiratory system airway by Peak flow meter",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierPeakExpiratoryFlowRate",
                display: "Peak Expiratory Flow Rate",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "L/min",
                system: "http://unitsofmeasure.org",
                unit: "L/min",
                value: 600.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func peripheralPerfusionIndex() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.peripheralPerfusionIndex),
            quantity: HKQuantity(unit: .percent(), doubleValue: 5)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "61006-3",
                display: "Perfusion index Tissue by Pulse oximetry",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierPeripheralPerfusionIndex",
                display: "Peripheral Perfusion Index",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "%",
                system: "http://unitsofmeasure.org",
                unit: "%",
                value: 5.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func pushCount() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.pushCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 5)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "96502-0",
                display: "Number of wheelchair pushes per time period",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierPushCount",
                display: "Wheelchair Push Count",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                unit: "wheelchair pushes",
                value: 5.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
    @Test
    func timeInDaylight() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.timeInDaylight),
            quantity: HKQuantity(unit: .minute(), doubleValue: 100)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierTimeInDaylight",
                display: "Time in Daylight",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "min",
                system: "http://unitsofmeasure.org",
                unit: "min",
                value: 100.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func uvExposure() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.uvExposure),
            quantity: HKQuantity(unit: .count(), doubleValue: 5)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierUVExposure",
                display: "UV Exposure",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                unit: "count",
                value: 5.asFHIRDecimalPrimitive()
            )
        ))
    }

    @Test
    func vo2Max() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.vo2Max),
            quantity: HKQuantity(unit: HKUnit(from: "mL/kg*min"), doubleValue: 31)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierVO2Max",
                display: "VO2Max",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "mL/kg/min",
                system: "http://unitsofmeasure.org",
                unit: "mL/kg/min",
                value: 31.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func waistCircumference() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.waistCircumference),
            quantity: HKQuantity(unit: HKUnit(from: "in"), doubleValue: 38.7)
        )
        #expect(observation.code.coding == [
            Coding(
                code: "8280-0",
                display: "Waist Circumference at umbilicus by Tape measure",
                system: .loincSystem
            ),
            Coding(
                code: "276361009",
                display: "Waist circumference",
                system: .snomedCT
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierWaistCircumference",
                display: "Waist Circumference",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "cm",
                system: "http://unitsofmeasure.org",
                unit: "cm",
                value: 98.298.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func bodyTemperature() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.bodyTemperature),
            quantity: HKQuantity(unit: .degreeCelsius(), doubleValue: 37)
        )
        #expect(observation.code.coding == [
            Coding(
                code: "8310-5",
                display: "Body temperature",
                system: .loincSystem
            ),
            Coding(
                code: "386725007",
                display: "Body temperature",
                system: .snomedCT
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierBodyTemperature",
                display: "Body Temperature",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "Cel",
                system: "http://unitsofmeasure.org",
                unit: "C",
                value: 37.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func basalBodyTemperature() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.basalBodyTemperature),
            quantity: HKQuantity(unit: .degreeCelsius(), doubleValue: 37)
        )
        #expect(observation.code.coding == [
            Coding(
                code: "8310-5",
                display: "Body temperature",
                system: .loincSystem
            ),
            Coding(
                code: "300076005",
                system: .snomedCT
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierBasalBodyTemperature",
                display: "Basal Body Temperature",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "Cel",
                system: "http://unitsofmeasure.org",
                unit: "C",
                value: 37.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func basalEnergyBurned() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.basalEnergyBurned),
            quantity: HKQuantity(unit: HKUnit(from: "kcal"), doubleValue: 1200)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierBasalEnergyBurned",
                display: "Basal Energy Burned",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "kcal",
                system: "http://unitsofmeasure.org",
                unit: "kcal",
                value: 1200.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func bloodAlcoholContent() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.bloodAlcoholContent),
            quantity: HKQuantity(unit: .percent(), doubleValue: 0.0)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "74859-0",
                display: "Ethanol [Mass/volume] in Blood Estimated from serum or plasma level",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierBloodAlcoholContent",
                display: "Blood Alcohol Content",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "%",
                system: "http://unitsofmeasure.org",
                unit: "%",
                value: 0.0.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func bodyFatPercentage() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.bodyFatPercentage),
            quantity: HKQuantity(unit: .percent(), doubleValue: 21)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "41982-0",
                display: "Percentage of body fat Measured",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierBodyFatPercentage",
                display: "Body Fat Percentage",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "%",
                system: "http://unitsofmeasure.org",
                unit: "%",
                value: 21.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func bodyMassIndex() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.bodyMassIndex),
            quantity: HKQuantity(unit: .count(), doubleValue: 20)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "39156-5",
                display: "Body mass index (BMI) [Ratio]",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierBodyMassIndex",
                display: "BMI",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "kg/m2",
                system: "http://unitsofmeasure.org",
                unit: "kg/m^2",
                value: 20.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func height() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.height),
            quantity: HKQuantity(unit: .meter(), doubleValue: 1.87)
        )
        #expect(observation.code.coding == [
            Coding(
                code: "8302-2",
                display: "Body height",
                system: .loincSystem
            ),
            Coding(
                code: "50373000",
                display: "Body height measure",
                system: .snomedCT
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierHeight",
                display: "Height",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "cm",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "cm",
                value: 187.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func bodyMass() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.bodyMass),
            quantity: HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: 68.7)
        )
        #expect(observation.code.coding == [
            Coding(
                code: "29463-7",
                display: "Body weight",
                system: .loincSystem
            ),
            Coding(
                code: "27113001",
                display: "Body weight",
                system: .snomedCT
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierBodyMass",
                display: "Body Mass",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "kg",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "kg",
                value: 68.7.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func leanBodyMass() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.leanBodyMass),
            quantity: HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: 67)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "91557-9",
                display: "Lean body weight",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierLeanBodyMass",
                display: "Lean Body Mass",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "kg",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "kg",
                value: 67.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func numberOfTimesFallen() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.numberOfTimesFallen),
            quantity: HKQuantity(unit: .count(), doubleValue: 0)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierNumberOfTimesFallen",
                display: "Number of Times Fallen",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                unit: "falls",
                value: 0.asFHIRDecimalPrimitive()
            )
        ))
    }

    @Test
    func swimmingStrokeCount() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.swimmingStrokeCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 10)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierSwimmingStrokeCount",
                display: "Swimming Stroke Count",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                unit: "strokes",
                value: 10.asFHIRDecimalPrimitive()
            )
        ))
    }

    @Test
    func respiratoryRate() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.respiratoryRate),
            quantity: HKQuantity(unit: .count().unitDivided(by: .minute()), doubleValue: 18)
        )
        #expect(observation.code.coding == [
            Coding(
                code: "9279-1",
                display: "Respiratory rate",
                system: .loincSystem
            ),
            Coding(
                code: "86290005",
                display: "Respiratory rate",
                system: .snomedCT
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierRespiratoryRate",
                display: "Respiratory Rate",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "/min",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "breaths/minute",
                value: 18.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func activeEnergyBurned() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.activeEnergyBurned),
            quantity: HKQuantity(unit: .largeCalorie(), doubleValue: 100)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "41981-2",
                display: "Calories burned",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierActiveEnergyBurned",
                display: "Active Energy Burned",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "kcal",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "kcal",
                value: 100.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func appleExerciseTime() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.appleExerciseTime),
            quantity: HKQuantity(unit: .minute(), doubleValue: 100)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierAppleExerciseTime",
                display: "Apple Exercise Time",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "min",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "min",
                value: 100.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func appleMoveTime() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.appleMoveTime),
            quantity: HKQuantity(unit: .minute(), doubleValue: 100)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierAppleMoveTime",
                display: "Apple Move Time",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "min",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "min",
                value: 100.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
    @Test
    func applePhysicalEffort() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.physicalEffort),
            quantity: HKQuantity(unit: HKUnit(from: "kcal/hr*kg"), doubleValue: 2)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierPhysicalEffort",
                display: "Physical Effort",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "kcal/hr/kg",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "kcal/hr/kg",
                value: 2.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func appleStandTime() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.appleStandTime),
            quantity: HKQuantity(unit: .minute(), doubleValue: 100)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierAppleStandTime",
                display: "Apple Stand Time",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "min",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "min",
                value: 100.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func ppleWalkingSteadiness() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.appleWalkingSteadiness),
            quantity: HKQuantity(unit: .percent(), doubleValue: 50)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierAppleWalkingSteadiness",
                display: "Apple Walking Steadiness",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "%",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "%",
                value: 50.asFHIRDecimalPrimitive()
            )
        ))
    }

    @Test
    func distanceCycling() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.distanceCycling),
            quantity: HKQuantity(unit: .meterUnit(with: .kilo), doubleValue: 1.75)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDistanceCycling",
                display: "Cycling Distance",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "m",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "m",
                value: 1750.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func distanceDownhillSnowSports() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.distanceDownhillSnowSports),
            quantity: HKQuantity(unit: .meter(), doubleValue: 1750)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDistanceDownhillSnowSports",
                display: "Downhill Snow Sports Distance",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "m",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "m",
                value: 1750.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func distanceSwimming() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.distanceSwimming),
            quantity: HKQuantity(unit: .meter(), doubleValue: 100)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "93816-7",
                display: "Swimming distance unspecified time",
                system: .loinc
            ),
            createCoding(
                code: "HKQuantityTypeIdentifierDistanceSwimming",
                display: "Swimming Distance",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "m",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "m",
                value: 100.asFHIRDecimalPrimitive()
            )
        ))
    }

    
    @Test
    func distanceWalkingRunning() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.distanceWalkingRunning),
            quantity: HKQuantity(unit: .meter(), doubleValue: 100)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDistanceWalkingRunning",
                display: "Distance Walking/Running",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "m",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "m",
                value: 100.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func distanceWheelchair() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.distanceWheelchair),
            quantity: HKQuantity(unit: .meter(), doubleValue: 100)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierDistanceWheelchair",
                display: "Wheelchair Distance",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "m",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "m",
                value: 100.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func environmentalAudioExposure() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.environmentalAudioExposure),
            quantity: HKQuantity(unit: .decibelAWeightedSoundPressureLevel(), doubleValue: 100)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierEnvironmentalAudioExposure",
                display: "Environmental Audio Exposure",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "dB(SPL)",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "dB(SPL)",
                value: 100.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    @Test
    func headphoneAudioExposure() throws {
        let observation = try createObservationFrom(
            type: HKQuantityType(.headphoneAudioExposure),
            quantity: HKQuantity(unit: .decibelAWeightedSoundPressureLevel(), doubleValue: 100)
        )
        #expect(observation.code.coding == [
            createCoding(
                code: "HKQuantityTypeIdentifierHeadphoneAudioExposure",
                display: "Headphone Audio Exposure",
                system: .apple
            )
        ])
        #expect(observation.value == .quantity(
            Quantity(
                code: "dB(SPL)",
                system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                unit: "dB(SPL)",
                value: 100.asFHIRDecimalPrimitive()
            )
        ))
    }
    
    // need to find a new unsupported type
//    @Test
//    func unsupportedTypeSample() throws {
//        let quantitySample = HKQuantitySample(
//            type: HKQuantityType(.nikeFuel),
//            quantity: HKQuantity(unit: .count(), doubleValue: 1),
//            start: try startDate,
//            end: try endDate
//        )
//        #expect(throws: SpeziHealthKitFHIRError.self) {
//            try quantitySample.resource().get(if: Observation.self)
//        }
//    }
    
    @Test
    func invalidComponent() throws {
        let startDate = try startDate
        let endDate = try endDate
        let nikeFuel = HKQuantitySample(
            type: HKQuantityType(.nikeFuel),
            quantity: HKQuantity(unit: .count(), doubleValue: 1),
            start: startDate,
            end: endDate
        )
        let correlation: HKCorrelation
        do {
            correlation = try catchingNSException {
                HKCorrelation(
                    type: HKCorrelationType(.bloodPressure),
                    start: startDate,
                    end: endDate,
                    objects: [nikeFuel]
                )
            }
        } catch {
            // it seems that HealthKit sometimes doesn't let us create an invalid sample.
            // in this case we simplu skip the test
            return
        }
        #expect(throws: SpeziHealthKitFHIRError.self) {
            try correlation.resource()
        }
    }
    
    @Test
    func unsupportedType() throws {
        #expect(throws: SpeziHealthKitFHIRError.self) {
            try HKVisionPrescription(
                type: .glasses,
                dateIssued: try startDate,
                expirationDate: nil,
                device: nil,
                metadata: nil
            ).resource()
        }
    }
    
    // need to find a new unsupported type
//    @Test
//    func unsupportedMapping() throws {
//        let sample = HKQuantitySample(
//            type: HKQuantityType(.nikeFuel),
//            quantity: HKQuantity(unit: .count(), doubleValue: 1),
//            start: try startDate,
//            end: try endDate
//        )
//        #expect(sample.quantityType.codes().isEmpty)
//    }
    
    @Test func invalidValue() throws {
        #expect(Decimal(Double.nan).doubleValue.isNaN)
        #expect(Decimal(Double.signalingNaN).doubleValue.isNaN)
        
        let unit: HKUnit = .count().unitDivided(by: .minute())
        let makeSample = {
            HKQuantitySample(
                type: HKQuantityType(.heartRate),
                quantity: HKQuantity(unit: unit, doubleValue: $0),
                start: .now,
                end: .now
            )
        }
        #expect(throws: (any Error).self) {
            try makeSample(+.infinity).resource()
        }
        #expect(throws: (any Error).self) {
            try makeSample(-.infinity).resource()
        }
        #expect(throws: Never.self) {
            try makeSample(.nan).resource()
        }
        
        let samples = [
            makeSample(+.infinity),
            makeSample(-.infinity),
            makeSample(.nan),
            makeSample(.signalingNaN),
            makeSample(+0),
            makeSample(-0)
        ]
        
        let resources = try samples.compactMapIntoResourceProxies()
        let values: [Double] = resources.compactMap { resource in
            guard let observation = resource.get(if: Observation.self) else {
                return nil
            }
            switch observation.value {
            case .quantity(let quantity):
                return quantity.value?.value?.decimal.doubleValue
            default:
                return nil
            }
        }
        #expect(values.map(\.bitPattern) == [Double.nan, .nan, 0, 0].map(\.bitPattern))
    }
    
    @Test
    func collectionSampleToResourceProxy() throws {
        func makeSample(numSteps: Int, date: DateComponents) throws -> HKQuantitySample {
            let date = try #require(Calendar.current.date(from: date))
            return HKQuantitySample(
                type: HKQuantityType(.stepCount),
                quantity: HKQuantity(unit: .count(), doubleValue: Double(numSteps)),
                start: date,
                end: date
            )
        }
        let samples = [
            try makeSample(numSteps: 12, date: .init(year: 2025, month: 1, day: 1, hour: 0)),
            try makeSample(numSteps: 13, date: .init(year: 2025, month: 1, day: 1, hour: 1)),
            try makeSample(numSteps: 14, date: .init(year: 2025, month: 1, day: 1, hour: 2)),
            try makeSample(numSteps: 15, date: .init(year: 2025, month: 1, day: 1, hour: 3)),
            try makeSample(numSteps: 16, date: .init(year: 2025, month: 1, day: 1, hour: 4)),
            try makeSample(numSteps: 17, date: .init(year: 2025, month: 1, day: 1, hour: 5))
        ]
        let resources = try samples.mapIntoResourceProxies()
        #expect(resources.count == samples.count)
        for resource in resources {
            #expect(resource.get(if: Observation.self) != nil)
        }
    }
    
    // need to find a new unsupported type
//    @Test
//    func collectionSampleToResourceProxyWithUnsupportedSample() throws {
//        func makeSample(numSteps: Int, date: DateComponents) throws -> HKQuantitySample {
//            let date = try #require(Calendar.current.date(from: date))
//            return HKQuantitySample(
//                type: HKQuantityType(.stepCount),
//                quantity: HKQuantity(unit: .count(), doubleValue: Double(numSteps)),
//                start: date,
//                end: date
//            )
//        }
//        let samples = [
//            try makeSample(numSteps: 12, date: .init(year: 2025, month: 1, day: 1, hour: 0)),
//            try makeSample(numSteps: 13, date: .init(year: 2025, month: 1, day: 1, hour: 1)),
//            try makeSample(numSteps: 14, date: .init(year: 2025, month: 1, day: 1, hour: 2)),
//            try makeSample(numSteps: 15, date: .init(year: 2025, month: 1, day: 1, hour: 3)),
//            try makeSample(numSteps: 16, date: .init(year: 2025, month: 1, day: 1, hour: 4)),
//            try makeSample(numSteps: 17, date: .init(year: 2025, month: 1, day: 1, hour: 5)),
//            HKQuantitySample(type: HKQuantityType(.nikeFuel), quantity: HKQuantity(unit: .count(), doubleValue: 123), start: .now, end: .now)
//        ]
//        #expect(throws: SpeziHealthKitFHIRError.self) {
//            try samples.mapIntoResourceProxies()
//        }
//        let resources = try samples.compactMapIntoResourceProxies()
//        #expect(resources.count == samples.count - 1)
//        for resource in resources {
//            #expect(resource.get(if: Observation.self) != nil)
//        }
//    }
    
    @Test
    func absoluteTimeRangeStoredInExtension() throws {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .gmt
        let startDate = try #require(cal.date(from: .init(year: 1970, month: 1, day: 1, hour: 0, minute: 0, second: 0)))
        let endDate = try #require(cal.date(from: .init(year: 1970, month: 1, day: 1, hour: 0, minute: 15, second: 0)))
        
        let observation1 = try createObservationFrom(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 42),
            timeRange: startDate..<endDate,
            extensions: []
        )
        do {
            let extensions = try #require(observation1.extension)
            #expect(extensions.count == 1)
            #expect(extensions.map(\.url) == [FHIRExtensionURL.sourceRevision.r4])
        }
        
        let observation2 = try createObservationFrom(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 42),
            timeRange: startDate..<endDate,
            extensions: [.includeAbsoluteTimeRange]
        )
        do {
            let extensions = try #require(observation2.extension)
            #expect(extensions.count == 3)
            #expect(Set(extensions.map(\.url)) == [
                FHIRExtensionURL.sourceRevision.r4, FHIRExtensionURL.absoluteTimeRangeStart.r4, FHIRExtensionURL.absoluteTimeRangeEnd.r4
            ])
            #expect(extensions.contains(Extension(url: FHIRExtensionURL.absoluteTimeRangeStart.r4, value: .decimal(0.asFHIRDecimalPrimitive()))))
            #expect(extensions.contains(Extension(url: FHIRExtensionURL.absoluteTimeRangeEnd.r4, value: .decimal(900.asFHIRDecimalPrimitive()))))
        }
    }
    
    @Test
    func sampleSourceInfo() throws {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .gmt
        let startDate = try #require(cal.date(from: .init(year: 1970, month: 1, day: 1, hour: 0, minute: 0, second: 0)))
        let endDate = try #require(cal.date(from: .init(year: 1970, month: 1, day: 1, hour: 0, minute: 15, second: 0)))
        let device = HKDevice(
            name: "Cerebral Activity Modulator",
            manufacturer: "Lukas Industries",
            model: "A1000",
            hardwareVersion: "X12/49",
            firmwareVersion: "2.1.4",
            softwareVersion: "1.7.9",
            localIdentifier: UUID().uuidString,
            udiDeviceIdentifier: nil
        )
        let observation = try createObservationFrom(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 42),
            timeRange: startDate..<endDate,
            device: device,
            extensions: []
        )
        let extensions = try #require(observation.extension)
        #expect(extensions.count == 2)
        #expect(Set(extensions.map(\.url)) == [FHIRExtensionURL.sourceRevision.r4, FHIRExtensionURL.sourceDevice.r4])
        let deviceExtension = try #require(extensions.first { $0.url == FHIRExtensionURL.sourceDevice.r4 })
        _ = try #require(extensions.first { $0.url == FHIRExtensionURL.sourceRevision.r4 })
        
        try checkProperty(in: deviceExtension, ["name"], value: device.name.map { .string($0.asFHIRStringPrimitive()) })
        try checkProperty(in: deviceExtension, ["manufacturer"], value: device.manufacturer.map { .string($0.asFHIRStringPrimitive()) })
        try checkProperty(in: deviceExtension, ["model"], value: device.model.map { .string($0.asFHIRStringPrimitive()) })
        try checkProperty(in: deviceExtension, ["hardwareVersion"], value: device.hardwareVersion.map { .string($0.asFHIRStringPrimitive()) })
        try checkProperty(in: deviceExtension, ["firmwareVersion"], value: device.firmwareVersion.map { .string($0.asFHIRStringPrimitive()) })
        try checkProperty(in: deviceExtension, ["softwareVersion"], value: device.softwareVersion.map { .string($0.asFHIRStringPrimitive()) })
        try checkProperty(in: deviceExtension, ["localIdentifier"], value: device.localIdentifier.map { .string($0.asFHIRStringPrimitive()) })
        try checkProperty(in: deviceExtension, ["udiDeviceIdentifier"], value: device.udiDeviceIdentifier.map { .string($0.asFHIRStringPrimitive()) })
        
        // can't unit-test the encoding of the source revision into the extensions,
        // since HKSamples only have a source revision once they're saved to HealthKit, which we can't do here.
    }
    
    
    @Test
    func sampleMetadataExtension() throws {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .gmt
        let startDate = try #require(cal.date(from: .init(year: 1970, month: 1, day: 1, hour: 0, minute: 0, second: 0)))
        let endDate = try #require(cal.date(from: .init(year: 1970, month: 1, day: 1, hour: 0, minute: 15, second: 0)))
        let metadataExternalUUID = UUID()
        let metadataTimeZone = TimeZone.current
        let metadataWeather = HKWeatherCondition.snow
        let observation = try createObservationFrom(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 42),
            timeRange: startDate..<endDate,
            metadata: [
                HKMetadataKeyExternalUUID: metadataExternalUUID.uuidString,
                HKMetadataKeyTimeZone: metadataTimeZone.identifier,
                HKMetadataKeyWeatherCondition: NSNumber(value: metadataWeather.rawValue)
            ]
        )
        let extensions = try #require(observation.extension)
        #expect(extensions.count == 2)
        #expect(Set(extensions.compactMap(\.url)) == [FHIRExtensionURL.metadata.r4, FHIRExtensionURL.sourceRevision.r4])
        let metadataExtension = try #require(extensions.first { $0.url == FHIRExtensionURL.metadata.r4 })
        
        try checkProperty(
            in: metadataExtension,
            [HKMetadataKeyExternalUUID],
            value: .string(metadataExternalUUID.uuidString.asFHIRStringPrimitive())
        )
        try checkProperty(
            in: metadataExtension,
            [HKMetadataKeyTimeZone],
            value: .string(metadataTimeZone.identifier.asFHIRStringPrimitive())
        )
        try checkProperty(
            in: metadataExtension,
            [HKMetadataKeyWeatherCondition],
            value: .coding(Coding(
                code: "12".asFHIRStringPrimitive(),
                display: "snow",
                system: "https://developer.apple.com/documentation/healthkit/hkweathercondition".asFHIRURIPrimitive()
            ))
        )
        
        // can't unit-test the encoding of the source revision into the extensions,
        // since HKSamples only have a source revision once they're saved to HealthKit, which we can't do here.
    }
}


// MARK: Utils

func checkProperty(
    in parentExtension: Extension,
    _ path: some Collection<String>,
    value expectedValue: Extension.ValueX?,
    loc: SourceLocation = #_sourceLocation
) throws {
    guard let name = path.first else {
        Issue.record("Empty path")
        return
    }
    let url: ModelsR4.FHIRPrimitive = try #require(parentExtension.url.value).url.appending(component: name).asFHIRURIPrimitive()
    guard let ext = parentExtension.extension?.first(where: { $0.url == url }) else {
        if expectedValue != nil {
            Issue.record("Unable to find extension for \(try #require(url.value?.url).absoluteString)")
        }
        return
    }
    guard path.count == 1 else {
        try checkProperty(in: ext, path.dropFirst(), value: expectedValue, loc: loc)
        return
    }
    let value = try #require(ext.value)
    #expect(value == expectedValue, sourceLocation: loc)
}
