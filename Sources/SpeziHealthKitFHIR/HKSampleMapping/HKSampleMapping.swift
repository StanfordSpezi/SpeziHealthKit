//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// A ``HKSampleMapping`` instance is used to specify the mapping of `HKSample`s to FHIR observations allowing the customization of, e.g., codings and units.
public struct HKSampleMapping: Decodable, Sendable {
    private enum CodingKeys: String, CodingKey {
        case quantitySampleMapping = "HKQuantitySamples"
        case categorySampleMapping = "HKCategorySamples"
        case correlationMapping = "HKCorrelations"
        case electrocardiogramMapping = "HKElectrocardiogram"
        case workoutSampleMapping = "HKWorkout"
        case stateOfMindMapping = "HKStateOfMind"
    }
    
    
    /// A default instance of an ``HKSampleMapping`` instance allowing developers to customize the ``HKSampleMapping``.
    ///
    /// The default values are loaded from the `HKSampleMapping.json` resource in the ``HealthKitOnFHIR`` Swift Package.
    public static let `default`: HKSampleMapping = {
        Bundle.module.decode(HKSampleMapping.self, from: "HKSampleMapping.json")
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
        let mappings = try decoder.container(keyedBy: CodingKeys.self)
        let quantityStringBasedSampleMapping = try mappings.decode(
            [String: HKQuantitySampleMapping].self,
            forKey: .quantitySampleMapping
        )
        let quantitySampleMapping = Dictionary(
            uniqueKeysWithValues: quantityStringBasedSampleMapping.map { mapping in
                guard let hkquantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: mapping.key)) else {
                    fatalError("HKQuantityType for the String value \(mapping.key) does not exist. Please inspect your configuration.")
                }
                return (hkquantityType, mapping.value)
            }
        )

        let categoryStringBasedSampleMapping = try mappings.decode(
            [String: HKCategorySampleMapping].self,
            forKey: .categorySampleMapping
        )

        let categorySampleMapping = Dictionary(
            uniqueKeysWithValues: categoryStringBasedSampleMapping.map { mapping in
                guard let hkcategorytype = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: mapping.key)) else {
                    fatalError("HKCategoryType for the String value \(mapping.key) does not exist. Please inspect your configuration.")
                }
                return (hkcategorytype, mapping.value)
            }
        )
        
        let correlationStringBasedMapping = try mappings.decode(
            [String: HKCorrelationMapping].self,
            forKey: .correlationMapping
        )
        
        let correlationMapping = Dictionary(
            uniqueKeysWithValues: correlationStringBasedMapping.map { mapping in
                let hkcorrelationTypeIdentifier = HKCorrelationTypeIdentifier(rawValue: mapping.key)
                guard let hkcorrelationType = HKCorrelationType.correlationType(forIdentifier: hkcorrelationTypeIdentifier) else {
                    fatalError("HKCorrelationType for the String value \(mapping.key) does not exist. Please inspect your configuration.")
                }
                return (hkcorrelationType, mapping.value)
            }
        )
        
        let electrocardiogramMapping = try mappings.decode(HKElectrocardiogramMapping.self, forKey: .electrocardiogramMapping)
        let workoutSampleMapping = try mappings.decode(HKWorkoutSampleMapping.self, forKey: .workoutSampleMapping)
        let stateOfMindMapping = try mappings.decode(HKStateOfMindMapping.self, forKey: .stateOfMindMapping)

        self.init(
            quantitySampleMapping: quantitySampleMapping,
            categorySampleMapping: categorySampleMapping,
            correlationMapping: correlationMapping,
            electrocardiogramMapping: electrocardiogramMapping,
            workoutSampleMapping: workoutSampleMapping,
            stateOfMindMapping: stateOfMindMapping
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
        quantitySampleMapping: [HKQuantityType: HKQuantitySampleMapping] = HKQuantitySampleMapping.default,
        categorySampleMapping: [HKCategoryType: HKCategorySampleMapping] = HKCategorySampleMapping.default,
        correlationMapping: [HKCorrelationType: HKCorrelationMapping] = HKCorrelationMapping.default,
        electrocardiogramMapping: HKElectrocardiogramMapping = .default,
        workoutSampleMapping: HKWorkoutSampleMapping = .default,
        stateOfMindMapping: HKStateOfMindMapping = .default
    ) {
        self.quantitySampleMapping = quantitySampleMapping
        self.categorySampleMapping = categorySampleMapping
        self.correlationMapping = correlationMapping
        self.electrocardiogramMapping = electrocardiogramMapping
        self.workoutSampleMapping = workoutSampleMapping
        self.stateOfMindMapping = stateOfMindMapping
    }
}
