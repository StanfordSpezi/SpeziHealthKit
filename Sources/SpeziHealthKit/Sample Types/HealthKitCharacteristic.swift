//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// A characteristic as defined by HealthKit.
public protocol HealthKitCharacteristicProtocol<Value>: Hashable, Sendable {
    /// The type of the characteristic's value
    associatedtype Value
    
    /// The underlying `HKCharacteristicType`
    var hkType: HKCharacteristicType { get }
    /// The characteristic's title, suitable for user-visible display.
    var displayTitle: String { get }
    
    /// Fetches the characteristic's value from a `HKHealthStore`.
    @_spi(APISupport)
    func value(in healthStore: HKHealthStore) throws -> Value
}


/// A type-safe wrapper around `HKCharacteristicType`, usable for reading data from HealthKit.
///
/// ## Topics
/// ### Instance Properties
/// - ``displayTitle``
/// - ``hkType``
/// ### Characteristic Types
/// - ``activityMoveMode``
/// - ``biologicalSex``
/// - ``bloodType``
/// - ``dateOfBirth``
/// - ``fitzpatrickSkinType``
/// - ``wheelchairUse``
public struct HealthKitCharacteristic<Value>: HealthKitCharacteristicProtocol, Sendable {
    public let hkType: HKCharacteristicType
    public let displayTitle: String
    let accessor: @Sendable (HKHealthStore) throws -> Value
    
    fileprivate init(
        _ identifier: HKCharacteristicTypeIdentifier,
        displayTitle: LocalizedStringResource,
        accessor: @escaping @Sendable (HKHealthStore) throws -> Value
    ) {
        self.hkType = .init(identifier)
        self.displayTitle = String(localized: displayTitle)
        self.accessor = accessor
    }
    
    @_spi(APISupport)
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
    public static var activityMoveMode: HealthKitCharacteristic<HKActivityMoveMode> {
        Self(.activityMoveMode, displayTitle: "Activity Move Mode") { healthStore in
            try healthStore.activityMoveMode().activityMoveMode
        }
    }
}

extension HealthKitCharacteristicProtocol where Self == HealthKitCharacteristic<HKBiologicalSex> {
    /// The characteristic representing the user's biological sex.
    public static var biologicalSex: HealthKitCharacteristic<HKBiologicalSex> {
        Self(.biologicalSex, displayTitle: "Biological Sex") { healthStore in
            try healthStore.biologicalSex().biologicalSex
        }
    }
}

extension HealthKitCharacteristicProtocol where Self == HealthKitCharacteristic<HKBloodType> {
    /// The characteristic representing the user's blood type.
    public static var bloodType: HealthKitCharacteristic<HKBloodType> {
        Self(.bloodType, displayTitle: "Blood Type") { healthStore in
            try healthStore.bloodType().bloodType
        }
    }
}

extension HealthKitCharacteristicProtocol where Self == HealthKitCharacteristic<Date> {
    /// The characteristic representing the user's date of birth.
    public static var dateOfBirth: HealthKitCharacteristic<Date> {
        Self(.dateOfBirth, displayTitle: "Date of Birth") { healthStore in
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
    public static var fitzpatrickSkinType: HealthKitCharacteristic<HKFitzpatrickSkinType> {
        Self(.fitzpatrickSkinType, displayTitle: "Fitzpatrick Skin Type") { healthStore in
            try healthStore.fitzpatrickSkinType().skinType
        }
    }
}

extension HealthKitCharacteristicProtocol where Self == HealthKitCharacteristic<HKWheelchairUse> {
    /// The characteristic representing the user's wheelchair use status.
    public static var wheelchairUse: HealthKitCharacteristic<HKWheelchairUse> {
        Self(.wheelchairUse, displayTitle: "Wheelchain Use") { healthStore in
            try healthStore.wheelchairUse().wheelchairUse
        }
    }
}
