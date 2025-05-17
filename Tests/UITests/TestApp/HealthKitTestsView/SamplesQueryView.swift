//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import SpeziHealthKitUI
import SwiftUI


struct SamplesQueryView: View {
    @Environment(HealthKit.self) private var healthKit
    
    @HealthKitQuery(.stepCount, timeRange: .today)
    private var stepSamples
    
    @HealthKitQuery(.heartRate, timeRange: .today)
    private var heartRateSamples
    
    @HealthKitQuery(.bloodOxygen, timeRange: .today)
    private var bloodOxygenSamples
    
    @HealthKitQuery(.sleepAnalysis, timeRange: .ever)
    private var sleepAnalysisSamples
    
    var body: some View {
        Form {
            Section {
                HealthChart {
                    HealthChartEntry($heartRateSamples, drawingConfig: .init(chartType: .line, color: .red))
                    HealthChartEntry($bloodOxygenSamples, drawingConfig: .init(chartType: .line, color: .blue))
                }
                .frame(height: 270)
            }
            makeSection(for: $stepSamples)
            sleepSamplesSection
        }
        .navigationTitle("Samples Query")
    }
    
    @ViewBuilder private var sleepSamplesSection: some View {
        let sessions = (try? sleepAnalysisSamples.splitIntoSleepSessions()) ?? []
        ForEach(sessions, id: \.self) { session in
            Section {
                LabeledContent("TimeRange", value: "\(session.startDate.ISO8601Format()) – \(session.endDate.ISO8601Format())")
                LabeledContent("totalTimeTracked", value: Duration.seconds(session.totalTimeTracked).formatted())
            }
        }
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
