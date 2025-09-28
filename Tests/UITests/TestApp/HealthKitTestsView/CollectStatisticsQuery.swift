//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import SpeziViews
import SwiftUI

@MainActor
@Observable
class CollectStatisticsQueryViewModel {
    static let shared = CollectStatisticsQueryViewModel()
    var dailyStepCountStats: [HKStatistics] = []
    var hourlyHeartRateState: [HKStatistics] = []
    
    func triggerStatisticsQueries(healthKit: HealthKit) async {
        do {
            dailyStepCountStats = try await healthKit.statisticsQuery(
                .stepCount,
                aggregatedBy: [.sum],
                over: .day,
                timeRange: .currentWeek
            )
            hourlyHeartRateState = try await healthKit.statisticsQuery(
                .heartRate,
                aggregatedBy: [.average, .min, .max],
                over: .hour,
                timeRange: .currentWeek
            )
        } catch {
            print(error)
        }
    }
}


struct CollectStatisticsQueryView: View {
    @Environment(HealthKit.self)
    private var healthKit
    
    @State var viewModel = CollectStatisticsQueryViewModel.shared
    
    var body: some View {
        Form {
            Section {
                AsyncButton("Trigger Statistics Queries") {
                    await viewModel.triggerStatisticsQueries(healthKit: healthKit)
                }
            }
            if !viewModel.dailyStepCountStats.isEmpty {
                Section("Daily Step Count Stats") {
                    ForEach(viewModel.dailyStepCountStats.reversed()) { statistics in
                        if let numSteps = statistics.sumQuantity()?.doubleValue(for: .count()) {
                            HStack {
                                Text("Steps on \((statistics.startDate..<statistics.endDate).middle.formatted(.iso8601))")
                                Spacer()
                                Text("\(Int(numSteps))").monospaced()
                            }
                        }
                    }
                }
            }
            if let heartRateState = viewModel.hourlyHeartRateState.first {
                Section("Heart Rate Stats for \(heartRateState.startDate.formatted(.iso8601))") {
                    makeRow(title: "Average", hkQuantity: heartRateState.averageQuantity())
                    makeRow(title: "Minimum", hkQuantity: heartRateState.minimumQuantity())
                    makeRow(title: "Maximum", hkQuantity: heartRateState.maximumQuantity())
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeRow(title: String, hkQuantity: HKQuantity?) -> some View {
        var unit = HKUnit.count().unitDivided(by: .minute())
        HStack {
            Text(title)
            Spacer()
            if let value = hkQuantity?.doubleValue(for: unit) {
                Text("\(Int(value)) \(unit.description)").monospaced()
                    .accessibilityIdentifier("hr-value-\(title.lowercased())")
            }
        }
    }
}
