//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziHealthKit
import SpeziHealthKitUI
import SwiftUI


struct CharacteristicsView: View {
    @HealthKitCharacteristicQuery(.activityMoveMode)
    private var moveMode
    
    @HealthKitCharacteristicQuery(.bloodType)
    private var bloodType
    
    @HealthKitCharacteristicQuery(.dateOfBirth)
    private var dateOfBirth
    
    @HealthKitCharacteristicQuery(.biologicalSex)
    private var biologicalSex
    
    @HealthKitCharacteristicQuery(.fitzpatrickSkinType)
    private var skinType
    
    @HealthKitCharacteristicQuery(.wheelchairUse)
    private var wheelchairUse
    
    var body: some View {
        Form {
            makeRow("Move Mode", value: moveMode)
            makeRow("Blood Type", value: bloodType)
            LabeledContent("Date of Birth", value: dateOfBirth?.formatted(.iso8601) ?? "n/a")
            makeRow("Biological Sex", value: biologicalSex)
            makeRow("Skin Type", value: skinType)
            makeRow("Wheelchair Use", value: wheelchairUse)
        }
    }
    
    private func makeRow(_ title: String, value: (some RawRepresentable<Int>)?) -> some View {
        LabeledContent(title, value: value.map { String($0.rawValue) } ?? "n/a")
    }
}
