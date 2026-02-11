//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order missing_docs

public import Foundation

#if !canImport(HealthKit)
public typealias HKUnit = _HKUnit
public typealias HKMetricPrefix = _HKMetricPrefix
public let HKUnitMolarMassBloodGlucose = _HKUnitMolarMassBloodGlucose
#endif


/// `HKUnit` API.
///
/// Losely inspired by their internal structure.
@_documentation(visibility: internal)
public class _HKUnit: NSObject, @unchecked Sendable {
    private static let nullUnit = _HKUnit(
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
        fatalError("Not Yet Implemented")
    }
//    public convenience init(from massFormatterUnit: MassFormatter.Unit)
//    public class func massFormatterUnit(from unit: _HKUnit) -> MassFormatter.Unit
//    public convenience init(from lengthFormatterUnit: LengthFormatter.Unit)
//    public class func lengthFormatterUnit(from unit: _HKUnit) -> LengthFormatter.Unit
//    public convenience init(from energyFormatterUnit: EnergyFormatter.Unit)
//    public class func energyFormatterUnit(from unit: _HKUnit) -> EnergyFormatter.Unit
    public func isNull() -> Bool {
        self == .nullUnit
    }
    
    public func unitMultiplied(by unit: _HKUnit) -> _HKUnit {
        _HKCompoundUnit(factorization: self.factorization * unit.factorization)
    }
    
    public func unitDivided(by unit: _HKUnit) -> _HKUnit {
        _HKCompoundUnit(factorization: self.factorization / unit.factorization)
    }
    
    public func unitRaised(toPower power: Int) -> _HKUnit {
        switch power {
        case 0: .nullUnit
        case 1: self
        default: _HKCompoundUnit(factorization: self.factorization.raised(to: power))
        }
    }
    
    public func reciprocal() -> _HKUnit {
        _HKCompoundUnit(factorization: self.factorization.reciprocal())
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        _compareEq(with: object, on: \.factorization, \.scaleOffset, \.scaleFactor)
    }
    
    func isCompatible(with other: _HKUnit) -> Bool {
        // TODO
        true
//        fatalError("Missing implementation in subclass \(Self.self)")
    }
}


extension _HKUnit {
    private enum Dimemsion: Sendable {
        case null
        case time
        case length
        case mass
        case temperature
    }
}


public enum _HKMetricPrefix: Int, @unchecked Sendable {
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


private class _HKBaseUnit: _HKUnit, @unchecked Sendable {
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
    
//    override func unitMultiplied(by unit: _HKUnit) -> _HKUnit {
//        _HKCompoundUnit(factorization: self.factorization * unit.factorization)
//    }
//    
//    override func unitDivided(by unit: _HKUnit) -> _HKUnit {
//        _HKCompoundUnit(factorization: self.factorization)
//    }
}



// TODO do we actually need this?
private class _HKCompoundUnit: _HKUnit, @unchecked Sendable {
    init(factorization: HKFactorization) {
        super.init(factorization: factorization, scaleOffset: 0, scaleFactor: 1)
    }
}


extension _HKUnit {
    func convertToBaseUnit(_ value: Double) -> Double {
        value * self.scaleFactor + self.scaleOffset
    }
    
    func convertFromBaseUnit(_ value: Double) -> Double {
        (value - self.scaleOffset) / self.scaleFactor
    }
    
