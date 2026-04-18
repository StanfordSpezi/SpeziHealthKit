//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import ModelsR4
public import SpeziHealthKit


public typealias CorrelationTypesFHIRMapping = [SampleType<HKCorrelation>: CorrelationTypeFHIRMapping]


public struct CorrelationTypeFHIRMapping: Hashable, Sendable {
    public let codings: [Coding]
    public let categories: [Coding]
    
    public init(codings: [Coding], categories: [Coding]) {
        self.codings = codings
        self.categories = categories
    }
}


extension CorrelationTypesFHIRMapping {
    public static let `default`: Self = [
        .bloodPressure: CorrelationTypeFHIRMapping(
            codings: [
                Coding(
                    code: "85354-9",
                    display: "Blood pressure panel",
                    system: "http://loinc.org"
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
