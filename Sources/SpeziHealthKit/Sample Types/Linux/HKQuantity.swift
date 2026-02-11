//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if !canImport(HealthKit)

public import Foundation


public final class HKQuantity: NSObject, Sendable {
    private let unit: HKUnit
    private let value: Double
    
    public init(unit: HKUnit, doubleValue: Double) {
        self.unit = unit
        self.value = doubleValue
    }
    
    public func `is`(compatibleWith unit: HKUnit) -> Bool {
        _notImplemented()
    }
    
    public func doubleValue(for unit: HKUnit) -> Double {
        _notImplemented()
    }
    
    public func compare(_ other: HKQuantity) -> ComparisonResult {
        _notImplemented()
    }
}

#endif
