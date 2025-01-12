//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


public enum ValueAdjustment { // TODO (way!!!) better name!
    /// no adjustment needs to be made
    case identity
    /// The value should be scaled (i.e., multiplied) by the specified factor
    case scale(factor: Double)
    /// The value should be converted to a different unit
    case convert(from: HKUnit, to: HKUnit)
    case custom((Double) -> Double)
    
    func apply(to value: Double) -> Double {
        switch self {
        case .identity:
            value
        case .scale(let factor):
            value * factor
        case .convert(let srcUnit, let dstUnit):
            HKQuantity(unit: srcUnit, doubleValue: value).doubleValue(for: dstUnit)
        case .custom(let fn):
            fn(value)
        }
    }
}



/// Associates a `HKSampleType` subclass with a `HKSample` subclass.
public protocol __HKSampleTypeProviding: HKSample {
    associatedtype _SampleType: HKSampleType
}


extension HKQuantitySample: __HKSampleTypeProviding {
    public typealias _SampleType = HKQuantityType
}

extension HKCorrelation: __HKSampleTypeProviding {
    public typealias _SampleType = HKCorrelationType
}

extension HKCategorySample: __HKSampleTypeProviding {
    public typealias _SampleType = HKCategoryType
}



/// A sample type defined by HealthKit.
public struct HealthKitSampleType<T: HKSample & __HKSampleTypeProviding>: Hashable, Identifiable, Sendable {
    public let hkSampleType: T._SampleType
    public let displayTitle: String
    /// The unit that should be used when displaying a sample of this type to the user.
    public let displayUnit: HKUnit
    /// The expected range of values we expect to see for this sample type, if applicable.
    /// The main purpose of this is to be able to e.g. adjust chart value ranges based on the specific sample types being visualised.
    public let expectedValuesRange: ClosedRange<Double>?
    
    public var id: String {
        hkSampleType.identifier
    }
    
    private init(_ hkSampleType: T._SampleType, displayTitle: String, displayUnit: HKUnit, expectedValuesRange: ClosedRange<Double>?) {
        self.hkSampleType = hkSampleType
        self.displayTitle = displayTitle
        self.displayUnit = displayUnit
        self.expectedValuesRange = expectedValuesRange
    }
    
    private static func quantity(
        _ identifier: HKQuantityTypeIdentifier,
        displayTitle: String,
        displayUnit: HKUnit,
        expectedValuesRange: ClosedRange<Double>? = nil
    ) -> HealthKitSampleType<HKQuantitySample> {
        .init(HKQuantityType(identifier), displayTitle: displayTitle, displayUnit: displayUnit, expectedValuesRange: expectedValuesRange)
    }
    
    private static func correlation(
        _ identifier: HKCorrelationTypeIdentifier,
        displayTitle: String,
        displayUnit: HKUnit,
        expectedValuesRange: ClosedRange<Double>? = nil
    ) -> HealthKitSampleType<HKCorrelation> {
        .init(HKCorrelationType(identifier), displayTitle: displayTitle, displayUnit: displayUnit, expectedValuesRange: expectedValuesRange)
    }
    
    private static func category(
        _ identifier: HKCategoryTypeIdentifier,
        displayTitle: String,
        displayUnit: HKUnit
    ) -> HealthKitSampleType<HKCategorySample> {
        .init(HKCategoryType(identifier), displayTitle: displayTitle, displayUnit: displayUnit, expectedValuesRange: nil)
    }
}


extension HealthKitSampleType {
    public static func == (lhs: Self, rhs: HealthKitSampleType<some Any>) -> Bool {
        lhs.id == rhs.id
    }
}


// MARK: Well-Known Quantity Types

public extension HealthKitSampleType where T == HKQuantitySample {
    /// The sample type representing step count quantity samples
    static var stepCount: Self { .quantity(.stepCount, displayTitle: "Step Count", displayUnit: .count()) }
    
    /// The sample type representing blood oxygen saturation quantity samples
    static var bloodOxygen: Self { .quantity(.oxygenSaturation, displayTitle: "Blood Oxygen", displayUnit: .percent()) }
    
    /// The sample type representing heart rate quantity samples
    static var heartRate: Self { .quantity(
        .heartRate,
        displayTitle: "Heart Rate",
        displayUnit: .count() / .minute()
//        expectedValuesRange: 60...150
    ) }
    
    /// The sample type representing resting heart rate quantity samples
    static var restingHeartRate: Self { .quantity(
        .restingHeartRate,
        displayTitle: "Resting Heart Rate",
        displayUnit: .count() / .minute()
    ) }
    
    /// The sample type representing heart rate variability
    static var heartRateVariability: Self { .quantity(
        .heartRateVariabilitySDNN,
        displayTitle: "Heart Rate Variability",
        displayUnit: .secondUnit(with: .milli)
    ) }
}


// MARK: Well-Known Correlation Types

public extension HealthKitSampleType where T == HKCorrelation {
    /// The sample type representing blood pressure correlation samples
    static var bloodPressure: Self { .correlation(.bloodPressure, displayTitle: "Blood Pressure", displayUnit: .millimeterOfMercury()) }
}


// MARK: Well-Known Category Types

public extension HealthKitSampleType where T == HKCategorySample {
    /// The sample type representing sleep analysis category samples
    static var sleepAnalysis: Self { .category(.sleepAnalysis, displayTitle: "Sleep Analysis", displayUnit: .hour()) }
}


// MARK: Name-based lookup

extension HealthKitSampleType where T == HKQuantitySample {
    // TODO!
}
