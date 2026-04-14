//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// An ``HKCategorySampleMapping`` allows developers to customize the mapping of `HKCategorySample`s to FHIR observations.
public struct HKCategorySampleMapping: Decodable, Sendable {
    /// A default instance of an ``HKCategorySampleMapping`` instance allowing developers to customize the ``HKCategorySampleMapping``.
    ///
    /// The default values are loaded from the `HKSampleMapping.json` resource in the ``HealthKitOnFHIR`` Swift Package.
    public static let `default` = HKSampleMapping.default.categorySampleMapping

    /// The FHIR codings defined as ``MappedCode``s used for the specified `HKCategorySample` type
    public var codings: [MappedCode]

    /// An ``HKCategorySampleMapping`` allows developers to customize the mapping of `HKCategorySample`s to an FHIR Observations.
    /// - Parameters:
    ///   - codings: The FHIR codings defined as ``MappedCode``s used for the specified `HKCategorySample` type
    public init(
        codings: [MappedCode]
    ) {
        self.codings = codings
    }
}
