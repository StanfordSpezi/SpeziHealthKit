//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI
import HealthKit
import Charts
import SpeziFoundation


public struct HealthChartDrawingConfig: Sendable {
    public enum Mode: Sendable {
        /// The entry is drawn as a line chart, i.e. a line that moves from data point to data point
        case line
        /// bar chart
        case bar
        /// each data point is its own point in the chart, not connected to anything else
        case point
    }
    
    let mode: Mode
    let color: Color
    
    public init(mode: Mode, color: Color) {
        self.mode = mode
        self.color = color
    }
}


// sadly can't nest in the struct directly :/
// see https://github.com/swiftlang/swift/issues/72069
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
    
    public static func range(_ range: ClosedRange<Date>) -> Self {
        .custom(range.lowerBound.distance(to: range.upperBound))
    }
}



private struct ChartXScrollPosition<Value: PrimitivePlottableProtocol>: Plottable {
    typealias PrimitivePlottable = Value
    
    let primitivePlottable: Value
    
    init(primitivePlottable: Value) {
        self.primitivePlottable = primitivePlottable
    }
}

extension ChartXScrollPosition: Equatable where Value: Equatable {}
extension ChartXScrollPosition: Hashable where Value: Hashable {}
extension ChartXScrollPosition: Sendable where Value: Sendable {}





public enum HealthChartInteractivity {
    case none
//    case scrolling
    case highlighting // TODO call it "selection" instead?
}



private enum HealthChartContentState { // TODO better name?!
    /// The chart has no entries
    case noEntries
    /// The chart has entries, but they have no samples in them.
    /// - parameter sampleTypesMissingData: The sample types of the entries for which no samples exist.
    case noSamples(sampleTypesMissingData: [any AnySampleType])
    /// The chart has content, and everything is fine.
    case hasContent
}



public struct HealthChart<each Results: HealthKitQueryResults>: View {
    private struct CurrentHighlightConfig: Hashable {
        struct HighlightEntry: Hashable, Identifiable {
            let dataPoint: HealthChartDataPoint
            let color: Color
            let seriesName: String
            var id: HealthChartDataPoint.ID { dataPoint.id }
        }
        
        let date: Date
        let entries: [HighlightEntry]
    }
    
    let entry: (repeat HealthChartEntry<each Results>)
    let interactivity: HealthChartInteractivity
    // TODO better name!
    /// The time interval for which the chart displays data, i.e. the "width" of the chart, in terms of how much time it represents/covers.
    let timeInterval: TimeInterval
    
    @State private var highlightConfig: CurrentHighlightConfig?
    
    @State private var xSelection: Date?
    @State private var xScrollPosition: ChartXScrollPosition<Date>
    
    
    public init(
        interactivity: HealthChartInteractivity = .highlighting,
        timeInterval timeIntervalInput: HealthChartTimeIntervalInput = .automatic,
        @HealthChartContentBuilder _ entry: () -> (repeat HealthChartEntry<each Results>)
    ) {
        self.interactivity = interactivity
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
        self._xScrollPosition = .init(initialValue: ChartXScrollPosition<Date>.init(primitivePlottable: .now)) // TODO WRONG a) left edge b) relative to last entry(???)
    }
    
