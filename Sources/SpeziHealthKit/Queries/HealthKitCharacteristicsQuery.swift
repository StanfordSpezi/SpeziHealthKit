//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import SwiftUI


/// A type-safe wrapper around `HKCharacteristicType`.
public struct HealthKitCharacteristic<Value>: Sendable {
    let hkType: HKCharacteristicType
    let displayTitle: String
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
}


extension HealthKitCharacteristic { // swiftlint:disable:this file_types_order
    /// The activity move mode characteristic.
    public static var activityMoveMode: HealthKitCharacteristic<HKActivityMoveMode> { .init(
        .activityMoveMode,
        displayTitle: "Activity Move Mode",
        accessor: { try $0.activityMoveMode().activityMoveMode }
    ) }
    
    /// The characteristic representing the user's biological sex.
    public static var biologicalSex: HealthKitCharacteristic<HKBiologicalSex> {
        .init(.biologicalSex, displayTitle: "Biological Sex", accessor: { try $0.biologicalSex().biologicalSex })
    }
    
    /// The characteristic representing the user's blood type.
    public static var bloodType: HealthKitCharacteristic<HKBloodType> {
        .init(.bloodType, displayTitle: "Blood Type", accessor: { try $0.bloodType().bloodType })
    }
    
    /// The characteristic representing the user's date of birth.
    public static var dateOfBirth: HealthKitCharacteristic<Date> {
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
    
    /// The characteristic representing the user's skin type.
    public static var fitzpatrickSkinType: HealthKitCharacteristic<HKFitzpatrickSkinType> {
        .init(.fitzpatrickSkinType, displayTitle: "Fitzpatrick Skin Type", accessor: { try $0.fitzpatrickSkinType().skinType })
    }
    
    /// The characteristic representing the user's wheelchair use status.
    public static var wheelchairUse: HealthKitCharacteristic<HKWheelchairUse> {
        .init(.wheelchairUse, displayTitle: "Wheelchain Use", accessor: { try $0.wheelchairUse().wheelchairUse })
    }
}


/// Fetches a `HKCharacteristicType` from the HealthKit data store, in a type-safe manner.
///
/// - Note: This property wrapper is not auto-updating; if the characteristic's value is changed while a view using this property wrapper is active,
///     it will continue displaying the old value until the view gets updated for some other reason.
///
/// Example:
/// ```swift
/// struct ExampleView: View {
///     @HealthKitCharacteristicQuery(.wheelchairUse)
///     private var wheelchairUse
///
///     var body: some View {
///         if wheelchairUse == .yes {
///             // use dedicated wheelchair-use-related UI
///         } else {
///             // use normal non-wheelchair-use UI
///         }
///     }
/// }
/// ```
@propertyWrapper
public struct HealthKitCharacteristicQuery<Value>: DynamicProperty {
    @Environment(HealthKit.self) private var healthKit
    
    private let characteristic: HealthKitCharacteristic<Value>
    
    /// The value of the underlying characteristic.
    public var wrappedValue: Value? {
        try? characteristic.accessor(healthKit.healthStore)
    }
    
    /// Creates a new characteristic query
    public init(_ characteristic: HealthKitCharacteristic<Value>) {
        self.characteristic = characteristic
    }
}
