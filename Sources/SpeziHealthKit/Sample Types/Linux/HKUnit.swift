//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order type_name identifier_name type_contents_order file_length missing_docs

public import Foundation
private import SpeziFoundation

#if !canImport(HealthKit)
public typealias HKUnit = _HKUnit
public typealias HKMetricPrefix = _HKMetricPrefix
public let HKUnitMolarMassBloodGlucose = _HKUnitMolarMassBloodGlucose
#endif


/// `HKUnit` API.
///
/// Loosely inspired by what they seem to be doing.
@_documentation(visibility: internal)
public final class _HKUnit: NSObject, @unchecked Sendable {
    private static let nullUnit = _HKUnit(
        // NOTE: HealthKit represents the null unit as having a factorization of `null: 1`.
        // We diverge from this, instead giving it an empty factorization.
        factorization: .init([:]),
        dimension: .null,
        scaleOffset: 0,
        scaleFactor: 1
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
    
    override public var hash: Int {
        factorization.hashValue
    }
    
    fileprivate init(factorization: HKFactorization, dimension: Dimension, scaleOffset: Double, scaleFactor: Double) {
        self.factorization = factorization
        self.dimension = dimension
        self.scaleOffset = scaleOffset
        self.scaleFactor = scaleFactor
    }
    
    public func isNull() -> Bool {
        self == .nullUnit || factorization.isNull
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? _HKUnit else {
            return false
        }
        return self === object || self.factorization == object.factorization
    }
}


extension _HKUnit {
    // MARK: base unit construction
    
    private struct BaseUnitDescriptor: Hashable {
        let dimension: Dimension
        let unitString: String
        let scaleOffset: Double
        let scaleFactor: Double
    }
    
    private static let baseUnitsCacheLock = RWLock()
    nonisolated(unsafe) private static var _baseUnitsCache: [BaseUnitDescriptor: _HKUnit] = [:]
    
    fileprivate static func baseUnit(
        dimension: _HKUnit.Dimension,
        unitString: String,
        scaleOffset: Double = 0,
        scaleFactor: Double = 1
    ) -> _HKUnit {
        switch dimension.variant {
        case .base:
            let descriptor = BaseUnitDescriptor(
                dimension: dimension,
                unitString: unitString,
                scaleOffset: scaleOffset,
                scaleFactor: scaleFactor
            )
            if let unit = baseUnitsCacheLock.withReadLock({ _baseUnitsCache[descriptor] }) {
                return unit
            }
            return baseUnitsCacheLock.withWriteLock {
                if let unit = _baseUnitsCache[descriptor] {
                    return unit
                } else {
                    let unit = _HKUnit(
                        factorization: HKFactorization([.init(dimension: dimension, unitString: unitString): 1]),
                        dimension: dimension,
                        scaleOffset: scaleOffset,
                        scaleFactor: scaleFactor
                    )
                    _baseUnitsCache[descriptor] = unit
                    return unit
                }
            }
        case .complex:
            fatalError("Attempted to construct base unit with complex dimension '\(dimension)'")
        }
    }
    
    fileprivate static func baseUnit(
        dimension: _HKUnit.Dimension,
        unitString: String,
        metricPrefix: _HKMetricPrefix,
        scaleOffset: Double = 0,
        scaleFactor: Double = 1
    ) -> _HKUnit {
        baseUnit(
            dimension: dimension,
            unitString: "\(metricPrefix.prefixString)\(unitString)",
            scaleOffset: scaleOffset,
            scaleFactor: scaleFactor * metricPrefix.factor
        )
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
        precondition(self.isCompatible(with: other), "Attempted to convert between incompatible units '\(self)' and '\(other)'")
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
        _HKUnit(
            factorization: self.factorization * other.factorization,
            dimension: self.dimension * other.dimension,
            scaleOffset: 0,
            scaleFactor: self.scaleFactor * other.scaleFactor
        )
    }
    
