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
    
    @HealthKitQuery(.heartRate, timeRange: .today)
    private var heartRateSamples
    
    @HealthKitQuery(.bloodOxygen, timeRange: .today)
    private var bloodOxygenSamples
    
    var body: some View {
        Form {
            Section {
                HealthChart {
                    HealthChartEntry($heartRateSamples, drawingConfig: .init(mode: .line, color: .red))
                    HealthChartEntry($bloodOxygenSamples, drawingConfig: .init(mode: .line, color: .blue))
                }
                .frame(height: 270)
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
                    Text("\(results.sampleType.displayTitle) \(sample.quantity.doubleValue(for: results.sampleType.displayUnit), format: .number)")
                }
            }
        }
    }
}
