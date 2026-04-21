//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import ModelsR4


/// Controls how `HKWorkout`s are mapped into FHIR Observations.
///
/// ## Topics
///
/// ### Static Properties
/// - ``default``
///
/// ### Initializers
/// - ``init(codings:categories:)``
///
/// ### Instance Properties
/// - ``codings``
/// - ``categories``
public struct WorkoutTypeFHIRMapping: Sendable {
    public let codings: [Coding]
    public let categories: [Coding]
    
    public init(codings: [Coding], categories: [Coding]) {
        self.codings = codings
        self.categories = categories
    }
}


extension WorkoutTypeFHIRMapping {
    /// The default FHIR mapping for `HKWorkout` samples
    public static let `default` = Self(
        codings: [
            Coding(
                code: "HKWorkout",
                display: "Workout",
                system: .healthKitSystem
            ),
            Coding(
                code: "73985-4",
                display: "Exercise activity",
                system: "http://loinc.org"
            )
        ],
        categories: [
            Coding(
                code: "activity",
                display: "Activity",
                system: "http://terminology.hl7.org/CodeSystem/observation-category"
            ),
            Coding(
                code: "PhysicalActivity",
                display: "Physical Activity",
                system: "http://hl7.org/fhir/us/physical-activity/CodeSystem/pa-temporary-codes"
            )
        ]
    )
}
