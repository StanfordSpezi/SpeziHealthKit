//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_length type_body_length function_body_length line_length shorthand_operator

import Algorithms
import Foundation
import SpeziFoundation
@_spi(APISupport) @_spi(Testing)
@testable import SpeziHealthKit
import Testing


/// (HKUnit) Tests, not HK (UnitTests).
@Suite(.serialized)
struct HKUnitTests {
    fileprivate typealias HKUnitA = HKUnit
    fileprivate typealias HKUnitB = _HKUnit
    
    private typealias HKQuantityA = HKQuantity
    private typealias HKQuantityB = _HKQuantity
    
    // ISSUE: HealthKit unitStrings are stable (not even intentionally, but (as it seems) effectively,
    // as a result of them using NSMapTable, and how they allocate their unique unit instances),
    // but our unit strings are not stable, which makes them difficult to compare.
    // "stable" here referring to the unit strings having a well-defined, stable order for e.g. multiplication terms.
    private let enableUnitStringTests = false
    
    private let hasHealthKit: Bool = {
        #if canImport(HealthKit)
        true
        #else
        false
        #endif
    }()
    
    
    @Test func unitCompatibility() throws {
        func _checkCompatible( // swiftlint:disable:this identifier_name
            _ unit1String: String,
            _ unit2String: String,
            expected: Bool,
            healthKitExpectedFailure: String? = nil
        ) throws {
            let unitA1 = try HKUnitA.parse(unit1String)
            let unitA2 = try HKUnitA.parse(unit2String)
            let unitB1 = try HKUnitB.parse(unit1String)
            let unitB2 = try HKUnitB.parse(unit2String)
            let hkImp = {
                #expect(unitA1.isCompatible(with: unitA1))
                #expect(unitA1.isCompatible(with: unitA2) == expected, "\(unitA1) vs \(unitA2)")
                #expect(unitA2.isCompatible(with: unitA1) == expected, "\(unitA2) vs \(unitA1)")
                #expect(unitA2.isCompatible(with: unitA2))
            }
            if hasHealthKit, let healthKitExpectedFailure {
                withKnownIssue("\(healthKitExpectedFailure)") {
                    hkImp()
                }
            } else {
                hkImp()
            }
            #expect(unitB1.isCompatible(with: unitB1))
            #expect(unitB1.isCompatible(with: unitB2) == expected, "\(unitB1) vs \(unitB2)")
            #expect(unitB2.isCompatible(with: unitB1) == expected, "\(unitB2) vs \(unitB1)")
            #expect(unitB2.isCompatible(with: unitB2))
        }
        func expectCompatible(_ unit1String: String, _ unit2String: String, healthKitExpectedFailure: String? = nil) throws {
            try _checkCompatible(unit1String, unit2String, expected: true, healthKitExpectedFailure: healthKitExpectedFailure)
        }
        func expectNotCompatible(_ unit1String: String, _ unit2String: String, healthKitExpectedFailure: String? = nil) throws {
            try _checkCompatible(unit1String, unit2String, expected: false, healthKitExpectedFailure: healthKitExpectedFailure)
        }
        
        try expectCompatible("%", "count")
        
        try expectCompatible("cm", "m")
        
        try expectCompatible("%/m", "count/m")
        try expectCompatible("%/m", "count/in")
        try expectCompatible("%/m", "count/ft")
        try expectNotCompatible("%/m", "%/m^2")
        
        try expectCompatible("m^3", "L")
        try expectCompatible("m^2·in", "L")
        try expectCompatible("m·km·mm", "L")
        
        try expectCompatible("W", "J/s", healthKitExpectedFailure: "FB22085099")
        try expectCompatible("kW", "J/s", healthKitExpectedFailure: "FB22085099")
        
        try expectCompatible("mol", "mol")
        try expectCompatible("Gmol", "kmol")
        try expectCompatible("mol<123>", "kmol<123>")
        try expectCompatible("mol<123>", "mol<456>")
        try expectCompatible("mol<123>", "kmol<456>")
    }
    
    
    @Test
    func quantityConversion() {
        #expect(HKQuantityA(unit: .meterUnit(with: .centi), doubleValue: 187).doubleValue(for: .meter()) == 1.87)
        #expect(HKQuantityB(unit: .meterUnit(with: .centi), doubleValue: 187).doubleValue(for: .meter()) == 1.87)
        #expect(HKUnitA.degreeCelsius().convert(27, to: HKUnitA.degreeFahrenheit()).isApproximatelyEqual(to: 80.6))
        #expect(HKUnitB.degreeCelsius().convert(27, to: HKUnitB.degreeFahrenheit()).isApproximatelyEqual(to: 80.6))
        do {
            let degF1 = HKUnitB.degreeCelsius().convert(27, to: .degreeFahrenheit())
            let degF2 = Measurement<UnitTemperature>(value: 27, unit: .celsius).converted(to: .fahrenheit).value
            #expect(degF1.isApproximatelyEqual(to: degF2))
        }
        #expect(HKQuantityA(unit: .ounce(), doubleValue: 1).doubleValue(for: .gram()) == 28.349523125)
        #expect(HKQuantityB(unit: .ounce(), doubleValue: 1).doubleValue(for: .gram()) == 28.349523125)
        
        #expect(HKQuantityA(unit: .meter(), doubleValue: 1.87).is(compatibleWith: HKUnitA.inch()))
        #expect(HKQuantityB(unit: .meter(), doubleValue: 1.87).is(compatibleWith: HKUnitB.inch()))
        #expect(!HKQuantityA(unit: .meter(), doubleValue: 1.87).is(compatibleWith: HKUnitA.gram()))
        #expect(!HKQuantityB(unit: .meter(), doubleValue: 1.87).is(compatibleWith: HKUnitB.gram()))
    }
    
    
    @Test
    func quantityConversionComplex() throws {
        func testConversion(_ unit1String: String, unit2String: String, input: Double, result expected: Double) throws {
            let unitA1 = try HKUnitA.parse(unit1String)
            let unitA2 = try HKUnitA.parse(unit2String)
            let resultAL = unitA1.convert(input, to: unitA2)
            #expect(resultAL.isApproximatelyEqual(to: expected), "from \(unitA1) to \(unitA2)")
            let resultAR = unitA2.convert(expected, to: unitA1)
            #expect(resultAR.isApproximatelyEqual(to: input), "from \(unitA2) to \(unitA1)")
            
            let unitB1 = try HKUnitB.parse(unit1String)
            let unitB2 = try HKUnitB.parse(unit2String)
            let resultBL = unitB1.convert(input, to: unitB2)
            #expect(resultBL.isApproximatelyEqual(to: expected), "from \(unitB1) to \(unitB2)")
            let resultBR = unitB2.convert(expected, to: unitB1)
            #expect(resultBR.isApproximatelyEqual(to: input), "from \(unitB2) to \(unitB1)")
        }
        
        do {
            let unitA1: HKUnitA = .degreeCelsius() * .meter()
            let unitB1: HKUnitB = .degreeCelsius() * .meter()
            if enableUnitStringTests {
                #expect(unitA1.unitString == "degC·m")
                #expect(unitB1.unitString == "degC·m")
            }
            let unitA2: HKUnitA = .degreeFahrenheit() * .meter()
            let unitB2: HKUnitB = .degreeFahrenheit() * .meter()
            if enableUnitStringTests {
                #expect(unitA2.unitString == "m·degF")
                #expect(unitB2.unitString == "m·degF")
            }
            #expect(unitA1.isCompatible(with: unitA2))
            #expect(unitB1.isCompatible(with: unitB2))
            #expect(unitA1.convert(1.1, to: unitA2) == 1.98)
            #expect(unitB1.convert(1.1, to: unitB2) == 1.98)
        }
        
        do {
            let unitA1: HKUnitA = .meter() / .second().unitRaised(toPower: 2)
            let unitB1: HKUnitB = .meter() / .second().unitRaised(toPower: 2)
            if enableUnitStringTests {
                #expect(unitA1.unitString == "m/s^2")
            }
            #expect(unitB1.factorization == HKFactorization([
                .init(dimension: .length, unitString: "m"): 1,
                .init(dimension: .time, unitString: "s"): -2
            ]))
            if enableUnitStringTests {
                #expect(unitB1.unitString == "m/s^2")
            }
            let unitA2: HKUnitA = .meterUnit(with: .centi) / .second().unitRaised(toPower: 2)
            let unitB2: HKUnitB = .meterUnit(with: .centi) / .second().unitRaised(toPower: 2)
            if enableUnitStringTests {
                #expect(unitA2.unitString == "cm/s^2")
                #expect(unitB2.unitString == "cm/s^2")
            }
            #expect(unitA1.isCompatible(with: unitA2))
            #expect(unitB1.isCompatible(with: unitB2))
            #expect(unitA1.convert(4.7, to: unitA2) == 470)
            #expect(unitB1.convert(4.7, to: unitB2) == 470)
        }
        do {
            let unitA1: HKUnitA = ((.meter().unitRaised(toPower: 4) / .inch().unitRaised(toPower: 2)) * .literUnit(with: .giga)) / .atmosphere().unitRaised(toPower: -2)
            let unitB1: HKUnitB = ((.meter().unitRaised(toPower: 4) / .inch().unitRaised(toPower: 2)) * .literUnit(with: .giga)) / .atmosphere().unitRaised(toPower: -2)
            let unitA2: HKUnitA = ((.inch().unitRaised(toPower: 4) / .inch().unitRaised(toPower: 2)) * .literUnit(with: .giga)) / .atmosphere().unitRaised(toPower: -2)
            let unitB2: HKUnitB = ((.inch().unitRaised(toPower: 4) / .inch().unitRaised(toPower: 2)) * .literUnit(with: .giga)) / .atmosphere().unitRaised(toPower: -2)
            if enableUnitStringTests {
                #expect(unitA1.unitString == "m^4·atm^2·GL/in^2")
                #expect(unitB1.unitString == "m^4·atm^2·GL/in^2")
                #expect(unitA2.unitString == "in^2·atm^2·GL")
                #expect(unitB2.unitString == "in^2·atm^2·GL")
            }
            #expect(unitA1.isCompatible(with: unitA2))
            #expect(unitB1.isCompatible(with: unitB2))
            #expect(unitB1.factorization == HKFactorization([
                .init(dimension: .length, unitString: "m"): 4,
                .init(dimension: .pressure, unitString: "atm"): 2,
                .init(dimension: .volume, unitString: "GL"): 1,
                .init(dimension: .length, unitString: "in"): -2
            ]))
            #expect(unitB2.factorization == HKFactorization([
                .init(dimension: .length, unitString: "in"): 2,
                .init(dimension: .pressure, unitString: "atm"): 2,
                .init(dimension: .volume, unitString: "GL"): 1
            ]))
        }
        
        try testConversion("m^3", unit2String: "L", input: 1, result: 1000)
        try testConversion("mL", unit2String: "L", input: 1000, result: 1)
        try testConversion("mL", unit2String: "L", input: 500, result: 0.5)
        
        #expect(try HKUnitA.parse("m^4·atm^2·GL/in^2").isCompatible(with: HKUnitA.parse("(m^2·atm)^2·GL/in^2")))
        #expect(try HKUnitB.parse("m^4·atm^2·GL/in^2").isCompatible(with: HKUnitB.parse("(m^2·atm)^2·GL/in^2")))
        #expect(try HKUnitA.parse("m^4·atm^2·GL/in^2").isCompatible(with: HKUnitA.parse("in^2·atm^2·GL")))
        #expect(try HKUnitB.parse("m^4·atm^2·GL/in^2").isCompatible(with: HKUnitB.parse("in^2·atm^2·GL")))
        try testConversion("m^4·atm^2·GL/in^2", unit2String: "in^2·atm^2·GL", input: 12.7, result: 30511872.047366135)
    }
    
    
    @Test
    func operations() {
        #expect(HKUnitA.meter().unitRaised(toPower: -1) == .meter().reciprocal())
        #expect(HKUnitB.meter().unitRaised(toPower: -1) == .meter().reciprocal())
        
        #if canImport(HealthKit)
        withKnownIssue("FB21934449") {
            #expect(HKUnitA.meter().unitRaised(toPower: 1) == .meter())
        }
        #endif
        #expect(HKUnitB.meter().unitRaised(toPower: 1) == .meter())
        
        #if canImport(HealthKit)
        withKnownIssue("FB21934449") {
            #expect(HKUnitA.meterUnit(with: .kilo).unitRaised(toPower: 1) == .meterUnit(with: .kilo))
        }
        #endif
        #expect(HKUnitB.meterUnit(with: .kilo).unitRaised(toPower: 1) == .meterUnit(with: .kilo))
        
        #expect(HKUnitA.meter().unitRaised(toPower: 0).isNull())
        #expect(HKUnitB.meter().unitRaised(toPower: 0).isNull())
        
        #expect(HKUnitA.meter().unitRaised(toPower: 1).unitString == HKUnitA.meter().unitString)
        #expect(HKUnitB.meter().unitRaised(toPower: 1).unitString == HKUnitB.meter().unitString)
        #expect(HKUnitA.meter().unitRaised(toPower: 2).isEqual(HKUnitA.meter().unitMultiplied(by: .meter())))
        #expect(HKUnitB.meter().unitRaised(toPower: 2).isEqual(HKUnitB.meter().unitMultiplied(by: .meter())))
        #expect(HKUnitA.meter().unitRaised(toPower: 2).unitString == HKUnitA.meter().unitMultiplied(by: .meter()).unitString)
        #expect(HKUnitB.meter().unitRaised(toPower: 2).unitString == HKUnitB.meter().unitMultiplied(by: .meter()).unitString)
        
        #expect(HKUnitA.count().unitRaised(toPower: 2).unitRaised(toPower: 2) == .count().unitRaised(toPower: 4))
        #expect(HKUnitB.count().unitRaised(toPower: 2).unitRaised(toPower: 2) == .count().unitRaised(toPower: 4))
        
        #expect(HKUnitA.meterUnit(with: .kilo).unitRaised(toPower: 1).unitString == "km")
        #expect(HKUnitB.meterUnit(with: .kilo).unitRaised(toPower: 1).unitString == "km")
        #expect(HKUnitA.meterUnit(with: .kilo).unitRaised(toPower: 0).unitString == "()")
        #expect(HKUnitB.meterUnit(with: .kilo).unitRaised(toPower: 0).unitString == "()")
    }
    
    
    /// Tests that some properties (in a logical sense) of the two types are identical
    @Test
    func properties() {
        guard enableUnitStringTests else {
            return
        }
        func checkOrderMul(unitsA inputsA: HKUnitA..., unitsB inputsB: HKUnitB...) {
            let unitsA = inputsA.permutations().map {
                $0.dropFirst().reduce($0[0]) { $0 * $1 }
            }
            for unit in unitsA.dropFirst() {
                #expect(unit == unitsA[0])
                #expect(unit.unitString == unitsA[0].unitString)
            }
            let unitsB = inputsB.permutations().map {
                $0.dropFirst().reduce($0[0]) { $0 * $1 }
            }
            for unit in unitsB.dropFirst() {
                #expect(unit == unitsB[0])
            }
        }
        checkOrderMul(
            unitsA: .liter(), .hour(), .atmosphere(), // swiftlint:disable:this multiline_arguments
            unitsB: .liter(), .hour(), .atmosphere()  // swiftlint:disable:this multiline_arguments
        )
    }
    
    
    @Test
    func powerAssociativity() {
        let unitA1: HKUnitA = (.meter().unitRaised(toPower: 2) * .liter().unitRaised(toPower: 3)).unitRaised(toPower: 5)
        let unitA2: HKUnitA = .meter().unitRaised(toPower: 10) * .liter().unitRaised(toPower: 15)
        #expect(unitA1 == unitA2)
        let unitB1: HKUnitB = (.meter().unitRaised(toPower: 2) * .liter().unitRaised(toPower: 3)).unitRaised(toPower: 5)
        let unitB2: HKUnitB = .meter().unitRaised(toPower: 10) * .liter().unitRaised(toPower: 15)
        #expect(unitB1 == unitB2)
    }
    
    
    @Test
    func dimensions() {
        let unit1: HKUnitB = .init(from: "m^4·atm^2·GL/in^2")
        #expect(unit1.dimension.factorization == HKFactorization([
            // Pressure^2 * Volume * Length^2
            .init(unitlessDimension: .pressure): 2,
            .init(unitlessDimension: .volume): 1,
            .init(unitlessDimension: .length): 2
        ]))
        let unit2: HKUnitB = .literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute())
        #expect(unit2.dimension.factorization == HKFactorization([
            // Volume * Mass^-1 * Time^-1
            .init(unitlessDimension: .volume): 1,
            .init(unitlessDimension: .mass): -1,
            .init(unitlessDimension: .time): -1
        ]))
    }
    
    
    @Test
    func unitConstruction() throws {
        // m^4·atm^2·GL/in^2
        // in^2·atm^2·GL
        
        #expect(try HKUnitA.parse("m^4·atm^2·GL/in^2") == HKUnitA.parse("(m^2·atm)^2·GL/in^2"))
        #expect(try HKUnitB.parse("m^4·atm^2·GL/in^2") == HKUnitB.parse("(m^2·atm)^2·GL/in^2"))
        
        #expect(try HKUnitA.parse("m^4·atm^2·GL/in^2").isCompatible(with: HKUnitA.parse("(m^2·atm)^2·GL/in^2")))
        #expect(try HKUnitB.parse("m^4·atm^2·GL/in^2").isCompatible(with: HKUnitB.parse("(m^2·atm)^2·GL/in^2")))
        
        #expect(try HKUnitA.parse("m^4·atm^2·GL/in^2").isCompatible(with: HKUnitA.parse("in^2·atm^2·GL")))
        #expect(try HKUnitB.parse("m^4·atm^2·GL/in^2").isCompatible(with: HKUnitB.parse("in^2·atm^2·GL")))
        
        do {
            var unit = HKUnitB.meter()
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == 1)
            
            unit = unit.unitRaised(toPower: 2)
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == 1)
            
            unit = unit * .atmosphere()
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == 101325)
            
            unit = unit.unitRaised(toPower: 2)
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == pow(101325, 2))
            
            unit = unit * .literUnit(with: .giga)
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == pow(101325, 2) * 1e+06)
            
            unit = unit / .inch().unitRaised(toPower: 2)
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == (pow(101325, 2) * 1e+06) / pow(HKUnitB.inch().scaleFactor, 2))
            #expect(unit.scaleFactor == (10266755625 * 1e+06) / 0.00064516)
        }
        
        do {
            // GL * atm^2 * in^2
            var unit: HKUnitB = .literUnit(with: .giga)
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == 1e+06)
            
            unit = unit * .atmosphere().unitRaised(toPower: 2)
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == 1e+06 * 101325 * 101325)
            #expect(unit.scaleFactor == 1.0266755625e16)
            #expect(HKUnitB.atmosphere().scaleFactor == 101325)
            #expect(HKUnitB.atmosphere().unitRaised(toPower: 2).scaleFactor == 101325 * 101325)
            
            unit = unit * .inch().unitRaised(toPower: 2)
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == 1e+06 * 101325 * 101325 * 0.0254 * 0.0254)
            #expect(unit.scaleFactor == (1e+06 as Double * (101325 as Double * 101325 as Double)) * (0.0254 as Double * 0.0254 as Double))
            #expect(unit.scaleFactor.isApproximatelyEqual(to: 6623700059025))
            #expect(HKUnitB.inch().scaleFactor == 0.0254)
            #expect(HKUnitB.inch().unitRaised(toPower: 2).scaleFactor == 0.0254 * 0.0254)
            
            #expect(1e+06 * 101325 * 101325 * 0.0254 * 0.0254 == 6623700059025 as Double)
        }
        
        do {
            let unit = try HKUnitB.parse("GL/in")
            #expect(unit.factorization == HKFactorization([
                .init(dimension: .volume, unitString: "GL"): 1,
                .init(dimension: .length, unitString: "in"): -1
            ]))
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == 1e+06 * (1 / 0.0254))
        }
        do {
            let unit = try HKUnitB.parse("GL/in^2")
            #expect(unit.factorization == HKFactorization([
                .init(dimension: .volume, unitString: "GL"): 1,
                .init(dimension: .length, unitString: "in"): -2
            ]))
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == 1e+06 * (1 / (0.0254 * 0.0254)))
        }
        do {
            let unit = try HKUnitB.parse("atm·GL/in^2")
            #expect(unit.factorization == HKFactorization([
                .init(dimension: .volume, unitString: "GL"): 1,
                .init(dimension: .pressure, unitString: "atm"): 1,
                .init(dimension: .length, unitString: "in"): -2
            ]))
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == 1e+06 * (101325) * (1 / (0.0254 * 0.0254)))
        }
        do {
            let unit = try HKUnitB.parse("atm^2·GL/in^2")
            #expect(unit.factorization == HKFactorization([
                .init(dimension: .volume, unitString: "GL"): 1,
                .init(dimension: .pressure, unitString: "atm"): 2,
                .init(dimension: .length, unitString: "in"): -2
            ]))
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == 1e+06 * (101325 as Double * 101325) * (1 / (0.0254 * 0.0254)))
        }
        do {
            let unit = try HKUnitB.parse("m·atm^2·GL/in^2")
            #expect(unit.factorization == HKFactorization([
                .init(dimension: .length, unitString: "m"): 1,
                .init(dimension: .volume, unitString: "GL"): 1,
                .init(dimension: .pressure, unitString: "atm"): 2,
                .init(dimension: .length, unitString: "in"): -2
            ]))
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == 1e+06 * 1 * (101325 as Double * 101325) * (1 / (0.0254 * 0.0254)))
        }
        do {
            let unit = try HKUnitB.parse("m^4·atm^2·GL/in^2")
            #expect(unit.factorization == HKFactorization([
                .init(dimension: .length, unitString: "m"): 4,
                .init(dimension: .volume, unitString: "GL"): 1,
                .init(dimension: .pressure, unitString: "atm"): 2,
                .init(dimension: .length, unitString: "in"): -2
            ]))
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == 1e+06 * (1 as Double * 1 * 1 * 1) * (101325 as Double * 101325) * (1 / (0.0254 * 0.0254)))
        }
        
        do {
            let unit = try HKUnitB.parse("m^4·atm^2·GL/in^2")
            #expect(unit.scaleOffset == 0)
            #expect(unit.factorization == HKFactorization([
                .init(dimension: .length, unitString: "m"): 4,
                .init(dimension: .pressure, unitString: "atm"): 2,
                .init(dimension: .volume, unitString: "GL"): 1,
                .init(dimension: .length, unitString: "in"): -2
            ]))
            #expect(unit.scaleFactor == 1.5913503045756092e+19)
            #expect(unit.convertFromBaseUnit(unit.convertToBaseUnit(12.71)) == 12.71)
        }
        
        do {
            let unit1 = try HKUnitB.parse("m^4·Pa^2·GL/m^2")
            let unit2 = try HKUnitB.parse("m^2·Pa^2·GL")
            #expect(unit1 == unit2)
            #expect(unit1.scaleOffset == unit2.scaleOffset)
            #expect(unit1.scaleFactor == unit2.scaleFactor)
        }
        
        do {
            let unit1 = try HKUnitB.parse("m^4·atm^2·GL/in^2")
            let unit2 = try HKUnitB.parse("m^4·Pa^2·GL/m^2")
            #expect(unit1.isCompatible(with: unit2))
            #expect(unit1.convert(12.7, to: unit2) == 202101488681102.38)
            #expect(unit1.convertFromBaseUnit(unit1.convertToBaseUnit(12.71)) == 12.71)
            #expect(unit2.convertFromBaseUnit(unit2.convertToBaseUnit(12.71)) == 12.71)
        }
        
        do {
            let unit1 = try HKUnitB.parse("m^4·atm^2·GL")
            let unit2 = try HKUnitB.parse("m^4·Pa^2·GL")
            #expect(unit1.isCompatible(with: unit2))
            #expect(unit1.convert(12.7, to: unit2) == 130387796437.5)
            #expect(unit2.convertFromBaseUnit(unit2.convertToBaseUnit(12.71)) == 12.71)
        }
    }
    
    
    @Test
    func baseUnitPointerIdentity() throws {
        // swiftlint:disable identical_operands
        #expect(HKUnitB.meter() === HKUnitB.meter())
        #expect(HKUnitB.inch() === HKUnitB.inch())
        // swiftlint:enable identical_operands
    }
    
    
    // MARK: null unit tests
    
    @Test func nullUnit() throws {
        #expect(HKUnitA._nullUnit.isNull())
        #expect(HKUnitB._nullUnit.isNull())
        
        #expect(try HKUnitA.parse("()").isNull())
        #expect(try HKUnitB.parse("()").isNull())
        
        #expect(HKUnitA._nullUnit.unitString == "()")
        #expect(HKUnitB._nullUnit.unitString == "()")
        
        #expect((HKUnitA.meter() / .meter()).isNull())
        #expect((HKUnitB.meter() / .meter()).isNull())
        
        #expect((HKUnitA.meter() / .meter()).unitString == "()")
        #expect((HKUnitB.meter() / .meter()).unitString == "()")
        
        #expect(!(HKUnitA.meter() / .inch()).isNull())
        #expect(!(HKUnitB.meter() / .inch()).isNull())
        
        // lmao https://developer.apple.com/documentation/healthkit/hkunit/isnull()
        #expect(!HKUnitA(from: "dL/L").isNull())
        #expect(!HKUnitB(from: "dL/L").isNull())
        #expect(!(HKUnitA.literUnit(with: .deci) / .liter()).isNull())
        #expect(!(HKUnitB.literUnit(with: .deci) / .liter()).isNull())
        
        #expect(HKUnitA._nullUnit.isCompatible(with: ._nullUnit))
        #expect(HKUnitB._nullUnit.isCompatible(with: ._nullUnit))
        
        if hasHealthKit {
            #expect(HKUnitA._nullUnit.isCompatible(with: .count()))
        }
        #expect(!HKUnitB._nullUnit.isCompatible(with: .count()))
        
        #expect(HKUnitB._nullUnit.factorization == HKFactorization([:]))
        #expect(HKUnitB._nullUnit.factorization.reducedToDimensions() == HKFactorization([:]))
        #expect(HKUnitB.count().factorization.reducedToDimensions() == HKFactorization([
            .init(unitlessDimension: .null): 1
        ]))
        
        if hasHealthKit {
            #expect(HKUnitA._nullUnit.isCompatible(with: .count().unitRaised(toPower: 2)))
        }
        #expect(!HKUnitB._nullUnit.isCompatible(with: .count().unitRaised(toPower: 2)))
        
        if hasHealthKit {
            #expect(HKUnitA._nullUnit.isCompatible(with: .percent()))
        }
        #expect(!HKUnitB._nullUnit.isCompatible(with: .percent()))
        
        #expect(HKUnitA.count().isCompatible(with: .percent()))
        #expect(HKUnitB.count().isCompatible(with: .percent()))
        
        #expect(HKUnitA.percent().isCompatible(with: .count()))
        #expect(HKUnitB.percent().isCompatible(with: .count()))
        
        #expect(HKUnitA._nullUnit.unitRaised(toPower: 2).isNull())
        #expect(HKUnitB._nullUnit.unitRaised(toPower: 2).isNull())
        
        #expect((HKUnitA.inch() / .inch()).isNull())
        #expect((HKUnitB.inch() / .inch()).isNull())
        
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            #expect(!HKUnitA._nullUnit.isCompatible(with: .appleEffortScore()))
            #expect(!HKUnitB._nullUnit.isCompatible(with: .appleEffortScore()))
        }
        
        #expect(!HKUnitA._nullUnit.isCompatible(with: .internationalUnit()))
        #expect(!HKUnitB._nullUnit.isCompatible(with: .internationalUnit()))
        
        #expect(!HKUnitA._nullUnit.isCompatible(with: .inch()))
        #expect(!HKUnitB._nullUnit.isCompatible(with: .inch()))
        
        #expect(!(HKUnitA.count() / .percent()).isNull())
        #expect(!(HKUnitB.count() / .percent()).isNull())
        #expect(!(HKUnitA.percent() / .count()).isNull())
        #expect(!(HKUnitB.percent() / .count()).isNull())
        
        if hasHealthKit {
            #expect(HKQuantityA(unit: ._nullUnit, doubleValue: 1).doubleValue(for: .count()) == 1)
            #expect(HKQuantityA(unit: ._nullUnit, doubleValue: 1).doubleValue(for: .percent()) == 1)
            #expect(HKQuantityA(unit: .count(), doubleValue: 1.1).doubleValue(for: .percent()) == 1.1)
            #expect(HKQuantityA(unit: .percent(), doubleValue: 0.5).doubleValue(for: .count()) == 0.5)
        }
        
        for (exp1, exp2) in product(-10...10, -10...10) {
            #expect(HKUnitA._nullUnit.unitRaised(toPower: exp1) == ._nullUnit.unitRaised(toPower: exp2))
            #expect(HKUnitA._nullUnit.unitRaised(toPower: exp1).isCompatible(with: ._nullUnit.unitRaised(toPower: exp2)))
            #expect(HKUnitB._nullUnit.unitRaised(toPower: exp1) == ._nullUnit.unitRaised(toPower: exp2))
            #expect(HKUnitB._nullUnit.unitRaised(toPower: exp1).isCompatible(with: ._nullUnit.unitRaised(toPower: exp2)))
        }
    }
    
    
    @Test
    func nullUnitDivision() throws {
        #expect(!(HKUnitA.liter() / ._nullUnit).isNull())
        #expect((HKUnitA.liter() / ._nullUnit).unitString == "L")
        #expect(!(HKUnitB.liter() / ._nullUnit).isNull())
        #expect((HKUnitB.liter() / ._nullUnit).unitString == "L")
        
        #expect(!(HKUnitA._nullUnit / .liter()).isNull())
        #expect((HKUnitA._nullUnit / .liter()).unitString == "1/L")
        #expect(!(HKUnitB._nullUnit / .liter()).isNull())
        #expect((HKUnitB._nullUnit / .liter()).unitString == "1/L")
        
        #expect(HKUnitA._nullUnit.convertToBaseUnit(12.7) == 12.7)
        #expect(HKUnitB._nullUnit.convertToBaseUnit(12.7) == 12.7)
        
        #expect(HKUnitA._nullUnit.convertFromBaseUnit(12.7) == 12.7)
        #expect(HKUnitB._nullUnit.convertFromBaseUnit(12.7) == 12.7)
    }
    
    
    @Test
    func nullUnitMultiplication() throws {
        #expect(!(HKUnitA.liter() * ._nullUnit).isNull())
        #expect((HKUnitA.liter() * ._nullUnit).unitString == "L")
        #expect(!(HKUnitB.liter() * ._nullUnit).isNull())
        #expect((HKUnitB.liter() * ._nullUnit).unitString == "L")
        
        #expect(!(HKUnitA._nullUnit * .liter()).isNull())
        #expect((HKUnitA._nullUnit * .liter()).unitString == "L")
        #expect(!(HKUnitB._nullUnit * .liter()).isNull())
        #expect((HKUnitB._nullUnit * .liter()).unitString == "L")
    }
    
    
    @Test
    func nullUnitPower() throws {
        #expect(HKUnitA._nullUnit.unitRaised(toPower: 12).isNull())
        #expect(HKUnitB._nullUnit.unitRaised(toPower: 12).isNull())
        
        #expect(HKUnitA._nullUnit.unitRaised(toPower: -12).isNull())
        #expect(HKUnitB._nullUnit.unitRaised(toPower: -12).isNull())
        
        #expect(HKUnitA._nullUnit.unitRaised(toPower: 12) == ._nullUnit)
        #expect(HKUnitB._nullUnit.unitRaised(toPower: 12) == ._nullUnit)
        
        #expect(HKUnitA._nullUnit.unitRaised(toPower: -12) == ._nullUnit)
        #expect(HKUnitB._nullUnit.unitRaised(toPower: -12) == ._nullUnit)
    }
    
    
    // MARK: Other
    
    @Test
    func hashing() throws {
        #expect(Set([try HKUnitA.parse("m/s^2"), try HKUnitA.parse("m·s^-2")]).count == 1)
        #expect(Set([try HKUnitB.parse("m/s^2"), try HKUnitB.parse("m·s^-2")]).count == 1)
        
        #expect(Set([try HKUnitA.parse("m/s^2"), try HKUnitA.parse("m·s^-1")]).count == 2)
        #expect(Set([try HKUnitB.parse("m/s^2"), try HKUnitB.parse("m·s^-1")]).count == 2)
    }
}


