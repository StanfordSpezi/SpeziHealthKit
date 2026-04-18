//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziHealthKit


/// A ``HKSampleMapping`` instance is used to specify the mapping of `HKSample`s to FHIR observations allowing the customization of, e.g., codings and units.
public struct HKSampleMapping: Decodable, Sendable {
    private enum CodingKeys: String, CodingKey {
        case quantitySample = "HKQuantitySample"
        case categorySample = "HKCategorySample"
        case correlation = "HKCorrelation"
        case electrocardiogram = "HKElectrocardiogram"
        case workoutSample = "HKWorkout"
        case stateOfMind = "HKStateOfMind"
    }
    
    
    /// A default instance of an ``HKSampleMapping`` instance allowing developers to customize the ``HKSampleMapping``.
    ///
    /// The default values are loaded from the `HKSampleMapping.json` resource in the ``HealthKitOnFHIR`` Swift Package.
    public static let `default`: HKSampleMapping = {
        let empty = HKSampleMapping(
            quantitySampleMapping: [:],
            categorySampleMapping: [:],
            correlationMapping: [:],
            electrocardiogramMapping: .init(
                codings: [],
                categories: [],
                classification: .init(codings: []),
                symptomsStatus: .init(codings: []),
                numberOfVoltageMeasurements: .init(codings: [], unit: .init(hkunit: .count(), unit: "count")),
                samplingFrequency: .init(codings: [], unit: .init(hkunit: .hertz(), unit: "Hz")),
                averageHeartRate: .init(codings: [], unit: .init(hkunit: .count() / .minute(), unit: "bpm")),
                voltageMeasurements: .init(codings: [], unit: .init(hkunit: .hertz(), unit: "Hz")),
                voltagePrecision: 0
            ),
            workoutSampleMapping: .init(codings: [], categories: []),
            stateOfMindMapping: .init(
                codings: [],
                categories: [],
                kind: .init(codings: []),
                valence: .init(codings: []),
                valenceClassification: .init(codings: []),
                label: .init(codings: []),
                association: .init(codings: [])
            )
        )
        guard let url = Bundle.module.url(forResource: "HKSampleMapping", withExtension: "json") else {
            print("Unable to find default \(Self.self). Falling back to empty mapping.")
            return empty
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            print("Error loading default \(Self.self). Falling back to empty mapping.")
            return empty
        }
    }()
    
    
    /// The mapping of `HKQuantityType`s to FHIR `Observation`s.
    public var quantitySampleMapping: [HKQuantityType: HKQuantitySampleMapping]
    
    /// The mapping of `HKCategoryType`s to FHIR `Observation`s.
    public var categorySampleMapping: [HKCategoryType: HKCategorySampleMapping]
    
    /// The mapping of `HKCorrelationType`s to FHIR `Observation`s.
    public var correlationMapping: [HKCorrelationType: HKCorrelationMapping]
    
    /// The mapping of `HKElectrocardiogramMapping`s to FHIR `Observation`s.
    public var electrocardiogramMapping: HKElectrocardiogramMapping
    
    /// The mapping of  `HKWorkout`s to FHIR `Observation`s.
    public var workoutSampleMapping: HKWorkoutSampleMapping
    
    /// The mapping of  `HKStateOfMind` samples to FHIR `Observation`s.
    public var stateOfMindMapping: HKStateOfMindMapping

    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        func imp<S: _HKSampleTypeWithIdentifierType, M: Decodable>(
            sampleType: S.Type,
            mappingType: M.Type,
            makeSampleType: (S._Identifier) -> S,
            key: CodingKeys
        ) throws -> [S: M] {
            let stringBasedSampleMapping = try container.decode(
                [String: M].self,
                forKey: key
            )
            return stringBasedSampleMapping.reduce(into: [:]) { result, mapping in
                let sampleType = makeSampleType(S._Identifier(rawValue: mapping.key))
                result[sampleType] = mapping.value
            }
        }
        
        self.init(
            quantitySampleMapping: try imp(sampleType: HKQuantityType.self, mappingType: HKQuantitySampleMapping.self, makeSampleType: HKQuantityType.init, key: .quantitySample),
            categorySampleMapping: try imp(sampleType: HKCategoryType.self, mappingType: HKCategorySampleMapping.self, makeSampleType: HKCategoryType.init, key: .categorySample),
            correlationMapping: try imp(sampleType: HKCorrelationType.self, mappingType: HKCorrelationMapping.self, makeSampleType: HKCorrelationType.init, key: .correlation),
            electrocardiogramMapping: try container.decode(HKElectrocardiogramMapping.self, forKey: .electrocardiogram),
            workoutSampleMapping: try container.decode(HKWorkoutSampleMapping.self, forKey: .workoutSample),
            stateOfMindMapping: try container.decode(HKStateOfMindMapping.self, forKey: .stateOfMind)
        )
    }
    
    /// A ``HKSampleMapping`` instance is used to specify the mapping of `HKSample`s to FHIR observations allowing the customization of, e.g., codings and units.
    /// - Parameters:
    ///   - quantitySampleMapping: The mapping of `HKQuantityType`s to FHIR Observations.
    ///   - categorySampleMapping: The mapping of `HKCategoryType`s to FHIR `Observation`s.
    ///   - correlationMapping: The mapping of `HKCorrelationType`s to FHIR Observations.
    ///   - workoutSampleMapping: The mapping of  `HKWorkout`s to FHIR `Observation`s.
    ///   - electrocardiogramMapping: The mapping of `HKElectrocardiogramMapping`s to FHIR `Observation`s.
    ///   - stateOfMindMapping: The mapping of `HKStateOfMind` samples to FHIR `Observation`s.
    public init(
        quantitySampleMapping: [HKQuantityType: HKQuantitySampleMapping] = Self.default.quantitySampleMapping,
        categorySampleMapping: [HKCategoryType: HKCategorySampleMapping] = Self.default.categorySampleMapping,
        correlationMapping: [HKCorrelationType: HKCorrelationMapping] = Self.default.correlationMapping,
        electrocardiogramMapping: HKElectrocardiogramMapping = Self.default.electrocardiogramMapping,
        workoutSampleMapping: HKWorkoutSampleMapping = Self.default.workoutSampleMapping,
        stateOfMindMapping: HKStateOfMindMapping = Self.default.stateOfMindMapping
    ) {
        self.quantitySampleMapping = quantitySampleMapping
        self.categorySampleMapping = categorySampleMapping
        self.correlationMapping = correlationMapping
        self.electrocardiogramMapping = electrocardiogramMapping
        self.workoutSampleMapping = workoutSampleMapping
        self.stateOfMindMapping = stateOfMindMapping
    }
}
