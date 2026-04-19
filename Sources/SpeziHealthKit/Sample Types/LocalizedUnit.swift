//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable identifier_name

import Foundation
#if canImport(HealthKit)
import HealthKit
#endif


/// Locale-aware `HKUnit`.
public struct LocalizedUnit: Sendable {
    /// The metric variant of the unit..
    public let metric: HKUnit
    /// The US variant of the unit.
    public let us: HKUnit
    /// The UK variant of the unit.
    public let uk: HKUnit
    
    /// Creates a new LocalizedUnit
    ///
    /// - parameter metric: The metric variant of the unit.
    /// - parameter us: The US variant of the unit.
    /// - parameter uk: The UK variant of the unit.
    ///
    /// - Note: This initializer will default the ``us`` and ``uk`` variants to the `metric` input, if their inputs in the init are `nil`.
    @inlinable
    public init(metric: HKUnit, us: HKUnit? = nil, uk: HKUnit? = nil) {
        self.metric = metric
        self.us = us ?? metric
        self.uk = uk ?? metric
    }
    
    @inlinable
    public subscript(_ system: Locale.MeasurementSystem) -> HKUnit {
        switch system {
        case .metric: metric
        case .us: us
        case .uk: uk
        default: metric
        }
    }
    
    @inlinable
    public subscript(_ locale: Locale) -> HKUnit {
        self[locale.measurementSystem]
    }
}