extension HKUnitTests {
    private struct UnitStringPair {
        let input: String
        let unitA: HKUnitA
        let unitB: HKUnitB
    }
    
    private static let unitStringPairs: [UnitStringPair] = [
        .init(
            input: "m",
            unitA: .meter(),
            unitB: .meter()
        ),
        .init(
            input: "mm",
            unitA: .meterUnit(with: .milli),
            unitB: .meterUnit(with: .milli)
        ),
        .init(
            input: "m/s^2",
            unitA: .meter() / .second().unitRaised(toPower: 2),
            unitB: .meter() / .second().unitRaised(toPower: 2)
        ),
        .init(
            input: "1/s",
            unitA: .second().reciprocal(),
            unitB: .second().reciprocal()
        ),
        .init(
            input: "s^-2",
            unitA: .second().unitRaised(toPower: -2),
            unitB: .second().unitRaised(toPower: -2)
        ),
        .init(
            input: "degC·m",
            unitA: .degreeCelsius() * .meter(),
            unitB: .degreeCelsius() * .meter()
        ),
        .init(
            input: "degF·m",
            unitA: .degreeFahrenheit() * .meter(),
            unitB: .degreeFahrenheit() * .meter()
        ),
        .init(
            input: "m/s^2",
            unitA: .meter() / .second().unitRaised(toPower: 2),
            unitB: .meter() / .second().unitRaised(toPower: 2)
        ),
        .init(
            input: "cm/s^2",
            unitA: .meterUnit(with: .centi) / .second().unitRaised(toPower: 2),
            unitB: .meterUnit(with: .centi) / .second().unitRaised(toPower: 2)
        ),
        .init(
            input: "m^4·atm^2·GL/in^2",
            unitA: ((.meter().unitRaised(toPower: 4) / .inch().unitRaised(toPower: 2)) * .literUnit(with: .giga)) / .atmosphere().unitRaised(toPower: -2),
            unitB: ((.meter().unitRaised(toPower: 4) / .inch().unitRaised(toPower: 2)) * .literUnit(with: .giga)) / .atmosphere().unitRaised(toPower: -2)
        ),
        .init(
            input: "in^2·atm^2·GL",
            unitA: ((.inch().unitRaised(toPower: 4) / .inch().unitRaised(toPower: 2)) * .literUnit(with: .giga)) / .atmosphere().unitRaised(toPower: -2),
            unitB: ((.inch().unitRaised(toPower: 4) / .inch().unitRaised(toPower: 2)) * .literUnit(with: .giga)) / .atmosphere().unitRaised(toPower: -2)
        )
    ]
    
    
    @Test
    func unitStringSimple() {
        #expect(HKUnitA.meter().unitString == "m")
        #expect(HKUnitB.meter().unitString == "m")
        
        #expect(HKUnitA.meter().unitRaised(toPower: 2).unitString == "m^2")
        #expect(HKUnitB.meter().unitRaised(toPower: 2).unitString == "m^2")
        
        #expect(HKUnitA.meter().unitRaised(toPower: 3).unitString == "m^3")
        #expect(HKUnitB.meter().unitRaised(toPower: 3).unitString == "m^3")
        
        #expect(HKUnitA.liter().unitString == "L")
        #expect(HKUnitB.liter().unitString == "L")
        
        #expect(HKUnitA.liter().unitRaised(toPower: 2).unitString == "L^2")
        #expect(HKUnitB.liter().unitRaised(toPower: 2).unitString == "L^2")
        
        #expect(HKUnitA.liter().unitRaised(toPower: 3).unitString == "L^3")
        #expect(HKUnitB.liter().unitRaised(toPower: 3).unitString == "L^3")
        
        #expect(HKUnitA.literUnit(with: .milli).unitString == "mL")
        #expect(HKUnitB.literUnit(with: .milli).unitString == "mL")
        
        #expect(HKUnitA.literUnit(with: .milli).unitRaised(toPower: 2).unitString == "mL^2")
        #expect(HKUnitB.literUnit(with: .milli).unitRaised(toPower: 2).unitString == "mL^2")
    }
    
