//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// A ``HealthKit-class`` configuration component that requests write acess to HealthKit sample types.
///
/// - Warning: Only request write access to HealthKit data if your app's `Info.plist` file
///     contains an entry for the `NSHealthUpdateUsageDescription` key.
public struct RequestWriteAccess: HealthKitConfigurationComponent {
    public let dataAccessRequirements: HealthKit.DataAccessRequirements
    
    /// Creates a HealthKit configuration component that requests write access to the specified `HKObjectType`s.
    public init(_ objectTypes: some Sequence<HKSampleType>) {
        dataAccessRequirements = .init(write: Set(objectTypes))
    }
    
    /// Creates a HealthKit configuration component that requests write access to the specified type identifiers.
    public init(
        quantity: Set<HKQuantityTypeIdentifier> = [],
        category: Set<HKCategoryTypeIdentifier> = [],
        correlation: Set<HKCorrelationTypeIdentifier> = []
    ) {
        self.init(Set(quantity.map(HKQuantityType.init))
            .union(category.map(HKCategoryType.init))
            .union(correlation.flatMap(\.knownAssociatedSampleTypes))
        )
    }
    
    public func configure(for healthKit: HealthKit, on standard: any HealthKitConstraint) {
        // This type only provides object types to the HealthKit module;
        // and consequently doesn't need to do anything in here.
    }
}
