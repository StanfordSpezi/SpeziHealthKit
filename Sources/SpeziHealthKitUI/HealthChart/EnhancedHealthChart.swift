// 
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import Charts
import HealthKit
import SpeziHealthKit

/// Enhanced health chart that provides additional visualization options
/// including area charts, scatter plots with trend lines, and gauges.
public struct EnhancedHealthChart: View {
    public typealias ContentBuilder = HealthChart.ContentBuilder
    
    private let entries: [any HealthChartEntryProtocol]
    private let timeInterval: TimeInterval
    private let chartStyle: ChartStyle
    private let showAverage: Bool
    private let averageLineStyle: AverageLineStyle
    private let animate: Bool
    
    /// Style options for enhanced health charts
    public enum ChartStyle {
        /// Standard line chart
        case line
        /// Bar chart
        case bar
        /// Point chart
        case point
        /// Area chart with gradient fill
        case area
        /// Scatter plot with trend line
        case scatterWithTrend
        /// Range chart showing min and max values
        case range
    }
    
    /// Style options for the average line
    public struct AverageLineStyle {
        let lineWidth: CGFloat
        let color: Color
        let dashPattern: [CGFloat]
        
        public init(
            lineWidth: CGFloat = 2,
            color: Color = .red,
            dashPattern: [CGFloat] = [5, 5]
        ) {
            self.lineWidth = lineWidth
            self.color = color
            self.dashPattern = dashPattern
        }
        
        /// Default average line style
        @MainActor public static let `default` = AverageLineStyle()
    }
    
    @Environment(\.locale) private var locale
    @Environment(\.timeZone) private var timeZone
    @Environment(\.calendar) private var calendar
    
    @State private var animationProgress: CGFloat = 0
    
    /// Creates a new Enhanced Health Chart
    /// - Parameters:
    ///   - timeInterval: The time interval for the chart
    ///   - chartStyle: The style of chart to display
    ///   - showAverage: Whether to show an average line
    ///   - averageLineStyle: Style configuration for the average line
    ///   - animate: Whether to animate the chart on appearance
    ///   - entries: Health chart entries to display
    public init(
        timeInterval timeIntervalInput: HealthChart.TimeIntervalInput = .automatic,
        chartStyle: ChartStyle = .line,
        showAverage: Bool = false,
        averageLineStyle: AverageLineStyle = .default,
        animate: Bool = true,
        @ContentBuilder entries: () -> [any HealthChartEntryProtocol]
    ) {
        let entryValues = entries()
        self.entries = entryValues
        self.chartStyle = chartStyle
        self.showAverage = showAverage
        self.averageLineStyle = averageLineStyle
        self.animate = animate
        
        switch timeIntervalInput {
        case .automatic:
            self.timeInterval = { () -> TimeInterval in
                var retval: TimeInterval = 0
                for entry in entryValues {
                    guard !entry.isEmpty else {
                        continue
                    }
                    let entryInterval = entry.resultsTimeRange.range.upperBound.distance(to: entry.resultsTimeRange.range.lowerBound)
                    retval = max(retval, entryInterval)
                }
                return retval
            }()
        case .custom(let timeInterval):
            self.timeInterval = timeInterval
        }
    }
    
