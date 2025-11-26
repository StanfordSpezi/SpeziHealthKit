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
    
    /// A single voltage measurement in an `HKElectrocardiogram`.
    public struct Measurement: Hashable, Sendable {
        /// The time of the measurement relative to the sample’s start time.
        public let timeOffset: TimeInterval
        /// The voltage as determined by the Apple Watch sensor, similar to a Lead I ECG.
        public let voltage: HKQuantity
    }
    
    /// All possible `HKCategoryType`s (`HKCategoryTypeIdentifier`s) that can be associated with an `HKElectrocardiogram`.
    public static let correlatedSymptomTypes: [SampleType<HKCategorySample>] = [
        .rapidPoundingOrFlutteringHeartbeat,
        .skippedHeartbeat,
        .fatigue,
        .shortnessOfBreath,
        .chestTightnessOrPain,
        .fainting,
        .dizziness
    ]
    
    
    /// Load the symptoms of an `HKElectrocardiogram` instance from an `HKHealthStore` instance.
    /// - Parameter healthKit: The ``HealthKit`` instance that should be used to load the `Symptoms`.
    /// - Returns: The symptoms associated with an `HKElectrocardiogram`.
    public func symptoms(from healthKit: HealthKit) async throws -> Symptoms {
        switch symptomsStatus {
        case .present:
            try await healthKit.askForAuthorization(for: .init(
                read: HKElectrocardiogram.correlatedSymptomTypes.map(\.hkSampleType)
            ))
            let predicate = HKQuery.predicateForObjectsAssociated(electrocardiogram: self)
            return try await HKElectrocardiogram.correlatedSymptomTypes.reduceAsync(into: Symptoms()) { symptoms, categoryType in
                if let sample = try await healthKit.query(categoryType, timeRange: .ever, predicate: predicate).first {
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
    public func voltageMeasurements(from healthStore: HKHealthStore) async throws -> [Measurement] {
        let queryDescriptor = HKElectrocardiogramQueryDescriptor(self)
        var measurements: [Measurement] = []
        measurements.reserveCapacity(numberOfVoltageMeasurements)
        for try await measurement in queryDescriptor.results(for: healthStore) {
            guard let voltage = measurement.quantity(for: .appleWatchSimilarToLeadI) else {
                continue
            }
            measurements.append(.init(
                timeOffset: measurement.timeSinceSampleStart,
                voltage: voltage
            ))
        }
        return measurements
    }
}