    public func unitDivided(by other: _HKUnit) -> _HKUnit {
        _HKUnit(
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
            _HKUnit(
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
            case base(_ unitString: String, reducedForm: HKFactorization?)
            case complex(HKFactorization)
        }
        
        let variant: Variant
        
        var unitString: String {
            switch variant {
            case .base(let unitString, reducedForm: _):
                unitString
            case .complex(let factorization):
                factorization.unitString
            }
        }
        
        var factorization: HKFactorization {
            switch variant {
            case .base(let unitString, reducedForm: _):
                HKFactorization([.init(dimension: self, unitString: unitString): 1])
            case .complex(let factorization):
                factorization
            }
        }
        
        public var description: String {
            unitString
        }
        
        private init(base unitString: String, reducedForm: Dimension? = nil) {
            variant = .base(unitString, reducedForm: reducedForm?.factorization.reducedToDimensions())
        }
        
        private init(complex factorization: HKFactorization) {
            variant = .complex(factorization)
        }
        
        static let null = Self(base: "null")
        static let time = Self(base: "Time")
        static let length = Self(base: "Length")
        static let mass = Self(base: "Mass")
        static let temperature = Self(base: "Temperature")
        static let volume = Self(base: "Volume", reducedForm: length.raised(to: 3))
        static let pressure = Self(base: "Pressure", reducedForm: mass / (time.raised(to: 2) * length))
        static let energy = Self(base: "Energy", reducedForm: pressure * volume)
        static let conductance = Self(base: "Conductance")
        static let frequency = Self(base: "Frequency", reducedForm: time.raised(to: -1))
        static let electricPotentialDifference = Self(base: "ElectricPotentialDifference")
        static let power = Self(base: "Power", reducedForm: energy / time)
        static let angle = Self(base: "Angle")
        static let illuminance = Self(base: "Illuminance")
        static let soundPressureLevel = Self(base: "SoundPressureLevel")
        static let internationalUnit = Self(base: "IU")
        static let hearingSensitivity = Self(base: "HearingSensitivity")
        static let diopter = Self(base: "Diopter")
        static let prismDiopter = Self(base: "PrismDiopter")
        static let appleEffortScore = Self(base: "AppleEffortScore")
        /// A dimension that represents a mass-less mol.
        static let masslessMole = Self(base: "Mol")
        
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


public enum _HKMetricPrefix: CaseIterable, Sendable {
    case none
    case femto
    case pico
    case nano
    case micro
    case milli
    case centi
    case deci
    case deca
    case hecto
    case kilo
    case mega
    case giga
    case tera
    
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


// MARK: Factorization

@_spi(Testing)
public struct HKFactorization: Hashable, CustomStringConvertible, ExpressibleByDictionaryLiteral, Sendable {
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
            case .base(let unitString, reducedForm: _):
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
    
    var isNull: Bool {
        factors.isEmpty
    }
    
    public var unitString: String {
        guard !isNull else {
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
    
    /// Constructs a factorization from a sequence of elements.
    ///
    /// The `factor^exp` pairs in `inputs` are interpreted as a multiplicative term; any factors that appear multiple times are multiplied onto each other.
    @_spi(Testing)
    public init(_ inputs: some Sequence<(key: Factor, value: Int)>) {
        factors = inputs
            .reduce(into: [:]) { factors, elem in
                let (factor, exp) = elem
                factors[factor, default: 0] += exp
            }
            .filter { $0.value != 0 }
        for factor in factors.keys {
            precondition(!factor.unitString.isEmpty)
        }
    }
    
    @_spi(Testing)
    public init(dictionaryLiteral elements: (Factor, Int)...) {
        self.init(elements)
    }
    
    func reciprocal() -> HKFactorization {
        raised(to: -1)
    }
    
    func multiply(by other: HKFactorization) -> HKFactorization {
        var newFactors = self.factors
        for (unit, exp) in other.factors {
            newFactors[unit, default: 0] += exp
        }
        return HKFactorization(newFactors)
    }
    
    func raised(to power: Int) -> Self {
        switch power {
        case 0:
            HKFactorization([:])
        case 1:
            self
        default:
            HKFactorization(factors.mapValues { $0 * power })
        }
    }
    
    /// Produces a `HKFactorization` of unitless dimensions, reducing factors with identical dimensions where possible.
    func reducedToDimensions() -> Self {
        HKFactorization(factors.flatMap { factor, exp -> [(Factor, Int)] in
            switch factor.dimension.variant {
            case .base(_, reducedForm: .none):
                return [(.init(unitlessDimension: factor.dimension), exp)]
            case .base(_, reducedForm: .some(let reducedForm)):
                return Array((reducedForm.raised(to: exp)).factors)
            case .complex:
                fatalError("unreachable?")
            }
        })
    }
    
    /// Determines whether the factorization is compatible with another one.
    ///
    /// Two factorizations are compatible if their unitless reduced forms are equal.
    func isCompatible(with other: Self) -> Bool {
        self.reducedToDimensions() == other.reducedToDimensions()
    }
    
    static func * (lhs: Self, rhs: Self) -> Self {
        lhs.multiply(by: rhs)
    }
    
    static func / (lhs: Self, rhs: Self) -> Self {
        lhs * rhs.reciprocal()
    }
}


// MARK: Parsing

// we need this as a workaround, to be able to assign in the initializer
/// Internal protocol; used to support creating ``_HKUnit`` instances by parsing a string.
@_documentation(visibility: internal)
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


extension _HKUnit {
    private struct ParseError: LocalizedError {
        let issue: String
        let input: String
        
        var errorDescription: String? {
            "\(issue) (input: '\(input)')"
        }
    }
    
    /// Creates a unit by parsing a unit string.
    @_spi(APISupport)
    public static func parse<S: StringProtocol>(_ input: S) throws -> _HKUnit {
        let syntax: UnitParser<S>.Node
        do {
            syntax = try UnitParser.parse(input: input)
        } catch {
            throw ParseError(issue: error.issue, input: String(input))
        }
        return try unit(for: syntax, from: input)
    }
    
    /// Constructs a ``_HKUnit`` from a parsed unit string.
    ///
    /// - parameter node: The parse result
    /// - parameter input: The original unit string from which `node` was parsed. Used for error reporting.
    private static func unit( // swiftlint:disable:this cyclomatic_complexity function_body_length
        for node: UnitParser<some Any>.Node,
        from input: some StringProtocol
    ) throws -> _HKUnit {
        switch node {
        case .null:
            return .nullUnit
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
            case .molarMass(gramsPerMole: .none):
                Self.masslessMole(with: metricPrefix)
            case .molarMass(gramsPerMole: .some(let gramsPerMole)):
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
            guard metricPrefix == .none else {
                throw ParseError(
                    issue: "Found metric prefix '\(metricPrefix.prefixString)' for non-SI unit '\(unitString)'",
                    input: String(input)
                )
            }
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
            case "yd":
                Self.yard()
            // Angle
            case "deg":
                Self.degreeAngle()
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
            case "kcal", "Cal":
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
            // Diopter
            case "D":
                Self.diopter()
            case "pD":
                Self.prismDiopter()
            // Unitless
            case "appleEffortScore":
                Self.appleEffortScore()
            default:
                nil
            }
            guard let unit else {
                throw ParseError(
                    issue: "Unhandled non-SI unit '\(unitString)'",
                    input: String(input)
                )
            }
            return unit.unitRaised(toPower: power)
        case let .cons(lhs, rhs):
            return try unit(for: lhs, from: input) * unit(for: rhs, from: input)
        }
    }
}

private struct UnitParser<Input: StringProtocol>: ~Copyable { // swiftlint:disable:this type_body_length
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
            case molarMass(gramsPerMole: Double?)
            case electricalPotentialDifference
            case power
            case angle
            case illuminance
            
            init?(_ input: some StringProtocol) { // swiftlint:disable:this cyclomatic_complexity
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
                    if input.starts(with: "mol") {
                        if let idx1 = input.firstIndex(of: "<"),
                           idx1 == input.dropFirst(3).startIndex,
                           let idx2 = input.lastIndex(of: ">"),
                           idx2 == input.index(before: input.endIndex) {
                            guard let gramsPerMol = Double(input[input.index(after: idx1)..<idx2]) else {
                                return nil
                            }
                            self = .molarMass(gramsPerMole: gramsPerMol)
                        } else {
                            // 'mol' w/out a '<x.y>' suffix is parsed into the massless molar unit.
                            self = .molarMass(gramsPerMole: nil)
                        }
                    } else {
                        return nil
                    }
                }
            }
        }
    }
    
    indirect enum Node {
        case null
        case atom(metricPrefix: _HKMetricPrefix, unit: Unit, power: Int)
        case cons(Node, Node)
        
        var isNull: Bool {
            switch self {
            case .null:
                true
            case .atom, .cons:
                false
            }
        }
        
        func reciprocal() -> Self {
            switch self {
            case .null:
                .null // Q should this be allowed?
            case let .atom(metricPrefix, unit, power):
                .atom(metricPrefix: metricPrefix, unit: unit, power: -power)
            case let .cons(lhs, rhs):
                .cons(lhs.reciprocal(), rhs.reciprocal())
            }
        }
        
        func raised(to power: Int) -> Self {
            switch self {
            case .null:
                .null // Q should this be allowed?
            case let .atom(metricPrefix, unit, power2):
                .atom(metricPrefix: metricPrefix, unit: unit, power: power2 * power)
            case let .cons(lhs, rhs):
                .cons(lhs.raised(to: power), rhs.raised(to: power))
            }
        }
    }
    
    struct ParseError: Error {
        let issue: String
        let position: Input.Index
    }
    
    private let multiplicationSeparators: Set<Character> = ["·", "*", "."]
    
    private let _input: Input
    private var position: Input.Index
    
    private var current: Character? {
        _input[safe: position]
    }
    private var isAtEnd: Bool {
        position >= _input.endIndex
    }
    private var remaining: Input.SubSequence {
        _input[position...]
    }
    
    init(input: Input) {
        self._input = input
        self.position = input.startIndex
    }
    
    static func parse(input: Input) throws(ParseError) -> Node {
        var parser = Self(input: input)
        return try parser.parseExpr(isAtRoot: true)
    }
    
    private func peek(_ offset: Int = 1) -> Character? {
        _input[safe: _input.index(position, offsetBy: offset)]
    }
    
    private mutating func advance(by count: Int = 1) {
        precondition(count > 0)
        _input.formIndex(&position, offsetBy: count)
    }
    
    private mutating func advance(to newPos: Input.Index) {
        precondition(newPos > position)
        position = newPos
    }
    
    private func parseError(at pos: Input.Index? = nil, issue: String) -> ParseError { // swiftlint:disable:this function_default_parameter_at_end
        ParseError(issue: issue, position: pos ?? position)
    }
    
    private mutating func parseExpr(isAtRoot: Bool) throws (ParseError) -> Node { // swiftlint:disable:this function_body_length cyclomatic_complexity
        var nodes: [Node] = []
        loop: while !isAtEnd {
            let posAtEntry = position
            if current == "(" {
                if !nodes.isEmpty {
                    // we're parsing a paren-expr that follows some other expr.
                    guard let prev = peek(-1), multiplicationSeparators.contains(prev) else {
                        throw parseError(issue: "Invalid input")
                    }
                }
                let exprPos = position
                let expr = try parseParenExpr()
                if expr.isNull && !nodes.isEmpty {
                    throw parseError(at: exprPos, issue: "Invalid '()'")
                } else if nodes.contains(where: \.isNull) {
                    throw parseError(at: exprPos, issue: "Invalid input: cannot multiply with '()'")
                } else {
                    nodes.append(expr)
                }
            } else if let current, multiplicationSeparators.contains(current) {
                guard !nodes.isEmpty else {
                    throw parseError(at: position, issue: "Unexpected '\(current)'")
                }
                advance()
            } else if current == "/" || current == "1" && peek() == "/" {
                guard isAtRoot else {
                    // we found a non-top-level division
                    throw parseError(at: position, issue: "'/' only allowed at root level")
                }
                // we found a top-level division
                switch (current == "/", nodes.first) {
                case (true, .none): // '/<rhs>'
                    throw parseError(at: position, issue: "missing lhs for '/'")
                case (true, .some(let lhsFst)): // '<lhs>/<rhs>'
                    advance(by: 1)
                    let lhs = nodes.dropFirst().reduce(lhsFst) { .cons($0, $1) }
                    let rhs = try parseExpr(isAtRoot: false)
                    // intentionally returning out of the loop here
                    return .cons(lhs, rhs.reciprocal())
                case (false, .none): // '1/<rhs>'
                    advance(by: 2)
                    let rhs = try parseExpr(isAtRoot: false)
                    // intentionally returning out of the loop here
                    return rhs.reciprocal()
                case (false, .some(let lhsFst)): // '<lhs>1/<rhs>'
                    advance(by: 2)
                    let lhs = nodes.dropFirst().reduce(lhsFst) { .cons($0, $1) }
                    let rhs = try parseExpr(isAtRoot: false)
                    // intentionally returning out of the loop here
                    return .cons(lhs, rhs.reciprocal())
                }
            } else if current == ")" {
                if isAtRoot {
                    throw parseError(issue: "Unexpected ')'")
                }
                // closing paren expr
                break loop
            } else {
                let exprPos = position
                let expr = try parseAtom()
                if nodes.contains(where: \.isNull) {
                    throw parseError(at: exprPos, issue: "Invalid input: cannot multiply with '()'")
                } else {
                    nodes.append(expr)
                }
            }
            guard position > posAtEntry else {
                throw parseError(issue: "Unable to parse")
            }
        }
        guard let fst = nodes.first else {
            return .null
        }
        return nodes.dropFirst().reduce(fst) { .cons($0, $1) }
    }
    
    private mutating func parseParenExpr() throws(ParseError) -> Node {
        guard current == "(" else {
            throw parseError(issue: "Expected '('")
        }
        advance()
        if current == ")" {
            // '()' input
            advance()
            return .null
        }
        let expr = try parseExpr(isAtRoot: false)
        guard current == ")" else {
            throw parseError(issue: "Expected ')'")
        }
        advance()
        if let power = try parseExponentiation() {
            guard !expr.isNull else {
                throw parseError(issue: "Invalid exponentiation")
            }
            return expr.raised(to: power)
        } else {
            return expr
        }
    }
    
    private mutating func parseAtom() throws(ParseError) -> Node { // swiftlint:disable:this cyclomatic_complexity
        let possibleAtomInput = try { () throws(ParseError) -> Input.SubSequence in
            let candidate = remaining.prefix { $0.isLetter || $0 == "_" }
            guard !candidate.isEmpty else {
                // handled below
                return candidate
            }
            if remaining.dropFirst(candidate.count).first == "<" {
                // `unit<spec>`?
                let numberPart = remaining.dropFirst(candidate.count + 1).prefix { $0.isWholeNumber || $0 == "." }
                guard !numberPart.isEmpty else {
                    throw parseError(at: remaining.dropFirst(candidate.count).startIndex, issue: "Empty '<>' specifier")
                }
                guard remaining[safe: numberPart.endIndex] == ">" else {
                    throw parseError(at: numberPart.startIndex, issue: "Unable to find matching '<'")
                }
                return remaining[candidate.startIndex...numberPart.endIndex]
            } else {
                return candidate
            }
        }()
        guard !possibleAtomInput.isEmpty else {
            // percent needs special handling bc it isn't covered by the prefix selection predicate above
            if remaining.starts(with: "%") {
                advance()
                return .atom(metricPrefix: .none, unit: .other("%"), power: 1)
            }
            throw parseError(issue: "Unable to parse atom")
        }
        let atom: Node? = { () -> Node? in
            for metricPrefix in _HKMetricPrefix.allCases {
                let prefixString = metricPrefix.prefixString
                if possibleAtomInput.starts(with: prefixString), let siUnit = Unit.SIUnit(possibleAtomInput.dropFirst(prefixString.count)) {
                    return .atom(metricPrefix: metricPrefix, unit: .SI(siUnit), power: 1)
                }
            }
            // we were unable to parse the `unitInput` as a metric-prefix-prepended SI unit
            return .atom(metricPrefix: .none, unit: .other(String(possibleAtomInput)), power: 1)
        }()
        guard let atom else {
            throw parseError(issue: "Unable to parse atom")
        }
        advance(by: possibleAtomInput.count)
        if let exponent = try parseExponentiation() {
            guard !atom.isNull else {
                throw parseError(issue: "Invalid exponentiation")
            }
            return atom.raised(to: exponent)
        } else {
            return atom
        }
    }
    
    /// Parses an exponentation of the form `^n`, if is exists at the current position.
    ///
    /// - returns: the power `n`, if an exponentiation exists at the current position. `nil` if no exponentiation exists.
    private mutating func parseExponentiation() throws(ParseError) -> Int? {
        guard current == "^" else {
            return nil
        }
        advance()
        let powerInput = remaining.prefix { $0 == "-" || $0.isNumber }
        guard let power = Int(powerInput) else {
            throw parseError(issue: "Unable to parse power")
        }
        advance(by: powerInput.count)
        return power
    }
}


// MARK: Base Unit Definitions

extension _HKUnit {
    public static func gramUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        baseUnit(dimension: .mass, unitString: "g", metricPrefix: prefix)
    }
    
    public static func gram() -> _HKUnit {
        gramUnit(with: .none)
    }
    
    public static func ounce() -> _HKUnit {
        baseUnit(dimension: .mass, unitString: "oz", scaleFactor: 28.349523125)
    }
    
    public static func pound() -> _HKUnit {
        baseUnit(dimension: .mass, unitString: "lb", scaleFactor: 453.59237)
    }
    
    public static func stone() -> _HKUnit {
        baseUnit(dimension: .mass, unitString: "st", scaleFactor: 6350.2931799999997)
    }
    
    public static func moleUnit(with prefix: _HKMetricPrefix, molarMass gramsPerMole: Double) -> _HKUnit {
        baseUnit(dimension: .mass, unitString: "mol<\(gramsPerMole)>", metricPrefix: prefix, scaleFactor: gramsPerMole)
    }
    
    public static func moleUnit(withMolarMass gramsPerMole: Double) -> _HKUnit {
        moleUnit(with: .none, molarMass: gramsPerMole)
    }
    
    @_spi(Testing)
    public static func masslessMole(with prefix: _HKMetricPrefix) -> _HKUnit {
        baseUnit(dimension: .masslessMole, unitString: "mol", metricPrefix: prefix)
    }
}


extension _HKUnit {
    public static func meterUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        baseUnit(dimension: .length, unitString: "m", metricPrefix: prefix)
    }
    
