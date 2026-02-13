//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order missing_docs type_name identifier_name type_contents_order file_length todo all

public import Foundation

#if !canImport(HealthKit)
public typealias HKUnit = _HKUnit
public typealias HKMetricPrefix = _HKMetricPrefix
public let HKUnitMolarMassBloodGlucose = _HKUnitMolarMassBloodGlucose
#endif


/// `HKUnit` API.
///
/// Losely inspired by what they seem to be doing.
@_documentation(visibility: internal)
public class _HKUnit: NSObject, @unchecked Sendable {
    private static let nullUnit = _HKUnit(
        factorization: .init(factors: [:]),
        dimension: .null,
        scaleOffset: 0,
        scaleFactor: 0
    )
    
    @_spi(Testing) public let factorization: HKFactorization
    @_spi(Testing) public let dimension: Dimension
    @_spi(Testing) public let scaleOffset: Double
    @_spi(Testing) public let scaleFactor: Double
    
    /// Returns a unique string representation for the unit that could be used with +unitFromString:
    public var unitString: String {
        factorization.unitString
    }
    
    override public var description: String {
        unitString
    }
    
    fileprivate init(factorization: HKFactorization, dimension: Dimension, scaleOffset: Double, scaleFactor: Double) {
        self.factorization = factorization
        self.dimension = dimension
        self.scaleOffset = scaleOffset
        self.scaleFactor = scaleFactor
    }
    
    public func isNull() -> Bool {
        self == .nullUnit
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        return _compareEq(with: object, on: \.factorization, \.scaleOffset, \.scaleFactor)
    }
}


extension _HKUnit {
    // MARK: Operations
    
    func isCompatible(with other: _HKUnit) -> Bool {
        factorization.isCompatible(with: other.factorization)
    }
    
    func convertToBaseUnit(_ value: Double) -> Double {
        value * self.scaleFactor + self.scaleOffset
    }
    
    func convertFromBaseUnit(_ value: Double) -> Double {
        (value - self.scaleOffset) / self.scaleFactor
    }
    
    func convert(_ value: Double, to other: _HKUnit) -> Double {
        precondition(self.isCompatible(with: other), "Attempted to convert between incompatible units '\(self)' and \(other)")
        let inBaseUnit = self.convertToBaseUnit(value)
        return other.convertFromBaseUnit(inBaseUnit)
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
    
    public func unitMultiplied(by other: _HKUnit) -> _HKUnit {
        _HKCompoundUnit(
            factorization: self.factorization * other.factorization,
            dimension: self.dimension * other.dimension,
            scaleOffset: 0,
            scaleFactor: self.scaleFactor * other.scaleFactor
        )
    }
    
    public func unitDivided(by other: _HKUnit) -> _HKUnit {
        _HKCompoundUnit(
            factorization: self.factorization / other.factorization,
            dimension: self.dimension / other.dimension,
            scaleOffset: 0,
            scaleFactor: self.scaleFactor / other.scaleFactor
        )
    }
    
    public func unitRaised(toPower power: Int) -> _HKUnit {
        switch power {
        case 0:
            .nullUnit
        case 1:
            self
        default:
            _HKCompoundUnit(
                factorization: self.factorization.raised(to: power),
                dimension: self.dimension.raised(to: power),
                scaleOffset: 0,
                scaleFactor: pow(scaleFactor, Double(power))
            )
        }
    }
    
    public func reciprocal() -> _HKUnit {
        self.unitRaised(toPower: -1)
    }
}


// MARK: Dimension

extension _HKUnit {
    @_spi(Testing)
    public struct Dimension: Hashable, CustomStringConvertible, Sendable {
        enum Variant: Hashable, Sendable {
            case base(_ unitString: String)
            case complex(HKFactorization)
        }
        
        let variant: Variant
        
        var unitString: String {
            switch variant {
            case .base(let unitString):
                unitString
            case .complex(let factorization):
                factorization.unitString
            }
        }
        
        var factorization: HKFactorization {
            switch variant {
            case .base(let unitString):
                HKFactorization(factors: [.init(dimension: self, unitString: unitString): 1])
            case .complex(let factorization):
                factorization
            }
        }
        
