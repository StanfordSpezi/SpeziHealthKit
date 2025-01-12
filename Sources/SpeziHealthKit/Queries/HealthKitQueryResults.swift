//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit



/// The ``HealthKitQueryResults`` protocol is an auto-updating, observable collection of results to a HealthKit query.
public protocol HealthKitQueryResults<Sample, Element>: Observable, RandomAccessCollection, Sendable where Element: Identifiable {
    /// The `HKSample` subclass of the queried sample type.
    /// - Note: this is not necessarily the same as the type of the elements in the query results: for e.g. statistical queries,
    ///     the query will typically return summarising objects rather than discrete samples.
    associatedtype Sample: HKSample & __HKSampleTypeProviding
    /// The type of the individual objects returned from the query.
    /// - Note: `Element` is not necesarily the same as `Sample`; this is depending on the type of query:
    ///     for "normal" `@HealthKitQuery`s, it is, but for `@HealthKitStatisticsQuery`s, the query returns `HKStatistics` objects instead.
    associatedtype Element
    
    /// The queried sample type.
    var sampleType: HealthKitSampleType<Sample> { get }
    /// The queried time range.
    var timeRange: HealthKitQueryTimeRange { get }
    
    /// Creates and returns a **new** query results object, with the specified time range.
    func withTimeRange(_ timeRange: HealthKitQueryTimeRange) async -> Self
    
    /// If the query raised an error (which can happen in some cases e.g. as a result of invalid input combinations),
    /// this property makes this error available.
    /// - Note: This property being non-nil typically implies that the query results themselves are empty.
    var queryError: (any Error)? { get }
}
