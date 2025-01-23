//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// A ``HealthKit-class`` configuration component that requests read acess to HealthKit sample types.
///
/// - Important: Apps can only request HealthKit read access if the `Info.plist` file contains an entry for the `NSHealthShareUsageDescription` key.
public struct RequestReadAccess: HealthKitConfigurationComponent {
    public let dataAccessRequirements: HealthKit.DataAccessRequirements
    
    /// Creates a HealthKit configuration component that requests read access to the specified `HKObjectType`s.
    public init(_ objectTypes: some Sequence<HKObjectType>) {
        dataAccessRequirements = .init(read: Set(objectTypes))
    }
    
    /// Creates a HealthKit configuration component that requests read access to the specified sample types.
    public init(
        quantity: Set<HKQuantityTypeIdentifier> = [],
        category: Set<HKCategoryTypeIdentifier> = [],
        correlation: Set<HKCorrelationTypeIdentifier> = [],
        characteristic: Set<HKCharacteristicTypeIdentifier> = []
    ) {
        let types = Set<HKObjectType>(quantity.map(HKQuantityType.init))
            .union(category.map(HKCategoryType.init))
            .union(correlation.flatMap(\.knownAssociatedSampleTypes))
            .union(characteristic.map(HKCharacteristicType.init))
        self.init(types)
    }
    
    public func configure(for healthKit: HealthKit, on standard: any HealthKitConstraint) {
        // This type only provides object types to the HealthKit module;
        // and consequently doesn't need to do anything in here.
    }
}
