//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A `QueryPredicate` is a single condition that a data point must meet in order to be included in a query.
/// An array of `QueryPredicate`s are provided to a `DataProvider`, which then fetches all the data points matching
/// the intersection of the provided predicates.
///
/// Note that `MeasurementType` is required directly by `DataProvider.fetchData()`
/// and is not passed through a `QueryPredicate`.
public enum QueryPredicate {
    case dateRange(start: Date, end: Date)
}
