//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import SwiftUI


struct SamplesQueryView: View {
    @Environment(HealthKit.self) private var healthKit
    
    @HealthKitQuery(.stepCount, timeRange: .today)
    private var stepSamples
    
    var body: some View {
        Form {
            Section {
                LabeledContent("#samples", value: "\(stepSamples.count)")
            }
            makeSection(for: $stepSamples)
        }
        .navigationTitle("Samples Query")
    }
    
    @ViewBuilder
    private func makeSection(
        for results: some HealthKitQueryResults<HKQuantitySample, HKQuantitySample>
    ) -> some View {
        Section(results.sampleType.displayTitle) {
            ForEach(results) { (sample: HKQuantitySample) in
                HStack {
                    Text(results.sampleType.displayTitle)
                    Text(sample.quantity.doubleValue(for: results.sampleType.displayUnit), format: .number)
                }
            }
        }
    }
}
