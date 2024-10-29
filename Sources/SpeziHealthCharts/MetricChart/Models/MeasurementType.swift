//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// An enumeration over the supported measurement types that can be queried for. To specify in a query, pass a
/// `QueryPredicate.type` with the desired type as its associated value.
///
/// For example, in the default `DataProvider` implementation `HealthKitDataProvider`, passing
/// `MeasurementType.heartRate` in a `QueryPredicate` will signal 
///
/// To add a new `MeasurementType`, add a case to the enum and include the type in your implementation
/// of a `DataProvider`.
public enum MeasurementType: Sendable {
    case heartRate, bodyMass, bloodPressure
}
