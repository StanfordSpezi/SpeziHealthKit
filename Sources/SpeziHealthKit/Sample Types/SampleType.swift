//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit



/// Associates a `HKSampleType` subclass with a `HKSample` subclass.
public protocol _HKSampleWithSampleType: HKSample {
    associatedtype _SampleType: HKSampleType
}


extension HKQuantitySample: _HKSampleWithSampleType {
    public typealias _SampleType = HKQuantityType
}

extension HKCorrelation: _HKSampleWithSampleType {
    public typealias _SampleType = HKCorrelationType
}

extension HKCategorySample: _HKSampleWithSampleType {
    public typealias _SampleType = HKCategoryType
}

extension HKElectrocardiogram: _HKSampleWithSampleType {
    public typealias _SampleType = HKElectrocardiogramType
}

extension HKAudiogramSample: _HKSampleWithSampleType {
    public typealias _SampleType = HKAudiogramSampleType
}


/// A sample type that can be used to query data from HealthKit.
///
/// This struct is a strongly-typed wrapper around `HKSampleType` that associates a sample type with its corresponding `HKSample` subclass.
/// Additionally, it also provides some useful information for working with a sample type, such as e.g. the sample type's recommended display title
public struct HealthKitSampleType<Sample: _HKSampleWithSampleType>: Hashable, Identifiable, Sendable {
    private enum Variant: Sendable {
        /// - parameter displayUnit: The unit that should be used when displaying a sample of this type to the user
        /// - parameter expectedValuesRange: The expected range of values we expect to see for this sample type, if applicable.
        ///     The main purpose of this is to be able to e.g. adjust chart value ranges based on the specific sample types being visualised.
        case quantity(displayUnit: HKUnit, expectedValuesRange: ClosedRange<Double>?) // TODO remove the range thing?!
        /// - parameter displayUnit: The unit that should be used when displaying a sample belonging to a correlation of this type to the user.
        ///    Depending on the specific correlation type, this value might be `nil`. (E.g., if the samples associated with the correlation don't all use the same unit.)
        case correlation(displayUnit: HKUnit?)
        case category
        case electrocardiogram
        case audiogram
    }
    
    /// The underlying `HKSampleType`
    public let hkSampleType: Sample._SampleType
    /// The recommended user-displayable name of this sample type.
    public let displayTitle: String
    /// Variant-specific additional information.
    private let variant: Variant
    
    public var id: String {
        hkSampleType.identifier
    }
    
    /// Creates a new ``HealthKitSampleType``.
    /// - Note: Don't use this initializer directly. Instead, use one of the static factory methods: `HealthKitSampleType.quantity`, `.correlation`, and `.category`.
    private init(_ hkSampleType: Sample._SampleType, displayTitle: String, variant: Variant) {
        self.hkSampleType = hkSampleType
        self.displayTitle = displayTitle
        self.variant = variant
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public static func == (lhs: Self, rhs: HealthKitSampleType<some Any>) -> Bool {
        lhs.id == rhs.id
    }
}


extension HealthKitSampleType where Sample == HKQuantitySample {
    /// The recommended unit that should be used when displaying values of this sample type to a user.
    public var displayUnit: HKUnit {
        switch variant {
        case .quantity(let displayUnit, _):
            return displayUnit
        case .correlation, .category, .electrocardiogram, .audiogram:
            // SAFETY:
            // This branch is unreachable; the initializers are defined and structured in a way that all
            // `HealthKitSampleType<HKQuantitySample>` objects always must specify a displayUnit.
            fatalError("Cannot provide '\(#function)' for '\(Self.self)'")
        }
    }
    
    public var expectedValuesRange: ClosedRange<Double>? {
        switch variant {
        case .quantity(displayUnit: _, let expectedValuesRange):
            return expectedValuesRange
        case .correlation, .category, .electrocardiogram, .audiogram:
            // SAFETY:
            // This branch is unreachable; the initializers are defined and structured in a way that all
            // `HealthKitSampleType<HKQuantitySample>` objects always must specify an expectedValuesRange.
            fatalError("Cannot provide '\(#function)' for '\(Self.self)'")
        }
    }
}


extension HealthKitSampleType where Sample == HKCorrelation {
    /// The recommended unit that should be used when displaying values of this sample type to a user.
    public var displayUnit: HKUnit? {
        switch variant {
        case .correlation(let displayUnit):
            return displayUnit
        case .quantity, .category, .electrocardiogram, .audiogram:
            // SAFETY:
            // This branch is unreachable; the initializers are defined and structured in a way that all
            // `HealthKitSampleType<HKCorrelation>` objects always must specify a displayUnit.
            fatalError("Cannot provide '\(#function)' for '\(Self.self)'")
        }
    }
}


// MARK: Factory methods for commonly-used sample types

extension HealthKitSampleType {
    /// Creates a new quantity sample type.
    /// - Note: This function is not intended to be used outside of defining new quantity sample types in a ``HealthKitSampleType`` extension.
    ///     If you want to get some specific sample type, refer to it via its accessor (e.g. `HealthKitSampleType.heartRate`).
    static func quantity(
        _ identifier: HKQuantityTypeIdentifier,
        displayTitle: String,
        displayUnit: HKUnit,
        expectedValuesRange: ClosedRange<Double>? = nil
    ) -> HealthKitSampleType<HKQuantitySample> {
        .init(
            HKQuantityType(identifier),
            displayTitle: displayTitle,
            variant: .quantity(displayUnit: displayUnit, expectedValuesRange: expectedValuesRange)
        )
    }
    
    /// Creates a new correlation sample type.
    /// - Note: This function is not intended to be used outside of defining new correlation sample types in a ``HealthKitSampleType`` extension.
    ///     If you want to get some specific sample type, refer to it via its accessor (e.g. `HealthKitSampleType.bloodPressure`).
    static func correlation(
        _ identifier: HKCorrelationTypeIdentifier,
        displayTitle: String,
        displayUnit: HKUnit?
    ) -> HealthKitSampleType<HKCorrelation> {
        .init(HKCorrelationType(identifier), displayTitle: displayTitle, variant: .correlation(displayUnit: displayUnit))
    }
    
    /// Creates a new category sample type.
    /// - Note: This function is not intended to be used outside of defining new quantity sample types in a ``HealthKitSampleType`` extension.
    ///     If you want to get some specific sample type, refer to it via its accessor (e.g. `HealthKitSampleType.heartRate`).
    static func category(_ identifier: HKCategoryTypeIdentifier, displayTitle: String) -> HealthKitSampleType<HKCategorySample> {
        .init(HKCategoryType(identifier), displayTitle: displayTitle, variant: .category)
    }
}


// MARK: Other sample types

extension HealthKitSampleType where Sample: HKElectrocardiogram {
    /// The electrocardiogram sample type
    public static var electrocardiogram: Self {
        .init(HKSampleType.electrocardiogramType(), displayTitle: "ECG", variant: .electrocardiogram)
    }
}


extension HealthKitSampleType where Sample: HKAudiogramSample {
    /// The audiogram sample type
    public static var audiogram: Self {
        .init(HKSampleType.audiogramSampleType(), displayTitle: "Audiogram", variant: .audiogram)
    }
}
