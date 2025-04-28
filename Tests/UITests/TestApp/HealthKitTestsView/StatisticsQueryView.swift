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


struct StatisticsQueryView: View {
    @Environment(HealthKit.self) private var healthKit
    
    @HealthKitQuery(.heartRate, timeRange: .currentWeek)
    private var heartRateSamples
    
    @HealthKitStatisticsQuery(.stepCount, aggregatedBy: [.sum], over: .day, timeRange: .currentWeek)
    private var dailyStepCountStats
    
    @HealthKitStatisticsQuery(.heartRate, aggregatedBy: [.average, .min, .max], over: .hour, timeRange: .currentWeek)
    private var hourlyHeartRateState
    
    @HealthKitStatisticsQuery(.activeEnergyBurned, aggregatedBy: [.sum], over: .day, timeRange: .currentWeek)
    private var dailyActiveEnergyStats
    
    // Mock data for visualizations when no real data is available
    private let mockDailySteps: [Double] = [7621, 8432, 5467, 9234, 6543, 10254, 8765]
    private let mockDailyLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    // Daily step goal
    private let dailyStepGoal: Double = 10000
    
    var body: some View {
        Form {
            Section {
                HealthChart {
                    HealthChartEntry($heartRateSamples, drawingConfig: .init(mode: .line, color: .red))
                }
                .frame(height: 300)
            }
            Section {
                HealthChart {
                    HealthChartEntry($hourlyHeartRateState, aggregationOption: .max, drawingConfig: .init(mode: .line, color: .red))
                    HealthChartEntry($hourlyHeartRateState, aggregationOption: .avg, drawingConfig: .init(mode: .line, color: .orange))
                    HealthChartEntry($hourlyHeartRateState, aggregationOption: .min, drawingConfig: .init(mode: .line, color: .yellow))
                }
            }
            
            Section("Health Insights") {
                Text("Heart Rate Zones")
                    .font(.headline)
                    .padding(.vertical, 8)
                
                heartRateZonesChart
                    .frame(height: 200)
                    .padding(.bottom)
            }
            
            Section("Visualization Components") {
                Text("Range Chart (Min/Max)")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                EnhancedHealthChart.rangeChart {
                    HealthChartEntry($hourlyHeartRateState, aggregationOption: .max, drawingConfig: .init(mode: .line, color: .red))
                    HealthChartEntry($hourlyHeartRateState, aggregationOption: .min, drawingConfig: .init(mode: .line, color: .yellow))
                }
                .frame(height: 250)
                
                Text("Activity Rings")
                    .font(.headline)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                
                VStack(spacing: 24) {
                    ActivityRingsView(
                        rings: [
                            (progress: 0.85, colors: (start: .red, end: .orange)),
                            (progress: 0.65, colors: (start: .green, end: .mint)),
                            (progress: 0.40, colors: (start: .blue, end: .cyan))
                        ],
                        centerContent: VStack {
                            Text("85%")
                                .font(.system(size: 14, weight: .bold))
                        }
                    )
                    .frame(height: 180)
                    .padding(.bottom, 10)
                    
                    Text("Dashboard Components")
                        .font(.headline)
                        .padding(.vertical, 8)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("Steps")
                                .font(.caption)
                            CircularProgressView(
                                value: getLatestDayStepCount(),
                                target: dailyStepGoal,
                                metric: "Today",
                                color: .blue,
                                unit: "steps"
                            )
                            .frame(height: 120)
                        }
                        
                        VStack {
                            Text("Heart Rate")
                                .font(.caption)
                            CircularProgressView(
                                value: 75,
                                target: 120,
                                metric: "Avg",
                                color: .red,
                                unit: "bpm"
                            )
                            .frame(height: 120)
                        }
                    }
                    .padding()
                    
                    HStack(spacing: 12) {
                        DashboardCard(
                            title: "Heart Rate",
                            value: "75",
                            unit: "bpm",
                            icon: "heart.fill",
                            color: .red
                        )
                        
                        DashboardCard(
                            title: "Steps",
                            value: "\(Int(getLatestDayStepCount()))",
                            unit: "steps",
                            icon: "figure.walk",
                            color: .blue
                        )
                    }
                    
                    HStack(spacing: 12) {
                        DashboardCard(
                            title: "Calories",
                            value: "\(Int(getLatestDayCalories()))",
                            unit: "kcal",
                            icon: "flame.fill",
                            color: .orange
                        )
                        
                        DashboardCard(
                            title: "Distance",
                            value: "2.5",
                            unit: "km",
                            icon: "figure.walk",
                            color: .green
                        )
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            Section("Raw Step Data") {
                ForEach(dailyStepCountStats.reversed()) { statistics in
                    if let numSteps = statistics.sumQuantity()?.doubleValue(for: .count()) {
                        HStack {
                            Text("Steps on \((statistics.startDate...statistics.endDate).middle.formatted(.dateTime.day().month(.abbreviated)))")
                            Spacer()
                            Text("\(Int(numSteps))").monospaced()
                        }
                    }
                }
            }
        }
        .navigationTitle("Statistics Query")
    }
    
    // MARK: - Heart Rate Zones Chart
    
    private var heartRateZonesChart: some View {
        let zoneData = getHeartRateZones()
        
        return VStack {
            HStack(spacing: 2) {
                ForEach(zoneData, id: \.zone) { zone in
                    ZStack {
                        Rectangle()
                            .fill(zone.color)
                            .frame(width: CGFloat(zone.percentage) * 3)
                        
                        if zone.percentage > 10 {
                            Text("\(Int(zone.percentage))%")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                        }
                    }
                }
            }
            .frame(height: 30)
            .cornerRadius(6)
            
            // Legend
            HStack(spacing: 12) {
                ForEach(zoneData, id: \.zone) { zone in
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(zone.color)
                            .frame(width: 10, height: 10)
                            .cornerRadius(2)
                        
                        Text(zone.zone)
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
            }
            .padding(.top, 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Average: 72 bpm")
                    .font(.subheadline)
                Text("Resting: 62 bpm")
                    .font(.subheadline)
                Text("Most time spent in: Rest zone")
                    .font(.subheadline)
            }
            .padding(.top, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Data Helpers
    
    private func getHeartRateZones() -> [(zone: String, percentage: Double, color: Color)] {
        return [
            ("Rest", 45, .blue),
            ("Light", 25, .green),
            ("Moderate", 15, .orange),
            ("Vigorous", 10, .red),
            ("Peak", 5, .purple)
        ]
    }
    
    private func getLatestDayStepCount() -> Double {
        // mock value
        return 2000
    }
    
    private func getLatestDayCalories() -> Double {
        // mock value
        return 320
    }
}


extension ClosedRange where Bound == Date {
    var middle: Date {
        lowerBound.addingTimeInterval(lowerBound.distance(to: upperBound) / 2)
    }
}
