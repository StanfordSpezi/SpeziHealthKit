//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

public import ModelsR4
public import SpeziHealthKit


/// Controls how `HKCorrelation` samples are mapped into FHIR Observations.
public typealias CorrelationTypesFHIRMapping = [SampleType<HKCorrelation>: CorrelationTypeFHIRMapping]


/// Controls how a `HKCorrelation` sample is mapped into a FHIR Observation.
///
/// ## Topics
///
/// ### Initializers
/// - ``init(codings:categories:)``
///
/// ### Instance Properties
/// - ``codings``
/// - ``categories``
public struct CorrelationTypeFHIRMapping: Sendable {
    public let codings: [Coding]
    public let categories: [Coding]
    
    public init(codings: [Coding], categories: [Coding]) {
        self.codings = codings
        self.categories = categories
    }
}


extension CorrelationTypesFHIRMapping {
    /// The default FHIR mapping for HealthKit Correlation types
    public static let `default`: Self = [
        .bloodPressure: CorrelationTypeFHIRMapping(
            codings: [
                Coding(
                    code: "35094-2",
                    display: "Blood pressure panel",
                    system: .loincSystem
                ),
                Coding(
                    code: "85354-9",
                    display: "Blood pressure panel with all children optional",
                    system: .loincSystem
                )
            ],
            categories: [
                Coding(
                    code: "vital-signs",
                    display: "Vital Signs",
                    system: "http://terminology.hl7.org/CodeSystem/observation-category"
                )
            ]
        )
    ]
}
