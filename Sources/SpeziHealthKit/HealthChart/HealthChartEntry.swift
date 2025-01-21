//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import HealthKit
import struct SwiftUI.Color


/// How a ``HealthChartEntry`` should be plotted in a Health Chart.
public struct HealthChartDrawingConfig: Sendable {
    /// A chart type.
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
    
    /// Creates a new drawing config for an entry in a health chart.
    public init(mode: Mode, color: Color) {
        self.mode = mode
        self.color = color
    }
}


/// An entry in a ``HealthChart``.
///
/// ## See Also
/// - <doc:HealthChart>
public final class HealthChartEntry<Results: HealthKitQueryResults>: Sendable {
    public typealias MakeDataPointImp = @Sendable (Results.Element, Results) -> HealthChartDataPoint?
    
    private enum Variant: Sendable {
        case regular(Results, HealthChartDrawingConfig, MakeDataPointImp)
        case empty
    }
    
    private let variant: Variant
    
    var results: Results {
        switch variant {
        case .regular(let results, _, _):
            return results
        case .empty:
            fatalError("Cannot access \(#function) on empty \(Self.self)")
        }
    }
    var drawingConfig: HealthChartDrawingConfig {
        switch variant {
        case .regular(_, let drawingConfig, _):
            return drawingConfig
        case .empty:
            fatalError("Cannot access \(#function) on empty \(Self.self)")
        }
    }
    var makeDataPointImp: MakeDataPointImp {
        switch variant {
        case .regular(_, _, let makeDataPointImp):
            return makeDataPointImp
        case .empty:
            fatalError("Cannot access \(#function) on empty \(Self.self)")
        }
    }
    
    var isEmpty: Bool {
        switch variant {
        case .regular:
            false
        case .empty:
            true
        }
    }
    
    private init(variant: Variant) {
        self.variant = variant
    }
    
    /// Creates a new Entry, using the specified configuration.
    public convenience init(
        _ results: Results,
        drawingConfig: HealthChartDrawingConfig,
        makeDataPoint: @escaping MakeDataPointImp
    ) {
        self.init(variant: .regular(results, drawingConfig, makeDataPoint))
    }
    
    /// Creates a new Entry for a HealthKit query collection of quantity samples.
    public convenience init(
        _ results: Results,
        drawingConfig: HealthChartDrawingConfig
    ) where Results.Sample == HKQuantitySample, Results.Element == HKQuantitySample {
        self.init(results, drawingConfig: drawingConfig) { sample, results in
            HealthChartDataPoint(sample: sample, unit: results.sampleType.displayUnit)
        }
    }
    
    /// Creates a new Entry for a statistical HealthKit query.
    public convenience init(
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
    
    func makeDataPoint(for element: Results.Element) -> HealthChartDataPoint? {
        makeDataPointImp(element, results)
    }
}
