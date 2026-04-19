//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import ModelsR4
@testable import SpeziHealthKitFHIR
import Testing


@Suite
struct HKCorrelationTests {
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

    @Test
    func bloodPressureCorrelation() throws {
        let systolicBloodPressure = HKQuantitySample(
            type: HKQuantityType(.bloodPressureSystolic),
            quantity: HKQuantity(unit: .millimeterOfMercury(), doubleValue: 120),
            start: try startDate,
            end: try endDate
        )

        let diastolicBloodPressure = HKQuantitySample(
            type: HKQuantityType(.bloodPressureDiastolic),
            quantity: HKQuantity(unit: .millimeterOfMercury(), doubleValue: 80),
            start: try startDate,
            end: try endDate
        )

        let correlation = HKCorrelation(
            type: HKCorrelationType(.bloodPressure),
            start: try startDate,
            end: try endDate,
            objects: [systolicBloodPressure, diastolicBloodPressure]
        )
        
        let observation = try #require(correlation.resource().get(if: Observation.self))

        #expect(1 == observation.component?.filter {
            $0.value == .quantity(
                Quantity(
                    code: "mm[Hg]",
                    system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                    unit: "mmHg",
                    value: 120.asFHIRDecimalPrimitive()
                )
            )
        }.count)

        #expect(1 == observation.component?.filter {
            $0.value == .quantity(
                Quantity(
                    code: "mm[Hg]",
                    system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
                    unit: "mmHg",
                    value: 80.asFHIRDecimalPrimitive()
                )
            )
        }.count)
    }

    @Test(.disabled())
    func unsupportedCorrelation() throws {
        // Food correlations are not currently supported
        let vitaminC = HKQuantitySample(
            type: HKQuantityType(.dietaryVitaminC),
            quantity: HKQuantity(unit: .gram(), doubleValue: 1),
            start: try startDate,
            end: try endDate
        )

        let correlation = HKCorrelation(
            type: HKCorrelationType(.food),
            start: try startDate,
            end: try endDate,
            objects: [vitaminC]
        )
        #expect(throws: HealthKitOnFHIRError.self) {
            try correlation.resource()
        }
    }
}