        public var description: String {
            unitString
        }
        
        private init(base unitString: String) {
            variant = .base(unitString)
        }
        
        private init(complex factorization: HKFactorization) {
            variant = .complex(factorization)
        }
        
        static let null = Self(base: "null")
        static let time = Self(base: "Time")
        static let length = Self(base: "Length")
        static let mass = Self(base: "Mass")
        static let temperature = Self(base: "Temperature")
        static let volume = Self(base: "Volume")
        static let pressure = Self(base: "Pressure")
        static let energy = Self(base: "Energy")
        static let conductance = Self(base: "Conductance")
        static let frequency = Self(base: "Frequency")
        static let electricPotentialDifference = Self(base: "ElectricPotentialDifference")
        static let power = Self(base: "Power")
        static let angle = Self(base: "Angle")
        static let illuminance = Self(base: "Illuminance")
        static let soundPressureLevel = Self(base: "SoundPressureLevel")
        static let internationalUnit = Self(base: "IU")
        static let hearingSensitivity = Self(base: "HearingSensitivity")
        static let diopter = Self(base: "Diopter")
        static let prismDiopter = Self(base: "PrismDiopter")
        static let appleEffortScore = Self(base: "AppleEffortScore")
        
        static func * (lhs: Self, rhs: Self) -> Self {
            Self(complex: lhs.factorization * rhs.factorization)
        }
        
        static func / (lhs: Self, rhs: Self) -> Self {
            Self(complex: lhs.factorization / rhs.factorization)
        }
        
        func raised(to power: Int) -> Self {
            Self(complex: self.factorization.raised(to: power))
        }
    }
}


public enum _HKMetricPrefix: Int, CaseIterable, Sendable {
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
        }
    }
}

private class _HKBaseUnit: _HKUnit, @unchecked Sendable {
    init(dimension: _HKUnit.Dimension, unitString: String, scaleOffset: Double = 0, scaleFactor: Double = 1) {
        switch dimension.variant {
        case .base:
            break // ok
        case .complex:
            fatalError("Attempted to construct base unit with complex dimension '\(dimension)'")
        }
        super.init(
            factorization: HKFactorization(factors: [.init(dimension: dimension, unitString: unitString): 1]),
            dimension: dimension,
            scaleOffset: scaleOffset,
            scaleFactor: scaleFactor
        )
    }
    
    convenience init(dimension: _HKUnit.Dimension, unitString: String, metricPrefix: _HKMetricPrefix, scaleOffset: Double = 0, scaleFactor: Double = 1) {
        self.init(dimension: dimension, unitString: "\(metricPrefix.prefixString)\(unitString)", scaleOffset: scaleOffset, scaleFactor: scaleFactor * metricPrefix.factor)
    }
}


// TODO do we actually need this?
private class _HKCompoundUnit: _HKUnit, @unchecked Sendable {
}


// MARK: Factorization

@_spi(Testing)
public struct HKFactorization: Hashable, CustomStringConvertible, Sendable {
    @_spi(Testing)
    public struct Factor: Hashable, Sendable {
        let dimension: _HKUnit.Dimension
        let unitString: String
        
        /// Creates a unit-less factor from a dimension
        ///
        /// The resulting factor will use the dimension's name (e.g. "Length", "Mass", or "Time") as its ``unitString``
        ///
        /// - parameter dimension: Must be a base dimension!
        init(unitlessDimension dimension: _HKUnit.Dimension) {
            switch dimension.variant {
            case .base(let unitString):
                self.dimension = dimension
                self.unitString = unitString
            case .complex:
                fatalError("Attempted to construct \(Self.self) with complex dimension '\(dimension)'")
            }
        }
        
        /// Creates a unit-based factor for a dimension
        init(dimension: _HKUnit.Dimension, unitString: String) {
            switch dimension.variant {
            case .base:
                self.dimension = dimension
                self.unitString = unitString
            case .complex:
                fatalError("Attempted to construct \(Self.self) with complex dimension '\(dimension)'")
            }
        }
    }
    
    private let factors: [Factor: Int]
    
    public var description: String {
        unitString
    }
    
