//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi
import SwiftUI


extension HKElectrocardiogram {
    /// A type alias used to associate symptoms in an `HKElectrocardiogram`.
    public typealias Symptoms = [HKCategoryType: HKCategoryValueSeverity]
    /// A type alias used to associate voltage measurements in an `HKElectrocardiogram`.
    public typealias VoltageMeasurements = [(TimeInterval, HKQuantity)]
    
    
    /// All possible `HKCategoryType`s (`HKCategoryTypeIdentifier`s) that can be associated with an `HKElectrocardiogram`.
    public static let correlatedSymptomTypes: [HKCategoryType] = [
        HKCategoryType(.rapidPoundingOrFlutteringHeartbeat),
        HKCategoryType(.skippedHeartbeat),
        HKCategoryType(.fatigue),
        HKCategoryType(.shortnessOfBreath),
        HKCategoryType(.chestTightnessOrPain),
        HKCategoryType(.fainting),
        HKCategoryType(.dizziness)
    ]
    
    
    /// Load the symptoms of an `HKElectrocardiogram` instance from an `HKHealthStore` instance.
    /// - Parameter healthStore: The `HKHealthStore` instance that should be used to load the `Symptoms`.
    /// - Returns: The symptoms associated with an `HKElectrocardiogram`.
    public func symptoms(from healthStore: HKHealthStore) async throws -> Symptoms {
        switch symptomsStatus {
        case .present:
            // TODO ideally, the auth reques should be moved out of here!!!
            // instead, have it run as part of the HealthKit config step?!
            try await healthStore.requestAuthorization(toShare: [], read: Set(HKElectrocardiogram.correlatedSymptomTypes))
            let predicate = HKQuery.predicateForObjectsAssociated(electrocardiogram: self)
            return try await HKElectrocardiogram.correlatedSymptomTypes.reduce(into: Symptoms()) { symptoms, categoryType in
                if let sample = try await healthStore.sampleQuery(for: categoryType, withPredicate: predicate).first,
                   let sample = sample as? HKCategorySample {
                    symptoms[sample.categoryType] = HKCategoryValueSeverity(rawValue: sample.value)
                }
            }
        case .none, .notSet:
            fallthrough
        @unknown default:
            return [:]
        }
    }
    
    /// Load the voltage measurements of an `HKElectrocardiogram` instance from an `HKHealthStore` instance.
    /// - Parameter healthStore: The `HKHealthStore` instance that should be used to load the `VoltageMeasurements`.
    /// - Returns: The voltage measurements associated with an `HKElectrocardiogram`.
    public func voltageMeasurements(from healthStore: HKHealthStore) async throws -> VoltageMeasurements {
        let electrocardiogramQueryDescriptor = HKElectrocardiogramQueryDescriptor(self)
        var voltageMeasurements: VoltageMeasurements = []
        voltageMeasurements.reserveCapacity(numberOfVoltageMeasurements)
        for try await measurement in electrocardiogramQueryDescriptor.results(for: healthStore) {
            if let voltageQuantity = measurement.quantity(for: .appleWatchSimilarToLeadI) {
                voltageMeasurements.append((measurement.timeSinceSampleStart, voltageQuantity))
            }
        }
        return voltageMeasurements
    }
}
