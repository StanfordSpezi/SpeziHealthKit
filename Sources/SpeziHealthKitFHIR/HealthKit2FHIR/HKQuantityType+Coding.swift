//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

import Foundation
import HealthKit
import ModelsR4
import SpeziHealthKit


extension HKQuantityType {
    /// Converts an `HKQuantityType` into corresponding FHIR Coding(s) based on a specified mapping
    func codes(
        mapping: QuantityTypesFHIRMapping = .default
    ) -> [Coding] {
        guard let sampleType = self.sampleType as? SampleType<HKQuantitySample> else {
            return []
        }
        guard let mapping = mapping[sampleType] else {
            return []
        }
        return mapping.codings
    }
}

#endif
