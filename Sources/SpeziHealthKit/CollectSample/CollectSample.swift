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
