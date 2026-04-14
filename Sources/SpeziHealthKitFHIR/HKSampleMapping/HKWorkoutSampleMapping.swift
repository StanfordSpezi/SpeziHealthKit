//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// An ``HKWorkoutSampleMapping`` allows developers to customize the mapping of `HKWorkout` samples to FHIR Observations.
public struct HKWorkoutSampleMapping: Decodable, Sendable {
    /// A default instance of an ``HKWorkoutSampleMapping`` allowing developers to customize the ``HKWorkoutSampleMapping``
    /// The default values are loaded from the `HKSampleMapping.json` resource in the ``HealthKitOnFHIR`` Swift Package.
    public static let `default` = HKSampleMapping.default.workoutSampleMapping

    /// The FHIR codings defined as ``MappedCode``s to be used for `HKWorkout` samples
    public var codings: [MappedCode]
    /// The FHIR categories defined as ``MappedCode``s to be used for `HKWorkout` samples
    public var categories: [MappedCode]


    /// An ``HKWorkoutSampleMapping`` allows developers to customize the mapping of `HKWorkout`s to FHIR observations.
    /// - Parameters:
    ///   - codings: The FHIR codings defined as ``MappedCode``s used for the `HKWorkout` sample
    ///   - categories: The FHIR categories defined as ``MappedCode``s used for the `HKWorkout` sample
    public init(
        codings: [MappedCode] = Self.default.codings,
        categories: [MappedCode] = Self.default.categories
    ) {
        self.codings = codings
        self.categories = categories
    }
}
