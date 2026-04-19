//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import FHIRModelsExtensions
import Foundation
public import HealthKit
import ModelsR4


extension FHIRExtensionBuilderProtocol where Self == FHIRExtensionBuilder<HKSample> {
    /// A FHIR Extension Builder that writes the absolute time range (i.e., start and end date) of a HealthKit sample into a FHIR `Observation` created from the sample.
    public static var includeAbsoluteTimeRange: FHIRExtensionBuilder<HKSample> {
        .init { (sample: HKSample, observation) in
            let timeRangeExtensions = [
                Extension(
                    url: .absoluteTimeRangeStart,
                    value: .decimal(sample.startDate.timeIntervalSince1970.asFHIRDecimalPrimitive())
                ),
                Extension(
                    url: .absoluteTimeRangeEnd,
                    value: .decimal(sample.endDate.timeIntervalSince1970.asFHIRDecimalPrimitive())
                )
            ]
            observation.append(extensions: timeRangeExtensions, behaviour: .replace)
        }
    }
}
