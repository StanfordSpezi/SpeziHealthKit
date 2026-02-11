//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@testable import SpeziHealthKit
import Testing


@Suite
struct HKUnitTests {
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
        #expect(HKQuantityA(unit: .ounce(), doubleValue: 1).doubleValue(for: .gram()) == 28.349523125)
        #expect(HKQuantityB(unit: .ounce(), doubleValue: 1).doubleValue(for: .gram()) == 28.349523125)
        
        #expect(HKQuantityA(unit: .meter(), doubleValue: 1.87).is(compatibleWith: HKUnitA.inch()))
        #expect(HKQuantityB(unit: .meter(), doubleValue: 1.87).is(compatibleWith: HKUnitB.inch()))
        #expect(!HKQuantityA(unit: .meter(), doubleValue: 1.87).is(compatibleWith: HKUnitA.gram()))
        #expect(!HKQuantityB(unit: .meter(), doubleValue: 1.87).is(compatibleWith: HKUnitB.gram()))
    }
    
    @Test
    func operations() {
        #expect(HKUnitA.meter().unitRaised(toPower: -1) == .meter().reciprocal())
        #expect(HKUnitB.meter().unitRaised(toPower: -1) == .meter().reciprocal())
        
        #expect(throws: ExpectationFailedError.self) { // FB21934449
            try #require(HKUnitA.meter().unitRaised(toPower: 1) == .meter())
        }
        #expect(HKUnitB.meter().unitRaised(toPower: 1) == .meter())
        
        #expect(throws: ExpectationFailedError.self) { // FB21934449
            try #require(HKUnitA.meterUnit(with: .kilo).unitRaised(toPower: 1) == .meterUnit(with: .kilo))
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
    
    
    @Test
    func unitString() {
        #expect((HKUnitA.literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute())).unitString == "mL/min·kg")
        #expect((HKUnitB.literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute())).unitString == "mL/min·kg")
        
        #expect((HKUnitA.literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute())).description == "mL/min·kg")
        #expect((HKUnitB.literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute())).description == "mL/min·kg")
        
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
    func parsing() {
//        #expect(HKUnitA(from: "mL/min·kg") == HKUnitA.literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute()))
//        #expect(HKUnitB(from: "mL/min·kg") == .literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute()))
    }
}
