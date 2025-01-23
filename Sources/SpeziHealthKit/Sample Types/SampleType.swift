//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


public struct SampleType<Sample: _HKSampleWithSampleType>: AnySampleType {
    @usableFromInline
    enum Variant: Sendable {
        /// - parameter displayUnit: The unit that should be used when displaying a sample of this type to the user
        /// - parameter expectedValuesRange: The expected range of values we expect to see for this sample type, if applicable.
        ///     The main purpose of this is to be able to e.g. adjust chart value ranges based on the specific sample types being visualised.
        case quantity(displayUnit: HKUnit, expectedValuesRange: ClosedRange<Double>?)
        /// - parameter displayUnit: The unit that should be used when displaying a sample belonging to a correlation of this type to the user.
        ///    Depending on the specific correlation type, this value might be `nil`. (E.g., if the samples associated with the correlation don't all use the same unit.)
        case correlation(displayUnit: HKUnit?)
        case category
        case electrocardiogram
        case audiogram
    }
    
    public let hkSampleType: Sample._SampleType
    
    public let displayTitle: String
    
    /// Variant-specific additional information.
    @usableFromInline let variant: Variant
    
    /// Creates a new ``SampleType``.
    /// Use this initializer only if the sample type you want to work with isn't already defined by SpeziHealthKit, and only if none of the static factory methods are suitable.
    /// - parameter hkSampleType: The sample type's underlying `HKSampleType`
    /// - parameter displayTitle: The localized string which should be used when displaying this sample type's title in a user-visible context.
    /// - parameter variant: The internal variant that should be used for storing any additional data associated with the sample type's specific underlying HealthKit sample type.
    @usableFromInline init(_ hkSampleType: Sample._SampleType, displayTitle: LocalizedStringResource, variant: Variant) {
        self.hkSampleType = hkSampleType
        self.displayTitle = String(localized: displayTitle)
        self.variant = variant
    }
}


extension SampleType where Sample == HKQuantitySample {
    /// The recommended unit that should be used when displaying values of this sample type to a user.
    @inlinable public var displayUnit: HKUnit {
        switch variant {
        case .quantity(let displayUnit, _):
            return displayUnit
        case .correlation, .category, .electrocardiogram, .audiogram:
            // SAFETY:
            // This branch is unreachable; the initializers are defined and structured in a way that all
            // `SampleType<HKQuantitySample>` objects always must specify a displayUnit.
            fatalError("Cannot provide '\(#function)' for '\(Self.self)'")
        }
    }
    
    /// The expected range of values we expect to see for this sample type, if applicable.
    ///
    /// The main purpose of this is to be able to e.g. adjust chart value ranges based on the specific sample types being visualised.
    @inlinable public var expectedValuesRange: ClosedRange<Double>? {
        switch variant {
        case .quantity(displayUnit: _, let expectedValuesRange):
            return expectedValuesRange
        case .correlation, .category, .electrocardiogram, .audiogram:
            // SAFETY:
            // This branch is unreachable; the initializers are defined and structured in a way that all
            // `SampleType<HKQuantitySample>` objects always must specify an expectedValuesRange.
            fatalError("Cannot provide '\(#function)' for '\(Self.self)'")
        }
    }
}


extension SampleType where Sample == HKCorrelation {
    /// The recommended unit that should be used when displaying values of this sample type to a user.
    @inlinable public var displayUnit: HKUnit? {
        switch variant {
        case .correlation(let displayUnit):
            return displayUnit
        case .quantity, .category, .electrocardiogram, .audiogram:
            // SAFETY:
            // This branch is unreachable; the initializers are defined and structured in a way that all
            // `SampleType<HKCorrelation>` objects always must specify a displayUnit.
            fatalError("Cannot provide '\(#function)' for '\(Self.self)'")
        }
    }
}


// MARK: Factory methods for commonly-used sample types

extension SampleType {
    /// Creates a new quantity sample type.
    /// Use this initializer only if the sample type you want to work with isn't already defined by SpeziHealthKit.
    /// - parameter identifier: The sample type's underlying `HKQuantityTypeIdentifier`
    /// - parameter displayTitle: The localized string which should be used when displaying this sample type's title in a user-visible context.
    /// - parameter displayUnit: The unit which should be used when displaying values of this quantity type to the user.
    /// - parameter expectedValuesRange: If applicable, the expected range the individual sample values will most likely fall into.
    ///     Providing this information allows some components to optimize how they display data belonging to this sample type.
    @inlinable public static func quantity(
        _ identifier: HKQuantityTypeIdentifier,
        displayTitle: LocalizedStringResource,
        displayUnit: HKUnit,
        expectedValuesRange: ClosedRange<Double>? = nil
    ) -> SampleType<HKQuantitySample> {
        .init(
            HKQuantityType(identifier),
            displayTitle: displayTitle,
            variant: .quantity(displayUnit: displayUnit, expectedValuesRange: expectedValuesRange)
        )
    }
    
    /// Creates a new correlation sample type.
    /// Use this initializer only if the sample type you want to work with isn't already defined by SpeziHealthKit.
    /// - parameter identifier: The sample type's underlying `HKCorrelationTypeIdentifier`
    /// - parameter displayTitle: The localized string which should be used when displaying this sample type's title in a user-visible context.
    /// - parameter displayUnit: The unit which should be used when displaying values of this correlation type to the user, if applicable.
    @inlinable public static func correlation(
        _ identifier: HKCorrelationTypeIdentifier,
        displayTitle: LocalizedStringResource,
        displayUnit: HKUnit?
    ) -> SampleType<HKCorrelation> {
        .init(HKCorrelationType(identifier), displayTitle: displayTitle, variant: .correlation(displayUnit: displayUnit))
    }
    
    /// Creates a new category sample type.
    /// Use this initializer only if the sample type you want to work with isn't already defined by SpeziHealthKit.
    /// - parameter identifier: The sample type's underlying `HKCategoryTypeIdentifier`
    /// - parameter displayTitle: The localized string which should be used when displaying this sample type's title in a user-visible context.
    @inlinable public static func category(
        _ identifier: HKCategoryTypeIdentifier,
        displayTitle: LocalizedStringResource
    ) -> SampleType<HKCategorySample> {
        .init(HKCategoryType(identifier), displayTitle: displayTitle, variant: .category)
    }
}


// MARK: Other sample types

extension SampleType {
    /// The electrocardiogram sample type
    @inlinable public static var electrocardiogram: SampleType<HKElectrocardiogram> {
        .init(HKSampleType.electrocardiogramType(), displayTitle: "ECG", variant: .electrocardiogram)
    }
}


extension SampleType {
    /// The audiogram sample type
    @inlinable public static var audiogram: SampleType<HKAudiogramSample> {
        .init(HKSampleType.audiogramSampleType(), displayTitle: "Audiogram", variant: .audiogram)
    }
}
