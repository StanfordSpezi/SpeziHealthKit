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


extension HKQuantitySample: FHIRObservationBuildable {
    func build(_ observation: inout Observation, mapping: HKSampleMapping) throws {
        guard let mapping = mapping.quantitySampleMapping[self.quantityType] else {
            throw HealthKitOnFHIRError.notSupported
        }
        for code in mapping.codings {
            observation.append(coding: code.coding)
        }
        observation.value = .quantity(try quantity.buildQuantity(mapping: mapping))
    }
}


extension HKQuantity {
    func buildObservationComponent(
        for quantityType: HKQuantityType,
        mappings: [HKQuantityType: HKQuantitySampleMapping] = HKQuantitySampleMapping.default
    ) throws -> ObservationComponent {
        guard let mapping = mappings[quantityType] else {
            throw HealthKitOnFHIRError.notSupported
        }
        return try buildObservationComponent(mapping: mapping)
    }
    
    func buildObservationComponent(mapping: HKQuantitySampleMapping) throws -> ObservationComponent {
        ObservationComponent(
            code: CodeableConcept(coding: mapping.codings.map(\.coding)),
            value: .quantity(try buildQuantity(mapping: mapping))
        )
    }
    
    func buildQuantity(mapping: HKQuantitySampleMapping) throws -> Quantity {
        Quantity(
            code: mapping.unit.code?.asFHIRStringPrimitive(),
            system: mapping.unit.system?.asFHIRURIPrimitive(),
            unit: mapping.unit.unit.asFHIRStringPrimitive(),
            value: try self.doubleValue(for: mapping.unit.hkunit).asFHIRDecimalPrimitiveSafe()
        )
    }
}
