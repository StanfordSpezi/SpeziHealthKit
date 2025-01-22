//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Charts
import Foundation
import HealthKit
import SpeziFoundation
import SwiftUI


// sadly can't nest in the struct directly :/
// see https://github.com/swiftlang/swift/issues/72069
/// The desired width of the chart, in time units.
public enum HealthChartTimeIntervalInput {
    /// The chart's time interval (i.e., the total time range represented by the visible x axis at any time)
    /// should be determined automatically based on the specified chart entries.
    case automatic
    
    /// The chart's visible x axis time range should equal the specified custom `TimeInterval`
    case custom(TimeInterval)
    
    /// The chart's visible x axis time range should equal an hour
    public static var hour: Self { .custom(TimeConstants.hour) }
    
    /// The chart's visible x axis time range should equal a day
    public static var day: Self { .custom(TimeConstants.day) }
    
    /// The chart's visible x axis time range should equal a week
    public static var week: Self { .custom(TimeConstants.week) }
    
    /// The chart's visible x axis time range should equal a month
    public static var month: Self { .custom(TimeConstants.month) }
    
    /// The chart's visible x axis time range should equal a year
    public static var year: Self { .custom(TimeConstants.year) }
    
    /// The chart's visible x axis time range should cover the width of the specified range.
    public static func range(_ range: ClosedRange<Date>) -> Self {
        .custom(range.lowerBound.distance(to: range.upperBound))
    }
}


public struct HealthChart<each Results: HealthKitQueryResults>: View {
    let entry: (repeat HealthChartEntry<each Results>)
    /// The time interval for which the chart displays data, i.e. the "width" of the chart, in terms of how much time it represents/covers.
    let timeInterval: TimeInterval
    
