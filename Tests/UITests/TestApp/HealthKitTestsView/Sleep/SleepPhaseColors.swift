//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import SwiftUI

@propertyWrapper
struct SleepPhaseColors: DynamicProperty {
    typealias SleepPhase = HKCategoryValueSleepAnalysis
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    var wrappedValue: Self { self }
    
    subscript(sleepPhase: SleepPhase) -> Color {
        // swiftlint:disable operator_usage_whitespace
        switch (sleepPhase, colorScheme) {
        case (.awake, .dark):
            Color(red: 237/255, green: 113/255, blue: 87/255)
        case (.awake, _):
            Color(red: 239/255, green: 136/255, blue: 114/255)
        case (.asleepREM, .dark):
            Color(red: 128/255, green: 208/255, blue: 250/255)
        case (.asleepREM, _):
            Color(red: 90/255, green: 170/255, blue: 224/255)
        case (.asleepCore, .dark):
            Color(red: 59/255, green: 129/255, blue: 246/255)
        case (.asleepCore, _):
            Color(red: 52/255, green: 120/255, blue: 246/255)
        case (.asleepDeep, .dark):
            Color(red: 53/255, green: 52/255, blue: 157/255)
        case (.asleepDeep, _):
            Color(red: 54/255, green: 52/255, blue: 157/255)
        case (.asleepUnspecified, .dark):
            Color(red: 135/255, green: 227/255, blue: 235/255)
        case (.asleepUnspecified, _):
            Color(red: 90/255, green: 195/255, blue: 189/255)
        case (.inBed, .dark):
            Color(red: 161/255, green: 234/255, blue: 234/255)
        case (.inBed, _):
            Color(red: 38/255, green: 90/255, blue: 90/255)
        default:
            fatalError("invalid sleep phase input")
        }
        // swiftlint:enable operator_usage_whitespace
    }
}
