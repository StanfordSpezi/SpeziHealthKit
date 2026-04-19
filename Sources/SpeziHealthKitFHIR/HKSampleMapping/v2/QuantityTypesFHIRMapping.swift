//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import ModelsR4
public import SpeziHealthKit

// TODO use HKQuantityType or SampleType<...> as the key here? (perf impact?!)
/// Controls how `HKQuantitySample`s are mapped into FHIR Observations.
public typealias QuantityTypesFHIRMapping = [SampleType<HKQuantitySample>: QuantityTypeFHIRMapping]


/// Controls how an `HKQuantitySample` is mapped into a FHIR Observation.
///
/// ## Topics
///
/// ### Initializers
/// - ``init(codings:unit:)``
///
/// ### Instance Properties
/// - ``codings``
/// - ``unit``
///
/// ### Supporting Types
/// - ``Unit``
public struct QuantityTypeFHIRMapping: Hashable, Sendable {
    // TODO docs!
    public struct Unit: Hashable, Sendable {
        public let hkUnit: HKUnit
        public let unit: String
        public let system: FHIRPrimitive<FHIRURI>?
        public let code: FHIRPrimitive<FHIRString>?
        
        public init(hkUnit: HKUnit, unit: String, system: FHIRPrimitive<FHIRURI>?, code: FHIRPrimitive<FHIRString>?) {
            self.hkUnit = hkUnit
            self.unit = unit
            self.system = system
            self.code = code
        }
    }
    
    // TODO add categories?!
    public let codings: [Coding]
    public let categories: [Coding]
    public let unit: Unit
    
    public init(codings: [Coding], categories: [Coding] = [], unit: Unit) {
        self.codings = codings
        self.categories = categories
        self.unit = unit
    }
}



extension FHIRPrimitive<FHIRURI> {
    // swiftlint:disable force_unwrapping
    internal static let loincSystem: Self = "http://loinc.org".asFHIRURIPrimitive()!
    internal static let snomedCT: Self = "http://snomed.info/sct".asFHIRURIPrimitive()!
    internal static let unitsOfMeasureSystem: Self = "http://unitsofmeasure.org".asFHIRURIPrimitive()!
    internal static let healthKitSystem: Self = "http://developer.apple.com/documentation/healthkit".asFHIRURIPrimitive()!
    // swiftlint:enable force_unwrapping
}


extension Coding {
    init(_ sampleType: SampleType<HKQuantitySample>) {
        self.init(
            code: sampleType.identifier.rawValue.asFHIRStringPrimitive(),
            display: sampleType.canonicalTitle.asFHIRStringPrimitive(),
            system: .healthKitSystem
        )
    }
}


