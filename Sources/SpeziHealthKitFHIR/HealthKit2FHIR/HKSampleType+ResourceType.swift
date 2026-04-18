//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import ModelsR4


extension HKSampleType {
    /// Converts an `HKSampleType` into the corresponding FHIR resource type, defined as a `ResourceType`
    public var resourceType: ResourceType {
        get throws {
            switch self {
            case is HKQuantityType, is HKCorrelationType, is HKCategoryType:
                return ResourceType.observation
            case let clinicalType as HKClinicalType:
                switch clinicalType {
                case HKClinicalType(.allergyRecord):
                    return ResourceType.allergyIntolerance
                case HKClinicalType(.conditionRecord):
                    return ResourceType.condition
                case HKClinicalType(.coverageRecord):
                    return ResourceType.coverage
                case HKClinicalType(.immunizationRecord):
                    return ResourceType.immunization
                case HKClinicalType(.labResultRecord):
                    return ResourceType.observation
                case HKClinicalType(.medicationRecord):
                    return ResourceType.medication
                case HKClinicalType(.procedureRecord):
                    return ResourceType.procedure
                case HKClinicalType(.vitalSignRecord):
                    return ResourceType.observation
                default:
                    throw HealthKitOnFHIRError.notSupported
                }
            default:
                throw HealthKitOnFHIRError.notSupported
            }
        }
    }
}
