//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
@_spi(APISupport) import SpeziHealthKit
import SwiftUI


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
@MainActor
public struct HealthKitCharacteristicQuery<Characteristic: HealthKitCharacteristicProtocol>: DynamicProperty {
    @Observable
    @MainActor
    fileprivate final class Storage {
        var viewUpdate: UInt8 = 0
    }
    
    @Environment(HealthKit.self) private var healthKit
    @State private var storage = Storage()
    @HealthAccessAuthorizationObserver private var accessAuthObserver
    
    private let characteristic: Characteristic
    
    /// The value of the underlying characteristic.
    public var wrappedValue: Characteristic.Value? {
        _ = storage.viewUpdate
        return try? characteristic.value(in: healthKit.healthStore)
    }
    
    /// Creates a new characteristic query
    public init(_ characteristic: Characteristic) {
        self.characteristic = characteristic
    }
    
    public nonisolated func update() {
        MainActor.assumeIsolated {
            accessAuthObserver.observeAuthorizationChanges(for: .init(read: [characteristic.hkType])) { [weak storage] in
                await MainActor.run {
                    storage?.viewUpdate &+= 1
                }
            }
        }
    }
}
