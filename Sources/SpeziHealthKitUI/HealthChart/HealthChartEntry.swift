//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import HealthKit
public import SpeziHealthKit
public import struct SwiftUI.Color


/// How a ``HealthChartEntry`` should be plotted in a Health Chart.
public struct HealthChartDrawingConfig: Hashable, Sendable {
    /// A chart type.
    public enum ChartType: Hashable, Sendable {
        /// The entry is drawn as a line chart, i.e. a line that moves from data point to data point
        case line
        /// bar chart
        case bar
        /// each data point is its own point in the chart, not connected to anything else
        case point
    }
    
    public let chartType: ChartType
    public let color: Color
    
    /// Creates a new drawing config for an entry in a health chart.
    public init(chartType: ChartType, color: Color) {
        self.chartType = chartType
        self.color = color
    }
}


/// Type-erased entry in a health chart
@_documentation(visibility: internal)
public protocol HealthChartEntryProtocol: Sendable {
    var isEmpty: Bool { get }
    var resultsTimeRange: HealthKitQueryTimeRange { get }
    var resultsSampleType: any AnySampleType { get }
    var drawingConfig: HealthChartDrawingConfig { get }
    var resultsDataPoints: [HealthChartDataPoint] { get }
}


/// An entry in a ``HealthChart``.
///
/// ## See Also
/// - <doc:HealthChart>
public struct HealthChartEntry<Results: HealthKitQueryResults>: Sendable {
    public typealias MakeDataPointImp = @Sendable (Results.Element, Results) -> HealthChartDataPoint?
    
    private enum Variant: Sendable {
        case regular(Results, HealthChartDrawingConfig, MakeDataPointImp)
        case empty
    }
    
    private let variant: Variant
    
    private var results: Results {
        switch variant {
        case .regular(let results, _, _):
            return results
        case .empty:
            fatalError("Cannot access \(#function) on empty \(Self.self)")
        }
    }
    
    private var makeDataPointImp: MakeDataPointImp {
        switch variant {
        case .regular(_, _, let makeDataPointImp):
            return makeDataPointImp
        case .empty:
            fatalError("Cannot access \(#function) on empty \(Self.self)")
        }
    }
    
    private init(variant: Variant) {
        self.variant = variant
    }
    
    /// Creates a new Entry, using the specified configuration.
    public init(
        _ results: Results,
        drawingConfig: HealthChartDrawingConfig,
        makeDataPoint: @escaping MakeDataPointImp
    ) {
        self.init(variant: .regular(results, drawingConfig, makeDataPoint))
    }
    
    /// Creates a new Entry for a HealthKit query collection of quantity samples.
    public init(
        _ results: Results,
        drawingConfig: HealthChartDrawingConfig
    ) where Results.Sample == HKQuantitySample, Results.Element == HKQuantitySample {
        self.init(results, drawingConfig: drawingConfig) { sample, results in
            HealthChartDataPoint(sample: sample, unit: results.sampleType.displayUnit)
        }
    }
    
    /// Creates a new Entry for a statistical HealthKit query.
    public init(
        _ results: Results,
        aggregationOption: StatisticsAggregationOption,
        drawingConfig: HealthChartDrawingConfig
    ) where Results.Sample == HKQuantitySample, Results.Element == HKStatistics {
        self.init(results, drawingConfig: drawingConfig) { statistics, results in
            HealthChartDataPoint(
                statistics: statistics,
                aggregationOption: aggregationOption,
                unit: results.sampleType.displayUnit
            )
        }
    }
    
    static func makeEmpty() -> Self {
        Self(variant: .empty)
    }
}


extension HealthChartEntry: HealthChartEntryProtocol {
    public var drawingConfig: HealthChartDrawingConfig {
        switch variant {
        case .regular(_, let drawingConfig, _):
            return drawingConfig
        case .empty:
            fatalError("Cannot access \(#function) on empty \(Self.self)")
        }
    }
    
    public var resultsTimeRange: HealthKitQueryTimeRange {
        results.timeRange
    }
    
    public var resultsSampleType: any AnySampleType {
        results.sampleType
    }
    
    public var resultsDataPoints: [HealthChartDataPoint] {
        let results = self.results
        return results.compactMap { makeDataPointImp($0, results) }
    }
    
    public var isEmpty: Bool {
        switch variant {
        case .regular:
            false
        case .empty:
            true
        }
    }
}
