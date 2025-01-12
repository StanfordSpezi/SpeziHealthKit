//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import SpeziFoundation


extension HKCorrelationType {
    public static let allKnownCorrelations: Set<HKCorrelationType> = Set(HKCorrelationTypeIdentifier.allKnownIdentifiers.map { HKCorrelationType($0) })
}

extension HKCorrelationTypeIdentifier {
    public static let allKnownIdentifiers: Set<Self> = [
        .bloodPressure,
        .food
    ]
    
    /// Returns the set of known associated `HKObjectType`s for the correlation identifier.
    /// This exists because, for e.g. blood pressure, you cannot request read access authorization to
    /// `HKCorrelationType(.bloodPressure)`, but instead need to request separate access to
    /// `HKQuantityType(.bloodPressureSystolic)` and `HKQuantityType(.bloodPressureDiastolic)`.
    @SetBuilder<HKObjectType>
    var knownAssociatedObjectTypes: Set<HKObjectType> {
        switch self {
        case .bloodPressure:
            HKQuantityType(.bloodPressureSystolic)
            HKQuantityType(.bloodPressureDiastolic)
        case .food:
            // As defined [here](https://developer.apple.com/documentation/healthkit/data_types/nutrition_type_identifiers)
            // Macronutrients
            HKQuantityType(.dietaryEnergyConsumed)
            HKQuantityType(.dietaryCarbohydrates)
            HKQuantityType(.dietaryFiber)
            HKQuantityType(.dietarySugar)
            HKQuantityType(.dietaryFatTotal)
            HKQuantityType(.dietaryFatMonounsaturated)
            HKQuantityType(.dietaryFatPolyunsaturated)
            HKQuantityType(.dietaryFatSaturated)
            HKQuantityType(.dietaryCholesterol)
            HKQuantityType(.dietaryProtein)
            // Vitamins
            HKQuantityType(.dietaryVitaminA)
            HKQuantityType(.dietaryThiamin)
            HKQuantityType(.dietaryRiboflavin)
            HKQuantityType(.dietaryNiacin)
            HKQuantityType(.dietaryPantothenicAcid)
            HKQuantityType(.dietaryVitaminB6)
            HKQuantityType(.dietaryBiotin)
            HKQuantityType(.dietaryVitaminB12)
            HKQuantityType(.dietaryVitaminC)
            HKQuantityType(.dietaryVitaminD)
            HKQuantityType(.dietaryVitaminE)
            HKQuantityType(.dietaryVitaminK)
            HKQuantityType(.dietaryFolate)
            // Minerals
            HKQuantityType(.dietaryCalcium)
            HKQuantityType(.dietaryChloride)
            HKQuantityType(.dietaryIron)
            HKQuantityType(.dietaryMagnesium)
            HKQuantityType(.dietaryPhosphorus)
            HKQuantityType(.dietaryPotassium)
            HKQuantityType(.dietarySodium)
            HKQuantityType(.dietaryZinc)
            // Hydration
            HKQuantityType(.dietaryWater)
            // Caffeination
            HKQuantityType(.dietaryCaffeine)
            // Ultratrace Minerals
            HKQuantityType(.dietaryChromium)
            HKQuantityType(.dietaryCopper)
            HKQuantityType(.dietaryIodine)
            HKQuantityType(.dietaryManganese)
            HKQuantityType(.dietaryMolybdenum)
            HKQuantityType(.dietarySelenium)
        default:
            let _ = ()
        }
    }
}
