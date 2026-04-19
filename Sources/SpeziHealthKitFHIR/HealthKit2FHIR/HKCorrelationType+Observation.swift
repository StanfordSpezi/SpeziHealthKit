//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import ModelsR4
import SpeziHealthKit


extension HKCorrelation: FHIRObservationBuildable {
    func build(_ observation: inout Observation, mapping: SampleTypesFHIRMapping) throws {
        guard let sampleType = SampleType(self.correlationType) else {
            preconditionFailure() // TODO msg
        }
        guard let mapping = mapping.correlationTypesMapping[sampleType] else {
            throw HealthKitOnFHIRError.notSupported
        }
        observation.append(codings: mapping.codings)
        for category in mapping.categories {
            observation.append(
                category: CodeableConcept(coding: [category])
            )
        }
        for object in self.objects {
            guard let sample = object as? HKQuantitySample else {
                throw HealthKitOnFHIRError.notSupported
            }
            guard let sampleType = SampleType(sample.quantityType) else {
                preconditionFailure() // TODO msg
            }
            observation.append(component: try sample.quantity.buildObservationComponent(for: sampleType))
        }
    }
}
