//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// A ``HealthKit`` configuration component that requests read acess to HealthKit sample types.
public struct RequestReadAccess: HealthKitConfigurationComponent {
    public let dataAccessRequirements: HealthKitDataAccessRequirements
    
    /// Creates a HealthKit configuration component that requests read access to the specified `HKObjectType`s.
    public init(_ objectTypes: some Sequence<HKObjectType>) {
        dataAccessRequirements = .init(read: Set(objectTypes))
    }
    
    // TODO this (and its RequestWriteAccess sibling) somehow needs to be able to allow requesting access to eg the electrocardiogram type (which isn't an identifier in the enum, and works differently!)
    /// Creates a HealthKit configuration component that requests read access to the specified sample types.
    public init(
        quantity: Set<HKQuantityTypeIdentifier> = [],
        category: Set<HKCategoryTypeIdentifier> = [],
        correlation: Set<HKCorrelationTypeIdentifier> = [],
        characteristic: Set<HKCharacteristicTypeIdentifier> = []
    ) {
        self.init(Set(quantity.map(HKQuantityType.init))
            .union(category.map(HKCategoryType.init))
            .union(correlation.flatMap(\.knownAssociatedSampleTypes))
            .union(characteristic.map(HKCharacteristicType.init))
        )
    }
    
    public func configure(for healthKit: HealthKit, on standard: any HealthKitConstraint) {
        // This type only provides object types to the HealthKit module;
        // and consequently doesn't need to do anything in here.
    }
}