    public var unitString: String {
        guard !factors.isEmpty else {
            return "()"
        }
        func unitString(_ factors: some Sequence<(Factor, Int)>) -> String {
            factors.lazy
                .map { unit, exp in
                    if exp == 1 {
                        unit.unitString
                    } else {
                        "\(unit.unitString)^\(exp)"
                    }
                }
                .joined(separator: "·")
        }
        var positiveFactors: [(Factor, Int)] = []
        /// the negative factors, with their exponents negated
        var negativeFactors: [(Factor, Int)] = []
        for (factor, exp) in factors {
            if exp > 0 {
                positiveFactors.append((factor, exp))
            } else {
                negativeFactors.append((factor, -exp))
            }
        }
        let positiveUnitString = unitString(positiveFactors)
        let negativeUnitString = unitString(negativeFactors)
        return switch (!positiveUnitString.isEmpty, !negativeUnitString.isEmpty) {
        case (false, false):
            "()"
        case (true, false):
            positiveUnitString
        case (false, true):
            "1/\(negativeUnitString)"
        case (true, true):
            "\(positiveUnitString)/\(negativeUnitString)"
        }
    }
    
    @_spi(Testing)
    public init(factors: [Factor: Int]) {
        self.factors = factors.filter { $0.value != 0 }
        for factor in factors.keys {
            precondition(!factor.unitString.isEmpty)
        }
    }
    
    func reciprocal() -> HKFactorization {
        raised(to: -1)
    }
    
    func multiply(by other: HKFactorization) -> HKFactorization {
        var newFactors = self.factors
        for (unit, exp) in other.factors {
            newFactors[unit, default: 0] += exp
        }
        return HKFactorization(factors: newFactors)
    }
    
    func raised(to power: Int) -> Self {
        switch power {
        case 0:
            // Raising anything to 0 creates a dimensionless scalar 1 (Count)
            HKFactorization(factors: [:])
        case 1:
            self
        default:
            HKFactorization(factors: factors.mapValues { $0 * power })
        }
    }
    
    func isCompatible(with other: Self) -> Bool {
        if self == other {
            return true
        }
        let imp = { (lhs: Self, rhs: Self) -> Bool in
            lhs.factors.allSatisfy { (factor1, exp1) in
                rhs.factors.contains { (factor2, exp2) in
                    exp1 == exp2 && factor1.dimension == factor2.dimension
                }
            }
        }
        print(self)
        print(other)
        return imp(self, other) && imp(other, self)
    }
    
    static func * (lhs: Self, rhs: Self) -> Self {
        lhs.multiply(by: rhs)
    }
    
    static func / (lhs: Self, rhs: Self) -> Self {
        lhs * rhs.reciprocal()
    }
}


// MARK: Parsing

#if true || !canImport(HealthKit)
public protocol _HKParsableUnit {}

extension _HKUnit: _HKParsableUnit {}

extension _HKParsableUnit where Self == _HKUnit {
    public init(from string: String) {
        self = try! Self.parse(string) // swiftlint:disable:this force_try
    }
    
    public init(from string: some StringProtocol) {
        self = try! Self.parse(string) // swiftlint:disable:this force_try
    }
}
#endif



extension _HKUnit {
    @_spi(APISupport)
    public static func parse(_ input: some StringProtocol) throws -> _HKUnit {
        let syntax = try UnitParser.parse(input: input)
        return unit(for: syntax)
    }
    