    @Test
    func unitString() {
        guard enableUnitStringTests else {
            return
        }
        // HealthKit keeps the order when constructing its unitString
        #expect((HKUnitA.liter() * .hour()).unitString == "L·hr")
        #expect((HKUnitA.hour() * .liter()).unitString == "L·hr")
        // do we?
        #expect((HKUnitB.liter() * .hour()).unitString == "L·hr")
        #expect((HKUnitB.hour() * .liter()).unitString == "L·hr")
        
        #expect((HKUnitA.liter() * .hour() * .atmosphere()).unitString == "L·atm·hr")
        #expect((HKUnitA.liter() * .atmosphere() * .hour()).unitString == "L·atm·hr")
        
        #expect((HKUnitA.atmosphere() * .liter() * .hour()).unitString == "atm·L·hr")
        #expect((HKUnitA.atmosphere() * .hour() * .liter()).unitString == "atm·L·hr")
        
        #expect((HKUnitA.liter() / .hour()).unitString == "L/hr")
        #expect((HKUnitB.liter() / .hour()).unitString == "L/hr")
        
        #expect((HKUnitA.literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute())).unitString == "mL/min·kg")
        #expect((HKUnitB.literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute())).unitString == "mL/min·kg")
        
        #expect((HKUnitA.literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute())).description == "mL/min·kg")
        #expect((HKUnitB.literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute())).description == "mL/min·kg")
        
        #expect((HKUnitA.liter() / .minute()).unitRaised(toPower: 2).unitString == "L^2/min^2")
        #expect((HKUnitB.liter() / .minute()).unitRaised(toPower: 2).unitString == "L^2/min^2")
        #expect((HKUnitA.liter() / .minute().unitRaised(toPower: 2)).unitString == "L/min^2")
        #expect((HKUnitB.liter() / .minute().unitRaised(toPower: 2)).unitString == "L/min^2")
        
        #expect((HKUnitA.liter() / .second() / .gram()).unitString == "L/g·s")
        #expect((HKUnitB.liter() / .second() / .gram()).unitString == "L/g·s")
        #expect(((HKUnitA.liter() / .second()) / .gram()).unitString == "L/g·s")
        #expect(((HKUnitB.liter() / .second()) / .gram()).unitString == "L/g·s")
        #expect((HKUnitA.liter() / (.second() / .gram())).unitString == "g·L/s")
        #expect((HKUnitB.liter() / (.second() / .gram())).unitString == "g·L/s")
        
        #expect(HKUnitA.count().unitString == "count")
        #expect(HKUnitB.count().unitString == "count")
        #expect(HKUnitA.count().unitRaised(toPower: 2).unitString == "count^2")
        #expect(HKUnitB.count().unitRaised(toPower: 2).unitString == "count^2")
        #expect(HKUnitA.count().unitRaised(toPower: 2).unitRaised(toPower: 2).unitString == "count^4")
        #expect(HKUnitB.count().unitRaised(toPower: 2).unitRaised(toPower: 2).unitString == "count^4")
        
        #expect((HKUnitA.count() * HKUnitA.minute()).unitString == "min·count")
        #expect((HKUnitB.count() * HKUnitB.minute()).unitString == "min·count")
    }
    
    
    @Test
    func parsing() throws {
        func expectNull(_ unitString: String) throws {
            #expect(try HKUnitA.parse(unitString).isNull())
            #expect(try HKUnitB.parse(unitString).isNull())
        }
        
        func expectEqual(_ unitString1: String, _ unitString2: String) throws {
            #expect(try HKUnitA.parse(unitString1) == HKUnitA.parse(unitString2))
            #expect(try HKUnitB.parse(unitString1) == HKUnitB.parse(unitString2))
        }
        
        func expectEqual(_ unitString: String, _ unitA: HKUnitA, _ unitB: HKUnitB) throws {
            let parsedUnitA = try HKUnitA.parse(unitString)
            let parsedUnitB = try HKUnitB.parse(unitString)
            #expect(parsedUnitA == unitA)
            #expect(parsedUnitB == unitB)
        }
        
        func expectFailsToParse(_ unitString: String) {
            #expect(throws: (any Error).self) {
                try HKUnitA.parse(unitString)
            }
            #expect(throws: (any Error).self) {
                try HKUnitB.parse(unitString)
            }
        }
        
        // invalid
        expectFailsToParse("(")
        expectFailsToParse(")")
        
        // null unit
        try expectNull("")
        try expectNull("()")
        try expectNull("(())")
        try expectNull("((()))")
        try expectNull("(((())))")
        try expectNull("((((()))))")
        
        expectFailsToParse("()·()")
        expectFailsToParse("()·m")
        expectFailsToParse("m·()")
        
        try expectNull("m/m")
        
        try expectEqual("(m)·(m)", "m·m")
        
        expectFailsToParse("(m)(m)")
        expectFailsToParse("m(m)")
        expectFailsToParse("()^2")
        
        try expectEqual("m·1/s", "m/s")
        expectFailsToParse("/s")
        
        for entry in Self.unitStringPairs {
            let parsedA = try HKUnitA.parse(entry.input)
            #expect(parsedA == entry.unitA)
            #expect(parsedA.unitRaised(toPower: 12) / parsedA.unitRaised(toPower: -12) == parsedA.unitRaised(toPower: 24))
            let parsedB = try HKUnitB.parse(entry.input)
            #expect(parsedB.unitRaised(toPower: 12) / parsedB.unitRaised(toPower: -12) == parsedB.unitRaised(toPower: 24))
            #expect(parsedB.factorization == entry.unitB.factorization)
            #expect(parsedB.scaleOffset == entry.unitB.scaleOffset, "'\(entry.input)', parsed into '\(parsedB.factorization)'")
            #expect(
                parsedB.scaleFactor.isApproximatelyEqual(to: entry.unitB.scaleFactor),
                "got \(parsedB.scaleFactor); expected \(entry.unitB.scaleFactor) ('\(entry.input)', parsed into '\(parsedB.factorization)')"
            )
            #expect(parsedB == entry.unitB)
            
            #expect(parsedA.description == parsedA.unitString)
            #expect(parsedB.description == parsedB.unitString)
        }
        
        try expectEqual(
            "1/s",
            .second().reciprocal(),
            .second().reciprocal()
        )
        try expectEqual(
            "s^-1",
            .second().reciprocal(),
            .second().reciprocal()
        )
        try expectEqual(
            "s^-2",
            .second().unitRaised(toPower: -2),
            .second().unitRaised(toPower: -2)
        )
        try expectEqual(
            "1/s^2",
            .second().unitRaised(toPower: -2),
            .second().unitRaised(toPower: -2)
        )
        try expectEqual(
            "%/m",
            .percent() / .meter(),
            .percent() / .meter()
        )
        
        #expect(throws: (any Error).self) {
            try HKUnitA.parse("percent")
        }
        #expect(throws: (any Error).self) {
            try HKUnitB.parse("percent")
        }
        
        #expect(try HKUnitB.parse("s^-2").unitString == "1/s^2")
        
        // Q: does HealthKit allow parentheses when parsing unit strings? (A: yes)
        try expectEqual("m^4·atm^2·GL/in^2", "(m^2·atm)^2·GL/in^2")
        
        // Q: does HealthKit allow nested parentheses when parsing unit strings?
        try expectEqual("m^4·atm^4·GL/in^2", "((m·atm)^2)^2·GL/in^2")
        
        // Q: does HealthKit allow parentheses containing fractions when parsing unit strings? (A: no)
        expectFailsToParse("(m·atm/in^4)^2")
        
        // Q: does HealthKit allow multiple exponentiations it not nested? (no)
        expectFailsToParse("m^2^2")
        
        // Q: does HealthKit allow multiple exponentiations it nested? (yes)
        try expectEqual("(m^2)^2", "m^4")
        
        // Q: does HealthKit allow ^1 and ^0? (yes)
        try expectEqual("m^1", "m")
        try expectEqual("m^0", "()")
        
        // Q: does HealthKit allow parentheses for grouping?
        try expectEqual("(m)", "m")
        try expectEqual("((m))", "m")
        try expectEqual("(((m)))", "m")
        
        // Q: does HealthKit allow multiplication with a paren-expr?
        try expectEqual("atm·(m·L)^2", "atm·m^2·L^2")
        try expectEqual("atm·(m·L)", "atm·m·L")
        try expectEqual("(atm·m)·L", "atm·m·L")
        
        do {
            try expectEqual("m^4·atm^2·GL/m^2", "m^2·atm^2·GL")
            let units: [HKUnitB] = [
                .init(from: "in^2·atm^2·GL"),
                ((.inch().unitRaised(toPower: 4) / .inch().unitRaised(toPower: 2)) * .literUnit(with: .giga)) / .atmosphere().unitRaised(toPower: -2),
                (.inch().unitRaised(toPower: 2) * .literUnit(with: .giga)) / .atmosphere().unitRaised(toPower: -2),
                .inch().unitRaised(toPower: 2) * .literUnit(with: .giga) * .atmosphere().unitRaised(toPower: 2)
            ]
            for unit in units {
                #expect(unit.factorization == units[0].factorization)
            }
        }
        
        try expectEqual("m*m", "m·m")
        
        try expectEqual("cup_us", .cupUS(), .cupUS())
        try expectEqual("yd", .yard(), .yard())
        try expectEqual("deg", .degreeAngle(), .degreeAngle())
        try expectEqual("D", .diopter(), .diopter())
        try expectEqual("pD", .prismDiopter(), .prismDiopter())
        
        expectFailsToParse("km<123>")
        
        #expect(try HKUnitA.parse(HKUnitA.largeCalorie().unitString) == HKUnitA.largeCalorie())
        #expect(try HKUnitB.parse(HKUnitB.largeCalorie().unitString) == HKUnitB.largeCalorie())
        
        #expect(try HKUnitA.parse(HKUnitA.smallCalorie().unitString) == HKUnitA.smallCalorie())
        #expect(try HKUnitB.parse(HKUnitB.smallCalorie().unitString) == HKUnitB.smallCalorie())
        
        #expect(try HKUnitA.parse(HKUnitA.calorie().unitString) == HKUnitA.calorie())
        #expect(try HKUnitB.parse(HKUnitB.calorie().unitString) == HKUnitB.calorie())
        
        // mol
        expectFailsToParse("mol<>")
        #expect(try HKUnitA.parse("mol") != HKUnitA.moleUnit(withMolarMass: HKUnitMolarMassBloodGlucose))
        #expect(try HKUnitB.parse("mol") != HKUnitB.moleUnit(withMolarMass: HKUnitMolarMassBloodGlucose))
        try expectEqual("mol<1234>", .moleUnit(withMolarMass: 1234), .moleUnit(withMolarMass: 1234))
        try expectEqual("Gmol<1234>", .moleUnit(with: .giga, molarMass: 1234), .moleUnit(with: .giga, molarMass: 1234))
    }
    
    
    @Test
    func mole() throws {
        #expect(try HKUnitB.parse("mol") == HKUnitB.masslessMole(with: .none))
        #expect(try HKUnitB.parse("Gmol") == HKUnitB.masslessMole(with: .giga))
        #expect(try HKUnitB.parse("mol<123>") == HKUnitB.moleUnit(withMolarMass: 123))
        #expect(try HKUnitB.parse("Gmol<123>") == HKUnitB.moleUnit(with: .giga, molarMass: 123))
        #expect(try HKUnitB.parse("mol<123.45>") == HKUnitB.moleUnit(withMolarMass: 123.45))
        #expect(try HKUnitB.parse("Gmol<123.45>") == HKUnitB.moleUnit(with: .giga, molarMass: 123.45))
        #expect(try HKUnitB.parse("mol<18.02>").convert(2, to: .gram()).isApproximatelyEqual(to: 36.04))
    }
}


