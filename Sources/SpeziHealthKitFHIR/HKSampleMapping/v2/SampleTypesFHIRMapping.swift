//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// Controls how HealthKit samples are mapped into FHIR resources.
///
/// TODO explain how exactly this influences the conversion process!!!
public struct SampleTypesFHIRMapping: Hashable, Sendable {
    public var quantityTypesMapping: QuantityTypesFHIRMapping
    public var categoryTypesMapping: CategoryTypesFHIRMapping
    public var correlationTypesMapping: CorrelationTypesFHIRMapping
    public var ecgTypeMapping: ECGTypeFHIRMapping
    public var workoutTypeMapping: WorkoutTypeFHIRMapping
    public var stateOfMindTypeMapping: StateOfMindTypeFHIRMapping
    
    
    public init(
        quantityTypesMapping: QuantityTypesFHIRMapping,
        categoryTypesMapping: CategoryTypesFHIRMapping,
        correlationTypesMapping: CorrelationTypesFHIRMapping,
        ecgTypeMapping: ECGTypeFHIRMapping,
        workoutTypeMapping: WorkoutTypeFHIRMapping,
        stateOfMindTypeMapping: StateOfMindTypeFHIRMapping
    ) {
        self.quantityTypesMapping = quantityTypesMapping
        self.categoryTypesMapping = categoryTypesMapping
        self.correlationTypesMapping = correlationTypesMapping
        self.ecgTypeMapping = ecgTypeMapping
        self.workoutTypeMapping = workoutTypeMapping
        self.stateOfMindTypeMapping = stateOfMindTypeMapping
    }
}


extension SampleTypesFHIRMapping {
    public static let `default` = Self(
        quantityTypesMapping: .default,
        categoryTypesMapping: .default,
        correlationTypesMapping: .default,
        ecgTypeMapping: .default,
        workoutTypeMapping: .default,
        stateOfMindTypeMapping: .default
    )
}