    private static func unit(for node: UnitParser.Node) -> _HKUnit {
        switch node {
        case let .atom(metricPrefix, .SI(siUnit), power):
            let unit = switch siUnit {
            case .mass:
                Self.gramUnit(with: metricPrefix)
            case .length:
                Self.meterUnit(with: metricPrefix)
            case .volume:
                Self.literUnit(with: metricPrefix)
            case .pressure:
                Self.pascalUnit(with: metricPrefix)
            case .time:
                Self.secondUnit(with: metricPrefix)
            case .energy:
                Self.jouleUnit(with: metricPrefix)
            case .temperature:
                Self.kelvinUnit(with: metricPrefix)
            case .electricalConductance:
                Self.siemenUnit(with: metricPrefix)
            case .frequency:
                Self.hertzUnit(with: metricPrefix)
            case .molarMass(gramsPerMole: let gramsPerMole):
                Self.moleUnit(with: metricPrefix, molarMass: gramsPerMole)
            case .electricalPotentialDifference:
                Self.voltUnit(with: metricPrefix)
            case .power:
                Self.wattUnit(with: metricPrefix)
            case .angle:
                Self.radianAngleUnit(with: metricPrefix)
            case .illuminance:
                Self.luxUnit(with: metricPrefix)
            }
            return unit.unitRaised(toPower: power)
        case let .atom(metricPrefix, unit: .other(unitString), power):
            precondition(metricPrefix == .none, "")
            let unit: _HKUnit? = switch unitString {
            // Mass
            case "oz":
                Self.ounce()
            case "lb":
                Self.pound()
            case "st":
                Self.stone()
            // Length
            case "in":
                Self.inch()
            case "ft":
                Self.foot()
            case "mi":
                Self.mile()
            // Pressure
            case "mmHg":
                Self.millimeterOfMercury()
            case "cmAq":
                Self.centimeterOfWater()
            case "atm":
                Self.atmosphere()
            case "dBASPL":
                Self.decibelAWeightedSoundPressureLevel()
            case "inHg":
                Self.inchesOfMercury()
            // Volume
            case "fl_oz_us":
                Self.fluidOunceUS()
            case "fl_oz_imp":
                Self.fluidOunceImperial()
            case "pt_us":
                Self.pintUS()
            case "pt_imp":
                Self.pintImperial()
            case "cup_us":
                Self.cupUS()
            case "cup_imp":
                Self.cupImperial()
            // Time
            case "min":
                Self.minute()
            case "hr":
                Self.hour()
            case "d":
                Self.day()
            // Energy
            case "cal":
                Self.smallCalorie()
            case "kcal":
                Self.largeCalorie()
            // Temperature
            case "degC":
                Self.degreeCelsius()
            case "degF":
                Self.degreeFahrenheit()
            // Pharmacology
            case "IU":
                Self.internationalUnit()
            // Scalar
            case "count":
                Self.count()
            case "%":
                Self.percent()
            // Hearing Sensitivity
            case "dBHL":
                Self.decibelHearingLevel()
            // Unitless
            case "appleEffortScore":
                Self.appleEffortScore()
            default:
                nil
            }
            guard let unit else {
                fatalError("Unhandled non-SI unit '\(unitString)'")
            }
            return unit.unitRaised(toPower: power)
        case let .cons(lhs, rhs):
            return unit(for: lhs) * unit(for: rhs)
        }
    }
}

private enum UnitParser {
    enum Unit {
        case SI(SIUnit)
        case other(String)
        
        enum SIUnit {
            case mass
            case length
            case volume
            case pressure
            case time
            case energy
            case temperature
            case electricalConductance
            case frequency
            case molarMass(gramsPerMole: Double)
            case electricalPotentialDifference
            case power
            case angle
            case illuminance
            
            init?(_ input: some StringProtocol) {
                switch input {
                case "g":   self = .mass
                case "m":   self = .length
                case "l":   self = .volume
                case "L":   self = .volume
                case "Pa":  self = .pressure
                case "s":   self = .time
                case "J":   self = .energy
                case "K":   self = .temperature
                case "S":   self = .electricalConductance
                case "Hz":  self = .frequency
                case "V":   self = .electricalPotentialDifference
                case "W":   self = .power
                case "rad": self = .angle
                case "lx":  self = .illuminance
                default:
                    if input.starts(with: "mol"),
                       let idx1 = input.firstIndex(of: "<"),
                       let idx2 = input.lastIndex(of: ">"),
                       idx2 == input.index(before: input.endIndex),
                       let gramsPerMol = Double(input[input.index(after: idx1)..<idx2]) {
                        self = .molarMass(gramsPerMole: gramsPerMol)
                    } else {
                        return nil
                    }
                }
            }
        }
    }
    
