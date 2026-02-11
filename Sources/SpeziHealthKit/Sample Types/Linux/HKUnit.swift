//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if !canImport(HealthKit)

// swiftlint:disable all

public import Foundation


public class HKUnit2: NSObject, @unchecked Sendable {
    private static let nullUnit = HKUnit2(
        factorization: .init(factor: 0, exponents: [:]),
        scaleOffset: 0,
        scaleFactor: 0
    )
    
    fileprivate let factorization: HKFactorization
    fileprivate let scaleOffset: Double
    fileprivate let scaleFactor: Double
    
    /// Returns a unique string representation for the unit that could be used with +unitFromString:
    public var unitString: String {
//        fatalError("\(Self.self).\(#function) Not Implemented")
        factorization.unitString
    }
    
    
    public override var description: String {
        factorization.description
    }
    
    
    fileprivate init(factorization: HKFactorization, scaleOffset: Double, scaleFactor: Double) {
        self.factorization = factorization
        self.scaleOffset = scaleOffset
        self.scaleFactor = scaleFactor
    }
    
    
    public convenience init(from string: String) {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
//    public convenience init(from massFormatterUnit: MassFormatter.Unit)
//    public class func massFormatterUnit(from unit: HKUnit2) -> MassFormatter.Unit
//    public convenience init(from lengthFormatterUnit: LengthFormatter.Unit)
//    public class func lengthFormatterUnit(from unit: HKUnit2) -> LengthFormatter.Unit
//    public convenience init(from energyFormatterUnit: EnergyFormatter.Unit)
//    public class func energyFormatterUnit(from unit: HKUnit2) -> EnergyFormatter.Unit
    public func isNull() -> Bool {
        self == .nullUnit
    }
    
    public func unitMultiplied(by unit: HKUnit2) -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Should be implemented in subclass")
    }
    
    public func unitDivided(by unit: HKUnit2) -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public func unitRaised(toPower power: Int) -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Should be implemented in subclass")
    }
    
    public func reciprocal() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Should be implemented in subclass")
    }
}


@available(macOS 13.0, *)
public enum HKMetricPrefix2: Int, @unchecked Sendable {
    case none = 0
    case femto = 13
    case pico = 1
    case nano = 2
    case micro = 3
    case milli = 4
    case centi = 5
    case deci = 6
    case deca = 7
    case hecto = 8
    case kilo = 9
    case mega = 10
    case giga = 11
    case tera = 12
    
    fileprivate var factor: Double {
        switch self {
        case .none: 1
        case .femto: 1e-15
        case .pico: 1e-12
        case .nano: 1e-09
        case .micro: 1e-06
        case .milli: 1e-03
        case .centi: 1e-02 // 0.01
        case .deci: 1e-01
        case .deca: 1e+01
        case .hecto: 1e+02
        case .kilo: 1e+03
        case .mega: 1e+06
        case .giga: 1e+09
        case .tera: 1e+12
        }
    }
    
    fileprivate var prefixString: String {
        switch self {
        case .none: ""
        case .femto: "f"
        case .pico: "p"
        case .nano: "n"
        case .micro: "mc"
        case .milli: "m"
        case .centi: "c"
        case .deci: "d"
        case .deca: "da"
        case .hecto: "h"
        case .kilo: "k"
        case .mega: "M"
        case .giga: "G"
        case .tera: "T"
//        case .peta: "P"
        }
    }
}


extension HKUnit2 {
    public class func gramUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        HKBaseUnit2(unit: "g", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func gram() -> HKUnit2 {
        gramUnit(with: .none)
    }
    
    public class func ounce() -> HKUnit2 {
        HKBaseUnit2(unit: "oz", prefix: "", factor: 1, scaleOffset: 0, scaleFactor: 28.349523125000001)
    }
    
    public class func pound() -> HKUnit2 {
        HKBaseUnit2(unit: "lb", prefix: "", factor: 1, scaleOffset: 0, scaleFactor: 453.59237000000002)
    }
    
    public class func stone() -> HKUnit2 {
        HKBaseUnit2(unit: "lb", prefix: "", factor: 1, scaleOffset: 0, scaleFactor: 6350.2931799999997)
    }
    
    public class func moleUnit(with prefix: HKMetricPrefix2, molarMass gramsPerMole: Double) -> HKUnit2 {
//        HKBaseUnit2(unit: "mol<\(gramsPerMole)>", prefix: prefix.prefixString, factor: 1, scaleOffset: 0, scaleFactor: 6350.2931799999997)
        fatalError()
    }
    
    public class func moleUnit(withMolarMass gramsPerMole: Double) -> HKUnit2 {
        HKBaseUnit2(unit: "mol<\(gramsPerMole)>", prefix: "", factor: 1, scaleOffset: 0, scaleFactor: gramsPerMole)
    }
}


extension HKUnit2 {
    public class func meterUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        HKBaseUnit2(unit: "m", prefix: prefix.prefixString, factor: prefix.factor, scaleFactor: 0.025399999999999999) // ?????
    }
    