#if canImport(HealthKit)
extension HKUnitTests.HKUnitA {
    fileprivate static var _nullUnit: HKUnit {
        .meter() / .meter()
    }
}

extension HKUnit {
    fileprivate static func parse(_ input: String) throws -> HKUnit {
        try catchingNSException {
            HKUnit(from: input)
        }
    }
    
    fileprivate func convert(_ value: Double, to newUnit: HKUnit) -> Double {
        HKQuantity(unit: self, doubleValue: value).doubleValue(for: newUnit)
    }
    
    fileprivate func isCompatible(with other: HKUnit) -> Bool {
        let ret0 = isCompatible0(with: other)
        let ret1 = isCompatible1(with: other)
        #expect(ret0 == ret1)
        return ret0
    }
    
    // - (double)_convertToBaseUnit:(double)arg1;
    fileprivate func convertToBaseUnit(_ value: Double) -> Double {
        let imp = _method("_convertToBaseUnit:", as: (@convention(c) (HKUnit, Selector, Double) -> Double).self)
        return imp(self, Selector(("_convertToBaseUnit:")), value)
    }
    
    // - (double)_convertFromBaseUnit:(double)arg1;
    fileprivate func convertFromBaseUnit(_ value: Double) -> Double {
        let imp = _method("_convertFromBaseUnit:", as: (@convention(c) (HKUnit, Selector, Double) -> Double).self)
        return imp(self, Selector(("_convertFromBaseUnit:")), value)
    }
    
    fileprivate func isCompatible1(with other: HKUnit) -> Bool {
        HKQuantity(unit: self, doubleValue: 12.9).is(compatibleWith: other)
    }
    
    // - (bool)_isCompatibleWithUnit:(id)arg1;
    fileprivate func isCompatible0(with other: HKUnit) -> Bool {
        let imp = _method("_isCompatibleWithUnit:", as: (@convention(c) (HKUnit, Selector, HKUnit) -> ObjCBool).self)
        return imp(self, Selector(("_isCompatibleWithUnit:")), other).boolValue
    }
    
    private func _method<F>(_ name: String, as _: F.Type) -> F {
        guard let imp = self.method(for: Selector(name)) else {
            fatalError("Unable to find method -\(name)")
        }
        return unsafeBitCast(imp, to: F.self)
    }
}
#endif


extension HKUnitTests.HKUnitB {
    fileprivate static var _nullUnit: HKUnitTests.HKUnitB {
        .meter() / .meter()
    }
}