    indirect enum Node {
        case atom(metricPrefix: _HKMetricPrefix, unit: Unit, power: Int)
        case cons(Node, Node)
        
        func reciprocal() -> Self {
            switch self {
            case let .atom(metricPrefix, unit, power):
                .atom(metricPrefix: metricPrefix, unit: unit, power: -power)
            case let .cons(lhs, rhs):
                .cons(lhs.reciprocal(), rhs.reciprocal())
            }
        }
    }
    
    struct ParseError: Error {
        let position: String.Index
        let issue: String
    }
    
    static func parse(input: some StringProtocol) throws(ParseError) -> Node {
        if let divIdx1 = input.firstIndex(of: "/"), let divIdx2 = input[divIdx1...].dropFirst().firstIndex(of: "/") {
            throw .init(position: divIdx2, issue: "Input contains multiple division signs")
        }
        return try _parse(input)
    }
    
    private static func _parse(_ input: some StringProtocol) throws(ParseError) -> Node {
        if let divIdx = input.firstIndex(of: "/") {
            let denominators = try _parse(input.suffix(from: divIdx).dropFirst())
            if input[..<divIdx] == "1" {
                // special case, to support "1/s" syntax
                return denominators.reciprocal()
            } else {
                let numerators = try _parse(input[..<divIdx])
                return .cons(numerators, denominators.reciprocal())
            }
        } else {
            let rawAtoms = input.split { $0 == "." || $0 == "*" || $0 == "·" }
            guard !rawAtoms.isEmpty else {
                throw .init(position: input.startIndex, issue: "Empty input")
            }
            // unrolled `rawAtoms.dropFirst().reduce`, bc of https://github.com/swiftlang/swift/issues/75430
            var node = try _parseAtom(rawAtoms[0])
            for rawAtom in rawAtoms.dropFirst() {
                node = .cons(node, try _parse(rawAtom))
            }
            return node
        }
    }
    
    private static func _parseAtom<S: StringProtocol>(_ input: S) throws(ParseError) -> Node {
        let exponent: Int
        let unitInput: S.SubSequence
        if let idx = input.firstIndex(of: "^") {
            guard let exp = Int(input.suffix(from: idx).dropFirst()) else {
                throw .init(position: input.index(after: idx), issue: "Unable to parse exponent")
            }
            exponent = exp
            unitInput = input[..<idx]
        } else {
            exponent = 1
            unitInput = input[...]
        }
        for metricPrefix in _HKMetricPrefix.allCases {
            let prefixString = metricPrefix.prefixString
            if unitInput.starts(with: prefixString), let siUnit = Unit.SIUnit(unitInput.dropFirst(prefixString.count)) {
                return .atom(metricPrefix: metricPrefix, unit: .SI(siUnit), power: exponent)
            }
        }
        // we were unable to parse the `unitInput` as a metric-prefix-prepended SI unit
        return .atom(metricPrefix: .none, unit: .other(String(unitInput)), power: exponent)
    }
}


// MARK: Base Unit Definitions

extension _HKUnit {
    public class func gramUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(dimension: .mass, unitString: "g", metricPrefix: prefix)
    }
    
    public class func gram() -> _HKUnit {
        gramUnit(with: .none)
    }
    
    public class func ounce() -> _HKUnit {
        _HKBaseUnit(dimension: .mass, unitString: "oz", scaleFactor: 28.349523125)
    }
    
    public class func pound() -> _HKUnit {
        _HKBaseUnit(dimension: .mass, unitString: "lb", scaleFactor: 453.59237)
    }
    
    public class func stone() -> _HKUnit {
        _HKBaseUnit(dimension: .mass, unitString: "st", scaleFactor: 6350.2931799999997)
    }
    
    public class func moleUnit(with prefix: _HKMetricPrefix, molarMass gramsPerMole: Double) -> _HKUnit {
        // TODO gramsPerMole as scale factor yes or no?
        _HKBaseUnit(dimension: .mass, unitString: "mol<\(gramsPerMole)>", metricPrefix: prefix, scaleFactor: gramsPerMole)
    }
    
    public class func moleUnit(withMolarMass gramsPerMole: Double) -> _HKUnit {
        moleUnit(with: .none, molarMass: gramsPerMole)
    }
}


