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

struct EmptyQuery {
    let id: String
}

public class HKQueryBuilder: QueryBuilder {
    typealias QueryType = EmptyQuery
    
    
    func build(from predicates: [QueryPredicate]) -> QueryType {
        EmptyQuery(id: "Null")
    }
}


// MARK: - HealthKitDataProvider


public final class HealthKitDataProvider: DataProvider {
    public typealias QueryBuilder = HKQueryBuilder
    
    
    public func fetchData(for measurementType: MeasurementType, in interval: DateInterval) async throws -> [DataPoint] {
        []
    }
    
    
    public init() {}
}