    public static func meter() -> _HKUnit {
        meterUnit(with: .none)
    }
    
    public static func inch() -> _HKUnit {
        baseUnit(dimension: .length, unitString: "in", scaleFactor: 0.0254)
    }
    
    public static func foot() -> _HKUnit {
        baseUnit(dimension: .length, unitString: "ft", scaleFactor: 0.3048)
    }
    
    public static func yard() -> _HKUnit {
        baseUnit(dimension: .length, unitString: "yd", scaleFactor: 0.9144)
    }
    
    public static func mile() -> _HKUnit {
        baseUnit(dimension: .length, unitString: "mi", scaleFactor: 1609.344)
    }
}


extension _HKUnit {
    public static func literUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        baseUnit(dimension: .volume, unitString: "L", metricPrefix: prefix, scaleFactor: 0.001)
    }
    
    public static func liter() -> _HKUnit {
        literUnit(with: .none)
    }
    
    public static func fluidOunceUS() -> _HKUnit {
        baseUnit(dimension: .volume, unitString: "fl_oz_us", scaleFactor: 0.0295735295625)
    }
    
    public static func fluidOunceImperial() -> _HKUnit {
        baseUnit(dimension: .volume, unitString: "fl_oz_imp", scaleFactor: 0.0284130625)
    }
    