extension _HKUnit {
    public class func meterUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(dimension: .length, unitString: "m", metricPrefix: prefix)
    }
    
    public class func meter() -> _HKUnit {
        meterUnit(with: .none)
    }
    
    public class func inch() -> _HKUnit {
        _HKBaseUnit(dimension: .length, unitString: "in", scaleFactor: 0.0254)
    }
    
    public class func foot() -> _HKUnit {
        _HKBaseUnit(dimension: .length, unitString: "ft", scaleFactor: 0.3048)
    }
    
    public class func yard() -> _HKUnit {
        _HKBaseUnit(dimension: .length, unitString: "yd", scaleFactor: 0.9144)
    }
    
    public class func mile() -> _HKUnit {
        _HKBaseUnit(dimension: .length, unitString: "mi", scaleFactor: 1609.344)
    }
}


extension _HKUnit {
    public class func literUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(dimension: .volume, unitString: "L", metricPrefix: prefix)
    }
    
    public class func liter() -> _HKUnit {
        literUnit(with: .none)
    }
    
    public class func fluidOunceUS() -> _HKUnit {
        _HKBaseUnit(dimension: .volume, unitString: "fl_oz_us", scaleFactor: 0.0295735295625)
    }
    
    public class func fluidOunceImperial() -> _HKUnit {
        _HKBaseUnit(dimension: .volume, unitString: "fl_oz_imp", scaleFactor: 0.0284130625)
    }
    
    public class func pintUS() -> _HKUnit {
        _HKBaseUnit(dimension: .volume, unitString: "pt_us", scaleFactor: 0.473176473)
    }
    
    public class func pintImperial() -> _HKUnit {
        _HKBaseUnit(dimension: .volume, unitString: "pt_imp", scaleFactor: 0.56826125)
    }
    
    public class func cupUS() -> _HKUnit {
        _HKBaseUnit(dimension: .volume, unitString: "cup_us", scaleFactor: 0.2365882365)
    }
    
    public class func cupImperial() -> _HKUnit {
        _HKBaseUnit(dimension: .volume, unitString: "cup_imp", scaleFactor: 0.284130625)
    }
}


extension _HKUnit {
    public class func pascalUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(dimension: .pressure, unitString: "Pa", metricPrefix: prefix)
    }
    
    public class func pascal() -> _HKUnit {
        pascalUnit(with: .none)
    }
    
    public class func millimeterOfMercury() -> _HKUnit {
        _HKBaseUnit(dimension: .pressure, unitString: "mmHg", scaleFactor: 133.322387415)
    }
    
    public class func centimeterOfWater() -> _HKUnit {
        _HKBaseUnit(dimension: .pressure, unitString: "cmAq", scaleFactor: 98.0665)
    }
    
    public class func atmosphere() -> _HKUnit {
        _HKBaseUnit(dimension: .pressure, unitString: "atm", scaleFactor: 101325)
    }
    
    public class func decibelAWeightedSoundPressureLevel() -> _HKUnit {
        _HKBaseUnit(dimension: .soundPressureLevel, unitString: "dBASPL", scaleFactor: 1)
    }
    
    public class func inchesOfMercury() -> _HKUnit {
        _HKBaseUnit(dimension: .pressure, unitString: "inHg", scaleFactor: 3386.38816)
    }
}


extension _HKUnit {
    public class func secondUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(dimension: .time, unitString: "s", metricPrefix: prefix)
    }
    
    public class func second() -> _HKUnit {
        secondUnit(with: .none)
    }
    
    public class func minute() -> _HKUnit {
        _HKBaseUnit(dimension: .time, unitString: "min", scaleFactor: 60)
    }
    
    public class func hour() -> _HKUnit {
        _HKBaseUnit(dimension: .time, unitString: "hr", scaleFactor: 60 * 60)
    }
    
    public class func day() -> _HKUnit {
        _HKBaseUnit(dimension: .time, unitString: "d", scaleFactor: 60 * 60 * 24)
    }
}