    public var body: some View {
        if entries.isEmpty {
            Text("No Data")
        } else {
            chart
                .onAppear {
                    if animate {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            animationProgress = 1.0
                        }
                    } else {
                        animationProgress = 1.0
                    }
                }
        }
    }
    
    @ViewBuilder
    private var chart: some View {
        Chart {
            chartContent
        }
        .transforming { view in
            if timeInterval > 0 {
                view.chartXVisibleDomain(length: timeInterval)
            } else {
                view
            }
        }
        .chartForegroundStyleScale({ () -> KeyValuePairs<String, Color> in
            var mapping: [(String, Color)] = []
            for entry in entries {
                mapping.append((entry.resultsSampleType.displayTitle, entry.drawingConfig.color))
            }
            return KeyValuePairs<String, Color>(mapping)
        }())
        .transforming { view in
            let valuesRange = { () -> ClosedRange<Double>? in
                var range: ClosedRange<Double>?
                for entry in entries {
                    guard let expectedRange = (entry.resultsSampleType as? SampleType<HKQuantitySample>)?.expectedValuesRange else {
                        continue
                    }
                    if let currentRange = range {
                        range = min(currentRange.lowerBound, expectedRange.lowerBound)...max(currentRange.upperBound, expectedRange.upperBound)
                    } else {
                        range = expectedRange
                    }
                }
                return range
            }()
            if let valuesRange {
                view.chartYScale(domain: [valuesRange.lowerBound, valuesRange.upperBound])
            } else {
                view
            }
        }
        .chartXAxis {
            HealthChart.xAxisContent(for: entries)
        }
    }
    
    private var chartContent: AnyChartContent {
        var blocks: [AnyChartContent] = []
        for entry in entries {
            guard !entry.isEmpty, !entry.resultsDataPoints.isEmpty else {
                continue
            }
            blocks.append(AnyChartContent(erasing: ChartContentBuilder.buildExpression(makeChartContent(for: entry))))
            
            // Add average line if requested
            if showAverage {
                blocks.append(AnyChartContent(erasing: ChartContentBuilder.buildExpression(makeAverageContent(for: entry))))
            }
        }
        
        var content = AnyChartContent(erasing: ChartContentBuilder.buildBlock())
        for block in blocks {
            if #available(iOS 18, macOS 15, *) {
                content = AnyChartContent(erasing: ChartContentBuilder.buildBlock(content, block))
            } else {
                content = AnyChartContent(erasing: ChartContentBuilder.buildPartialBlock(accumulated: content, next: block))
            }
        }
        return content
    }
    
    @ChartContentBuilder
    private func makeChartContent(for entry: any HealthChartEntryProtocol) -> some ChartContent {
        let name = entry.resultsSampleType.displayTitle
        
        ForEach(entry.resultsDataPoints) { dataPoint in
            let xVal: PlottableValue = .value("Date", dataPoint.date)
            let yVal: PlottableValue = .value(name, dataPoint.value * (entry.resultsSampleType == SampleType<HKQuantitySample>.bloodOxygen ? 100 : 1))
            
            SomeChartContent {
                switch chartStyle {
                case .line:
                    LineMark(x: xVal, y: yVal)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                case .bar:
                    BarMark(x: xVal, y: yVal)
                case .point:
                    PointMark(x: xVal, y: yVal)
                case .area:
                    AreaMark(x: xVal, y: yVal)
                        .opacity(0.3 * animationProgress)
                        .interpolationMethod(.catmullRom)
                    LineMark(x: xVal, y: yVal)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                case .scatterWithTrend:
                    PointMark(x: xVal, y: yVal)
                    
                    // Only add trend line if we have enough data points
                    if entry.resultsDataPoints.count >= 3 {
                        let trendPoints = calculateTrendLine(for: entry.resultsDataPoints)
                        ForEach(trendPoints, id: \.id) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value(name, point.value * (entry.resultsSampleType == SampleType<HKQuantitySample>.bloodOxygen ? 100 : 1))
                            )
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))
                            .opacity(0.7 * animationProgress)
                        }
                    }
                case .range:
                    if let (minPoints, maxPoints) = calculateRangeValues(for: entry.resultsDataPoints) {
                        ForEach(minPoints, id: \.id) { minPoint in
                            let maxPoint = maxPoints.first { abs($0.date.timeIntervalSince(minPoint.date)) < 1 }
                            if let maxPoint = maxPoint {
                                RectangleMark(
                                    x: .value("Date", minPoint.date),
                                    yStart: .value("Min", minPoint.value * (entry.resultsSampleType == SampleType<HKQuantitySample>.bloodOxygen ? 100 : 1)),
                                    yEnd: .value("Max", maxPoint.value * (entry.resultsSampleType == SampleType<HKQuantitySample>.bloodOxygen ? 100 : 1))
                                )
                                .opacity(0.3 * animationProgress)
                            }
                        }
                        LineMark(x: xVal, y: yVal)
                            .lineStyle(StrokeStyle(lineWidth: 2.5))
                    } else {
                        LineMark(x: xVal, y: yVal)
                            .lineStyle(StrokeStyle(lineWidth: 2.5))
                    }
                }
            }
        }
        .foregroundStyle(by: .value("Sample Type", entry.resultsSampleType.displayTitle))
    }
    
    @ChartContentBuilder
    private func makeAverageContent(for entry: any HealthChartEntryProtocol) -> some ChartContent {
        let name = "\(entry.resultsSampleType.displayTitle) Average"
        let dataPoints = entry.resultsDataPoints
        
        if !dataPoints.isEmpty {
            let averageValue = dataPoints.reduce(0) { $0 + $1.value } / Double(dataPoints.count)
            let adjustedValue = averageValue * (entry.resultsSampleType == SampleType<HKQuantitySample>.bloodOxygen ? 100 : 1)
            
            // We need at least the first and last date to draw the average line
            if let firstDate = dataPoints.first?.date, let lastDate = dataPoints.last?.date {
                RuleMark(
                    y: .value(name, adjustedValue)
                )
                .lineStyle(StrokeStyle(
                    lineWidth: averageLineStyle.lineWidth,
                    dash: averageLineStyle.dashPattern
                ))
                .foregroundStyle(averageLineStyle.color)
                .opacity(animationProgress)
                .annotation(position: .top, alignment: .trailing) {
                    Text("Avg: \(String(format: "%.1f", adjustedValue))")
                        .font(.caption)
                        .foregroundStyle(averageLineStyle.color)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.8))
                        )
                }
            }
        }
    }
    
    // Helper functions for advanced chart visualizations
    
    private func calculateTrendLine(for dataPoints: [HealthChartDataPoint]) -> [HealthChartDataPoint] {
        guard dataPoints.count >= 2 else { return [] }
        
        // Simple linear regression to calculate trend line
        let n = Double(dataPoints.count)
        let dates = dataPoints.map { $0.date.timeIntervalSince1970 }
        let values = dataPoints.map { $0.value }
        
        let sumX = dates.reduce(0, +)
        let sumY = values.reduce(0, +)
        let sumXY = zip(dates, values).map(*).reduce(0, +)
        let sumX2 = dates.map { $0 * $0 }.reduce(0, +)
        
        let slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
        let intercept = (sumY - slope * sumX) / n
        
        // Create trend line points
        if let firstDate = dataPoints.first?.date, let lastDate = dataPoints.last?.date {
            let firstValue = slope * firstDate.timeIntervalSince1970 + intercept
            let lastValue = slope * lastDate.timeIntervalSince1970 + intercept
            
            return [
                HealthChartDataPoint(
                    id: "trend_start",
                    date: firstDate,
                    value: firstValue,
                    unit: dataPoints.first?.unit ?? .count()
                ),
                HealthChartDataPoint(
                    id: "trend_end",
                    date: lastDate,
                    value: lastValue,
                    unit: dataPoints.first?.unit ?? .count()
                )
            ]
        }
        
        return []
    }
    
    private func calculateRangeValues(for dataPoints: [HealthChartDataPoint]) -> ([HealthChartDataPoint], [HealthChartDataPoint])? {
        guard dataPoints.count >= 4 else { return nil }
        
        // Group data points by day for range calculation
        let calendar = Calendar.current
        var groupedByDay: [Date: [HealthChartDataPoint]] = [:]
        
        for point in dataPoints {
            let day = calendar.startOfDay(for: point.date)
            if groupedByDay[day] == nil {
                groupedByDay[day] = []
            }
            groupedByDay[day]?.append(point)
        }
        
        var minPoints: [HealthChartDataPoint] = []
        var maxPoints: [HealthChartDataPoint] = []
        
        for (day, points) in groupedByDay {
            if points.count >= 2 {
                if let minPoint = points.min(by: { $0.value < $1.value }) {
                    let min = HealthChartDataPoint(
                        id: "min_\(day.timeIntervalSince1970)",
                        date: day,
                        value: minPoint.value,
                        unit: minPoint.unit
                    )
                    minPoints.append(min)
                }
                
                if let maxPoint = points.max(by: { $0.value < $1.value }) {
                    let max = HealthChartDataPoint(
                        id: "max_\(day.timeIntervalSince1970)",
                        date: day,
                        value: maxPoint.value,
                        unit: maxPoint.unit
                    )
                    maxPoints.append(max)
                }
            }
        }
        
        return (minPoints, maxPoints)
    }
}