    func convert(_ value: Double, to otherUnit: _HKUnit) -> Double {
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
        let string = exponents.lazy
            .map { base, exp in
                if exp == 1 {
                    base
                } else {
                    "base^\(exp)"
                }
            }
            .joined(separator: "·")
        return if factor == 1 {
            string
        } else {
            // incorect // TODO!!!
            "\(factor) * \(string)"
        }
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




extension _HKUnit {
    /// Creates a unit as the composition of multiplying a unit with another unit.
    @inlinable public static func * (lhs: _HKUnit, rhs: _HKUnit) -> _HKUnit {
        lhs.unitMultiplied(by: rhs)
    }
    
    /// Creates a unit as the composition of dividing a unit by another unit.
    @inlinable public static func / (lhs: _HKUnit, rhs: _HKUnit) -> _HKUnit {
        lhs.unitDivided(by: rhs)
    }
}


// MARK: Base Unit Definitions

extension _HKUnit {
    public class func gramUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(unit: "g", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func gram() -> _HKUnit {
        gramUnit(with: .none)
    }
    
    public class func ounce() -> _HKUnit {
        _HKBaseUnit(unit: "oz", prefix: "", factor: 1, scaleOffset: 0, scaleFactor: 28.349523125)
    }
    
    public class func pound() -> _HKUnit {
        _HKBaseUnit(unit: "lb", prefix: "", factor: 1, scaleOffset: 0, scaleFactor: 453.59237)
    }
    
    public class func stone() -> _HKUnit {
        _HKBaseUnit(unit: "st", prefix: "", factor: 1, scaleOffset: 0, scaleFactor: 6350.2931799999997)
    }
    
    public class func moleUnit(with prefix: _HKMetricPrefix, molarMass gramsPerMole: Double) -> _HKUnit {
        _HKBaseUnit(unit: "mol<\(gramsPerMole)>", prefix: prefix.prefixString, factor: prefix.factor, scaleOffset: 0, scaleFactor: gramsPerMole)
    }
    
    public class func moleUnit(withMolarMass gramsPerMole: Double) -> _HKUnit {
        moleUnit(with: .none, molarMass: gramsPerMole)
    }
}


extension _HKUnit {
    public class func meterUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(unit: "m", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func meter() -> _HKUnit {
        meterUnit(with: .none)
    }
    
    public class func inch() -> _HKUnit {
        _HKBaseUnit(unit: "in", prefix: "", factor: 1, scaleFactor: 0.0254)
    }
    
    public class func foot() -> _HKUnit {
        _HKBaseUnit(unit: "ft", prefix: "", factor: 1, scaleFactor: 0.3048)
    }
    
    public class func yard() -> _HKUnit {
        _HKBaseUnit(unit: "yd", prefix: "", factor: 1, scaleFactor: 0.9144)
    }
    
    public class func mile() -> _HKUnit {
        _HKBaseUnit(unit: "mi", prefix: "", factor: 1609.344)
    }
}


extension _HKUnit {
    public class func literUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(unit: "L", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func liter() -> _HKUnit {
        literUnit(with: .none)
    }
    
    public class func fluidOunceUS() -> _HKUnit {
        _HKBaseUnit(unit: "fl_oz_us", prefix: "", factor: 1, scaleFactor: 0.0295735295625)
    }
    
    public class func fluidOunceImperial() -> _HKUnit {
        _HKBaseUnit(unit: "fl_oz_imp", prefix: "", factor: 1, scaleFactor: 0.0284130625)
    }
    
    public class func pintUS() -> _HKUnit {
        _HKBaseUnit(unit: "pt_us", prefix: "", factor: 1, scaleFactor: 0.473176473)
    }
    
    public class func pintImperial() -> _HKUnit {
        _HKBaseUnit(unit: "pt_imp", prefix: "", factor: 1, scaleFactor: 0.56826125)
    }
    
    public class func cupUS() -> _HKUnit {
        _HKBaseUnit(unit: "cup_us", prefix: "", factor: 1, scaleFactor: 0.2365882365)
    }
    
    public class func cupImperial() -> _HKUnit {
        _HKBaseUnit(unit: "cup_imp", prefix: "", factor: 1, scaleFactor: 0.284130625)
    }
}


extension _HKUnit {
    public class func pascalUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(unit: "Pa", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func pascal() -> _HKUnit {
        pascalUnit(with: .none)
    }
    
    public class func millimeterOfMercury() -> _HKUnit {
        _HKBaseUnit(unit: "mmHg", prefix: "", factor: 133.322387415)
    }
    
    public class func centimeterOfWater() -> _HKUnit {
        _HKBaseUnit(unit: "cmAq", prefix: "", factor: 1, scaleFactor: 98.0665)
    }
    
    public class func atmosphere() -> _HKUnit {
        _HKBaseUnit(unit: "atm", prefix: "", factor: 101325)
    }
    
    public class func decibelAWeightedSoundPressureLevel() -> _HKUnit {
        _HKBaseUnit(unit: "dBASPL", prefix: "", factor: 1)
    }
    
    public class func inchesOfMercury() -> _HKUnit {
        _HKBaseUnit(unit: "inHg", prefix: "", factor: 1, scaleFactor: 3386.38816)
    }
}


extension _HKUnit {
    public class func secondUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(unit: "s", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func second() -> _HKUnit {
        secondUnit(with: .none)
    }
    
    public class func minute() -> _HKUnit {
        _HKBaseUnit(unit: "min", prefix: "", factor: 1, scaleFactor: 60)
    }
    
    public class func hour() -> _HKUnit {
        _HKBaseUnit(unit: "hr", prefix: "", factor: 1, scaleFactor: 60 * 60)
    }
    
    public class func day() -> _HKUnit {
        _HKBaseUnit(unit: "d", prefix: "", factor: 1, scaleFactor: 60 * 60 * 24)
    }
}


extension _HKUnit {
    public class func jouleUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(unit: "J", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func joule() -> _HKUnit {
        jouleUnit(with: .none)
    }
    
    public class func kilocalorie() -> _HKUnit {
        _HKBaseUnit(unit: "kcal", prefix: "", factor: 1, scaleFactor: 4184)
    }
    
    public class func smallCalorie() -> _HKUnit {
        _HKBaseUnit(unit: "cal", prefix: "", factor: 1, scaleFactor: 4.184)
    }
    
    public class func largeCalorie() -> _HKUnit {
        _HKBaseUnit(unit: "Cal", prefix: "", factor: 1, scaleFactor: 4184)
    }
    
    public class func calorie() -> _HKUnit {
        .smallCalorie()
    }
}


extension _HKUnit {
    public class func degreeCelsius() -> _HKUnit {
        _HKBaseUnit(unit: "degC", prefix: "", factor: 1, scaleOffset: 273.15, scaleFactor: 1)
    }
    
    public class func degreeFahrenheit() -> _HKUnit {
        _HKBaseUnit(unit: "degF", prefix: "", factor: 1, scaleOffset: (5/9) * 459.67, scaleFactor: 5/9)
    }
    
    public class func kelvin() -> _HKUnit {
        _HKBaseUnit(unit: "K", prefix: "", factor: 1)
    }
}


extension _HKUnit {
    public class func siemenUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(unit: "S", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func siemen() -> _HKUnit {
        siemenUnit(with: .none)
    }
}


extension _HKUnit {
    public class func internationalUnit() -> _HKUnit {
        _HKBaseUnit(unit: "IU", prefix: "", factor: 1)
    }
}


extension _HKUnit {
    public class func count() -> _HKUnit {
        _HKBaseUnit(unit: "count", prefix: "", factor: 1)
    }
    
    public class func percent() -> _HKUnit {
        _HKBaseUnit(unit: "%", prefix: "", factor: 1)
    }
}


extension _HKUnit {
    public class func decibelHearingLevel() -> _HKUnit {
        _HKBaseUnit(unit: "dBHL", prefix: "", factor: 1)
    }
}


extension _HKUnit {
    public class func hertzUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(unit: "Hz", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func hertz() -> _HKUnit {
        hertzUnit(with: .none)
    }
}


extension _HKUnit {
    public class func voltUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(unit: "V", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func volt() -> _HKUnit {
        voltUnit(with: .none)
    }
}


extension _HKUnit {
    public class func wattUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(unit: "W", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func watt() -> _HKUnit {
        wattUnit(with: .none)
    }
}


extension _HKUnit {
    public class func diopter() -> _HKUnit {
        _HKBaseUnit(unit: "D", prefix: "", factor: 1)
    }
    
    public class func prismDiopter() -> _HKUnit {
        _HKBaseUnit(unit: "pD", prefix: "", factor: 1)
    }
}


extension _HKUnit {
    public class func radianAngleUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(unit: "rad", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func radianAngle() -> _HKUnit {
        radianAngleUnit(with: .none)
    }
    
    public class func degreeAngle() -> _HKUnit {
        _HKBaseUnit(unit: "deg", prefix: "", factor: 1, scaleOffset: 0, scaleFactor: 1 / (180 / .pi))
    }
}


extension _HKUnit {
    public class func luxUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(unit: "lx", prefix: prefix.prefixString, factor: prefix.factor)
    }
    
    public class func lux() -> _HKUnit {
        luxUnit(with: .none)
    }
}


extension _HKUnit {
    public class func appleEffortScore() -> _HKUnit {
        _HKBaseUnit(unit: "appleEffortScore", prefix: "", factor: 1)
    }
}


public let _HKUnitMolarMassBloodGlucose: Double = 180.15588000005408
