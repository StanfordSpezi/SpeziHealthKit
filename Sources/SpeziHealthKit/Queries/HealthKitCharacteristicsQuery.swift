//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI
import HealthKit


public struct HealthKitCharacteristic<Value>: Sendable {
    let hkType: HKCharacteristicType
    let displayTitle: String
    let accessor: @Sendable (HKHealthStore) throws -> Value
    
    fileprivate init(_ identifier: HKCharacteristicTypeIdentifier, displayTitle: String, accessor: @escaping @Sendable (HKHealthStore) throws -> Value) {
        self.hkType = .init(identifier)
        self.displayTitle = displayTitle
        self.accessor = accessor
    }
}


extension HealthKitCharacteristic {
    public static var activityMoveMode: HealthKitCharacteristic<HKActivityMoveMode> {
        .init(.activityMoveMode, displayTitle: "Activity Mode", accessor: { try $0.activityMoveMode().activityMoveMode }) // TODO "Activity Move Mode"?
    }
    
    public static var biologicalSex: HealthKitCharacteristic<HKBiologicalSex> {
        .init(.biologicalSex, displayTitle: "Biological Sex", accessor: { try $0.biologicalSex().biologicalSex })
    }
    
    public static var bloodType: HealthKitCharacteristic<HKBloodType> {
        .init(.bloodType, displayTitle: "Blood Type", accessor: { try $0.bloodType().bloodType })
    }
    
    public static var dateOfBirth: HealthKitCharacteristic<Date> {
        .init(.dateOfBirth, displayTitle: "Date of Birth") { healthStore in
            let components = try healthStore.dateOfBirthComponents()
            if let date = Calendar.current.date(from: components) { // TODO what about time zones here?!!!
                return date
            } else {
                throw NSError(domain: "SpeziHealthKit", code: 0, userInfo: [ // TODO custom error type!
                    NSLocalizedDescriptionKey: "Unable to construct date from components"
                ])
            }
        }
    }
    
    public static var fitzpatrickSkinType: HealthKitCharacteristic<HKFitzpatrickSkinType> {
        .init(.fitzpatrickSkinType, displayTitle: "Fitzpatrick Skin Type", accessor: { try $0.fitzpatrickSkinType().skinType })
    }
    
    public static var wheelchairUse: HealthKitCharacteristic<HKWheelchairUse> {
        .init(.wheelchairUse, displayTitle: "Wheelchain Use", accessor: { try $0.wheelchairUse().wheelchairUse })
    }
}



@propertyWrapper
public struct HealthKitCharacteristicQuery<Value>: DynamicProperty {
    @Environment(HealthKit.self) private var healthKit
    
    private let characteristic: HealthKitCharacteristic<Value>
    
    public init(_ characteristic: HealthKitCharacteristic<Value>) {
        self.characteristic = characteristic
    }
    
    public var wrappedValue: Value? {
        try? characteristic.accessor(healthKit.healthStore)
    }
}

