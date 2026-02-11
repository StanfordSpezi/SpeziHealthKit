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


public class HKUnit: NSObject, @unchecked Sendable {
    /// Returns a unique string representation for the unit that could be used with +unitFromString:
    public var unitString: String {
        _notImplemented()
    }
    public convenience init(from string: String) {
        Self._notImplemented()
    }
//    public convenience init(from massFormatterUnit: MassFormatter.Unit)
//    public class func massFormatterUnit(from unit: HKUnit) -> MassFormatter.Unit
//    public convenience init(from lengthFormatterUnit: LengthFormatter.Unit)
//    public class func lengthFormatterUnit(from unit: HKUnit) -> LengthFormatter.Unit
//    public convenience init(from energyFormatterUnit: EnergyFormatter.Unit)
//    public class func energyFormatterUnit(from unit: HKUnit) -> EnergyFormatter.Unit
    public func isNull() -> Bool {
        _notImplemented()
    }
}

@available(macOS 13.0, *)
public enum HKMetricPrefix : Int, @unchecked Sendable {
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
}

extension HKUnit {
    public class func gramUnit(with prefix: HKMetricPrefix) -> Self {
        _notImplemented()
    }
    
    public class func gram() -> Self {
        _notImplemented()
    }
    
    public class func ounce() -> Self {
        _notImplemented()
    }
    
    public class func pound() -> Self {
        _notImplemented()
    }
    
    public class func stone() -> Self {
        _notImplemented()
    }
    
    public class func moleUnit(with prefix: HKMetricPrefix, molarMass gramsPerMole: Double) -> Self {
        _notImplemented()
    }
    
    public class func moleUnit(withMolarMass gramsPerMole: Double) -> Self {
        _notImplemented()
    }
}

extension HKUnit {
    public class func meterUnit(with prefix: HKMetricPrefix) -> Self {
        _notImplemented()
    }
    
    public class func meter() -> Self {
        _notImplemented()
    }
    
    public class func inch() -> Self {
        _notImplemented()
    }
    
    public class func foot() -> Self {
        _notImplemented()
    }
    
    public class func yard() -> Self {
        _notImplemented()
    }
    
    public class func mile() -> Self {
        _notImplemented()
    }
}

extension HKUnit {
    public class func literUnit(with prefix: HKMetricPrefix) -> Self {
        _notImplemented()
    }
    
    public class func liter() -> Self {
        _notImplemented()
    }
    
    public class func fluidOunceUS() -> Self {
        _notImplemented()
    }
    
    public class func fluidOunceImperial() -> Self {
        _notImplemented()
    }
    
    public class func pintUS() -> Self {
        _notImplemented()
    }
    
    public class func pintImperial() -> Self {
        _notImplemented()
    }
    
    public class func cupUS() -> Self {
        _notImplemented()
    }
    
    public class func cupImperial() -> Self {
        _notImplemented()
    }
}

extension HKUnit {
    public class func pascalUnit(with prefix: HKMetricPrefix) -> Self {
        _notImplemented()
    }
    
    public class func pascal() -> Self {
        _notImplemented()
    }
    
    public class func millimeterOfMercury() -> Self {
        _notImplemented()
    }
    
    public class func centimeterOfWater() -> Self {
        _notImplemented()
    }
    
    public class func atmosphere() -> Self {
        _notImplemented()
    }
    
    public class func decibelAWeightedSoundPressureLevel() -> Self {
        _notImplemented()
    }
    
    public class func inchesOfMercury() -> Self {
        _notImplemented()
    }
}

extension HKUnit {
    public class func secondUnit(with prefix: HKMetricPrefix) -> Self {
        _notImplemented()
    }
    
    public class func second() -> Self {
        _notImplemented()
    }
    
    public class func minute() -> Self {
        _notImplemented()
    }
    
    public class func hour() -> Self {
        _notImplemented()
    }
    
    public class func day() -> Self {
        _notImplemented()
    }
}


extension HKUnit {
    public class func jouleUnit(with prefix: HKMetricPrefix) -> Self {
        _notImplemented()
    }
    
    public class func joule() -> Self {
        _notImplemented()
    }
    
    public class func kilocalorie() -> Self {
        _notImplemented()
    }
    
    public class func smallCalorie() -> Self {
        _notImplemented()
    }
    
    public class func largeCalorie() -> Self {
        _notImplemented()
    }
    
    public class func calorie() -> Self {
        _notImplemented()
    }
}


extension HKUnit {
    public class func degreeCelsius() -> Self {
        _notImplemented()
    }
    
    public class func degreeFahrenheit() -> Self {
        _notImplemented()
    }
    
    public class func kelvin() -> Self {
        _notImplemented()
    }
}


extension HKUnit {
    public class func siemenUnit(with prefix: HKMetricPrefix) -> Self {
        _notImplemented()
    }
    
    public class func siemen() -> Self {
        _notImplemented()
    }
}

extension HKUnit {
    public class func internationalUnit() -> Self {
        _notImplemented()
    }
}

extension HKUnit {
    public class func count() -> Self {
        _notImplemented()
    }
    
    public class func percent() -> Self {
        _notImplemented()
    }
}

extension HKUnit {
    public class func decibelHearingLevel() -> Self {
        _notImplemented()
    }
}

extension HKUnit {
    public func unitMultiplied(by unit: HKUnit) -> HKUnit {
        _notImplemented()
    }
    
    public func unitDivided(by unit: HKUnit) -> HKUnit {
        _notImplemented()
    }
    
    public func unitRaised(toPower power: Int) -> HKUnit {
        _notImplemented()
    }
    
    public func reciprocal() -> HKUnit {
        _notImplemented()
    }
}

extension HKUnit {
    public class func hertzUnit(with prefix: HKMetricPrefix) -> Self {
        _notImplemented()
    }
    
    public class func hertz() -> Self {
        _notImplemented()
    }
}

extension HKUnit {
    public class func voltUnit(with prefix: HKMetricPrefix) -> Self {
        _notImplemented()
    }
    
    public class func volt() -> Self {
        _notImplemented()
    }
}

extension HKUnit {
    public class func wattUnit(with prefix: HKMetricPrefix) -> Self {
        _notImplemented()
    }
    
    public class func watt() -> Self {
        _notImplemented()
    }
}

extension HKUnit {
    public class func diopter() -> Self {
        _notImplemented()
    }
    
    public class func prismDiopter() -> Self {
        _notImplemented()
    }
}

extension HKUnit {
    public class func radianAngleUnit(with prefix: HKMetricPrefix) -> Self {
        _notImplemented()
    }
    
    public class func radianAngle() -> Self {
        _notImplemented()
    }
    
    public class func degreeAngle() -> Self {
        _notImplemented()
    }
}

extension HKUnit {
    public class func luxUnit(with prefix: HKMetricPrefix) -> Self {
        _notImplemented()
    }
    
    public class func lux() -> Self {
        _notImplemented()
    }
}

extension HKUnit {
    public class func appleEffortScore() -> Self {
        _notImplemented()
    }
}

public var HKUnitMolarMassBloodGlucose: Double {
    fatalError()
}




extension NSObject {
    static func _notImplemented(_ caller: StaticString = #function) -> Never {
        fatalError("+[\(Self.self) \(caller)]: Not Implemented")
    }
    
    func _notImplemented(_ caller: StaticString = #function) -> Never {
        fatalError("-[\(Self.self) \(caller)]: Not Implemented")
    }
}



#endif
