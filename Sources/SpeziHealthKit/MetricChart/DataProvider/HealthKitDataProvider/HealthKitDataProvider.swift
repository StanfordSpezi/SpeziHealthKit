//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


// MARK: - HKQueryBuilder


class HKQueryBuilder: QueryBuilder {
    typealias QueryType = HKQuery
    
    
    func build(from predicates: [QueryPredicate]) -> QueryType {
        <#code#>
    }
}



// MARK: - HealthKitDataProvider


public class HealthKitDataProvider: DataProvider {
    typealias QueryBuilder = HKQueryBuilder
    
    
    public func fetchData(for measurementType: MeasurementType, matching predicates: [QueryPredicate]) async throws -> [DataPoint] {
        []
    }
}