    public class func meter() -> HKUnit2 {
        meterUnit(with: .none)
    }
    
    public class func inch() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func foot() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func yard() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func mile() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
}


extension HKUnit2 {
    public class func literUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        HKBaseUnit2(unit: "L", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func liter() -> HKUnit2 {
        literUnit(with: .none)
    }
    
    public class func fluidOunceUS() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func fluidOunceImperial() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func pintUS() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func pintImperial() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func cupUS() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func cupImperial() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
}


extension HKUnit2 {
    public class func pascalUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        HKBaseUnit2(unit: "Pa", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func pascal() -> HKUnit2 {
        pascalUnit(with: .none)
    }
    
    public class func millimeterOfMercury() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func centimeterOfWater() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func atmosphere() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func decibelAWeightedSoundPressureLevel() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func inchesOfMercury() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
}


extension HKUnit2 {
    public class func secondUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        HKBaseUnit2(unit: "s", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func second() -> HKUnit2 {
        secondUnit(with: .none)
    }
    
    public class func minute() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func hour() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func day() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
}


extension HKUnit2 {
    public class func jouleUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        HKBaseUnit2(unit: "J", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func joule() -> HKUnit2 {
        jouleUnit(with: .none)
    }
    
    public class func kilocalorie() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func smallCalorie() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func largeCalorie() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func calorie() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
}


extension HKUnit2 {
    public class func degreeCelsius() -> HKUnit2 {
        HKBaseUnit2(unit: "degC", prefix: "", factor: 1, scaleOffset: 273.14999999999998, scaleFactor: 1)
    }
    
    public class func degreeFahrenheit() -> HKUnit2 {
        HKBaseUnit2(unit: "degF", prefix: "", factor: 1, scaleOffset: (5/9) * 459.67, scaleFactor: 5/9)
    }
    
    public class func kelvin() -> HKUnit2 {
        HKBaseUnit2(unit: "K", prefix: "", factor: 1)
    }
}


extension HKUnit2 {
    public class func siemenUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func siemen() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
}


extension HKUnit2 {
    public class func internationalUnit() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
}


extension HKUnit2 {
    public class func count() -> HKUnit2 {
        HKBaseUnit2(unit: "count", prefix: "", factor: 1)
    }
    
    public class func percent() -> HKUnit2 {
        HKBaseUnit2(unit: "%", prefix: "", factor: 1)
    }
}


extension HKUnit2 {
    public class func decibelHearingLevel() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
}


extension HKUnit2 {
    public class func hertzUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func hertz() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
}


extension HKUnit2 {
    public class func voltUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func volt() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
}


extension HKUnit2 {
    public class func wattUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        HKBaseUnit2(unit: "W", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func watt() -> HKUnit2 {
        wattUnit(with: .none)
    }
}


extension HKUnit2 {
    public class func diopter() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func prismDiopter() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
}


extension HKUnit2 {
    public class func radianAngleUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func radianAngle() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func degreeAngle() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
}


extension HKUnit2 {
    public class func luxUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
    
    public class func lux() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
}


extension HKUnit2 {
    public class func appleEffortScore() -> HKUnit2 {
        fatalError("\(Self.self).\(#function) Not Implemented")
    }
}


public let HKUnit2MolarMassBloodGlucose: Double = 180.15588000005408


extension NSObject {
    static func _notImplemented(_ caller: StaticString = #function) -> Never {
        fatalError("+[\(Self.self) \(caller)]: Not Implemented")
    }
    
    func _notImplemented(_ caller: StaticString = #function) -> Never {
        fatalError("-[\(Self.self) \(caller)]: Not Implemented")
    }
}



// MARK: Internals


extension NSObjectProtocol {
    fileprivate func _compareEq<each Value: Equatable>(with other: Any?, on keyPath: repeat KeyPath<Self, each Value>) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        if ObjectIdentifier(self) == ObjectIdentifier(other) {
            return true
        }
        for keyPath in repeat each keyPath {
            guard self[keyPath: keyPath] == other[keyPath: keyPath] else {
                return false
            }
        }
        return true
    }
}

private class HKBaseUnit2: HKUnit2, @unchecked Sendable {
    private let unit: String
    private let prefix: String
//    private let scaleOffset: Double
//    private let scaleFactor: Double
    
    override var unitString: String {
        prefix + unit
    }
    
    init(unit: String, prefix: String, factor: Double, scaleOffset: Double = 0, scaleFactor: Double = 1) {
        self.unit = unit
        self.prefix = prefix
        super.init(
            factorization: HKFactorization(factor: factor, exponents: [unit: 1]),
            scaleOffset: scaleOffset,
            scaleFactor: scaleFactor * factor
        )
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        _compareEq(with: object, on: \.factorization, \.unit, \.prefix, \.scaleOffset, \.scaleFactor)
//        guard let other = object as? HKBaseUnit2 else {
//            return false
//        }
//        return other.unit == self.unit && other.prefix == self.prefix && other.factor == self.factor
    }
    
