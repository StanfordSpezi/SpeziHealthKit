//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

import AsyncAlgorithms
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
    /// - Returns: The electrocardiogram's associated symptoms
    public func symptoms(from healthKit: HealthKit) async throws -> Symptoms {
        switch symptomsStatus {
        case .present:
            try await healthKit.askForAuthorization(for: .init(
                read: HKElectrocardiogram.correlatedSymptomTypes.map(\.hkSampleType)
            ))
            #if swift(>=6.3)
            // SAFETY: the predicate doesn't use a block and therefore is Sendable.
            nonisolated(unsafe) let predicate = HKQuery.predicateForObjectsAssociated(electrocardiogram: self)
            #endif
            let symptoms: Symptoms = try await withThrowingTaskGroup(of: Symptoms.self) { taskGroup in
                for categoryType in HKElectrocardiogram.correlatedSymptomTypes {
                    taskGroup.addTask {
                        #if swift(>=6.3)
                        let predicate = predicate
                        #else
                        let predicate = HKQuery.predicateForObjectsAssociated(electrocardiogram: self)
                        #endif
                        let samples = try await healthKit.query(categoryType, timeRange: .ever, predicate: predicate)
                        guard let sample = samples.first, let value = HKCategoryValueSeverity(rawValue: sample.value) else {
                            return [:]
                        }
                        return [sample.categoryType: value]
                    }
                }
                return try await taskGroup.reduce(into: [:]) { result, symptoms in
                    for (key, value) in symptoms {
                        result[key] = value
                    }
                }
            }
            return symptoms
        case .none, .notSet:
            fallthrough
        @unknown default:
            return [:]
        }
    }
    
    
    /// Load the voltage measurements of an `HKElectrocardiogram` instance from an `HKHealthStore` instance.
    /// - Parameter healthStore: The `HKHealthStore` instance that should be used to load the `VoltageMeasurements`.
    /// - Returns: The electrocardiogram's associated voltage measurements
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

#endif