    private var hasEntries: Bool {
        for entry in repeat each entry {
            if !entry.isEmpty {
                return true
            }
        }
        return false
    }
    
    
    public var body: some View {
        if !hasEntries {
            Text("No Data")
        } else {
            chart
                .overlay {
                    queryErrorsOverlay
                }
                .onChange(of: xSelection) { _, xSelection in
                    guard let xSelection else {
                        highlightConfig = nil
                        return
                    }
                    func highlightEntry(in entry: HealthChartEntry<some Any>) -> CurrentHighlightConfig.HighlightEntry? {
                        guard !entry.results.isEmpty else {
                            return nil
                        }
                        // TODO do a binary search instead? (somehow)
                        let closestEntry: HealthChartDataPoint? = entry.results
                            .lazy
                            .compactMap { entry.makeDataPoint(for: $0) }
                            .min { lhs, rhs -> Bool in
                                let lhsDist = abs(lhs.date.distance(to: xSelection))
                                let rhsDist = abs(rhs.date.distance(to: xSelection))
                                return lhsDist < rhsDist
                            }
                        guard let closestEntry, abs(closestEntry.date.distance(to: xSelection)) < 60*60 else {
                            return nil
                        }
                        return CurrentHighlightConfig.HighlightEntry(
                            dataPoint: closestEntry,
                            color: entry.drawingConfig.color,
                            seriesName: entry.results.sampleType.displayTitle
                        )
                    }
                    var highlightEntries: [CurrentHighlightConfig.HighlightEntry] = []
                    for entry in repeat each entry {
                        guard !entry.isEmpty else {
                            continue
                        }
                        if let highlightEntry = highlightEntry(in: entry) {
                            highlightEntries.append(highlightEntry)
                        }
                    }
                    guard !highlightEntries.isEmpty else {
                        highlightConfig = nil
                        return
                    }
                    highlightConfig = .init(date: highlightEntries.first!.dataPoint.date, entries: highlightEntries) // TODO do we want to require them all to have the same date?!
                }
                .onChange(of: xScrollPosition, initial: true) { old, new in
                    print("X SCROLL FROM \(old.primitivePlottable) ---> \(new.primitivePlottable)")
                }
        }
    }
    
    
    @ViewBuilder
    private var chart: some View {
        Chart {
            chartContent
            chartSelectionHighlight
        }
        .transforming { view in
            switch interactivity {
            case .none:
                view
//            case .scrolling:
//                view.chartScrollableAxes(.horizontal)
            case .highlighting:
                view.chartXSelection(value: $xSelection)
            }
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
                    if let _range = range {
                        range = min(_range.lowerBound, expectedRange.lowerBound)...max(_range.upperBound, expectedRange.upperBound)
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
    
    
    @ChartContentBuilder
    private func makeChartContent<Results2: HealthKitQueryResults>(for entry: HealthChartEntry<Results2>) -> some ChartContent {
        let name = entry.results.sampleType.displayTitle
        ForEach(entry.results) { element in
            if let dataPoint = entry.makeDataPoint(for: element) {
                let x: PlottableValue = .value("Date", dataPoint.date)
                let y: PlottableValue = .value(name, dataPoint.value * (entry.results.sampleType == .bloodOxygen ? 100 : 1))
                let s: PlottableValue = .value("Series", name)
                SomeChartContent {
                    switch entry.drawingConfig.mode {
                    case .line:
                        LineMark(x: x, y: y)
                    case .bar:
                        BarMark(x: x, y: y)
                    case .point:
                        PointMark(x: x, y: y)
                    }
                }
                .annotation { // TODO?
//                    let date = dataPoint.date.ISO8601Format(Date.ISO8601FormatStyle())
//                    Text("\(dataPoint.stringValue)\n\(date)")
                    Text(dataPoint.stringValue)
                        .font(.caption)
                }
            }
        }
        .foregroundStyle(by: .value("Sample Type", entry.results.sampleType.displayTitle))
    }
    
    
    @ChartContentBuilder
    private var chartSelectionHighlight: some ChartContent {
        if let highlightConfig {
            RuleMark(x: .value("Selected", highlightConfig.date)) // TODO can we dynamically determine wjether this is day/hour/etc?
                .foregroundStyle(Color.gray.opacity(0.3))
                .offset(yStart: -10)
                .zIndex(-1)
                .annotation(
                    position: .top,
                    spacing: 0,
                    overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
                ) {
//                    Rectangle()
//                        .fill(.red)
//                        .frame(width: 1000, height: 1000)
//                        .onAppear {
//                            print("ANNOTATION ON APPEAR")
//                        }
//                    SelectionHighlightSummaryView(entries: highlightConfig.entries)
                }
        }
    }
    
    
    private struct SelectionHighlightSummaryView: View {
        let entries: [CurrentHighlightConfig.HighlightEntry]
        
        var body: some View {
            HStack {
                ForEach(0..<entries.endIndex, id: \.self) { entryIdx in
                    makeEntry(for: entries[entryIdx])
                    if entryIdx < entries.endIndex - 1 {
                        Divider()
                    }
                }
            }
            .padding(8)
//            .background(.primary, in: RoundedRectangle(cornerRadius: 8))
            .background(.secondary, in: RoundedRectangle(cornerRadius: 8))
//            .background(.tertiary, in: RoundedRectangle(cornerRadius: 8))
//            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            //            .background(.thinMaterial)
//            .background(.clear)
            //.clipShape(RoundedRectangle(cornerRadius: 8))
        }
        
        @ViewBuilder
        private func makeEntry(for entry: CurrentHighlightConfig.HighlightEntry) -> some View {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text(entry.dataPoint.stringValue)
                    Text(entry.dataPoint.unit.unitString)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                HStack {
                    Circle()
                        .fill(entry.color)
                        .frame(width: 7, height: 7)
                    Text(entry.seriesName)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
        }
    }
    
    
    // MARK: Error Overlay
    
    private var queryErrorsOverlay: some View {
        let errors: [any Error] = { () -> [any Error] in
            var retval: [any Error] = []
            for entry in repeat each entry {
                if let queryError = entry.results.queryError {
                    retval.append(queryError)
                }
            }
            return retval
        }()
        return ForEach(0..<errors.endIndex, id: \.self) { idx in
            Text("Error: \(errors[idx])")
        }
    }
}
