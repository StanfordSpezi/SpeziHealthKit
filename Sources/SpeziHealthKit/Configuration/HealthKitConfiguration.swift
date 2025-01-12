//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import Foundation
import HealthKit





public protocol HealthKitConfigurationComponent { // TODO better name?
    /// The object types this component needs read-access to.
    var accessedObjectTypes: Set<HKObjectType> { get }
    
    @MainActor
    func configure(for healthKit: HealthKit)
}





public struct RequestReadAccess: HealthKitConfigurationComponent {
    public let accessedObjectTypes: Set<HKObjectType>
    
    public init(_ objectTypes: some Collection<HKObjectType>) {
        accessedObjectTypes = Set(objectTypes)
    }
    
    public init(
        quantity: Set<HKQuantityTypeIdentifier> = [],
        category: Set<HKCategoryTypeIdentifier> = [],
        correlation: Set<HKCorrelationTypeIdentifier> = [],
        characteristic: Set<HKCharacteristicTypeIdentifier> = []
    ) {
        accessedObjectTypes = Set(quantity.map(HKQuantityType.init))
            .union(category.map(HKCategoryType.init))
            .union(correlation.flatMap(\.knownAssociatedObjectTypes))
            .union(characteristic.map(HKCharacteristicType.init))
    }
    
    public func configure(for healthKit: HealthKit) {
        // This type only provides objectTypes to the HealthKit module;
        // and consequently doesn't need to do anything in here.
    }
}
