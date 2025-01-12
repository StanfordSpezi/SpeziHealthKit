//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import Spezi


/// Collects `HKSampleType`s  in the ``HealthKit`` module.
public struct CollectSamples: HealthKitSampleCollectionDescriptor {
    let sampleTypes: Set<HKSampleType>
    let predicate: NSPredicate?
    let deliverySetting: HealthKitDeliverySetting
    
    public var accessedObjectTypes: Set<HKObjectType> { sampleTypes }
    
    
    /// - Parameters:
    ///   - sampleTypes: The set of `HKSampleType`s that should be collected
    ///   - predicate: A custom predicate that should be passed to the HealthKit query.
    ///                The default predicate collects all samples that have been collected from the first time that the user
    ///                provided the application authorization to collect the samples.
    ///   - deliverySetting: The ``HealthKitDeliverySetting`` that should be used to collect the sample type. `.manual` is the default argument used.
    public init(
        _ sampleTypes: some Collection<HKSampleType>,
        predicate: NSPredicate? = nil,
        deliverySetting: HealthKitDeliverySetting = .manual()
    ) {
        self.sampleTypes = Set(sampleTypes)
        self.predicate = predicate
        self.deliverySetting = deliverySetting
    }

    public func dataSources(
        healthKit: HealthKit,
        standard: any HealthKitConstraint
    ) -> [any HealthKitDataSource] {
        sampleTypes.map { sampleType in
            HealthKitSampleDataSource(
                healthKit: healthKit,
                standard: standard,
                sampleType: sampleType,
                predicate: predicate,
                deliverySetting: deliverySetting
            )
        }
    }
}

extension CollectSamples: Hashable {}
