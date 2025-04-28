// 
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import HealthKit
import SpeziHealthKit

/// A demonstration view that showcases all the enhanced visualization components
/// for health data. This view can be used in sample apps to demonstrate the
/// capabilities of the SpeziHealthKit visualizations.
public struct HealthVisualizationDemo: View {
    @HealthKitQuery(.heartRate, timeRange: .last(weeks: 1))
    private var heartRateSamples
    
    @HealthKitQuery(.stepCount, timeRange: .last(weeks: 1))
    private var stepCountSamples
    
    @HealthKitStatisticsQuery(.activeEnergyBurned, aggregatedBy: [.sum], over: .day, timeRange: .last(weeks: 1))
    private var energyStatistics
    
    public init() {
        // This is intentionally empty
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    featuredSection
                    
                    dashboardSection
                    
                    chartsSection
                    
                    visualComponentsSection
                }
                .padding()
            }
            .navigationTitle("Health Visualizations")
        }
    }
    
    private var featuredSection: some View {
        VStack(alignment: .leading) {
            Text("Featured")
                .font(.headline)
                .padding(.horizontal)
            
            HealthDashboard(
                items: [
                    HealthDashboard.heartRateItem(
                        samples: Array(heartRateSamples),
                        timeRange: .last(weeks: 1)
                    ),
                    HealthDashboard.stepsItem(
                        samples: Array(stepCountSamples),
                        timeRange: .last(weeks: 1)
                    ),
                    HealthDashboard.activeEnergyItem(
                        statistics: Array(energyStatistics),
                        timeRange: .last(weeks: 1)
                    )
                ],
                columns: 1,
                spacing: 16,
                padding: 0
            )
        }
    }
    
    private var dashboardSection: some View {
        VStack(alignment: .leading) {
            Text("Dashboard")
                .font(.headline)
                .padding(.horizontal)
            
            HealthDashboard(
                items: [
                    // Steps with activity ring
                    createStepsDashboardItem(),
                    
                    // Heart rate with area chart
                    createHeartRateDashboardItem(),
                    
                    // Active energy with gauge
                    createEnergyDashboardItem()
                ],
                columns: 2,
                spacing: 12,
                padding: 0
            )
        }
    }
    
    private var chartsSection: some View {
        VStack(alignment: .leading) {
            Text("Enhanced Charts")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                // Area chart
                DemoCard(title: "Area Chart") {
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
                DemoCard(title: "Scatter with Trend") {
                    EnhancedHealthChart.scatterPlot {
                        createHeartRateEntry()
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
                
                // Range chart
                DemoCard(title: "Range Chart") {
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
            Text("Visual Components")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                // Circular progress
                DemoCard(title: "Circular Progress") {
                    CircularProgressView(
                        value: 8500,
                        target: 10000,
                        metric: "Steps",
                        color: .blue,
                        unit: "steps"
                    )
                    .frame(height: 180)
                }
                
                // Activity rings
                DemoCard(title: "Activity Rings") {
                    ActivityRingsView(
                        rings: [
                            (progress: 0.75, colors: (start: .red, end: .orange)),
                            (progress: 0.45, colors: (start: .green, end: .mint)),
                            (progress: 0.9, colors: (start: .blue, end: .cyan))
                        ],
                        centerContent: Text("75%")
                            .font(.title3.bold())
                    )
                    .frame(height: 180)
                }
                
                // Gauge
                DemoCard(title: "Health Gauge") {
                    HealthGaugeView(
                        value: 124,
                        range: 40...200,
                        label: "Heart Rate",
                        color: .red
                    )
                    .frame(height: 180)
                }
                
                // Multiple rings
                DemoCard(title: "Multiple Metrics") {
                    VStack {
                        Text("Week Progress")
                            .font(.subheadline)
                        
                        ActivityRingsView(
                            rings: [
                                (progress: 0.85, colors: (start: .blue, end: .cyan)),
                                (progress: 0.62, colors: (start: .green, end: .mint)),
                                (progress: 0.38, colors: (start: .orange, end: .red))
                            ]
                        )
                        .frame(height: 120)
                        
                        HStack {
                            Label("Steps", systemImage: "figure.walk")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Spacer()
                            Label("Calories", systemImage: "flame.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Spacer()
                            Label("Exercise", systemImage: "heart.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createHeartRateEntry() -> HealthChartEntry<HealthKitQueryResultsContainer<HKQuantitySample>> {
        HealthChartEntry(
            HealthKitQueryResultsContainer(
                sampleType: SampleType<HKQuantitySample>.heartRate,
                samples: Array(heartRateSamples),
                timeRange: .last(weeks: 1),
                queryError: nil as (any Error)?
            ),
            drawingConfig: .init(mode: .line, color: .red)
        )
    }
    
    private func createStepsDashboardItem() -> HealthDashboard.ItemConfig {
        let samples = Array(stepCountSamples)
        let dailyGoal = 10000.0
        let latestValue = samples.last?.quantity.doubleValue(for: HKUnit.count()) ?? 0
        
        let progress = min(latestValue / dailyGoal, 1.0)
        let activityRing = ActivityRingsView(
            rings: [(
                progress: progress,
                colors: (start: .blue, end: .cyan)
            )],
            centerContent: VStack {
                Text("\(Int(latestValue))")
                    .font(.title2.bold())
                Text("Steps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        )
        
        return HealthDashboard.ItemConfig(
            title: "Steps",
            subtitle: "Daily Goal: \(Int(dailyGoal))",
            visualization: .activityRings(activityRing)
        )
    }
    
    private func createHeartRateDashboardItem() -> HealthDashboard.ItemConfig {
        let chart = EnhancedHealthChart.areaChart {
            createHeartRateEntry()
        }
        
        return HealthDashboard.ItemConfig(
            title: "Heart Rate",
            subtitle: "Last week",
            visualization: .enhancedChart(chart)
        )
    }
    
    private func createEnergyDashboardItem() -> HealthDashboard.ItemConfig {
        let statistics = Array(energyStatistics)
        let dailyGoal = 600.0
        
        let latestValue = statistics.last?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
        
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
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HealthVisualizationDemo()
} 