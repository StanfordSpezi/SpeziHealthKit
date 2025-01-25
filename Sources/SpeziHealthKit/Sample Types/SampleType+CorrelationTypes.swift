//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


extension SampleType {
    /// The sample type representing blood pressure correlation samples
    @inlinable public static var bloodPressure: SampleType<HKCorrelation> {
        .correlation(
            .bloodPressure,
            displayTitle: "Blood Pressure",
            associatedQuantityTypes: [.bloodPressureDiastolic, .bloodPressureSystolic]
        )
    }
    
    /// Food correlation types combine any number of nutritional samples into a single food object.
    @inlinable public static var food: SampleType<HKCorrelation> {
        .correlation(.food, displayTitle: "Food", associatedQuantityTypes: [
            // As defined [here](https://developer.apple.com/documentation/healthkit/data_types/nutrition_type_identifiers)
            // Macronutrients
            .dietaryEnergyConsumed,
            .dietaryCarbohydrates,
            .dietaryFiber,
            .dietarySugar,
            .dietaryFatTotal,
            .dietaryFatMonounsaturated,
            .dietaryFatPolyunsaturated,
            .dietaryFatSaturated,
            .dietaryCholesterol,
            .dietaryProtein,
            // Vitamins
            .dietaryVitaminA,
            .dietaryThiamin,
            .dietaryRiboflavin,
            .dietaryNiacin,
            .dietaryPantothenicAcid,
            .dietaryVitaminB6,
            .dietaryBiotin,
            .dietaryVitaminB12,
            .dietaryVitaminC,
            .dietaryVitaminD,
            .dietaryVitaminE,
            .dietaryVitaminK,
            .dietaryFolate,
            // Minerals
            .dietaryCalcium,
            .dietaryChloride,
            .dietaryIron,
            .dietaryMagnesium,
            .dietaryPhosphorus,
            .dietaryPotassium,
            .dietarySodium,
            .dietaryZinc,
            // Hydration
            .dietaryWater,
            // Caffeination
            .dietaryCaffeine,
            // Ultratrace Minerals
            .dietaryChromium,
            .dietaryCopper,
            .dietaryIodine,
            .dietaryManganese,
            .dietaryMolybdenum,
            .dietarySelenium
        ])
    }
}