    private var hasEntries: Bool {
        for entry in repeat each entry {
            if !entry.isEmpty { // swiftlint:disable:this for_where
                return true
            }
        }
        return false
    }
    
    
    @_documentation(visibility: internal)
    public var body: some View {
        if !hasEntries {
            Text("No Data")
        } else {
            chart
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
            func imp(_ entry: HealthChartEntry<some Any>) {
                mapping.append((entry.results.sampleType.displayTitle, entry.drawingConfig.color))
            }
            repeat imp(each entry)
            return KeyValuePairs<String, Color>(mapping)
        }())
        .transforming { view in
            let valuesRange = { () -> ClosedRange<Double>? in
                var range: ClosedRange<Double>?
                func imp(_ entry: HealthChartEntry<some Any>) {
                    guard let expectedRange = (entry.results.sampleType as? SampleType<HKQuantitySample>)?.expectedValuesRange else {
                        return
                    }
                    if let currentRange = range {
                        range = min(currentRange.lowerBound, expectedRange.lowerBound)...max(currentRange.upperBound, expectedRange.upperBound)
                    } else {
                        range = expectedRange
                    }
                }
                repeat imp(each entry)
                return range
            }()
            if let valuesRange {
                view.chartYScale(domain: [valuesRange.lowerBound, valuesRange.upperBound])
            } else {
                view
            }
        }
        .chartXAxis {
            xAxisContent()
        }
    }
    
    
    private var chartContent: AnyChartContent {
        // In an ideal world, we would simply place the `for entry in repeat each entry` loop directly in the `Chart { }` call.
        // BUT, sadly, we do not live in this world. (The ChartContentBuilder doesn't support for loops,
        // and there is no ForEach-equivalent that would work with a variadic tuple.)
        // So, what we do instead is that we essentially unroll the for loop into manual, explicit calls of the result builder functions.
        var blocks: [AnyChartContent] = []
        for entry in repeat each entry {
            guard !entry.isEmpty, !entry.results.isEmpty else {
                continue
            }
            guard entry.results.queryError == nil else {
                continue
            }
            blocks.append(AnyChartContent(erasing: ChartContentBuilder.buildExpression(makeChartContent(for: entry))))
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
    
    
    /// Creates a new Health Chart
    public init(
        timeInterval timeIntervalInput: HealthChartTimeIntervalInput = .automatic,
        @HealthChartContentBuilder _ entry: () -> (repeat HealthChartEntry<each Results>)
    ) {
        let entry = entry()
        self.entry = entry
        switch timeIntervalInput {
        case .automatic:
            self.timeInterval = { () -> TimeInterval in
                var retval: TimeInterval = 0
                for entry in repeat each entry {
                    guard !entry.isEmpty else {
                        continue
                    }
                    let entryInterval = entry.results.timeRange.range.upperBound.distance(to: entry.results.timeRange.range.lowerBound)
                    retval = max(retval, entryInterval)
                }
                return retval
            }()
        case .custom(let timeInterval):
            self.timeInterval = timeInterval
        }
    }
    
    
    @ChartContentBuilder
    private func makeChartContent<Results2: HealthKitQueryResults>(for entry: HealthChartEntry<Results2>) -> some ChartContent {
        let name = entry.results.sampleType.displayTitle
        ForEach(entry.results) { element in
            if let dataPoint = entry.makeDataPoint(for: element) {
                let xVal: PlottableValue = .value("Date", dataPoint.date)
                let yVal: PlottableValue = .value(name, dataPoint.value * (entry.results.sampleType == .bloodOxygen ? 100 : 1))
                SomeChartContent {
                    switch entry.drawingConfig.mode {
                    case .line:
                        LineMark(x: xVal, y: yVal)
                    case .bar:
                        BarMark(x: xVal, y: yVal)
                    case .point:
                        PointMark(x: xVal, y: yVal)
                    }
                }
            }
        }
        .foregroundStyle(by: .value("Sample Type", entry.results.sampleType.displayTitle))
    }
    
    
    @Environment(\.locale) private var locale
    @Environment(\.timeZone) private var timeZone
    @Environment(\.calendar) private var calendar
    
    @AxisContentBuilder
    private func xAxisContent() -> some AxisContent {
        if let maxTimeRange = self.maxTimeRange(), let config = xAxisMarksConfig(for: maxTimeRange) {
            let locale = self.locale
            let timeZone = self.timeZone
            let calendar = self.calendar
            AxisMarks(values: .stride(by: config.strideComponent, count: config.strideCount)) { value in
                if let date = value.as(Date.self) {
    //                let component = Calendar.current.component(strideConfig.component, from: date)
                    AxisValueLabel(format: config.valueFormat.locale(locale).timeZone(timeZone).calendar(calendar))
                }
                AxisGridLine()
                AxisTick()
            }
        } else {
            // the chart is empty (i.e., has no entries), or we weren't able to come up w/ a good config.
            AxisMarks(values: .automatic)
        }
    }
    
    // Ideally, this would be nested in the `xAxisContent()` function, but the compiler currently doesn't allow this.
    private struct XAxisMarksConfig {
        let strideComponent: Calendar.Component
        let strideCount: Int
        let valueFormat: Date.FormatStyle
    }
    
    
    private func maxTimeRange() -> HealthKitQueryTimeRange? {
        var maxTimeRange: HealthKitQueryTimeRange?
        for entry in repeat each entry {
            maxTimeRange = maxTimeRange.map { max($0, entry.results.timeRange) } ?? entry.results.timeRange
        }
        return maxTimeRange
    }
    
    private func xAxisMarksConfig(for maxTimeRange: HealthKitQueryTimeRange) -> XAxisMarksConfig? {
        let duration = maxTimeRange.duration
        if duration <= TimeConstants.hour {
            return .init(strideComponent: .minute, strideCount: 10, valueFormat: .dateTime.minute())
        } else if duration <= TimeConstants.day / 2 {
            return .init(strideComponent: .hour, strideCount: 1, valueFormat: .dateTime.hour())
        } else if duration <= TimeConstants.day {
            return .init(strideComponent: .hour, strideCount: 3, valueFormat: .dateTime.hour())
        } else if duration <= TimeConstants.week {
            return .init(strideComponent: .day, strideCount: 1, valueFormat: .dateTime.month(.abbreviated).day())
        } else if duration <= TimeConstants.month {
            return .init(strideComponent: .weekOfMonth, strideCount: 1, valueFormat: .dateTime.day())
        } else {
            // we just give up at this point...
            return nil
        }
    }
}


extension Date.FormatStyle {
    /// Returns a version of the `FormatStyle` that uses the specified time zone.
    func timeZone(_ timeZone: TimeZone) -> Self {
        var style = self
        style.timeZone = timeZone
        return style
    }
    
    /// Returns a version of the `FormatStyle` that uses the specified calendar.
    func calendar(_ calendar: Calendar) -> Self {
        var style = self
        style.calendar = calendar
        return style
    }
}
