//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if !canImport(HealthKit)
public typealias HKUnit = HKUnit2
#endif

#if true || !canImport(HealthKit)

// swiftlint:disable all

public import Foundation


/// `HKUnit` API.
///
/// Losely inspired by their internal structure.
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
        HKCompoundUnit2(factorization: self.factorization * unit.factorization)
    }
    
    public func unitDivided(by unit: HKUnit2) -> HKUnit2 {
        HKCompoundUnit2(factorization: self.factorization / unit.factorization)
    }
    
    public func unitRaised(toPower power: Int) -> HKUnit2 {
        switch power {
        case 0:
            .count()
        case 1:
            self
        default:
            HKCompoundUnit2(factorization: self.factorization.raised(to: power))
        }
    }
    
    public func reciprocal() -> HKUnit2 {
        HKCompoundUnit2(factorization: self.factorization.reciprocal())
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        _compareEq(with: object, on: \.factorization, \.scaleOffset, \.scaleFactor)
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
        super.isEqual(object) && _compareEq(with: object, on: \.unit, \.prefix)
    }
    
//    override func unitMultiplied(by unit: HKUnit2) -> HKUnit2 {
//        HKCompoundUnit2(factorization: self.factorization * unit.factorization)
//    }
//    
//    override func unitDivided(by unit: HKUnit2) -> HKUnit2 {
//        HKCompoundUnit2(factorization: self.factorization)
//    }
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
        self.exponents = exponents.filter { $0.value != 0 }
    }
    
    func reciprocal() -> HKFactorization {
        let newExponents = exponents.mapValues { $0 * -1 }
        return HKFactorization(factor: 1.0 / factor, exponents: newExponents)
    }
    
    func multiply(by other: HKFactorization) -> HKFactorization {
        var newExponents = self.exponents
        for (unit, exp) in other.exponents {
            newExponents[unit, default: 0] += exp
        }
        let filtered = newExponents.filter { $0.value != 0 }
        return HKFactorization(
            factor: self.factor * other.factor,
            exponents: filtered
        )
    }
    
    func raised(to power: Int) -> Self {
        switch power {
        case 0:
            // Raising anything to 0 creates a dimensionless scalar 1 (Count)
            HKFactorization(factor: 1, exponents: [:])
        case 1:
            self
        default:
            HKFactorization(
                factor: pow(factor, Double(power)),
                exponents: exponents.mapValues { $0 * power }
            )
        }
    }
    
    static func * (lhs: Self, rhs: Self) -> Self {
        lhs.multiply(by: rhs)
    }
    
    static func / (lhs: Self, rhs: Self) -> Self {
        lhs * rhs.reciprocal()
    }
}




extension HKUnit2 {
    /// Creates a unit as the composition of multiplying a unit with another unit.
    @inlinable public static func * (lhs: HKUnit2, rhs: HKUnit2) -> HKUnit2 {
        lhs.unitMultiplied(by: rhs)
    }
    
    /// Creates a unit as the composition of dividing a unit by another unit.
    @inlinable public static func / (lhs: HKUnit2, rhs: HKUnit2) -> HKUnit2 {
        lhs.unitDivided(by: rhs)
    }
}


// MARK: Base Unit Definitions

