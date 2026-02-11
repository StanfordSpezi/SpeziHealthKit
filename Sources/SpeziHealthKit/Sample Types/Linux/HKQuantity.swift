//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


#if !canImport(HealthKit)
public typealias HKQuantity = HKQuantity2
#endif


#if true || !canImport(HealthKit)

public import Foundation


public final class HKQuantity2: NSObject, Sendable {
    private let unit: HKUnit2
    private let value: Double
    
    public init(unit: HKUnit2, doubleValue: Double) {
        self.unit = unit
        self.value = doubleValue
    }
    
    public func `is`(compatibleWith unit: HKUnit2) -> Bool {
        fatalError()
    }
    
    public func doubleValue(for unit: HKUnit2) -> Double {
        self.unit.convert(value, to: unit)
    }
    
    public func compare(_ other: HKQuantity) -> ComparisonResult {
        fatalError()
    }
}

#endif

