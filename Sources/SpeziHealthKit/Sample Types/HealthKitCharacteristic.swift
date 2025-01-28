//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// A ahcracteristic as defined by HealthKit.
public protocol HealthKitCharacteristicProtocol<Value>: Hashable, Sendable {
    associatedtype Value
    var hkType: HKCharacteristicType { get }
    var displayTitle: String { get }
    
    @_spi(Internal)
    func value(in healthStore: HKHealthStore) throws -> Value
}


/// A type-safe wrapper around `HKCharacteristicType`.
public struct HealthKitCharacteristic<Value>: HealthKitCharacteristicProtocol, Sendable {
    public let hkType: HKCharacteristicType
    public let displayTitle: String
    let accessor: @Sendable (HKHealthStore) throws -> Value
    
    fileprivate init(
        _ identifier: HKCharacteristicTypeIdentifier,
        displayTitle: String,
        accessor: @escaping @Sendable (HKHealthStore) throws -> Value
    ) {
        self.hkType = .init(identifier)
        self.displayTitle = displayTitle
        self.accessor = accessor
    }
    
    @_spi(Internal)
    public func value(in healthStore: HKHealthStore) throws -> Value {
        try accessor(healthStore)
    }
}

// NOTE: `HealthKitCharacteristic`'s conformance to Hashable and Equatable
// intentionally looks only at the characteristic's underlying HKCharacteristicType.
// This is fine, since there is a fixed amount of characteristics, all of which are defined here in this file,
// and it is impossible for users to create custom characteristics.
// As a result, we can guarantee that each instance uses a different HKCharacteristicType,
// and that the hkType can be used as a stable identity.
extension HealthKitCharacteristicProtocol {
    /// Compares two characteristics for equality, based on their underlying `HKCharacteristicType`s
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hkType == rhs.hkType
    }
    
    /// Hashes the characteristic, based on its underlying `HKCharacteristicType`
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hkType)
    }
}


extension HealthKitCharacteristicProtocol where Self == HealthKitCharacteristic<HKActivityMoveMode> {
    /// The activity move mode characteristic.
    public static var activityMoveMode: Self {
        .init(
            .activityMoveMode,
            displayTitle: "Activity Move Mode",
            accessor: { try $0.activityMoveMode().activityMoveMode }
        )
    }
}


extension HealthKitCharacteristicProtocol where Self == HealthKitCharacteristic<HKBiologicalSex> {
    /// The characteristic representing the user's biological sex.
    public static var biologicalSex: Self {
        .init(.biologicalSex, displayTitle: "Biological Sex", accessor: { try $0.biologicalSex().biologicalSex })
    }
}


extension HealthKitCharacteristicProtocol where Self == HealthKitCharacteristic<HKBloodType> {
    /// The characteristic representing the user's blood type.
    public static var bloodType: Self {
        .init(.bloodType, displayTitle: "Blood Type", accessor: { try $0.bloodType().bloodType })
    }
}


extension HealthKitCharacteristicProtocol where Self == HealthKitCharacteristic<Date> {
    /// The characteristic representing the user's date of birth.
    public static var dateOfBirth: Self {
        .init(.dateOfBirth, displayTitle: "Date of Birth") { healthStore in
            let components = try healthStore.dateOfBirthComponents()
            if let date = Calendar.current.date(from: components) {
                // Question: Do we need to take time zones into account here?
                // What if the user entered their DoB in a different time zone than the one they're currently in?
                return date
            } else {
                // We don't use a custom error type here, since the error will be discarded anyway.
                throw NSError(domain: "SpeziHealthKit", code: 0)
            }
        }
    }
}


extension HealthKitCharacteristicProtocol where Self == HealthKitCharacteristic<HKFitzpatrickSkinType> {
    /// The characteristic representing the user's skin type.
    public static var fitzpatrickSkinType: Self {
        .init(.fitzpatrickSkinType, displayTitle: "Fitzpatrick Skin Type", accessor: { try $0.fitzpatrickSkinType().skinType })
    }
}


extension HealthKitCharacteristicProtocol where Self == HealthKitCharacteristic<HKWheelchairUse> {
    /// The characteristic representing the user's wheelchair use status.
    public static var wheelchairUse: Self {
        .init(.wheelchairUse, displayTitle: "Wheelchain Use", accessor: { try $0.wheelchairUse().wheelchairUse })
    }
}
