//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import Foundation

#if !canImport(HealthKit)
public typealias HKQuantity = _HKQuantity
#endif


@_documentation(visibility: internal)
public final class _HKQuantity: NSObject, Sendable {
    private let unit: _HKUnit
    private let value: Double
    
    public init(unit: _HKUnit, doubleValue: Double) {
        self.unit = unit
        self.value = doubleValue
    }
    
    public func `is`(compatibleWith unit: _HKUnit) -> Bool {
        self.unit.isCompatible(with: unit)
    }
    
    public func doubleValue(for unit: _HKUnit) -> Double {
        self.unit.convert(value, to: unit)
    }
    
    public func compare(_ other: _HKQuantity) -> ComparisonResult {
        guard self.unit.isCompatible(with: other.unit) else {
            fatalError("Quantity \(other) has incompatible unit")
        }
        let selfValue = self.unit.convertToBaseUnit(value)
        let otherValue = other.unit.convertToBaseUnit(other.value)
        return NSNumber(value: selfValue).compare(NSNumber(value: otherValue))
    }
}