    public static func pintUS() -> _HKUnit {
        baseUnit(dimension: .volume, unitString: "pt_us", scaleFactor: 0.473176473)
    }
    
    public static func pintImperial() -> _HKUnit {
        baseUnit(dimension: .volume, unitString: "pt_imp", scaleFactor: 0.56826125)
    }
    
    public static func cupUS() -> _HKUnit {
        baseUnit(dimension: .volume, unitString: "cup_us", scaleFactor: 0.2365882365)
    }
    
    public static func cupImperial() -> _HKUnit {
        baseUnit(dimension: .volume, unitString: "cup_imp", scaleFactor: 0.284130625)
    }
}


extension _HKUnit {
    public static func pascalUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        baseUnit(dimension: .pressure, unitString: "Pa", metricPrefix: prefix)
    }
    
    public static func pascal() -> _HKUnit {
        pascalUnit(with: .none)
    }
    
    public static func millimeterOfMercury() -> _HKUnit {
        baseUnit(dimension: .pressure, unitString: "mmHg", scaleFactor: 133.322387415)
    }
    
    public static func centimeterOfWater() -> _HKUnit {
        baseUnit(dimension: .pressure, unitString: "cmAq", scaleFactor: 98.0665)
    }
    
    public static func atmosphere() -> _HKUnit {
        baseUnit(dimension: .pressure, unitString: "atm", scaleFactor: 101325)
    }
    
    public static func decibelAWeightedSoundPressureLevel() -> _HKUnit {
        baseUnit(dimension: .soundPressureLevel, unitString: "dBASPL", scaleFactor: 1)
    }
    
    public static func inchesOfMercury() -> _HKUnit {
        baseUnit(dimension: .pressure, unitString: "inHg", scaleFactor: 3386.38816)
    }
}


