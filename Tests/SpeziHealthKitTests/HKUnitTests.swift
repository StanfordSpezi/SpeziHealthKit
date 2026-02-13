//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Algorithms
@_spi(APISupport) @_spi(Testing)
@testable import SpeziHealthKit
import Testing


@Suite(.serialized) struct HKUnitTests {
    private typealias HKUnitA = HKUnit
    private typealias HKUnitB = _HKUnit
    
    private typealias HKQuantityA = HKQuantity
    private typealias HKQuantityB = _HKQuantity
    
    @Test
    func quantityConversion() {
        #expect(HKQuantityA(unit: .meterUnit(with: .centi), doubleValue: 187).doubleValue(for: .meter()) == 1.87)
        #expect(HKQuantityB(unit: .meterUnit(with: .centi), doubleValue: 187).doubleValue(for: .meter()) == 1.87)
        //        #expect(HKUnitA.degreeCelsius().convert(27, to: HKUnitA.degreeFahrenheit()) == 80.59999999999994)
        #expect(HKUnitB.degreeCelsius().convert(27, to: HKUnitB.degreeFahrenheit()) == 80.59999999999994)
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
    func quantityConversionComplex() {
        do {
            let unitA1: HKUnitA = .degreeCelsius() * .meter()
            let unitB1: HKUnitB = .degreeCelsius() * .meter()
            #expect(unitA1.unitString == "degC·m")
            #expect(unitB1.unitString == "degC·m")
            let unitA2: HKUnitA = .degreeFahrenheit() * .meter()
            let unitB2: HKUnitB = .degreeFahrenheit() * .meter()
            #expect(unitA2.unitString == "m·degF")
            #expect(unitB2.unitString == "m·degF")
            #expect(unitA1.isCompatible(with: unitA2))
            #expect(unitB1.isCompatible(with: unitB2))
            #expect(unitA1.convert(1.1, to: unitA2) == 1.98)
            #expect(unitB1.convert(1.1, to: unitB2) == 1.98)
        }
        
        do {
            let unitA1: HKUnitA = .meter() / .second().unitRaised(toPower: 2)
            let unitB1: HKUnitB = .meter() / .second().unitRaised(toPower: 2)
            #expect(unitA1.unitString == "m/s^2")
            #expect(unitB1.factorization == HKFactorization(factors: [
                .init(dimension: .length, unitString: "m"): 1,
                .init(dimension: .time, unitString: "s"): -2
            ]))
            #expect(unitB1.unitString == "m/s^2")
            let unitA2: HKUnitA = .meterUnit(with: .centi) / .second().unitRaised(toPower: 2)
            let unitB2: HKUnitB = .meterUnit(with: .centi) / .second().unitRaised(toPower: 2)
            #expect(unitA2.unitString == "cm/s^2")
            #expect(unitB2.unitString == "cm/s^2")
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
            #expect(unitA1.unitString == "m^4·atm^2·GL/in^2")
            #expect(unitB1.unitString == "m^4·atm^2·GL/in^2")
            #expect(unitA2.unitString == "in^2·atm^2·GL")
            #expect(unitB2.unitString == "in^2·atm^2·GL")
            #expect(unitA1.isCompatible(with: unitA2))
            #expect(unitB1.isCompatible(with: unitB2))
            //            #expect(unitA1.convert(12.7, to: unitA2) == 0)
            //            #expect(unitB1.convert(12.7, to: unitB2) == 0)
        }
    }
    
    
    @Test
    func operations() {
        #expect(HKUnitA.meter().unitRaised(toPower: -1) == .meter().reciprocal())
        #expect(HKUnitB.meter().unitRaised(toPower: -1) == .meter().reciprocal())
        
        withKnownIssue("FB21934449") {
            #expect(HKUnitA.meter().unitRaised(toPower: 1) == .meter())
        }
        #expect(HKUnitB.meter().unitRaised(toPower: 1) == .meter())
        
        withKnownIssue("FB21934449") {
            #expect(HKUnitA.meterUnit(with: .kilo).unitRaised(toPower: 1) == .meterUnit(with: .kilo))
        }
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
        
        //        #expect(_HKUnit.meter().unitRaised(toPower: -1) == .meter().reciprocal())
        //
        //        #expect(_HKUnit.meterUnit(with: .kilo).unitRaised(toPower: 0).isNull())
        //
        //        #expect(_HKUnit.meter().unitRaised(toPower: -1) == .meter().reciprocal())
        //
        //        #expect(_HKUnit.meter().unitRaised(toPower: 0).isNull())
        //        #expect(_HKUnit.meter().unitRaised(toPower: 1).isEqual(_HKUnit.meter()))
        //        #expect(_HKUnit.meter().unitRaised(toPower: 1).unitString == _HKUnit.meter().unitString)
        //        #expect(_HKUnit.meter().unitRaised(toPower: 2).isEqual(_HKUnit.meter().unitMultiplied(by: .meter())))
        //        #expect(_HKUnit.meter().unitRaised(toPower: 2).unitString == _HKUnit.meter().unitMultiplied(by: .meter()).unitString)
        //
        //        #expect(_HKUnit.count().unitString == "count")
        //        #expect(_HKUnit.count().unitRaised(toPower: 2).unitString == "count^2")
        //        #expect(_HKUnit.count().unitRaised(toPower: 2).unitRaised(toPower: 2).unitString == "count^4")
        //        #expect(_HKUnit.count().unitRaised(toPower: 2).unitRaised(toPower: 2) == HKUnit.count().unitRaised(toPower: 4))
        //
        //        #expect(_HKUnit.meterUnit(with: .kilo).unitRaised(toPower: 1).unitString == "km")
        //        #expect(_HKUnit.meterUnit(with: .kilo).unitRaised(toPower: 0).unitString == "")
    }
    
    
    /// Tests that some properties (in a logical sense) of the two types are identical
    @Test
    func properties() {
        func checkOrderMul(unitsA inputsA: HKUnitA..., unitsB inputsB: HKUnitB...) {
            let unitsA = inputsA.permutations().map {
                print($0)
                return $0.dropFirst().reduce($0[0]) { $0 * $1 }
            }
            print("unitsA: \(unitsA)")
            for unit in unitsA.dropFirst() {
                #expect(unit == unitsA[0])
                print(unit.unitString, unitsA[0].unitString)
                #expect(unit.unitString == unitsA[0].unitString)
            }
            let unitsB = inputsB.permutations().map {
                $0.dropFirst().reduce($0[0]) { $0 * $1 }
            }
            print("unitsB: \(unitsB)")
            for unit in unitsB.dropFirst() {
                #expect(unit == unitsB[0])
            }
        }
        //        checkOrderMul(
        //            unitsA: .liter(), .hour(),
        //            unitsB: .liter(), .hour()
        //        )
        checkOrderMul(
            unitsA: .liter(), .hour(), .atmosphere(),
            unitsB: .liter(), .hour(), .atmosphere()
        )
    }
    
    
    @Test
    func powerAssociativity() {
        do {
            let unitA1: HKUnitA = (.meter().unitRaised(toPower: 2) * .liter().unitRaised(toPower: 3)).unitRaised(toPower: 5)
            let unitA2: HKUnitA = .meter().unitRaised(toPower: 10) * .liter().unitRaised(toPower: 15)
            #expect(unitA1 == unitA2)
            let unitB1: HKUnitB = (.meter().unitRaised(toPower: 2) * .liter().unitRaised(toPower: 3)).unitRaised(toPower: 5)
            let unitB2: HKUnitB = .meter().unitRaised(toPower: 10) * .liter().unitRaised(toPower: 15)
            #expect(unitB1 == unitB2)
        }
    }
    
    
    @Test
    func dimensions() {
        let unit1: HKUnitB = .init(from: "m^4·atm^2·GL/in^2")
        #expect(unit1.dimension.factorization == HKFactorization(factors: [
            // Pressure^2 * Volume * Length^2
            .init(unitlessDimension: .pressure): 2,
            .init(unitlessDimension: .volume): 1,
            .init(unitlessDimension: .length): 2
        ]))
        let unit2: HKUnitB = .literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute())
        #expect(unit2.dimension.factorization == HKFactorization(factors: [
            // Volume * Mass^-1 * Time^-1
            .init(unitlessDimension: .volume): 1,
            .init(unitlessDimension: .mass): -1,
            .init(unitlessDimension: .time): -1
        ]))
    }
    
    
    @Test
    func unitConstruction() {
        // m^4·atm^2·GL/in^2
        // in^2·atm^2·GL
        do {
            var unit = HKUnitB.meter()
            #expect(unit.scaleOffset == 0)
            #expect(unit.scaleFactor == 1)
            
            unit = unit.unitRaised(toPower: 4)
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
            #expect(unit.scaleFactor == 1)
        }
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
        ),
    ]
    
    @Test
    func unitString() {
        // HealthKit keeps the order when constructing its unitString
        #expect((HKUnitA.liter() * .hour()).unitString == "L·hr")
        #expect((HKUnitA.hour() * .liter()).unitString == "L·hr")
        
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
        for entry in Self.unitStringPairs {
            let parsedA = HKUnitA(from: entry.input)
            #expect(parsedA == entry.unitA)
            let parsedB = try HKUnitB.parse(entry.input)
            #expect(parsedB.factorization == entry.unitB.factorization)
            #expect(parsedB.scaleOffset == entry.unitB.scaleOffset, "'\(entry.input)', parsed into '\(parsedB.factorization)'")
            #expect(parsedB.scaleFactor == entry.unitB.scaleFactor, "'\(entry.input)', parsed into '\(parsedB.factorization)'")
            #expect(parsedB == entry.unitB)
        }
        #expect(HKUnitB(from: "1/s") == .second().reciprocal())
        #expect(HKUnitB(from: "s^-1") == .second().reciprocal())
        #expect(HKUnitB(from: "s^-2") == .second().unitRaised(toPower: -2))
        #expect(HKUnitB(from: "1/s^2") == .second().unitRaised(toPower: -2))
    }
}


#if canImport(HealthKit)
extension HKUnit {
    fileprivate func convert(_ value: Double, to newUnit: HKUnit) -> Double {
        HKQuantity(unit: self, doubleValue: value).doubleValue(for: newUnit)
    }
    fileprivate func isCompatible(with other: HKUnit) -> Bool {
        HKQuantity(unit: self, doubleValue: 1).is(compatibleWith: other)
    }
}
#endif
