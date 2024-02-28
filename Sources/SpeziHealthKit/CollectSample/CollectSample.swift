//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi


/// Collects a specified `HKSampleType`  in the ``HealthKit`` module.
///
/// This structure define what and how the HealthKit samples are collected. By default, all samples of the provided `HKSampleType` after you provide the application authorization to collect the samples will be collected when the ``HealthKit/triggerDataSourceCollection()`` function is called.
///
/// Your can filter and specify when to collect the HealthKit sample. You can, e.g. specify a time range by defining and providing your `predicate` and set the `deliverySetting` during initialization:
/// ```swift
/// private var predicateOneMonth: NSPredicate {
///     let calendar = Calendar(identifier: .gregorian)
///     let today = calendar.startOfDay(for: Date())
///     guard let endDate = calendar.date(byAdding: .day, value: 1, to: today) else {
///         fatalError("*** Unable to calculate the end time ***")
///     }
///     // Collect the data in the previous month.
///     guard let startDate = calendar.date(byAdding: .month, value: -1, to: endDate) else {
///         fatalError("*** Unable to calculate the start time ***")
///     }
///     return HKQuery.predicateForSamples(withStart: startDate, end: endDate)
/// }
/// ...
/// CollectSample(
///     HKQuantityType(.stepCount),
///     predicate: predicateOneMonth,
///     deliverySetting: .background(.afterAuthorizationAndApplicationWillLaunch)
/// )
/// ```
public struct CollectSample: HealthKitDataSourceDescription {
    private let collectSamples: CollectSamples
    
    
    public var sampleTypes: Set<HKSampleType> {
        collectSamples.sampleTypes
    }
    
    
    /// - Parameters:
    ///   - sampleType: The `HKSampleType` that should be collected
    ///   - predicate: A custom predicate that should be passed to the HealthKit query.
    ///                The default predicate collects all samples that have been collected from the first time that the user
    ///                provided the application authorization to collect the samples.
    ///   - deliverySetting: The ``HealthKitDeliverySetting`` that should be used to collect the sample type. `.manual` is the default argument used.
    public init<S: HKSampleType>(
        _ sampleType: S,
        predicate: NSPredicate? = nil,
        deliverySetting: HealthKitDeliverySetting = .manual()
    ) {
        self.collectSamples = CollectSamples([sampleType], predicate: predicate, deliverySetting: deliverySetting)
    }
    
    
    public func dataSources(
        healthStore: HKHealthStore,
        standard: any HealthKitConstraint
    ) -> [any HealthKitDataSource] {
        collectSamples.dataSources(healthStore: healthStore, standard: standard)
    }
}
