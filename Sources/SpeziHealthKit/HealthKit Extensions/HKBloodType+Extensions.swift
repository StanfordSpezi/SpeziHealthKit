//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


extension HKBloodType {
    /// All known Blood Types
    public static let allKnownValues: [Self] = [
        .notSet,
        .aPositive, .aNegative,
        .bPositive, .bNegative,
        .abPositive, .abNegative,
        .oPositive, .oNegative
    ]
    
    /// The blood type's title, suitable for user-visible contexts.
    public var displayTitle: LocalizedStringResource {
        switch self {
        case .notSet: "Not Set"
        case .aPositive: "A+"
        case .aNegative: "A-"
        case .bPositive: "B+"
        case .bNegative: "B-"
        case .abPositive: "AB+"
        case .abNegative: "AB-"
        case .oPositive: "O+"
        case .oNegative: "O-"
        @unknown default: "Unknown"
        }
    }
}
