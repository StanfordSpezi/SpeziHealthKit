//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import ModelsR4


/// A HealthKit type that can be used to build up a FHIR `Observation`.
protocol FHIRObservationBuildable: HKSample {
    /// Populates the observation with the contents of the HealthKit sample.
    ///
    /// - throws: if the sample cannot be expressed as a FHIR Observation
    func build(_ observation: inout Observation, mapping: HKSampleMapping) throws
}