extension _HKUnit {
    public static func secondUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        baseUnit(dimension: .time, unitString: "s", metricPrefix: prefix)
    }
    
    public static func second() -> _HKUnit {
        secondUnit(with: .none)
    }
    
    public static func minute() -> _HKUnit {
        baseUnit(dimension: .time, unitString: "min", scaleFactor: 60)
    }
    
    public static func hour() -> _HKUnit {
        baseUnit(dimension: .time, unitString: "hr", scaleFactor: 60 * 60)
    }
    
    public static func day() -> _HKUnit {
        baseUnit(dimension: .time, unitString: "d", scaleFactor: 60 * 60 * 24)
    }
}


extension _HKUnit {
    public static func jouleUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        baseUnit(dimension: .energy, unitString: "J", metricPrefix: prefix)
    }
    
    public static func joule() -> _HKUnit {
        jouleUnit(with: .none)
    }
    
    public static func kilocalorie() -> _HKUnit {
        baseUnit(dimension: .energy, unitString: "kcal", scaleFactor: 4184)
    }
    
    public static func smallCalorie() -> _HKUnit {
        baseUnit(dimension: .energy, unitString: "cal", scaleFactor: 4.184)
    }
    
    public static func largeCalorie() -> _HKUnit {
        baseUnit(dimension: .energy, unitString: "Cal", scaleFactor: 4184)
    }
    
    @available(*, deprecated, message: "Use smallCalorie or largeCalorie, depending on which you mean")
    public static func calorie() -> _HKUnit {
        .smallCalorie()
    }
}


