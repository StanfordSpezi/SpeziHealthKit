//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi

public struct BulkUpload: HealthKitDataSourceDescription {
    public let sampleTypes: Set<HKSampleType>
    let predicate: NSPredicate?
    let deliverySetting: HealthKitDeliverySetting
    let bulkSize: Int
    
    /// - Parameters:
    ///   - sampleTypes: The set of `HKSampleType`s that should be collected
    ///   - predicate: A custom predicate that should be passed to the HealthKit query.
    ///                The default predicate collects all samples that have been collected from the first time that the user
    ///                provided the application authorization to collect the samples.
    ///   - deliverySetting: The ``HealthKitDeliverySetting`` that should be used to collect the sample type. `.manual` is the default argument used.
    public init(
        _ sampleTypes: Set<HKSampleType>,
        predicate: NSPredicate? = nil,
        deliveryStartSetting: HealthKitDeliveryStartSetting = .manual,
        bulkSize: Int
    ) {
        self.sampleTypes = sampleTypes
        self.predicate = predicate
        self.deliverySetting = HealthKitDeliverySetting.anchorQuery(deliveryStartSetting, saveAnchor: true)
        self.bulkSize = bulkSize
    }
    
    public func dataSources(healthStore: HKHealthStore, standard: any HealthKitConstraint) -> [any HealthKitDataSource] {
        <#code#>
    }
}
