//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import Foundation
#if canImport(HealthKit)
import HealthKit
#endif


public struct LocalizedUnit: Sendable {
    public let metric: HKUnit
    public let us: HKUnit?
    public let uk: HKUnit?
    
    @inlinable
    public init(metric: HKUnit, us: HKUnit? = nil, uk: HKUnit? = nil) {
        // TODO we could make self.us and self.uk non-optional, and assign them to metric here in the init if their respecive args are nil.
        // that would save us the extra fallback each time the unit is resolved.
        self.metric = metric
        self.us = us
        self.uk = uk
    }
    
    @inlinable
    public subscript(_ locale: Locale) -> HKUnit {
        switch locale.measurementSystem {
        case .metric:
            metric
        case .us:
            us ?? metric
        case .uk:
            uk ?? metric
        default:
            metric
        }
    }
}
