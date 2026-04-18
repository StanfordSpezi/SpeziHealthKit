//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public struct SampleTypesFHIRMapping: Hashable, Sendable {
    public let quantityTypesMapping: QuantityTypesFHIRMapping
    public let categoryTypesMapping: CategoryTypesFHIRMapping
    public let correlationTypesMapping: CorrelationTypesFHIRMapping
    public let ecgTypeMapping: ECGTypeFHIRMapping
    public let workoutTypeMapping: WorkoutTypeFHIRMapping
    public let stateOfMindTypeMapping: StateOfMindTypeFHIRMapping
    
    
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
