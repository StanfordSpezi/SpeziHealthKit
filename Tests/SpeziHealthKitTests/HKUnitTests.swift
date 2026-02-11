//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if !canImport(HealthKit)

@testable import SpeziHealthKit
import Testing


@Suite
struct HKUnitTests {
    @Test
    func quantityConversion() {
        #expect(HKQuantity2(unit: .meterUnit(with: .centi), doubleValue: 187).doubleValue(for: .meter()) == 1.87)
        #expect(HKUnit2.degreeCelsius().convert(27, to: .degreeFahrenheit()) == 80.59999999999994)
        #expect(HKQuantity2(unit: .ounce(), doubleValue: 1).doubleValue(for: .gram()) == 28.349523125)
    }
}

#endif
