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
import SpeziViews
import SwiftUI


struct CharacteristicsView: View {
    @Environment(\.calendar)
    private var calendar
    
    @HealthKitCharacteristicQuery(.activityMoveMode)
    private var moveMode
    
    @HealthKitCharacteristicQuery(.bloodType)
    private var bloodType
    
    @HealthKitCharacteristicQuery(.dateOfBirth)
    private var dateOfBirth
    
    @HealthKitCharacteristicQuery(.dateOfBirthComponents)
    private var dateOfBirthComponents
    
    @HealthKitCharacteristicQuery(.biologicalSex)
    private var biologicalSex
    
    @HealthKitCharacteristicQuery(.fitzpatrickSkinType)
    private var skinType
    
    @HealthKitCharacteristicQuery(.wheelchairUse)
    private var wheelchairUse
    
    var body: some View {
        Form {
            makeRow("Move Mode", value: moveMode)
            LabeledContent("Blood Type", value: bloodType?.displayTitle.localizedString() ?? "n/a")
            LabeledContent("Date of Birth", value: dateOfBirth?.formatted(.iso8601) ?? "n/a")
            LabeledContent("Date of Birth is Midnight", value: (dateOfBirth.map { $0 == calendar.startOfDay(for: $0) } ?? false).description)
            LabeledContent("Date of Birth Components", value: dateOfBirthComponents?.description ?? "n/a")
            makeRow("Biological Sex", value: biologicalSex)
            makeRow("Skin Type", value: skinType)
            makeRow("Wheelchair Use", value: wheelchairUse)
        }
    }
    
    private func makeRow(_ title: String, value: (some RawRepresentable<Int>)?) -> some View {
        LabeledContent(title, value: value.map { String($0.rawValue) } ?? "n/a")
    }
}