extension _HKUnit {
    public static func degreeCelsius() -> _HKUnit {
        baseUnit(dimension: .temperature, unitString: "degC", scaleOffset: 273.15, scaleFactor: 1)
    }
    
    public static func degreeFahrenheit() -> _HKUnit {
        baseUnit(dimension: .temperature, unitString: "degF", scaleOffset: (5 / 9) * 459.67, scaleFactor: 5 / 9)
    }
    
    public static func kelvin() -> _HKUnit {
        kelvinUnit(with: .none)
    }
    
    fileprivate static func kelvinUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        baseUnit(dimension: .temperature, unitString: "K", metricPrefix: prefix)
    }
}


extension _HKUnit {
    public static func siemenUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        baseUnit(dimension: .conductance, unitString: "S", metricPrefix: prefix)
    }
    
    public static func siemen() -> _HKUnit {
        siemenUnit(with: .none)
    }
}


extension _HKUnit {
    public static func internationalUnit() -> _HKUnit {
        baseUnit(dimension: .internationalUnit, unitString: "IU")
    }
}


extension _HKUnit {
    public static func count() -> _HKUnit {
        baseUnit(dimension: .null, unitString: "count")
    }
    
    public static func percent() -> _HKUnit {
        baseUnit(dimension: .null, unitString: "%")
    }
}


