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

/// A dashboard component for displaying multiple health metrics with various visualizations.
///
/// This component provides a configurable grid layout to display multiple health metrics
/// in different visualization styles including charts, rings, and gauges.
public struct HealthDashboard: View {
    /// Configuration for a dashboard item
    public struct ItemConfig {
        /// Type of visualization to use for this item
        public enum VisualizationType {
            /// Standard health chart
            case chart(HealthChart)
            /// Enhanced health chart
            case enhancedChart(EnhancedHealthChart)
            /// Circular progress
            case circularProgress(CircularProgressView)
            /// Activity rings
            case activityRings(ActivityRingsView)
            /// Health gauge
            case gauge(HealthGaugeView)
            /// Custom view
            case custom(AnyView)
        }
        
        let title: String
        let subtitle: String?
        let visualization: VisualizationType
        let backgroundColor: Color
        let cornerRadius: CGFloat
        
        /// Creates a new dashboard item configuration
        /// - Parameters:
        ///   - title: Title of the dashboard item
        ///   - subtitle: Optional subtitle
        ///   - visualization: Type of visualization to use
        ///   - backgroundColor: Background color for the item
        ///   - cornerRadius: Corner radius for the item
        public init(
            title: String,
            subtitle: String? = nil,
            visualization: VisualizationType,
            backgroundColor: Color = Color(.systemBackground),
            cornerRadius: CGFloat = 12
        ) {
            self.title = title
            self.subtitle = subtitle
            self.visualization = visualization
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
        }
    }
    
    private let items: [ItemConfig]
    private let columns: Int
    private let spacing: CGFloat
    private let padding: CGFloat
    
    /// Creates a new health dashboard
    /// - Parameters:
    ///   - items: Array of dashboard item configurations
    ///   - columns: Number of columns in the grid
    ///   - spacing: Spacing between items
    ///   - padding: Padding around the dashboard
    public init(
        items: [ItemConfig],
        columns: Int = 2,
        spacing: CGFloat = 16,
        padding: CGFloat = 16
    ) {
        self.items = items
        self.columns = max(1, columns)
        self.spacing = spacing
        self.padding = padding
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns), spacing: spacing) {
                ForEach(0..<items.count, id: \.self) { index in
                    dashboardItem(for: items[index])
                }
            }
            .padding(padding)
        }
    }
    
    @ViewBuilder
    private func dashboardItem(for config: ItemConfig) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(config.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let subtitle = config.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Visualization
            visualizationView(for: config.visualization)
                .frame(minHeight: 200)
                .padding(.bottom)
        }
        .background(config.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    private func visualizationView(for visualization: ItemConfig.VisualizationType) -> some View {
        switch visualization {
        case .chart(let chart):
            chart
        case .enhancedChart(let enhancedChart):
            enhancedChart
        case .circularProgress(let circularProgress):
            circularProgress
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .padding()
        case .activityRings(let activityRings):
            activityRings
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .padding()
        case .gauge(let gauge):
            gauge
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .padding()
        case .custom(let view):
            view
        }
    }
}

/// Factory methods to create common dashboard configurations
public extension HealthDashboard {
    /// Creates a dashboard item for steps data
    static func stepsItem(
        samples: [HKQuantitySample],
        timeRange: HealthKitQueryTimeRange,
        dailyGoal: Double = 10000
    ) -> ItemConfig {
        let latestValue = samples.last?.quantity.doubleValue(for: .count()) ?? 0
        
        // Create activity ring
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
        
        return ItemConfig(
            title: "Steps",
            subtitle: "Daily Goal: \(Int(dailyGoal))",
            visualization: .activityRings(activityRing)
        )
    }
    
    /// Creates a dashboard item for heart rate data
    static func heartRateItem(
        samples: [HKQuantitySample],
        timeRange: HealthKitQueryTimeRange
    ) -> ItemConfig {
        // Create heart rate chart entry
        let entry = HealthChartEntry(
            HealthKitQueryResultsContainer(
                sampleType: SampleType<HKQuantitySample>.heartRate,
                samples: samples,
                timeRange: timeRange,
                queryError: nil as (any Error)?
            ),
            drawingConfig: .init(mode: .line, color: .red)
        )
        
        // Create enhanced chart
        let chart = EnhancedHealthChart.areaChart {
            entry
        }
        
        return ItemConfig(
            title: "Heart Rate",
            subtitle: "BPM over time",
            visualization: .enhancedChart(chart)
        )
    }
    
    /// Creates a dashboard item for active energy data
    static func activeEnergyItem(
        statistics: [HKStatistics],
        timeRange: HealthKitQueryTimeRange,
        dailyGoal: Double = 600
    ) -> ItemConfig {
        // Get the latest value
        let latestValue = statistics.last?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
        
        // Create gauge
        let gauge = HealthGaugeView(
            value: latestValue,
            range: 0...dailyGoal * 1.5,
            label: "Active Energy",
            color: .orange
        )
        
        return ItemConfig(
            title: "Active Energy",
            subtitle: "\(Int(latestValue)) / \(Int(dailyGoal)) kcal",
            visualization: .gauge(gauge)
        )
    }
}

// MARK: - Helper Types

/// A container for HealthKit query results to be used with HealthChartEntry
public struct HealthKitQueryResultsContainer<S>: HealthKitQueryResults where S: _HKSampleWithSampleType, S: Identifiable {
    public typealias Sample = S
    public typealias Element = S
    
    public let sampleType: SampleType<Sample>
    public let timeRange: HealthKitQueryTimeRange
    public let queryError: (any Error)?
    public let isCurrentlyPerformingInitialFetch: Bool = false
    
    private let elements: [Sample]
    
    /// Creates a new container with the provided samples
    public init(
        sampleType: SampleType<Sample>,
        samples: [Sample],
        timeRange: HealthKitQueryTimeRange,
        queryError: (any Error)?
    ) {
        self.sampleType = sampleType
        self.elements = samples
        self.timeRange = timeRange
        self.queryError = queryError
    }
    
    public func makeIterator() -> Array<Sample>.Iterator {
        elements.makeIterator()
    }
    
    public var startIndex: Int {
        elements.startIndex
    }
    
    public var endIndex: Int {
        elements.endIndex
    }
    
    public subscript(position: Int) -> Sample {
        elements[position]
    }
    
    public func index(after i: Int) -> Int {
        elements.index(after: i)
    }
} 