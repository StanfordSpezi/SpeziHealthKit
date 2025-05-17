//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@testable import SpeziHealthKit
import Testing


@Suite
struct SampleTypesTests {
    @Test
    func isSampleType() {
        let quantitySample = HKQuantitySample(
            type: HKQuantityType(.activeEnergyBurned),
            quantity: HKQuantity(unit: .largeCalorie(), doubleValue: 128),
            start: .now,
            end: .now
        )
        #expect(quantitySample.is(.activeEnergyBurned))
        #expect(!quantitySample.is(.sleepAnalysis))
        #expect(!quantitySample.is(.bloodPressure))
        
        let categorySample = HKCategorySample(
            type: HKCategoryType(.sleepAnalysis),
            value: HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            start: .now,
            end: .now
        )
        #expect(quantitySample.is(.sleepAnalysis))
        #expect(!quantitySample.is(.activeEnergyBurned))
        #expect(!quantitySample.is(.bloodPressure))
        
        let correlation = HKCorrelation(
            type: HKCorrelationType(.bloodPressure),
            start: .now,
            end: .now,
            objects: [
                HKQuantitySample(
                    type: HKQuantityType(.bloodPressureSystolic),
                    quantity: HKQuantity(unit: .millimeterOfMercury(), doubleValue: 420),
                    start: .now,
                    end: .now
                ),
                HKQuantitySample(
                    type: HKQuantityType(.bloodPressureDiastolic),
                    quantity: HKQuantity(unit: .millimeterOfMercury(), doubleValue: 69),
                    start: .now,
                    end: .now
                )
            ]
        )
        #expect(correlation.is(.bloodPressure))
        #expect(!correlation.is(.activeEnergyBurned))
        #expect(!correlation.is(.sleepAnalysis))
    }
}