extension HKUnit2 {
    public class func gramUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        HKBaseUnit2(unit: "g", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func gram() -> HKUnit2 {
        gramUnit(with: .none)
    }
    
    public class func ounce() -> HKUnit2 {
        HKBaseUnit2(unit: "oz", prefix: "", factor: 1, scaleOffset: 0, scaleFactor: 28.349523125)
    }
    
    public class func pound() -> HKUnit2 {
        HKBaseUnit2(unit: "lb", prefix: "", factor: 1, scaleOffset: 0, scaleFactor: 453.59237)
    }
    
    public class func stone() -> HKUnit2 {
        HKBaseUnit2(unit: "st", prefix: "", factor: 1, scaleOffset: 0, scaleFactor: 6350.2931799999997)
    }
    
    public class func moleUnit(with prefix: HKMetricPrefix2, molarMass gramsPerMole: Double) -> HKUnit2 {
        HKBaseUnit2(unit: "mol<\(gramsPerMole)>", prefix: prefix.prefixString, factor: prefix.factor, scaleOffset: 0, scaleFactor: gramsPerMole)
    }
    
    public class func moleUnit(withMolarMass gramsPerMole: Double) -> HKUnit2 {
        moleUnit(with: .none, molarMass: gramsPerMole)
    }
}


extension HKUnit2 {
    public class func meterUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        HKBaseUnit2(unit: "m", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func meter() -> HKUnit2 {
        meterUnit(with: .none)
    }
    
    public class func inch() -> HKUnit2 {
        HKBaseUnit2(unit: "in", prefix: "", factor: 1, scaleFactor: 0.0254)
    }
    
    public class func foot() -> HKUnit2 {
        HKBaseUnit2(unit: "ft", prefix: "", factor: 1, scaleFactor: 0.3048)
    }
    
    public class func yard() -> HKUnit2 {
        HKBaseUnit2(unit: "yd", prefix: "", factor: 1, scaleFactor: 0.9144)
    }
    
    public class func mile() -> HKUnit2 {
        HKBaseUnit2(unit: "mi", prefix: "", factor: 1609.344)
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
        HKBaseUnit2(unit: "fl_oz_us", prefix: "", factor: 1, scaleFactor: 0.0295735295625)
    }
    
    public class func fluidOunceImperial() -> HKUnit2 {
        HKBaseUnit2(unit: "fl_oz_imp", prefix: "", factor: 1, scaleFactor: 0.0284130625)
    }
    
    public class func pintUS() -> HKUnit2 {
        HKBaseUnit2(unit: "pt_us", prefix: "", factor: 1, scaleFactor: 0.473176473)
    }
    
    public class func pintImperial() -> HKUnit2 {
        HKBaseUnit2(unit: "pt_imp", prefix: "", factor: 1, scaleFactor: 0.56826125)
    }
    
    public class func cupUS() -> HKUnit2 {
        HKBaseUnit2(unit: "cup_us", prefix: "", factor: 1, scaleFactor: 0.2365882365)
    }
    
    public class func cupImperial() -> HKUnit2 {
        HKBaseUnit2(unit: "cup_imp", prefix: "", factor: 1, scaleFactor: 0.284130625)
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
        HKBaseUnit2(unit: "mmHg", prefix: "", factor: 133.322387415)
    }
    
    public class func centimeterOfWater() -> HKUnit2 {
        HKBaseUnit2(unit: "cmAq", prefix: "", factor: 1, scaleFactor: 98.0665)
    }
    
    public class func atmosphere() -> HKUnit2 {
        HKBaseUnit2(unit: "atm", prefix: "", factor: 101325)
    }
    
    public class func decibelAWeightedSoundPressureLevel() -> HKUnit2 {
        HKBaseUnit2(unit: "dBASPL", prefix: "", factor: 1)
    }
    
    public class func inchesOfMercury() -> HKUnit2 {
        HKBaseUnit2(unit: "inHg", prefix: "", factor: 1, scaleFactor: 3386.38816)
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
        HKBaseUnit2(unit: "min", prefix: "", factor: 1, scaleFactor: 60)
    }
    
    public class func hour() -> HKUnit2 {
        HKBaseUnit2(unit: "hr", prefix: "", factor: 1, scaleFactor: 60 * 60)
    }
    
    public class func day() -> HKUnit2 {
        HKBaseUnit2(unit: "d", prefix: "", factor: 1, scaleFactor: 60 * 60 * 24)
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
        HKBaseUnit2(unit: "kcal", prefix: "", factor: 1, scaleFactor: 4184)
    }
    
    public class func smallCalorie() -> HKUnit2 {
        HKBaseUnit2(unit: "cal", prefix: "", factor: 1, scaleFactor: 4.184)
    }
    
    public class func largeCalorie() -> HKUnit2 {
        HKBaseUnit2(unit: "Cal", prefix: "", factor: 1, scaleFactor: 4184)
    }
    
    public class func calorie() -> HKUnit2 {
        .smallCalorie()
    }
}


extension HKUnit2 {
    public class func degreeCelsius() -> HKUnit2 {
        HKBaseUnit2(unit: "degC", prefix: "", factor: 1, scaleOffset: 273.15, scaleFactor: 1)
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
        HKBaseUnit2(unit: "S", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func siemen() -> HKUnit2 {
        siemenUnit(with: .none)
    }
}


extension HKUnit2 {
    public class func internationalUnit() -> HKUnit2 {
        HKBaseUnit2(unit: "IU", prefix: "", factor: 1)
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
        HKBaseUnit2(unit: "dBHL", prefix: "", factor: 1)
    }
}


extension HKUnit2 {
    public class func hertzUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        HKBaseUnit2(unit: "Hz", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func hertz() -> HKUnit2 {
        hertzUnit(with: .none)
    }
}


extension HKUnit2 {
    public class func voltUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        HKBaseUnit2(unit: "V", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func volt() -> HKUnit2 {
        voltUnit(with: .none)
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
        HKBaseUnit2(unit: "D", prefix: "", factor: 1)
    }
    
    public class func prismDiopter() -> HKUnit2 {
        HKBaseUnit2(unit: "pD", prefix: "", factor: 1)
    }
}


extension HKUnit2 {
    public class func radianAngleUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        HKBaseUnit2(unit: "rad", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func radianAngle() -> HKUnit2 {
        radianAngleUnit(with: .none)
    }
    
    public class func degreeAngle() -> HKUnit2 {
        HKBaseUnit2(unit: "deg", prefix: "", factor: 1, scaleOffset: 0, scaleFactor: 1 / (180 / .pi))
    }
}


extension HKUnit2 {
    public class func luxUnit(with prefix: HKMetricPrefix2) -> HKUnit2 {
        HKBaseUnit2(unit: "lx", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func lux() -> HKUnit2 {
        luxUnit(with: .none)
    }
}


extension HKUnit2 {
    public class func appleEffortScore() -> HKUnit2 {
        HKBaseUnit2(unit: "appleEffortScore", prefix: "", factor: 1)
    }
}


public let HKUnit2MolarMassBloodGlucose: Double = 180.15588000005408


#endif
