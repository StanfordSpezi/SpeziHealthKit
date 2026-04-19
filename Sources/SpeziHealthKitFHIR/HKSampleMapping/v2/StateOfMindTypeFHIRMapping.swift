//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import ModelsR4


/// Controls how `HKStateOfMind`s are mapped into FHIR Observations.
///
/// ## Topics
///
/// ### Static Properties
/// - ``default``
///
/// ### Initializers
/// - ``init(codings:categories:kind:valence:valenceClassification:label:association:)``
///
/// ### Instance Properties
/// - ``codings``
/// - ``categories``
/// - ``kind``
/// - ``valence``
/// - ``valenceClassification``
/// - ``label``
/// - ``association``
public struct StateOfMindTypeFHIRMapping: Hashable, Sendable {
    /// The FHIR codings defined as ``MappedCode``s to be used for `HKStateOfMind` samples
    public let codings: [Coding]
    /// The FHIR categories defined as ``MappedCode``s to be used for `HKStateOfMind` samples
    public let categories: [Coding]
    /// The mapping for a `HKStateOfMind` sample's kind.
    public let kind: CategoryTypeFHIRMapping
    /// The mapping for a `HKStateOfMind` sample's valence.
    public let valence: CategoryTypeFHIRMapping
    /// The mapping for a `HKStateOfMind` sample's valence classification.
    public let valenceClassification: CategoryTypeFHIRMapping
    /// The mapping for a `HKStateOfMind` sample's label.
    public let label: CategoryTypeFHIRMapping
    /// The mapping for a `HKStateOfMind` sample's association.
    public let association: CategoryTypeFHIRMapping
    
    public init(
        codings: [Coding],
        categories: [Coding],
        kind: CategoryTypeFHIRMapping,
        valence: CategoryTypeFHIRMapping,
        valenceClassification: CategoryTypeFHIRMapping,
        label: CategoryTypeFHIRMapping,
        association: CategoryTypeFHIRMapping
    ) {
        self.codings = codings
        self.categories = categories
        self.kind = kind
        self.valence = valence
        self.valenceClassification = valenceClassification
        self.label = label
        self.association = association
    }
}


extension StateOfMindTypeFHIRMapping {
    /// The default FHIR mapping for `HKStateOfMind` samples.
    public static let `default` = Self(
        codings: [
            Coding(
                code: "HKStateOfMind",
                display: "State of Mind",
                system: "http://developer.apple.com/documentation/healthkit"
            )
        ],
        categories: [
            Coding(
                code: "survey",
                display: "Survey",
                system: "http://terminology.hl7.org/CodeSystem/observation-category"
            )
        ],
        kind: CategoryTypeFHIRMapping(
            codings: [
                Coding(
                    code: "HKStateOfMindKind",
                    display: "State of Mind Kind",
                    system: "http://developer.apple.com/documentation/healthkit"
                )
            ],
            categories: []
        ),
        valence: CategoryTypeFHIRMapping(
            codings: [
                Coding(
                    code: "HKStateOfMindValence",
                    display: "State of Mind Valence",
                    system: "http://developer.apple.com/documentation/healthkit"
                )
            ],
            categories: []
        ),
        valenceClassification: CategoryTypeFHIRMapping(
            codings: [
                Coding(
                    code: "HKStateOfMindValenceClassification",
                    display: "State of Mind Valence Classification",
                    system: "http://developer.apple.com/documentation/healthkit"
                )
            ],
            categories: []
        ),
        label: CategoryTypeFHIRMapping(
            codings: [
                Coding(
                    code: "HKStateOfMindLabel",
                    display: "State of Mind Label",
                    system: "http://developer.apple.com/documentation/healthkit"
                )
            ],
            categories: []
        ),
        association: CategoryTypeFHIRMapping(
            codings: [
                Coding(
                    code: "HKStateOfMindAssociation",
                    display: "State of Mind Association",
                    system: "http://developer.apple.com/documentation/healthkit"
                )
            ],
            categories: []
        )
    )
}
