//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

/// A class conforming to `DataProvider` fetches the data from .
/// Given an array of predicates
protocol DataProvider {
    associatedtype QueryBuilder
    
    func fetchData(for measurementType: MeasurementType, matching predicates: [QueryPredicate]) async throws -> [DataPoint]
}
