//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import SpeziHealthKitUI
import SwiftUI


struct EnhancedVisualizationsView: View {
    @Environment(HealthKit.self) private var healthKit
    
    @HealthKitQuery(.heartRate, timeRange: .last(weeks: 1))
    private var heartRateSamples
    
    @HealthKitQuery(.stepCount, timeRange: .last(weeks: 1))
    private var stepCountSamples
    
    @HealthKitStatisticsQuery(.activeEnergyBurned, aggregatedBy: [.sum], over: .day, timeRange: .last(weeks: 1))
    private var energyStatistics
    
    // Mock data for when actual data isn't available
    private let mockHeartRates: [Double] = [65, 72, 68, 75, 80, 72, 68, 70, 75, 82, 79, 73]
    private let mockSteps: Double = 8542
    private let mockCalories: Double = 385
    
    // Daily step goal
    private let dailyStepGoal: Double = 10000
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                dashboardSection
                
                chartsSection
                
                visualComponentsSection
            }
            .padding()
        }
        .navigationTitle("Health Visuals")
    }
    
    private var dashboardSection: some View {
        VStack(alignment: .leading) {
            Text("Health Dashboard")
                .font(.headline)
                .padding(.horizontal)
            
            HealthDashboard(
                items: [
                    // Heart rate with area chart
                    createHeartRateItem(),
                    
                    // Steps with activity ring
                    createStepsItem(),
                    
                    // Active energy with gauge
                    createEnergyItem()
                ],
                columns: 1,
                spacing: 16,
                padding: 0
            )
        }
    }
    
    private var chartsSection: some View {
        VStack(alignment: .leading) {
            Text("Chart Types")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                // Area chart
                DemoCard(title: "Area and Average Chart") {
                    EnhancedHealthChart.areaChart(
                        timeInterval: .week,
                        showAverage: true
                    ) {
                        createHeartRateEntry()
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
                
                // Scatter with trend
                DemoCard(title: "Scatter Plot with Trend Line") {
                    EnhancedHealthChart.scatterPlot {
                        createHeartRateEntry()
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
                
                // Range chart
                DemoCard(title: "Range Chart (Min/Max)") {
                    EnhancedHealthChart.rangeChart {
                        createHeartRateEntry()
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var visualComponentsSection: some View {
        VStack(alignment: .leading) {
            Text("Ring and Gauge Components")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 20) {
                VStack {
                    Text("Activity Rings")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                    
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
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                HStack(spacing: 20) {
                    VStack {
                        Text("Steps Progress")
                            .font(.subheadline)
                        CircularProgressView(
                            value: getLatestDailyStepCount(),
                            target: dailyStepGoal,
                            metric: "Steps",
                            color: .blue,
                            unit: "steps"
                        )
                        .frame(height: 140)
                    }
                    
                    VStack {
                        Text("Heart Rate")
                            .font(.subheadline)
                        HealthGaugeView(
                            value: Array(heartRateSamples).isEmpty ? 72 :
                                (Array(heartRateSamples).last?.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) ?? 72),
                            range: 40...200,
                            label: "Current",
                            color: .red
                        )
                        .frame(height: 140)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                VStack(spacing: 16) {
                    Text("Dashboard Cards")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 12) {
                        DashboardCard(
                            title: "Heart Rate",
                            value: Array(heartRateSamples).isEmpty ? "72" : 
                                "\(Int(Array(heartRateSamples).last?.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) ?? 72))",
                            unit: "bpm",
                            icon: "heart.fill",
                            color: .red
                        )
                        
                        DashboardCard(
                            title: "Steps",
                            value: "\(Int(getLatestDailyStepCount()))",
                            unit: "steps",
                            icon: "figure.walk",
                            color: .blue
                        )
                    }
                    
                    HStack(spacing: 12) {
                        DashboardCard(
                            title: "Calories",
                            value: Array(energyStatistics).isEmpty ? "\(Int(mockCalories))" :
                                "\(Int(Array(energyStatistics).last?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? mockCalories))",
                            unit: "kcal",
                            icon: "flame.fill",
                            color: .orange
                        )
                        
                        DashboardCard(
                            title: "Sleep",
                            value: "7.5",
                            unit: "hours",
                            icon: "bed.double.fill",
                            color: .purple
                        )
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createHeartRateEntry() -> HealthChartEntry<HealthKitQueryResultsContainer<HKQuantitySample>> {
        let samples = Array(heartRateSamples)
        
        if samples.isEmpty {
            return createMockHeartRateEntry()
        }
        
        return HealthChartEntry(
            HealthKitQueryResultsContainer(
                sampleType: SampleType<HKQuantitySample>.heartRate,
                samples: samples,
                timeRange: .last(weeks: 1),
                queryError: nil as (any Error)?
            ),
            drawingConfig: .init(mode: .line, color: .red)
        )
    }
    
    private func createMockHeartRateEntry() -> HealthChartEntry<HealthKitQueryResultsContainer<HKQuantitySample>> {
        let mockSamples = mockHeartRates.enumerated().map { index, rate -> HKQuantitySample in
            let date = Date().addingTimeInterval(-1 * Double(12 - index) * 3600)
            return HKQuantitySample(
                type: HKQuantityType(.heartRate),
                quantity: HKQuantity(unit: HKUnit.count().unitDivided(by: .minute()), doubleValue: rate),
                start: date,
                end: date
            )
        }
        
        return HealthChartEntry(
            HealthKitQueryResultsContainer(
                sampleType: SampleType<HKQuantitySample>.heartRate,
                samples: mockSamples,
                timeRange: .last(weeks: 1),
                queryError: nil as (any Error)?
            ),
            drawingConfig: .init(mode: .line, color: .red)
        )
    }
    
    private func createHeartRateItem() -> HealthDashboard.ItemConfig {
        let chart = EnhancedHealthChart.areaChart {
            createHeartRateEntry()
        }
        
        return HealthDashboard.ItemConfig(
            title: "Heart Rate",
            subtitle: "Last week",
            visualization: .enhancedChart(chart)
        )
    }
    
    private func createStepsItem() -> HealthDashboard.ItemConfig {
        let samples = Array(stepCountSamples)
        let latestSteps = getLatestDailyStepCount()
        
        let progress = min(latestSteps / dailyStepGoal, 1.0)
        let activityRing = ActivityRingsView(
            rings: [(
                progress: progress,
                colors: (start: .blue, end: .cyan)
            )],
            centerContent: VStack {
                Text("\(Int(latestSteps))")
                    .font(.title2.bold())
                Text("Steps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        )
        
        return HealthDashboard.ItemConfig(
            title: "Steps",
            subtitle: "Daily Goal: \(Int(dailyStepGoal))",
            visualization: .activityRings(activityRing)
        )
    }
    
    private func createEnergyItem() -> HealthDashboard.ItemConfig {
        let statistics = Array(energyStatistics)
        let dailyGoal = 600.0
        
        let latestValue = statistics.isEmpty ? mockCalories :
            (statistics.last?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? mockCalories)
        
        let gauge = HealthGaugeView(
            value: latestValue,
            range: 0...dailyGoal * 1.5,
            label: "Active Energy",
            color: .orange
        )
        
        return HealthDashboard.ItemConfig(
            title: "Active Energy",
            subtitle: "\(Int(latestValue)) / \(Int(dailyGoal)) kcal",
            visualization: .gauge(gauge)
        )
    }
    
    // Returns the step count for today only
    private func getLatestDailyStepCount() -> Double {
        // Use a fixed mock value for demo purposes
        return 2000
    }
}

/// Dashboard card view for health metrics
struct DashboardCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                Spacer()
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.title2.bold())
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

/// A simple card view for the demo
private struct DemoCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal)
                .padding(.top, 12)
            
            content
                .padding(.bottom, 12)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        EnhancedVisualizationsView()
    }
} 