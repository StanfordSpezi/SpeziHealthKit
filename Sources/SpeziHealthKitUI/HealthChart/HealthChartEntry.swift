//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import HealthKit
import SpeziHealthKit


// TODO why is it that, if this is a class, the chart will be able to auto-update when the contained `results` property (which is @Observable) changes,
// (even though this class itself isn't), but if we instead turn the entry into a struct, it does not work???
// TODO Rename HealthChartDateSet? (Entry kinda sounds like it's referring to a single data point. But then again, it could very well also be the case that we want to split eg "step count" up into separate data sets, to make it look nicer?
/// An entry in a ``HealthChart``
public final class HealthChartEntry<Results: HealthKitQueryResults>: Sendable {
    public typealias HealthKitQueryDataPoint = SpeziHealthKitUI.HealthKitQueryDataPoint//<Results.Element.ID>
    public typealias MakeDataPointImp = @Sendable (Results.Element, Results) -> HealthKitQueryDataPoint?
    
    private enum Variant {
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
    
    static func makeEmpty() -> Self {
        Self.init(variant: .empty)
    }
    
    public convenience init(
        _ results: Results,
        drawingConfig: HealthChartDrawingConfig, // TODO drawingOptions?
        makeDataPoint: @escaping MakeDataPointImp
    ) {
        self.init(variant: .regular(results, drawingConfig, makeDataPoint))
    }
    
    public convenience init(
        _ results: Results,
        drawingConfig: HealthChartDrawingConfig
    ) where Results.Sample == HKQuantitySample, Results.Element == HKQuantitySample {
        self.init(results, drawingConfig: drawingConfig) { sample, results in
            HealthKitQueryDataPoint(sample: sample, unit: results.sampleType.displayUnit)
        }
    }
    
    public convenience init(
        _ results: Results,
        aggregationOption: StatisticsAggregationOption, // TODO custom/better type here?!
        drawingConfig: HealthChartDrawingConfig
    ) where Results.Sample == HKQuantitySample, Results.Element == HKStatistics {
        self.init(results, drawingConfig: drawingConfig) { statistics, results in
            HealthKitQueryDataPoint(
                statistics: statistics,
                aggregationOption: aggregationOption,
                unit: results.sampleType.displayUnit
            )
        }
    }
    
    func makeDataPoint(for element: Results.Element) -> HealthKitQueryDataPoint? {
        makeDataPointImp(element, results)
    }
    
    func withTimeRange(_ timeRange: HealthKitQueryTimeRange) async -> Self {
        await Self.init(
            results.withTimeRange(timeRange),
            drawingConfig: drawingConfig,
            makeDataPoint: makeDataPointImp
        )
    }
}
