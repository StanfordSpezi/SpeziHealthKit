//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import ModelsR4


@available(watchOS, unavailable)
extension HKClinicalRecord {
    /// Converts an `HKClinicalRecord` into a corresponding FHIR resource, encapsulated in a `ResourceProxy`
    func resource() throws -> ResourceProxy {
        guard let fhirResource = self.fhirResource else {
            throw HealthKitOnFHIRError.invalidFHIRResource
        }
        guard fhirResource.fhirVersion == HKFHIRVersion.primaryR4() else {
            throw HealthKitOnFHIRError.unsupportedFHIRVersion
        }
        return try JSONDecoder().decode(ResourceProxy.self, from: fhirResource.data)
    }
}
