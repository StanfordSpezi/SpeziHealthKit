//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import SpeziHealthKit
import SpeziHealthKitUI
import SpeziViews
import SwiftUI


struct DeferredAuthorizationTests: View {
    @Environment(HealthKit.self) var healthKit
    @HealthKitCharacteristicQuery(.bloodType) private var bloodType
    @Binding var viewState: ViewState
    
    @HealthKitQuery(.distanceCycling, timeRange: .ever)
    private var cyclingDistanceSamples
    @HealthKitStatisticsQuery(.distanceCycling, aggregatedBy: [.sum], over: .year, timeRange: .ever)
    private var cyclingDistanceStats
    
    var body: some View {
        Form {
            Section {
                LabeledContent("Blood Type", value: (bloodType?.displayTitle).map { String(localized: $0) } ?? "n/a")
                LabeledContent("#cyclingSamples", value: cyclingDistanceSamples.count, format: .number)
                LabeledContent(
                    "#km cycled",
                    // swiftlint:disable:next force_unwrapping
                    value: cyclingDistanceStats.reduce(into: 0) { $0 += $1.sumQuantity()!.doubleValue(for: .meterUnit(with: .kilo)) },
                    format: .number
                )
            }
            Section {
                AsyncButton("Request BloodType", state: $viewState) {
                    try await healthKit.askForAuthorization(for: .init(read: [HKCharacteristicType(.bloodType)]))
                }
                AsyncButton("Request CyclingDistance", state: $viewState) {
                    try await healthKit.askForAuthorization(for: .init(read: [HKQuantityType(.distanceCycling)]))
                }
            }
        }
    }
}
