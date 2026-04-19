//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import HealthKit
public import ModelsR4


extension HKSampleType {
    private static let fhirObservationMappedTypes: [HKSampleType.Type] = {
        var types = [
            HKQuantityType.self, HKCorrelationType.self, HKCategoryType.self, HKElectrocardiogramType.self, HKWorkoutType.self
        ]
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            types.append(HKStateOfMindType.self)
        }
        return types
    }()
    
    
    /// The sample type's corresponding FHIR resource type, if supported.
    public var fhirResourceType: ResourceType? {
        if self is HKClinicalType {
            switch HKClinicalTypeIdentifier(rawValue: self.identifier) {
            case .allergyRecord:
                .allergyIntolerance
            case .conditionRecord:
                .condition
            case .coverageRecord:
                .coverage
            case .immunizationRecord:
                .immunization
            case .labResultRecord:
                .observation
            case .medicationRecord:
                .medication
            case .procedureRecord:
                .procedure
            case .vitalSignRecord:
                .observation
            default:
                nil
            }
        } else {
            Self.fhirObservationMappedTypes.contains { self.isKind(of: $0) } ? .observation : nil
        }
    }
}
