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
import SpeziHealthKit
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






//public protocol HealthKitQueryResultsDataPoint: Identifiable {
//    associatedtype ResultElement: Identifiable
//}



public enum StatisticsAggregationOption: Sendable {
    case sum, avg, min, max
    
    public init(_ sampleType: HealthKitSampleType<HKQuantitySample>) {
        switch sampleType.hkSampleType.aggregationStyle {
        case .cumulative:
            self = .sum
        case .discreteArithmetic, .discreteTemporallyWeighted:
            self = .avg
        case .discreteEquivalentContinuousLevel:
            fatalError()
        @unknown default:
            fatalError()
        }
    }
}


public struct HealthKitQueryDataPoint/*<ID: Hashable>*/: Hashable, Identifiable {
    public let id: AnyHashable
    public let date: Date
    public let value: Double
    public let unit: HKUnit
    
    public init(id: some Hashable, date: Date, value: Double, unit: HKUnit) {
        self.id = AnyHashable(id)
        self.date = date
        self.value = value
        self.unit = unit
    }
    
    public init(sample: HKQuantitySample, unit: HKUnit) /*where ID == UUID*/ {
        self.id = AnyHashable(sample.uuid)
        self.date = (sample.startDate...sample.endDate).middle
        self.value = sample.quantity.doubleValue(for: unit)
        self.unit = unit
    }
    
    public init?(statistics: HKStatistics, aggregationOption: StatisticsAggregationOption, unit: HKUnit) /*where ID == HKStatistics.ID*/ {
        self.id = AnyHashable(statistics.id)
        self.date = (statistics.startDate...statistics.endDate).middle
        let value: Double?
        switch aggregationOption {
        case .sum:
            value = statistics.sumQuantity()?.doubleValue(for: unit)
        case .avg:
            value = statistics.averageQuantity()?.doubleValue(for: unit)
        case .min:
            value = statistics.minimumQuantity()?.doubleValue(for: unit)
        case .max:
            value = statistics.maximumQuantity()?.doubleValue(for: unit)
        }
        guard let value else {
            return nil
        }
        self.value = value
        self.unit = unit
    }
    
    public var stringValue: String {
        let fmt = NumberFormatter()
        fmt.usesGroupingSeparator = true
        switch unit {
        case .percent():
            fmt.numberStyle = .percent
//            fmt.maximumFractionDigits = 1 // TODO make this dependent on the sample type?!
        case .count() / .minute(): // TODO can we match against all `.count / X` units?
            fmt.numberStyle = .decimal
        default:
            break
        }
        return fmt.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}



//
//func tupleLength<each T>(_ element: (repeat each T)) -> Int {
//    var length = 0
//    for _ in repeat each element {
//        length += 1
//    }
//    return length
//}



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
    case scrolling
    case selection
}



public struct HealthChart<each Results: HealthKitQueryResults>: View {
    private struct CurrentHighlightConfig: Hashable {
        struct HighlightEntry: Hashable, Identifiable {
            let dataPoint: HealthKitQueryDataPoint
            let color: Color
            let seriesName: String
            var id: HealthKitQueryDataPoint.ID { dataPoint.id }
        }
        
        let date: Date
        let entries: [HighlightEntry]
    }
    
    private let entry: (repeat HealthChartEntry<each Results>)
    private let interactivity: HealthChartInteractivity
    // TODO better name!
    /// The time interval for which the chart displays data, i.e. the "width" of the chart, in terms of how much time it represents/covers.
    private let timeInterval: TimeInterval
    
//    @State private var highlightedDataPoint: (Date, Double)?
    @State private var highlightConfig: CurrentHighlightConfig?
    
