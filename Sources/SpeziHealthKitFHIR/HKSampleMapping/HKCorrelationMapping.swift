//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// An ``HKCorrelationMapping`` allows developers to customize the mapping of `HKCorrelation`s to an FHIR observations.
public struct HKCorrelationMapping: Decodable, Sendable {
    /// A default instance of an ``HKCorrelationMapping`` instance allowing developers to customize the ``HKCorrelationMapping``.
    ///
    /// The default values are loaded from the `HKSampleMapping.json` resource in the ``HealthKitOnFHIR`` Swift Package.
    public static let `default` = HKSampleMapping.default.correlationMapping
    
    
    /// The FHIR codings defined as ``MappedCode``s used for the specified `HKCorrelation` type
    public var codings: [MappedCode]
    /// The FHIR categories defined as ``MappedCode``s used for the specified `HKCorrelation` type
    public var categories: [MappedCode]
    
    
    /// An ``HKCorrelationMapping`` allows developers to customize the mapping of `HKCorrelation`s to an FHIR Observations.
    /// - Parameters:
    ///   - codings: The FHIR codings defined as ``MappedCode``s used for the specified `HKCorrelation` type
    ///   - categories: The FHIR categories defined as ``MappedCode``s used for the specified `HKCorrelation` type
    public init(
        codings: [MappedCode],
        categories: [MappedCode]
    ) {
        self.codings = codings
        self.categories = categories
    }
}