extension QuantityTypesFHIRMapping {
    /// The default FHIR mapping for HealthKit Quantity types
    public static let `default`: Self = {
        var mapping: Self = [:]
        func addMapping(
            for sampleType: SampleType<HKQuantitySample>,
            extraCodings: [Coding] = [],
            case categories: [Coding] = [],
            code: FHIRPrimitive<FHIRString>?,
            unitString: String,
            system: FHIRPrimitive<FHIRURI>?
        ) {
            mapping[sampleType] = QuantityTypeFHIRMapping(
                codings: extraCodings + [Coding(sampleType)],
                categories: categories,
                unit: QuantityTypeFHIRMapping.Unit(
                    hkUnit: sampleType.canonicalUnit,
                    unit: unitString,
                    system: system,
                    code: code
                )
            )
        }
        addMapping(
            for: .activeEnergyBurned,
            extraCodings: [
                Coding(
                    code: "41981-2",
                    display: "Calories burned",
                    system: .loincSystem
                )
            ],
            code: "kcal",
            unitString: "kcal",
            system: .unitsOfMeasureSystem
        )
        addMapping(for: .appleExerciseTime, code: "min", unitString: "min", system: .unitsOfMeasureSystem)
        addMapping(for: .appleMoveTime, code: "min", unitString: "min", system: .unitsOfMeasureSystem)
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            addMapping(for: .appleSleepingBreathingDisturbances, code: nil, unitString: "count", system: nil)
        }
        addMapping(for: .appleSleepingWristTemperature, code: "Cel", unitString: "C", system: .unitsOfMeasureSystem)
        addMapping(for: .appleStandTime, code: "min", unitString: "min", system: .unitsOfMeasureSystem)
        addMapping(for: .appleWalkingSteadiness, code: "%", unitString: "%", system: .unitsOfMeasureSystem)
        addMapping(for: .atrialFibrillationBurden, code: "%", unitString: "%", system: .unitsOfMeasureSystem)
        addMapping(
            for: .basalBodyTemperature,
            extraCodings: [
                Coding(
                    code: "8310-5",
                    display: "Body temperature",
                    system: .loincSystem
                ),
                Coding(
                    code: "300076005",
                    system: .snomedCT
                )
            ],
            code: "Cel",
            unitString: "C",
            system: .unitsOfMeasureSystem
        )
        addMapping(for: .basalEnergyBurned, code: "kcal", unitString: "kcal", system: .unitsOfMeasureSystem)
        addMapping(
            for: .bloodAlcoholContent,
            extraCodings: [
                Coding(
                    code: "74859-0", // 5640-8?
                    display: "Ethanol [Mass/volume] in Blood Estimated from serum or plasma level",
                    system: .loincSystem
                )
            ],
            code: "%",
            unitString: "%",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .bloodGlucose,
            extraCodings: [
                Coding(
                    code: "41653-7",
                    display: "Glucose Glucometer (BldC) [Mass/Vol]",
                    system: .loincSystem
                )
            ],
            code: "mg/dL",
            unitString: "mg/dL",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .bloodPressureDiastolic,
            extraCodings: [
                Coding(
                    code: "8462-4",
                    display: "Diastolic blood pressure",
                    system: .loincSystem
                ),
                Coding(
                    code: "271650006",
                    display: "Diastolic blood pressure",
                    system: .snomedCT
                )
            ],
            code: "mm[Hg]",
            unitString: "mmHg",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .bloodPressureSystolic,
            extraCodings: [
                Coding(
                    code: "8480-6",
                    display: "Systolic blood pressure",
                    system: .loincSystem
                ),
                Coding(
                    code: "271649006",
                    display: "Systolic blood pressure",
                    system: .snomedCT
                )
            ],
            code: "mm[Hg]",
            unitString: "mmHg",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .bodyFatPercentage,
            extraCodings: [
                Coding(
                    code: "41982-0",
                    display: "Percentage of body fat Measured",
                    system: .loincSystem
                )
            ],
            code: "%",
            unitString: "%",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .bodyMass,
            extraCodings: [
                Coding(
                    code: "29463-7",
                    display: "Body weight",
                    system: .loincSystem
                ),
                Coding(
                    code: "27113001",
                    display: "Body weight",
                    system: .snomedCT
                )
            ],
            code: "kg",
            unitString: "kg",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .bodyMassIndex,
            extraCodings: [
                Coding(
                    code: "39156-5",
                    display: "Body mass index (BMI) [Ratio]",
                    system: .loincSystem
                )
            ],
            code: "kg/m2",
            unitString: "kg/m^2",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .bodyTemperature,
            extraCodings: [
                Coding(
                    code: "8310-5",
                    display: "Body temperature",
                    system: .loincSystem
                ),
                Coding(
                    code: "386725007",
                    display: "Body temperature",
                    system: .snomedCT
                )
            ],
            code: "Cel",
            unitString: "C",
            system: .unitsOfMeasureSystem
        )
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            addMapping(
                for: .crossCountrySkiingSpeed,
                code: "m/s",
                unitString: "m/s",
                system: .unitsOfMeasureSystem
            )
        }
        addMapping(
            for: .cyclingCadence,
            code: "/min",
            unitString: "r/min",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .cyclingFunctionalThresholdPower,
            code: "W",
            unitString: "watt",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .cyclingPower,
            code: "W",
            unitString: "watt",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .cyclingSpeed,
            code: "km/h",
            unitString: "km/h",
            system: .unitsOfMeasureSystem
        )
        do {
            let byUnit: [String: [SampleType<HKQuantitySample>]] = [
                "ug": [.dietaryBiotin, .dietaryChromium, .dietaryCopper, .dietaryFolate, .dietaryIodine, .dietaryMolybdenum, .dietarySelenium, .dietaryVitaminA, .dietaryVitaminB12, .dietaryVitaminD, .dietaryVitaminK],
                "mg": [.dietaryCaffeine, .dietaryCalcium, .dietaryChloride, .dietaryCholesterol, .dietaryIron, .dietaryMagnesium, .dietaryManganese, .dietaryNiacin, .dietaryPantothenicAcid, .dietaryPhosphorus, .dietaryPotassium, .dietaryRiboflavin, .dietarySodium, .dietaryThiamin, .dietaryVitaminB6, .dietaryVitaminC, .dietaryVitaminE, .dietaryZinc],
                "g": [.dietaryCarbohydrates, .dietaryFatMonounsaturated, .dietaryFatPolyunsaturated, .dietaryFatSaturated, .dietaryFatTotal, .dietaryProtein, .dietarySugar]
            ]
            for (unit, sampleTypes) in byUnit {
                for sampleType in sampleTypes {
                    addMapping(
                        for: sampleType,
                        code: unit.asFHIRStringPrimitive(),
                        unitString: unit,
                        system: .unitsOfMeasureSystem
                    )
                }
            }
        }
        
        addMapping(
            for: .dietaryEnergyConsumed,
            extraCodings: [
                Coding(
                    code: "9052-2",
                    display: "Calorie intake total",
                    system: .loincSystem
                )
            ],
            code: "kcal",
            unitString: "kcal",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .dietaryFiber,
            extraCodings: [
                Coding(
                    code: "LP203183-1",
                    display: "Fiber intake",
                    system: .loincSystem
                )
            ],
            code: "g",
            unitString: "g",
            system: .unitsOfMeasureSystem
        )
        
        addMapping(
            for: .dietaryWater,
            extraCodings: [
                Coding(
                    code: "8999-5",
                    display: "Fluid intake oral Estimated",
                    system: .loincSystem
                ),
                Coding(
                    code: "226354008",
                    display: "Water intake",
                    system: .snomedCT
                )
            ],
            code: "l",
            unitString: "l",
            system: .unitsOfMeasureSystem
        )
        
        do {
            var sampleTypes: [SampleType<HKQuantitySample>] = [
                .distanceCycling, .distanceDownhillSnowSports
            ]
            if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
                sampleTypes += [
                    .distanceCrossCountrySkiing,
                    .distancePaddleSports,
                    .distanceRowing,
                    .distanceSkatingSports
                ]
            }
            for sampleType in sampleTypes {
                addMapping(for: sampleType, code: "m", unitString: "m", system: .unitsOfMeasureSystem)
            }
        }
        addMapping(
            for: .distanceSwimming,
            extraCodings: [
                Coding(
                    code: "93816-7",
                    display: "Swimming distance unspecified time",
                    system: .loincSystem
                )
            ],
            code: "m",
            unitString: "m",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .distanceWalkingRunning,
            extraCodings: [
                // TODO SURELU THIS HAS A COPDE?
            ],
            code: "m",
            unitString: "m",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .distanceWheelchair,
            extraCodings: [
                // TODO SURELU THIS HAS A COPDE?
            ],
            code: "m",
            unitString: "m",
            system: .unitsOfMeasureSystem
        )
        
        addMapping(for: .electrodermalActivity, code: "mcS", unitString: "microsiemens", system: .unitsOfMeasureSystem)
        addMapping(for: .environmentalAudioExposure, code: "dB(SPL)", unitString: "dB(SPL)", system: .unitsOfMeasureSystem)
        addMapping(for: .environmentalSoundReduction, code: "dB(HL)", unitString: "dB(HL)", system: .unitsOfMeasureSystem)
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            addMapping(for: .estimatedWorkoutEffortScore, code: nil, unitString: "effort", system: nil)
        }
        addMapping(for: .heartRateRecoveryOneMinute, code: "/min", unitString: "beats/minute", system: .unitsOfMeasureSystem)
        addMapping(
            for: .flightsClimbed,
            extraCodings: [
                Coding(
                    code: "100304-5",
                    display: "Flights climbed [#] Reporting Period",
                    system: .loincSystem
                )
            ],
            code: nil,
            unitString: "flights",
            system: nil
        )
        addMapping(
            for: .forcedExpiratoryVolume1,
            extraCodings: [
                Coding(
                    code: "20150-9",
                    display: "FEV1",
                    system: .loincSystem
                )
            ],
            code: "L",
            unitString: "L",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .forcedVitalCapacity,
            extraCodings: [
                Coding(
                    code: "19870-5",
                    display: "Forced vital capacity [Volume] Respiratory system",
                    system: .loincSystem
                )
            ],
            code: "L",
            unitString: "L",
            system: .unitsOfMeasureSystem
        )
        addMapping(for: .headphoneAudioExposure, code: "dB(SPL)", unitString: "dB(SPL)", system: .unitsOfMeasureSystem)
        addMapping(
            for: .heartRate,
            extraCodings: [
                Coding(
                    code: "8867-4",
                    display: "Heart rate",
                    system: .loincSystem
                ),
                Coding(
                    code: "364075005",
                    display: "Heart rate",
                    system: .snomedCT
                )
            ],
            code: "/min",
            unitString: "beats/minute",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .heartRateVariabilitySDNN,
            extraCodings: [
                Coding(
                    code: "80404-7",
                    display: "R-R interval.standard deviation (Heart rate variability)",
                    system: .loincSystem
                )
            ],
            code: "ms",
            unitString: "ms",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .height,
            extraCodings: [
                Coding(
                    code: "8302-2",
                    display: "Body height",
                    system: .loincSystem
                ),
                Coding(
                    code: "50373000",
                    display: "Body height measure",
                    system: .snomedCT
                )
            ],
            code: "cm",
            unitString: "cm",
            system: .unitsOfMeasureSystem
        )
        addMapping(for: .inhalerUsage, code: nil, unitString: "count", system: nil)
        addMapping(for: .insulinDelivery, code: "IU", unitString: "IU", system: .unitsOfMeasureSystem)
        addMapping(
            for: .leanBodyMass,
            extraCodings: [
                Coding(
                    code: "91557-9",
                    display: "Lean body weight",
                    system: .loincSystem
                )
            ],
            code: "kg",
            unitString: "kg",
            system: .unitsOfMeasureSystem
        )
        addMapping(for: .nikeFuel, code: nil, unitString: "nikeFuel", system: nil)
        addMapping(for: .numberOfAlcoholicBeverages, code: nil, unitString: "beverages", system: nil)
        addMapping(for: .numberOfTimesFallen, code: nil, unitString: "falls", system: nil)
        addMapping(
            for: .bloodOxygen,
            extraCodings: [
                Coding(
                    code: "59408-5",
                    display: "Oxygen saturation in Arterial blood by Pulse oximetry",
                    system: .loincSystem
                ),
                Coding(
                    code: "431314004",
                    display: "Peripheral oxygen saturation",
                    system: .snomedCT
                )
            ],
            code: "%",
            unitString: "%",
            system: .unitsOfMeasureSystem
        )
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            addMapping(for: .paddleSportsSpeed, code: "m/s", unitString: "m/s", system: .unitsOfMeasureSystem)
        }
        addMapping(
            for: .peakExpiratoryFlowRate,
            extraCodings: [
                Coding(
                    code: "19935-6",
                    display: "Maximum expiratory gas flow Respiratory system airway by Peak flow meter",
                    system: .loincSystem
                )
            ],
            code: "L/min",
            unitString: "L/min",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .peripheralPerfusionIndex,
            extraCodings: [
                Coding(
                    code: "61006-3",
                    display: "Perfusion index Tissue by Pulse oximetry",
                    system: .loincSystem
                )
            ],
            code: "%",
            unitString: "%",
            system: .unitsOfMeasureSystem
        )
        addMapping(for: .physicalEffort, code: "kcal/hr/kg", unitString: "kcal/hr/kg", system: .unitsOfMeasureSystem)
        addMapping(
            for: .pushCount,
            extraCodings: [
                Coding(
                    code: "96502-0",
                    display: "Number of wheelchair pushes per time period",
                    system: .loincSystem
                )
            ],
            code: nil,
            unitString: "wheelchair pushes",
            system: nil
        )
        addMapping(
            for: .respiratoryRate,
            extraCodings: [
                Coding(
                    code: "9279-1",
                    display: "Respiratory rate",
                    system: .loincSystem
                ),
                Coding(
                    code: "86290005",
                    display: "Respiratory rate",
                    system: .snomedCT
                )
            ],
            code: "/min",
            unitString: "breaths/minute",
            system: .unitsOfMeasureSystem
        )
        addMapping(
            for: .restingHeartRate,
            extraCodings: [
                Coding(
                    code: "40443-4",
                    display: "Heart rate --resting",
                    system: .loincSystem
                )
            ],
            code: "/min",
            unitString: "beats/minute",
            system: .unitsOfMeasureSystem
        )
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            addMapping(for: .rowingSpeed, code: "m/s", unitString: "m/s", system: .unitsOfMeasureSystem)
        }
        addMapping(for: .runningGroundContactTime, code: "ms", unitString: "ms", system: .unitsOfMeasureSystem)
        addMapping(for: .runningPower, code: "W", unitString: "watt", system: .unitsOfMeasureSystem)
        addMapping(for: .runningSpeed, code: "km/h", unitString: "km/h", system: .unitsOfMeasureSystem)
        addMapping(for: .runningStrideLength, code: "m", unitString: "meters", system: .unitsOfMeasureSystem)
        addMapping(for: .runningVerticalOscillation, code: "m", unitString: "m", system: .unitsOfMeasureSystem)
        addMapping(
            for: .sixMinuteWalkTestDistance,
            extraCodings: [
                Coding(
                    code: "55430-3",
                    display: "6 minute walk test Distance",
                    system: .loincSystem
                )
            ],
            code: "m",
            unitString: "m",
            system: .unitsOfMeasureSystem
        )
        addMapping(for: .stairAscentSpeed, code: "m/s", unitString: "m/s", system: .unitsOfMeasureSystem)
        addMapping(for: .stairDescentSpeed, code: "m/s", unitString: "m/s", system: .unitsOfMeasureSystem)
        addMapping(
            for: .stepCount,
            extraCodings: [
                Coding(
                    code: "55423-8",
                    display: "Number of steps in unspecified time Pedometer",
                    system: .loincSystem
                )
            ],
            code: nil,
            unitString: "steps",
            system: nil
        )
        addMapping(for: .swimmingStrokeCount, code: nil, unitString: "strokes", system: nil)
        addMapping(for: .timeInDaylight, code: "min", unitString: "min", system: .unitsOfMeasureSystem)
        addMapping(for: .underwaterDepth, code: "m", unitString: "m", system: .unitsOfMeasureSystem)
        addMapping(for: .uvExposure, code: nil, unitString: "count", system: nil)
        // TODO surely this one has a LOINC?
        addMapping(for: .vo2Max, code: "mL/kg/min", unitString: "mL/kg/min", system: .unitsOfMeasureSystem)
        addMapping(
            for: .waistCircumference,
            extraCodings: [
                Coding(
                    code: "8280-0",
                    display: "Waist Circumference at umbilicus by Tape measure",
                    system: .loincSystem
                ),
                Coding(
                    code: "276361009",
                    display: "Waist circumference",
                    system: .snomedCT
                )
            ],
            code: "cm",
            unitString: "cm",
            system: .unitsOfMeasureSystem
        )
        addMapping(for: .walkingAsymmetryPercentage, code: "%", unitString: "%", system: .unitsOfMeasureSystem)
        addMapping(for: .walkingDoubleSupportPercentage, code: "%", unitString: "%", system: .unitsOfMeasureSystem)
        addMapping(for: .walkingHeartRateAverage, code: "/min", unitString: "beats/minute", system: .unitsOfMeasureSystem)
        addMapping(for: .walkingSpeed, code: "m/s", unitString: "m/s", system: .unitsOfMeasureSystem)
        addMapping(for: .walkingStepLength, code: "m", unitString: "m", system: .unitsOfMeasureSystem)
        addMapping(for: .waterTemperature, code: "Cel", unitString: "C", system: .unitsOfMeasureSystem)
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            addMapping(for: .workoutEffortScore, code: nil, unitString: "effort", system: nil)
        }
        return mapping
    }()
}
