//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import FHIRModelsExtensions
import HealthKit
import ModelsR4
import SpeziHealthKit


extension HKQuantitySample: FHIRObservationBuildable {
    func build(_ observation: inout Observation, mapping: SampleTypesFHIRMapping) throws {
        guard let quantityType = SampleType(self.quantityType) else {
            preconditionFailure("Missing \(self.quantityType)")
        }
        guard let mapping = mapping.quantityTypesMapping[quantityType] else {
            throw HealthKitOnFHIRError.notSupported
        }
        observation.append(codings: mapping.codings)
        observation.value = .quantity(try quantity.buildQuantity(mapping: mapping))
    }
}


extension HKQuantity {
    func buildObservationComponent(
        for quantityType: SampleType<HKQuantitySample>,
        mappings: QuantityTypesFHIRMapping = .default
    ) throws -> ObservationComponent {
        guard let mapping = mappings[quantityType] else {
            throw HealthKitOnFHIRError.notSupported
        }
        return try buildObservationComponent(mapping: mapping)
    }
    
    func buildObservationComponent(mapping: QuantityTypeFHIRMapping) throws -> ObservationComponent {
        ObservationComponent(
            code: CodeableConcept(coding: mapping.codings),
            value: .quantity(try buildQuantity(mapping: mapping))
        )
    }
    
    func buildQuantity(mapping: QuantityTypeFHIRMapping) throws -> Quantity {
        Quantity(
            code: mapping.unit.code,
            system: mapping.unit.system,
            unit: mapping.unit.unit.asFHIRStringPrimitive(),
            value: try self.doubleValue(for: mapping.unit.hkUnit).asFHIRDecimalPrimitiveSafe()
        )
    }
}
