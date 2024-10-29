//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Given an array of predicates, builds a query conforming of type `QueryType`.
protocol QueryBuilder {
    associatedtype QueryType
    
    func build(from predicates: [QueryPredicate]) -> QueryType
}