    @State private var xSelection: Date?
    @State private var xScrollPosition: ChartXScrollPosition<Date>
    
    
    public init(
        interactivity: HealthChartInteractivity = .selection,
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
//        let _ = Self._printChanges()
        if !hasEntries {
            Text("No Data")
        } else {
            VStack(spacing: 0) {
//                HStack {
//                    Color.red.frame(height: 75)
//                    Color.green.frame(height: 75)
//                }
                chart
                    .overlay {
                        let errors: [any Error] = { () -> [any Error] in
                            var retval: [any Error] = []
                            for entry in repeat each entry {
                                if let queryError = entry.results.queryError {
                                    retval.append(queryError)
                                }
                            }
                            return retval
                        }()
                        ForEach(0..<errors.endIndex, id: \.self) { idx in
                            Text("Error: \(errors[idx])")
                        }
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
                            let closestEntry = entry.results
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
                            ////                        entry.results.lk_binarySearchFirstIndex { element -> BinarySearchComparisonResult in
                            ////                            guard let dataPoint = entry.makeDataPoint(for: element) else {
                            ////                                return
                            ////                            }
                            ////                        }
                            //                        closeDataPoints.append(contentsOf: entry.results.compactMap { element in
                            //                            guard let dataPoint = entry.makeDataPoint(for: element) else {
                            //                                return nil
                            //                            }
                            //                            if abs(dataPoint.date.distance(to: xSelection)) < 60 * 60 * 24 { // TODO threshold here must be based on total x axis scale!
                            //                                return dataPoint
                            //                            } else {
                            //                                return nil
                            //                            }
                            //                        })
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
//                LabeledContent("chartXPosition", value: "\(xScrollPosition)")
            }
            .onChange(of: xScrollPosition, initial: true) { old, new in
                print("X SCROLL FROM \(old.primitivePlottable) ---> \(new.primitivePlottable)")
            }
        }
    }
    
    
    @ViewBuilder
    private var chart: some View {
//        let _ = { () -> Void in
//            print("[\(Self.self)] timeInterval: \(timeInterval)")
//            var minMaxDates: (min: Date, max: Date)?
//            for entry in repeat each entry {
//                for element in entry.results {
//                    guard let dataPoint = entry.makeDataPoint(for: element) else {
//                        continue
//                    }
//                    if minMaxDates == nil {
//                        minMaxDates = (dataPoint.date, dataPoint.date)
//                    } else {
//                        minMaxDates!.min = min(minMaxDates!.min, dataPoint.date)
//                        minMaxDates!.max = max(minMaxDates!.max, dataPoint.date)
//                    }
//                }
//            }
//            print("[\(Self.self)] totalDataPointsSpan: \(minMaxDates)")
//        }()
        Chart {
            chartContent
            chartSelectionHighlight
        }
        .transforming { view in
            switch interactivity {
            case .none:
                view
            case .scrolling:
                view.chartScrollableAxes(.horizontal)
            case .selection:
                view.chartXSelection(value: $xSelection)
            }
        }
//        .chartScrollTargetBehavior(.)
//        .chartScrollPosition(x: $xScrollPosition)
        //.chartXVisibleDomain(length: 60 * 60 * 24 * 30) // TODO this needs to be determined based on the timePeriod!
//        .chartXVisibleDomain(length: timeInterval)
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
                    guard let expectedRange = entry.results.sampleType.expectedValuesRange else {
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
//        .chartOverlay { (chartProxy: ChartProxy) in
//            GeometryReader { geometry in
//                //Rectangle().fill(.clear).contentShape(Rectangle())
//                Color.clear
//                    .gesture(LongPressGesture(minimumDuration: 0.25).sequenced(before: DragGesture(minimumDistance: 0)
//                        .onChanged { value in
//                            guard let origin = chartProxy.plotFrame.map({ geometry[$0].origin }) else {
//                                self.xSelection = nil
//                                return
//                            }
//                            let location = CGPoint(
//                                x: value.location.x - origin.x,
//                                y: value.location.y - origin.y
//                            )
//                            //if let date = chartProxy.value(at: location, as: (Date, Double).)
//                            if let date = chartProxy.value(atX: location.x, as: Date.self) {
//                                self.xSelection = date
//                            } else {
//                                self.xSelection = nil
//                            }
//                        }
//                    ))
//            }
//        }
//        .clipped()
    }
    
    
    private var chartContent: AnyChartContent {
        // In an ideal world, we would simply place the `for entry in repeat each entry` loop directly in the `Chart { }` call.
        // BUT, sadly, we do not live in this world. (The ChartContentBuilder doesn't support for loops,
        // and there is no ForEach-equivalent that would work with a variadic tuple.)
        // So, what we do instead is that we essentially unroll the for loop into manual, explicit calls of the result builder functions.
        var blocks: [AnyChartContent] = []
        for entry in repeat each entry {
            guard !entry.isEmpty else {
                continue
            }
            guard entry.results.queryError == nil else {
                continue
            }
            blocks.append(AnyChartContent(erasing: ChartContentBuilder.buildExpression(makeChartContent(for: entry))))
        }
        var content = AnyChartContent(erasing: ChartContentBuilder.buildBlock())
        for block in blocks {
            if #available(iOS 18.0, *) {
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
                    Text("\(dataPoint.stringValue)")
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
}





// MARK: InteractiveHealthChart



extension HealthChart {
    public func makeInteractive(
        selection: Binding<HealthChartGranularity>,
        enabledGranularities: Set<HealthChartGranularity>// = Set(InteractiveHealthChart.Granularity.all)
    ) -> some View {
        // TODO QUESTION: what if $selection is not in enabledGranularities?!
        InteractiveHealthChart<repeat each Results>(
            interactivity: self.interactivity,
            granularity: selection,
            enabledGranularities: enabledGranularities,
            (repeat each entry)
        )
    }
}



public struct HealthChartGranularity: Hashable, Sendable {
    let timeRange: HealthKitQueryTimeRange
    let displayTitle: String
    
    public static let day = Self(timeRange: .today, displayTitle: "Day")
    public static let week = Self(timeRange: .lastNDays(7), displayTitle: "Week")
    public static let month = Self(timeRange: .lastNMonths(1), displayTitle: "Month")
    public static let quarter = Self(timeRange: .lastNMonths(3), displayTitle: "3M")
    public static let halfYear = Self(timeRange: .lastNMonths(6), displayTitle: "6M")
    public static let year = Self(timeRange: .lastNYears(1), displayTitle: "Year")
    public static let twoYears = Self(timeRange: .lastNYears(2), displayTitle: "2Y")
    public static let fiveYears = Self(timeRange: .lastNYears(5), displayTitle: "5Y")
    
    public static let all: [Self] = [
        .day, .week, .month, .quarter, .halfYear, .year, .twoYears, .fiveYears
    ]
}






struct InteractiveHealthChart<each Results: HealthKitQueryResults>: View {
    typealias Granularity = HealthChartGranularity
    
    private let interactivity: HealthChartInteractivity
    private let enabledGranularities: Set<Granularity>
    @Binding private var granularity: Granularity
    @State private var entry: (repeat HealthChartEntry<each Results>)
    
    
    fileprivate init(
        interactivity: HealthChartInteractivity,
        granularity: Binding<Granularity>,
        enabledGranularities: Set<Granularity>,
        _ entry: (repeat HealthChartEntry<each Results>)
    ) {
        self.interactivity = interactivity
        self.enabledGranularities = enabledGranularities
        self._granularity = granularity
        self._entry = .init(initialValue: (repeat each entry))
    }
    
    
    var body: some View {
        VStack {
            Picker("Time Range", selection: $granularity) {
                ForEach(Granularity.all.filter(enabledGranularities.contains), id: \.self) { granularity in
                    Text(granularity.displayTitle)
                }
            }
            .pickerStyle(.segmented)
            
            HealthChart(
                interactivity: interactivity,
                timeInterval: .range(granularity.timeRange.range)
            ) {
                (repeat each entry)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
//            LabeledContent("TimeRange", value: "\(granularity.timeRange.range)")
            LabeledContent("#DataPoints", value: { () -> String in
                var counts: [Int] = []
                for entry in repeat each entry {
                    guard !entry.isEmpty else {
                        continue
                    }
                    counts.append(entry.results.count)
                }
                return "\(counts.map(String.init).joined(separator: " + ")) = \(counts.reduce(0, +))"
            }())
        }
        .onChange(of: granularity) { old, new in
            precondition(old != new, "is same?")
            Task {
                entry = (repeat await (each entry).withTimeRange(new.timeRange))
            }
        }
    }
}





// MARK: Chart Utils


struct SomeChartContent<Body: ChartContent>: ChartContent {
    private let content: () -> Body
    
    init(@ChartContentBuilder _ content: @escaping () -> Body) {
        self.content = content
    }
    
    var body: some ChartContent {
        content()
    }
}





// MARK: Other


extension KeyValuePairs {
    public init<S: Sequence>(_ seq: S) where S.Element == (Key, Value) {
        let initFn = unsafeBitCast(Self.init(dictionaryLiteral:), to: (([S.Element]) -> Self).self)
        self = initFn(Array(seq))
    }
}


extension ClosedRange where Bound == Date {
    var middle: Date {
        let diff = upperBound.timeIntervalSinceReferenceDate - lowerBound.timeIntervalSinceReferenceDate
        return Date(timeIntervalSinceReferenceDate: lowerBound.timeIntervalSinceReferenceDate + (diff / 2))
    }
}



extension View {
    func transforming(@ViewBuilder _ transform: (Self) -> some View) -> some View {
        transform(self)
    }
}



enum TimeConstants {
    static let minute: TimeInterval = 60
    static let hour = 60 * minute
    static let day = 24 * hour
    static let week = 7 * day
    static let month = 31 * day
    static let year = 365 * day
}


public extension Duration {
    /// The duration's total length, in milliseconds.
    var totalMilliseconds: Double {
        Double(components.seconds) * 1000 + Double(components.attoseconds) * 1e-15
    }
    
    /// The duration's total length, in seconds.
    var totalSeconds: Double {
        totalMilliseconds / 1000
    }
    
    var timeInterval: TimeInterval {
        totalSeconds
    }
}


// TODO these are not necessarily a good idea!!!!!
// - what about days w/ DST changes? you could have only 23 or 25 hours!
// - what about months that have only 28/29/30 days?
// -> the whole "chart time interval" thing would ideally be dynamically computed based on the specific month currently being displayed in the chart!!!
public extension Duration {
    static let hour: Self = .seconds(60 * 60)
    
    static let day = hour * 24
    
    static let week = day * 7
    
    static let month = day * 31
}
