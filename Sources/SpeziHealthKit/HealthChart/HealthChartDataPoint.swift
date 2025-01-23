//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SwiftUI


/// A data point, intended for visualisation purposes, representing an element of a HealthKit query.
///
/// `DataPoint`s are lightweight objects which can be trivially constructed and provide sufficient information for displaying
/// a value as part of e.g. a Chart or some other user-facing UI component.
///
/// This type is primarily intended to be used in the context of the ``HealthChart``, but it can also be used outside of that.
public struct HealthChartDataPoint: Hashable, Identifiable { // swiftlint:disable:this file_types_order
    public let id: AnyHashable
    public let date: Date
    public let value: Double
    public let unit: HKUnit
    
    /// Creates a new DataPoint, using the provided values
    public init(id: some Hashable, date: Date, value: Double, unit: HKUnit) {
        self.id = AnyHashable(id)
        self.date = date
        self.value = value
        self.unit = unit
    }
    
    /// Creates a DataPoint from a `HKQuantitySample`
    public init(sample: HKQuantitySample, unit: HKUnit) {
        self.init(
            id: sample.uuid,
            date: (sample.startDate...sample.endDate).middle,
            value: sample.quantity.doubleValue(for: unit),
            unit: unit
        )
    }
    
    /// Creates a DataPoint from a `HKStatistics` summary object.
    public init?(statistics: HKStatistics, aggregationOption: StatisticsAggregationOption, unit: HKUnit) {
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
}


extension HealthChartDataPoint { // swiftlint:disable:this file_types_order
    /// The DataPoint's value (excluding its unit), formatted based on the unit.
    public var stringValue: String {
        let fmt = NumberFormatter()
        fmt.usesGroupingSeparator = true
        switch unit {
        case .percent(): // swiftlint:disable:this empty_enum_arguments
            // ^^^ it's not an enum case we're matching against here, but SwiftLint doesn't know about this...
            fmt.numberStyle = .percent
        case .count() / .minute():
            fmt.numberStyle = .decimal
        default:
            break
        }
        return fmt.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}


/// How a ``HealthChartDataPoint`` based on a `HKStatistics` object should select its value.
public enum StatisticsAggregationOption: Sendable {
    /// The sum quantity
    case sum
    /// The average quantity
    case avg
    /// The minimum quantity
    case min
    /// The maximum quantity
    case max
    
    /// Creates a `StatisticsAggregationOption` based on a quantity sample's suggested aggregation style.
    public init(_ sampleType: SampleType<HKQuantitySample>) {
        let suggestedAggStyle = sampleType.hkSampleType.aggregationStyle
        switch suggestedAggStyle {
        case .cumulative:
            self = .sum
        case .discreteArithmetic, .discreteTemporallyWeighted:
            self = .avg
        case .discreteEquivalentContinuousLevel:
            preconditionFailure("Unsupported aggregation style: 'discreteEquivalentContinuousLevel'")
        @unknown default:
            preconditionFailure("Unsupported aggregation style: '\(suggestedAggStyle.rawValue)'")
        }
    }
}
