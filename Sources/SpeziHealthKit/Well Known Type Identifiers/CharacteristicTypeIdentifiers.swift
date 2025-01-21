//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


extension HKCharacteristicType {
    /// All well-known `HKCharacteristicType`s
    public static let allKnownCharacteristics: Set<HKCharacteristicType> = Set(
        HKCharacteristicTypeIdentifier.allKnownIdentifiers.map { HKCharacteristicType($0) }
    )
}

extension HKCharacteristicTypeIdentifier {
    /// All well-known `HKCharacteristicTypeIdentifier`s
    public static let allKnownIdentifiers: Set<Self> = [
        .activityMoveMode,
        .biologicalSex,
        .bloodType,
        .dateOfBirth,
        .fitzpatrickSkinType,
        .wheelchairUse
    ]
}