extension _HKUnit {
    public static func decibelHearingLevel() -> _HKUnit {
        baseUnit(dimension: .hearingSensitivity, unitString: "dBHL")
    }
}


extension _HKUnit {
    public static func hertzUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        baseUnit(dimension: .frequency, unitString: "Hz", metricPrefix: prefix)
    }
    
    public static func hertz() -> _HKUnit {
        hertzUnit(with: .none)
    }
}


extension _HKUnit {
    public static func voltUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        baseUnit(dimension: .electricPotentialDifference, unitString: "V", metricPrefix: prefix)
    }
    
    public static func volt() -> _HKUnit {
        voltUnit(with: .none)
    }
}


extension _HKUnit {
    public static func wattUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        baseUnit(dimension: .power, unitString: "W", metricPrefix: prefix)
    }
    
    public static func watt() -> _HKUnit {
        wattUnit(with: .none)
    }
}


extension _HKUnit {
    public static func diopter() -> _HKUnit {
        baseUnit(dimension: .diopter, unitString: "D")
    }
    
    public static func prismDiopter() -> _HKUnit {
        baseUnit(dimension: .prismDiopter, unitString: "pD")
    }
}


extension _HKUnit {
    public static func radianAngleUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        baseUnit(dimension: .angle, unitString: "rad", metricPrefix: prefix)
    }
    
    public static func radianAngle() -> _HKUnit {
        radianAngleUnit(with: .none)
    }
    
    public static func degreeAngle() -> _HKUnit {
        baseUnit(dimension: .angle, unitString: "deg", scaleFactor: 1 / (180 / .pi))
    }
}


extension _HKUnit {
    public static func luxUnit(with prefix: _HKMetricPrefix) -> _HKUnit {
        baseUnit(dimension: .illuminance, unitString: "lx", metricPrefix: prefix)
    }
    
    public static func lux() -> _HKUnit {
        luxUnit(with: .none)
    }
}


extension _HKUnit {
    public static func appleEffortScore() -> _HKUnit {
        baseUnit(dimension: .appleEffortScore, unitString: "appleEffortScore")
    }
}


public let _HKUnitMolarMassBloodGlucose: Double = 180.15588000005408
