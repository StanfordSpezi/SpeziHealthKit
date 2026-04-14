//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// An ``HKQuantitySampleMapping`` allows developers to customize the mapping of `HKQuantitySample`s to an FHIR observations.
public struct HKQuantitySampleMapping: Decodable, Sendable {
    /// A default instance of an ``HKQuantitySampleMapping`` instance allowing developers to customize the ``HKQuantitySampleMapping``.
    ///
    /// The default values are loaded from the `HKSampleMapping.json` resource in the ``HealthKitOnFHIR`` Swift Package.
    public static let `default` = HKSampleMapping.default.quantitySampleMapping
    
    
    /// The FHIR codings defined as ``MappedCode``s used for the specified `HKQuantitySample` type
    public var codings: [MappedCode]
    /// The FHIR units defined as ``MappedUnit``s used for the specified `HKQuantitySample` type
    public var unit: MappedUnit

    
    /// An ``HKQuantitySampleMapping`` allows developers to customize the mapping of `HKQuantitySample`s to FHIR observations.
    /// - Parameters:
    ///   - codings: The FHIR codings defined as ``MappedCode``s used for the specified `HKQuantitySample` type
    ///   - unit: The FHIR units defined as ``MappedUnit``s used for the specified `HKQuantitySample` type
    public init(
        codings: [MappedCode],
        unit: MappedUnit
    ) {
        self.codings = codings
        self.unit = unit
    }
}