    override func unitMultiplied(by unit: HKUnit2) -> HKUnit2 {
        HKCompoundUnit2(factorization: self.factorization * unit.factorization)
    }
}



private class HKCompoundUnit2: HKUnit2, @unchecked Sendable {
    init(factorization: HKFactorization) {
        super.init(factorization: factorization, scaleOffset: 0, scaleFactor: 1)
    }
}


extension HKUnit2 {
    func convertToBaseUnit(_ value: Double) -> Double {
        value * self.scaleFactor + self.scaleOffset
    }
    
    func convertFromBaseUnit(_ value: Double) -> Double {
        (value - self.scaleOffset) / self.scaleFactor
    }
    
    func convert(_ value: Double, to otherUnit: HKUnit2) -> Double {
        // TODO assert self is compatible with otherUnit
        let inBaseUnit = self.convertToBaseUnit(value)
        return otherUnit.convertFromBaseUnit(inBaseUnit)
    }
}


private struct HKFactorization: Hashable, CustomStringConvertible, Sendable {
    private let factor: Double
    private let exponents: [String: Int]
    
    var description: String {
        guard !exponents.isEmpty else {
            return "null"
        }
        var desc = "\(factor)"
        for (base, exp) in exponents {
            desc += " * \(base)^\(exp)"
        }
        return desc
    }
    
    var unitString: String {
        "·"
    }
    
    init(factor: Double, exponents: [String: Int]) {
        self.factor = factor
        self.exponents = exponents
    }
    
    // Mathematical Operations
    func multiply(by other: HKFactorization) -> HKFactorization {
        var newExponents = self.exponents
        for (unit, exp) in other.exponents {
            newExponents[unit, default: 0] += exp
        }
        // Remove units with exponent 0 (e.g., m/m cancels out)
        let filtered = newExponents.filter { $0.value != 0 }
        return HKFactorization(
            factor: self.factor * other.factor,
            exponents: filtered
        )
    }
    
    func reciprocal() -> HKFactorization {
        let newExponents = exponents.mapValues { $0 * -1 }
        return HKFactorization(factor: 1.0 / factor, exponents: newExponents)
    }
}


extension HKFactorization {
    static func * (lhs: Self, rhs: Self) -> Self {
        lhs.multiply(by: rhs)
    }
}



extension HKUnit2 {
    /// Creates a unit as the composition of dividing a unit by another unit.
    @inlinable public static func / (lhs: HKUnit2, rhs: HKUnit2) -> HKUnit2 {
        lhs.unitDivided(by: rhs)
    }
    
    /// Creates a unit as the composition of multiplying a unit with another unit.
    @inlinable public static func * (lhs: HKUnit2, rhs: HKUnit2) -> HKUnit2 {
        lhs.unitMultiplied(by: rhs)
    }
}


public func unitPlaygtound() {
    print(HKUnit.meter() * HKUnit.meter())
    print(HKUnit.meter() * HKUnit.meterUnit(with: .kilo))
    print(HKUnit.meterUnit(with: .kilo) * HKUnit.meterUnit(with: .kilo))
    
    print(HKFactorization(factor: 1, exponents: ["m": 1]) * HKFactorization(factor: 1, exponents: ["m": 1]))
    
    func imp(
        _ label: String,
        hkUnit1: HKUnit,
        hkUnit2: HKUnit2
    ) {
        print("\n\(label)")
        print("- 1: '\(hkUnit1.description)' '\(hkUnit1.unitString)'")
        print("- 2: '\(hkUnit2.description)' '\(hkUnit2.unitString)'")
    }
    
    imp(
        "m*m",
        hkUnit1: .meter() * .meter(),
        hkUnit2: .meter() * .meter()
    )
    imp(
        "m*km",
        hkUnit1: .meter() * .meterUnit(with: .kilo),
        hkUnit2: .meter() * .meterUnit(with: .kilo)
    )
    imp(
        "km*km",
        hkUnit1: .meterUnit(with: .kilo) * .meterUnit(with: .kilo),
        hkUnit2: .meterUnit(with: .kilo) * .meterUnit(with: .kilo)
    )
    
    print(HKQuantity2(unit: .degreeCelsius(), doubleValue: 27).doubleValue(for: .degreeFahrenheit()))
    print(HKQuantity2(unit: .degreeFahrenheit(), doubleValue: 80.6).doubleValue(for: .degreeCelsius()))
    
    print(HKQuantity2(unit: .ounce(), doubleValue: 1).doubleValue(for: .gram()) == 28.349523125000001)
    
    print(HKQuantity2(unit: .meterUnit(with: .centi), doubleValue: 187).doubleValue(for: .meter()))
    
    fatalError()
}


#endif