// MARK: - Additional Visualization Components

/// A gauge-style view for displaying health metrics
public struct HealthGaugeView: View {
    private let value: Double
    private let range: ClosedRange<Double>
    private let label: String
    private let color: Color
    private let showAnimation: Bool
    
    @State private var animatedValue: Double = 0
    
    /// Creates a new health gauge view
    /// - Parameters:
    ///   - value: Current value
    ///   - range: Range of possible values
    ///   - label: Label for the gauge
    ///   - color: Color of the gauge
    ///   - showAnimation: Whether to animate on appearance
    public init(
        value: Double,
        range: ClosedRange<Double>,
        label: String,
        color: Color = .blue,
        showAnimation: Bool = true
    ) {
        self.value = min(max(value, range.lowerBound), range.upperBound)
        self.range = range
        self.label = label
        self.color = color
        self.showAnimation = showAnimation
    }
    
    public var body: some View {
        Gauge(
            value: animatedValue,
            in: range.lowerBound...range.upperBound
        ) {
            Text(label)
        } currentValueLabel: {
            Text(formattedValue)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(color)
        .scaleEffect(1.5)
        .onAppear {
            if showAnimation {
                withAnimation(.easeInOut(duration: 1.0)) {
                    animatedValue = value
                }
            } else {
                animatedValue = value
            }
        }
    }
    
    private var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}

/// Additional convenience initializers for EnhancedHealthChart
public extension EnhancedHealthChart {
    /// Creates an area chart with the given entries
    static func areaChart(
        timeInterval: HealthChart.TimeIntervalInput = .automatic,
        showAverage: Bool = true,
        animate: Bool = true,
        @ContentBuilder entries: () -> [any HealthChartEntryProtocol]
    ) -> EnhancedHealthChart {
        EnhancedHealthChart(
            timeInterval: timeInterval,
            chartStyle: .area,
            showAverage: showAverage,
            animate: animate,
            entries: entries
        )
    }
    
    /// Creates a scatter plot with trend line
    static func scatterPlot(
        timeInterval: HealthChart.TimeIntervalInput = .automatic,
        showAverage: Bool = false,
        animate: Bool = true,
        @ContentBuilder entries: () -> [any HealthChartEntryProtocol]
    ) -> EnhancedHealthChart {
        EnhancedHealthChart(
            timeInterval: timeInterval,
            chartStyle: .scatterWithTrend,
            showAverage: showAverage,
            animate: animate,
            entries: entries
        )
    }
    
    /// Creates a range chart showing min and max values
    static func rangeChart(
        timeInterval: HealthChart.TimeIntervalInput = .automatic,
        animate: Bool = true,
        @ContentBuilder entries: () -> [any HealthChartEntryProtocol]
    ) -> EnhancedHealthChart {
        EnhancedHealthChart(
            timeInterval: timeInterval,
            chartStyle: .range,
            showAverage: false,
            animate: animate,
            entries: entries
        )
    }
} 
