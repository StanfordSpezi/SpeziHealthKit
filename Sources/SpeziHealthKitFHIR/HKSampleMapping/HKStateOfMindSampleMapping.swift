//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// An ``HKStateOfMindMapping`` allows developers to customize the mapping of `HKStateOfMind` samples to FHIR Observations.
public struct HKStateOfMindMapping: Decodable, Sendable {
    /// A default instance of an ``HKStateOfMindMapping`` allowing developers to customize the ``HKStateOfMindMapping``
    /// The default values are loaded from the `HKSampleMapping.json` resource in the ``HealthKitOnFHIR`` Swift Package.
    public static let `default` = HKSampleMapping.default.stateOfMindMapping

    /// The FHIR codings defined as ``MappedCode``s to be used for `HKStateOfMind` samples
    public var codings: [MappedCode]
    /// The FHIR categories defined as ``MappedCode``s to be used for `HKStateOfMind` samples
    public var categories: [MappedCode]
    /// The mapping for a `HKStateOfMind` sample's kind.
    public var kind: HKCategorySampleMapping
    /// The mapping for a `HKStateOfMind` sample's valence.
    public var valence: HKCategorySampleMapping
    /// The mapping for a `HKStateOfMind` sample's valence classification.
    public var valenceClassification: HKCategorySampleMapping
    /// The mapping for a `HKStateOfMind` sample's label.
    public var label: HKCategorySampleMapping
    /// The mapping for a `HKStateOfMind` sample's association.
    public var association: HKCategorySampleMapping


    /// An ``HKWorkoutSampleMapping`` allows developers to customize the mapping of `HKStateOfMind`s to FHIR observations.
    /// - Parameters:
    ///   - codings: The FHIR codings defined as ``MappedCode``s used for the `HKStateOfMind` sample
    ///   - categories: The FHIR categories defined as ``MappedCode``s used for the `HKStateOfMind` sample
    public init(
        codings: [MappedCode] = Self.default.codings,
        categories: [MappedCode] = Self.default.categories,
        kind: HKCategorySampleMapping = Self.default.kind,
        valence: HKCategorySampleMapping = Self.default.valence,
        valenceClassification: HKCategorySampleMapping = Self.default.valenceClassification,
        label: HKCategorySampleMapping = Self.default.label,
        association: HKCategorySampleMapping = Self.default.association
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