extension _HKUnit {
    public class func jouleUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(dimension: .energy, unitString: "J", metricPrefix: prefix)
    }
    
    public class func joule() -> _HKUnit {
        jouleUnit(with: .none)
    }
    
    public class func kilocalorie() -> _HKUnit {
        _HKBaseUnit(dimension: .energy, unitString: "kcal", scaleFactor: 4184)
    }
    
    public class func smallCalorie() -> _HKUnit {
        _HKBaseUnit(dimension: .energy, unitString: "cal", scaleFactor: 4.184)
    }
    
    public class func largeCalorie() -> _HKUnit {
        _HKBaseUnit(dimension: .energy, unitString: "Cal", scaleFactor: 4184)
    }
    
    public class func calorie() -> _HKUnit {
        .smallCalorie()
    }
}


extension _HKUnit {
    public class func degreeCelsius() -> _HKUnit {
        _HKBaseUnit(dimension: .temperature, unitString: "degC", scaleOffset: 273.15, scaleFactor: 1)
    }
    
    public class func degreeFahrenheit() -> _HKUnit {
        _HKBaseUnit(dimension: .temperature, unitString: "degF", scaleOffset: (5 / 9) * 459.67, scaleFactor: 5 / 9)
    }
    
    public class func kelvin() -> _HKUnit {
//        _HKBaseUnit(dimension: .temperature, unitString: "K")
        kelvinUnit(with: .none)
    }
    
    fileprivate class func kelvinUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(dimension: .temperature, unitString: "K", metricPrefix: prefix)
    }
}


extension _HKUnit {
    public class func siemenUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(dimension: .conductance, unitString: "S", metricPrefix: prefix)
    }
    
    public class func siemen() -> _HKUnit {
        siemenUnit(with: .none)
    }
}


extension _HKUnit {
    public class func internationalUnit() -> _HKUnit {
        _HKBaseUnit(dimension: .internationalUnit, unitString: "IU")
    }
}


extension _HKUnit {
    public class func count() -> _HKUnit {
        _HKBaseUnit(dimension: .null, unitString: "count")
    }
    
    public class func percent() -> _HKUnit {
        _HKBaseUnit(dimension: .null, unitString: "%")
    }
}


extension _HKUnit {
    public class func decibelHearingLevel() -> _HKUnit {
        _HKBaseUnit(dimension: .hearingSensitivity, unitString: "dBHL")
    }
}


extension _HKUnit {
    public class func hertzUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(dimension: .frequency, unitString: "Hz", metricPrefix: prefix)
    }
    
    public class func hertz() -> _HKUnit {
        hertzUnit(with: .none)
    }
}


extension _HKUnit {
    public class func voltUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(dimension: .electricPotentialDifference, unitString: "V", metricPrefix: prefix)
    }
    
    public class func volt() -> _HKUnit {
        voltUnit(with: .none)
    }
}


extension _HKUnit {
    public class func wattUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(dimension: .power, unitString: "W", metricPrefix: prefix)
    }
    
    public class func watt() -> _HKUnit {
        wattUnit(with: .none)
    }
}


extension _HKUnit {
    public class func diopter() -> _HKUnit {
        _HKBaseUnit(dimension: .diopter, unitString: "D")
    }
    
    public class func prismDiopter() -> _HKUnit {
        _HKBaseUnit(dimension: .prismDiopter, unitString: "pD")
    }
}


extension _HKUnit {
    public class func radianAngleUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(dimension: .angle, unitString: "rad", metricPrefix: prefix)
    }
    
    public class func radianAngle() -> _HKUnit {
        radianAngleUnit(with: .none)
    }
    
    public class func degreeAngle() -> _HKUnit {
        _HKBaseUnit(dimension: .angle, unitString: "deg", scaleFactor: 1 / (180 / .pi))
    }
}


extension _HKUnit {
    public class func luxUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        _HKBaseUnit(dimension: .illuminance, unitString: "lx", metricPrefix: prefix)
    }
    
    public class func lux() -> _HKUnit {
        luxUnit(with: .none)
    }
}


extension _HKUnit {
    public class func appleEffortScore() -> _HKUnit {
        _HKBaseUnit(dimension: .appleEffortScore, unitString: "appleEffortScore")
    }
}


public let _HKUnitMolarMassBloodGlucose: Double = 180.15588000005408


// MARK: Utils

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
