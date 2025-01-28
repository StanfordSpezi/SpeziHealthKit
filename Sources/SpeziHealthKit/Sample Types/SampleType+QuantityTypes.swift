//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_length

import HealthKit


@inlinable func localeDependentUnit(
    us: @autoclosure () -> HKUnit, // swiftlint:disable:this identifier_name
    uk: @autoclosure () -> HKUnit? = nil, // swiftlint:disable:this identifier_name
    metric: @autoclosure () -> HKUnit
) -> HKUnit {
    switch Locale.current.measurementSystem {
    case .us: us()
    case .uk: uk() ?? metric()
    case .metric: metric()
    default: metric()
    }
}


// MARK: Activity

extension SampleType {
    /// A quantity sample type that measures the number of steps the user has taken.
    @inlinable public static var stepCount: SampleType<HKQuantitySample> {
        .quantity(
            .stepCount,
            displayTitle: "Step Count",
            displayUnit: .count()
        )
    }
    
    /// A quantity sample type that measures the distance the user has moved by walking or running.
    @inlinable public static var distanceWalkingRunning: SampleType<HKQuantitySample> {
        .quantity(
            .distanceWalkingRunning,
            displayTitle: "Walking + Running Distance",
            displayUnit: localeDependentUnit(us: .mile(), metric: .meterUnit(with: .kilo))
        )
    }
    
    /// A quantity sample type that measures the amount of time the runner’s foot is in contact with the ground while running.
    @inlinable public static var runningGroundContactTime: SampleType<HKQuantitySample> {
        .quantity(
            .runningGroundContactTime,
            displayTitle: "Ground Contact Time",
            displayUnit: .secondUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the rate of work required for the runner to maintain their speed.
    @inlinable public static var runningPower: SampleType<HKQuantitySample> {
        .quantity(
            .runningPower,
            displayTitle: "Running Power",
            displayUnit: .watt()
        )
    }
    
    /// A quantity sample type that measures the runner’s speed.
    @inlinable public static var runningSpeed: SampleType<HKQuantitySample> {
        .quantity(
            .runningSpeed,
            displayTitle: "Running Speed",
            displayUnit: localeDependentUnit(us: .mile() / .hour(), metric: .meterUnit(with: .kilo) / .hour())
        )
    }
    
    /// A quantity sample type that measures the distance covered by a single step while running.
    @inlinable public static var runningStrideLength: SampleType<HKQuantitySample> {
        .quantity(
            .runningStrideLength,
            displayTitle: "Running Stride Length",
            displayUnit: localeDependentUnit(us: .foot(), metric: .meter())
        )
    }
    
    /// A quantity sample type measuring pelvis vertical range of motion during a single running stride.
    @inlinable public static var runningVerticalOscillation: SampleType<HKQuantitySample> {
        .quantity(
            .runningVerticalOscillation,
            displayTitle: "Vertical Oscillation",
            displayUnit: localeDependentUnit(us: .inch(), metric: .meterUnit(with: .centi))
        )
    }
    
    /// A quantity sample type that measures the distance the user has moved by cycling.
    @inlinable public static var distanceCycling: SampleType<HKQuantitySample> {
        .quantity(
            .distanceCycling,
            displayTitle: "Cycling Distance",
            displayUnit: localeDependentUnit(us: .mile(), metric: .meterUnit(with: .kilo))
        )
    }
    
    /// A quantity sample type that measures the number of pushes that the user has performed while using a wheelchair.
    @inlinable public static var pushCount: SampleType<HKQuantitySample> {
        .quantity(
            .pushCount,
            displayTitle: "Pushes",
            displayUnit: .count()
        )
    }
    
    /// A quantity sample type that measures the distance the user has moved using a wheelchair.
    @inlinable public static var distanceWheelchair: SampleType<HKQuantitySample> {
        .quantity(
            .distanceWheelchair,
            displayTitle: "Wheelchair Distance",
            displayUnit: localeDependentUnit(us: .mile(), metric: .meterUnit(with: .kilo))
        )
    }
    
    /// A quantity sample type that measures the number of strokes performed while swimming.
    @inlinable public static var swimmingStrokeCount: SampleType<HKQuantitySample> {
        .quantity(
            .swimmingStrokeCount,
            displayTitle: "Swimming Strokes",
            displayUnit: .count()
        )
    }
    
    /// A quantity sample type that measures the distance the user has moved while swimming.
    @inlinable public static var distanceSwimming: SampleType<HKQuantitySample> {
        .quantity(
            .distanceSwimming,
            displayTitle: "Swimming Distance",
            displayUnit: localeDependentUnit(us: .yard(), uk: .yard(), metric: .meter())
        )
    }
    
    /// A quantity sample type that measures the distance the user has traveled while skiing or snowboarding.
    @inlinable public static var distanceDownhillSnowSports: SampleType<HKQuantitySample> {
        .quantity(
            .distanceDownhillSnowSports,
            displayTitle: "Downhill Snow Sports Distance",
            displayUnit: localeDependentUnit(us: .mile(), metric: .meterUnit(with: .kilo))
        )
    }
    
    /// A quantity sample type that measures the resting energy burned by the user.
    @inlinable public static var basalEnergyBurned: SampleType<HKQuantitySample> {
        .quantity(
            .basalEnergyBurned,
            displayTitle: "Resting Energy",
            displayUnit: .largeCalorie()
        )
    }
    
    /// A quantity sample type that measures the amount of active energy the user has burned.
    @inlinable public static var activeEnergyBurned: SampleType<HKQuantitySample> {
        .quantity(
            .activeEnergyBurned,
            displayTitle: "Active Energy",
            displayUnit: .largeCalorie()
        )
    }
    
    /// A quantity sample type that measures the number flights of stairs that the user has climbed.
    @inlinable public static var flightsClimbed: SampleType<HKQuantitySample> {
        .quantity(
            .flightsClimbed,
            displayTitle: "Flights Climbed",
            displayUnit: .count()
        )
    }
    
    /// A quantity sample type that measures the amount of time the user spent exercising.
    @inlinable public static var appleExerciseTime: SampleType<HKQuantitySample> {
        .quantity(
            .appleExerciseTime,
            displayTitle: "Exercise Minutes",
            displayUnit: .minute()
        )
    }
    
    /// A quantity sample type that measures the amount of time the user has spent performing activities that involve full-body movements during the specified day.
    @inlinable public static var appleMoveTime: SampleType<HKQuantitySample> {
        .quantity(
            .appleMoveTime,
            displayTitle: "Move Minutes",
            displayUnit: .minute()
        )
    }
    
    /// A quantity sample type that measures the amount of time the user has spent standing.
    @inlinable public static var appleStandTime: SampleType<HKQuantitySample> {
        .quantity(
            .appleStandTime,
            displayTitle: "Stand Hours",
            displayUnit: .hour()
        )
    }
    
    /// A quantity sample that measures the maximal oxygen consumption during exercise.
    @inlinable public static var vo2Max: SampleType<HKQuantitySample> {
        .quantity(
            .vo2Max,
            displayTitle: "VO₂ max",
            displayUnit: .literUnit(with: .milli) / (.gramUnit(with: .kilo) / .minute())
        )
    }
}


// MARK: Body Measurements

extension SampleType {
    /// A quantity sample type that measures the user’s height.
    @inlinable public static var height: SampleType<HKQuantitySample> {
        .quantity(
            .height,
            displayTitle: "Height",
            displayUnit: localeDependentUnit(us: .foot(), metric: .meter())
        )
    }
    
    /// A quantity sample type that measures the user’s weight.
    @inlinable public static var bodyMass: SampleType<HKQuantitySample> {
        .quantity(
            .bodyMass,
            displayTitle: "Body Mass",
            displayUnit: localeDependentUnit(us: .pound(), uk: .pound(), metric: .gramUnit(with: .kilo))
        )
    }
    
    /// A quantity sample type that measures the user’s body mass index.
    @inlinable public static var bodyMassIndex: SampleType<HKQuantitySample> {
        .quantity(
            .bodyMassIndex,
            displayTitle: "Body Mass Index",
            displayUnit: .count()
        )
    }
    
    /// A quantity sample type that measures the user’s lean body mass.
    @inlinable public static var leanBodyMass: SampleType<HKQuantitySample> {
        .quantity(
            .leanBodyMass,
            displayTitle: "Lean Body Mass",
            displayUnit: localeDependentUnit(us: .pound(), uk: .pound(), metric: .gramUnit(with: .kilo))
        )
    }
    
    /// A quantity sample type that measures the user’s body fat percentage.
    @inlinable public static var bodyFatPercentage: SampleType<HKQuantitySample> {
        .quantity(
            .bodyFatPercentage,
            displayTitle: "Body Fat Percentage",
            displayUnit: .percent()
        )
    }
    
    /// A quantity sample type that measures the user’s waist circumference.
    @inlinable public static var waistCircumference: SampleType<HKQuantitySample> {
        .quantity(
            .waistCircumference,
            displayTitle: "Waist Circumference",
            displayUnit: localeDependentUnit(us: .inch(), metric: .meterUnit(with: .centi))
        )
    }
    
    /// A quantity sample type that records the wrist temperature during sleep.
    @inlinable public static var appleSleepingWristTemperature: SampleType<HKQuantitySample> {
        .quantity(
            .appleSleepingWristTemperature,
            displayTitle: "Wrist Temperature",
            displayUnit: localeDependentUnit(us: .degreeFahrenheit(), metric: .degreeCelsius())
        )
    }
}


// MARK: Reproductive Health

extension SampleType {
    /// A quantity sample type that records the user’s basal body temperature.
    @inlinable public static var basalBodyTemperature: SampleType<HKQuantitySample> {
        .quantity(
            .basalBodyTemperature,
            displayTitle: "Basal Body Temperature",
            displayUnit: localeDependentUnit(us: .degreeFahrenheit(), metric: .degreeCelsius())
        )
    }
}


// MARK: Hearing

extension SampleType {
    /// A quantity sample type that measures audio exposure to sounds in the environment.
    @inlinable public static var environmentalAudioExposure: SampleType<HKQuantitySample> {
        .quantity(
            .environmentalAudioExposure,
            displayTitle: "Environmental Audio Exposure",
            displayUnit: .decibelHearingLevel()
        )
    }
    
    /// A quantity sample type that measures audio exposure from headphones.
    @inlinable public static var headphoneAudioExposure: SampleType<HKQuantitySample> {
        .quantity(
            .headphoneAudioExposure,
            displayTitle: "Headphone Audio Exposure",
            displayUnit: .decibelHearingLevel()
        )
    }
}


// MARK: Vital Signs

extension SampleType {
    /// A quantity sample type that measures the user’s heart rate.
    @inlinable public static var heartRate: SampleType<HKQuantitySample> {
        .quantity(
            .heartRate,
            displayTitle: "Heart Rate",
            displayUnit: .count() / .minute(),
            expectedValuesRange: 0...175
        )
    }
    
    /// A quantity sample type that measures the user’s resting heart rate.
    @inlinable public static var restingHeartRate: SampleType<HKQuantitySample> {
        .quantity(
            .restingHeartRate,
            displayTitle: "Resting Heart Rate",
            displayUnit: .count() / .minute()
        )
    }
    
    /// A quantity sample type that measures the user’s heart rate while walking.
    @inlinable public static var walkingHeartRateAverage: SampleType<HKQuantitySample> {
        .quantity(
            .walkingHeartRateAverage,
            displayTitle: "Walking Heart Rate Average",
            displayUnit: .count() / .minute()
        )
    }
    
    /// A quantity sample type that measures the standard deviation of heartbeat intervals.
    @inlinable public static var heartRateVariabilitySDNN: SampleType<HKQuantitySample> {
        .quantity(
            .heartRateVariabilitySDNN,
            displayTitle: "Heart Rate Variability",
            displayUnit: .secondUnit(with: .milli)
        )
    }
    
    /// A quantity sample that records the reduction in heart rate from the peak exercise rate to the rate one minute after exercising ended.
    @inlinable public static var heartRateRecoveryOneMinute: SampleType<HKQuantitySample> {
        .quantity(
            .heartRateRecoveryOneMinute,
            displayTitle: "Cardio Recovery",
            displayUnit: .count() / .minute() // might not be the correct unit; docs say count, but the health app seems to use BPM?
        )
    }
    
    /// A quantity type that measures an estimate of the percentage of time a person’s heart shows signs of atrial fibrillation (AFib) while wearing Apple Watch.
    @inlinable public static var atrialFibrillationBurden: SampleType<HKQuantitySample> {
        .quantity(
            .atrialFibrillationBurden,
            displayTitle: "Atrial Fibrillation",
            displayUnit: .percent()
        )
    }
    
    /// A quantity sample type that measures the user’s oxygen saturation.
    @inlinable public static var bloodOxygen: SampleType<HKQuantitySample> {
        .quantity(
            .oxygenSaturation,
            displayTitle: "Blood Oxygen",
            displayUnit: .percent(),
            expectedValuesRange: 80...105
        )
    }
    
    /// A quantity sample type that measures the user’s body temperature.
    @inlinable public static var bodyTemperature: SampleType<HKQuantitySample> {
        .quantity(
            .bodyTemperature,
            displayTitle: "Body Temperature",
            displayUnit: localeDependentUnit(us: .degreeFahrenheit(), metric: .degreeCelsius())
        )
    }
    
    /// A quantity sample type that measures the user’s diastolic blood pressure.
    @inlinable public static var bloodPressureDiastolic: SampleType<HKQuantitySample> {
        .quantity(
            .bloodPressureDiastolic,
            displayTitle: "Blood Pressure (Diastolic)",
            displayUnit: .millimeterOfMercury()
        )
    }
    
    /// A quantity sample type that measures the user’s systolic blood pressure.
    @inlinable public static var bloodPressureSystolic: SampleType<HKQuantitySample> {
        .quantity(
            .bloodPressureSystolic,
            displayTitle: "Blood Pressure (Systolic)",
            displayUnit: .millimeterOfMercury()
        )
    }
    
    /// A quantity sample type that measures the user’s respiratory rate.
    @inlinable public static var respiratoryRate: SampleType<HKQuantitySample> {
        .quantity(
            .respiratoryRate,
            displayTitle: "Respiratory Rate",
            displayUnit: .count() / .minute()
        )
    }
}


// MARK: Lab and Test Results

extension SampleType {
    /// A quantity sample type that measures the user’s blood glucose level.
    @inlinable public static var bloodGlucose: SampleType<HKQuantitySample> {
        .quantity(
            .bloodGlucose,
            displayTitle: "Blood Glucose",
            displayUnit: .gramUnit(with: .milli) / .literUnit(with: .deci)
        )
    }
    
    /// A quantity sample type that measures electrodermal activity.
    @inlinable public static var electrodermalActivity: SampleType<HKQuantitySample> {
        .quantity(
            .electrodermalActivity,
            displayTitle: "Electrodermal Activity",
            displayUnit: .siemenUnit(with: .micro)
        )
    }
    
    /// A quantity sample type that measures the amount of air that can be forcibly exhaled from the lungs during the first second of a forced exhalation.
    @inlinable public static var forcedExpiratoryVolume1: SampleType<HKQuantitySample> {
        .quantity(
            .forcedExpiratoryVolume1,
            displayTitle: "Forced Expiratory Volume, 1 sec",
            displayUnit: .liter()
        )
    }
    
    /// A quantity sample type that measures the amount of air that can be forcibly exhaled from the lungs after taking the deepest breath possible.
    @inlinable public static var forcedVitalCapacity: SampleType<HKQuantitySample> {
        .quantity(
            .forcedVitalCapacity,
            displayTitle: "Forced Vital Capacity",
            displayUnit: .liter()
        )
    }
    
    /// A quantity sample type that measures the number of puffs the user takes from their inhaler.
    @inlinable public static var inhalerUsage: SampleType<HKQuantitySample> {
        .quantity(
            .inhalerUsage,
            displayTitle: "Inhaler Usage",
            displayUnit: .count()
        )
    }
    
    /// A quantity sample that measures the amount of insulin delivered.
    @inlinable public static var insulinDelivery: SampleType<HKQuantitySample> {
        .quantity(
            .insulinDelivery,
            displayTitle: "Insulin Delivery",
            displayUnit: .internationalUnit()
        )
    }
    
    /// A quantity sample type that measures the number of times the user fell.
    @inlinable public static var numberOfTimesFallen: SampleType<HKQuantitySample> {
        .quantity(
            .numberOfTimesFallen,
            displayTitle: "Number of Times Fallen",
            displayUnit: .count()
        )
    }
    
    /// A quantity sample type that measures the user’s maximum flow rate generated during a forceful exhalation.
    @inlinable public static var peakExpiratoryFlowRate: SampleType<HKQuantitySample> {
        .quantity(
            .peakExpiratoryFlowRate,
            displayTitle: "Peak Expiratory Flow Rate",
            displayUnit: .liter() / .minute()
        )
    }
    
    /// A quantity sample type that measures the user’s peripheral perfusion index.
    @inlinable public static var peripheralPerfusionIndex: SampleType<HKQuantitySample> {
        .quantity(
            .peripheralPerfusionIndex,
            displayTitle: "Peripheral Perfusion Index",
            displayUnit: .percent()
        )
    }
}


// MARK: Nutrition

extension SampleType {
    /// A quantity sample type that measures the amount of biotin (vitamin B7) consumed.
    @inlinable public static var dietaryBiotin: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryBiotin,
            displayTitle: "Biotin",
            displayUnit: .gramUnit(with: .micro)
        )
    }
    
    /// A quantity sample type that measures the amount of caffeine consumed.
    @inlinable public static var dietaryCaffeine: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryCaffeine,
            displayTitle: "Caffeine",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of calcium consumed.
    @inlinable public static var dietaryCalcium: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryCalcium,
            displayTitle: "Calcium",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of carbohydrates consumed.
    @inlinable public static var dietaryCarbohydrates: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryCarbohydrates,
            displayTitle: "Carbohydrates",
            displayUnit: .gram()
        )
    }
    
    /// A quantity sample type that measures the amount of chloride consumed.
    @inlinable public static var dietaryChloride: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryChloride,
            displayTitle: "Chloride",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of cholesterol consumed.
    @inlinable public static var dietaryCholesterol: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryCholesterol,
            displayTitle: "Cholesterol",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of chromium consumed.
    @inlinable public static var dietaryChromium: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryChromium,
            displayTitle: "Chromium",
            displayUnit: .gramUnit(with: .micro)
        )
    }
    
    /// A quantity sample type that measures the amount of copper consumed.
    @inlinable public static var dietaryCopper: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryCopper,
            displayTitle: "Copper",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of energy consumed.
    @inlinable public static var dietaryEnergyConsumed: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryEnergyConsumed,
            displayTitle: "Dietary Energy Consumed",
            displayUnit: .largeCalorie()
        )
    }
    
    /// A quantity sample type that measures the amount of monounsaturated fat consumed.
    @inlinable public static var dietaryFatMonounsaturated: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryFatMonounsaturated,
            displayTitle: "Monounsaturated Fat",
            displayUnit: .gram()
        )
    }
    
    /// A quantity sample type that measures the amount of polyunsaturated fat consumed.
    @inlinable public static var dietaryFatPolyunsaturated: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryFatPolyunsaturated,
            displayTitle: "Polyunsaturated Fat",
            displayUnit: .gram()
        )
    }
    
    /// A quantity sample type that measures the amount of saturated fat consumed.
    @inlinable public static var dietaryFatSaturated: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryFatSaturated,
            displayTitle: "Saturated Fat",
            displayUnit: .gram()
        )
    }
    
    /// A quantity sample type that measures the total amount of fat consumed.
    @inlinable public static var dietaryFatTotal: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryFatTotal,
            displayTitle: "Total Fat",
            displayUnit: .gram()
        )
    }
    
    /// A quantity sample type that measures the amount of fiber consumed.
    @inlinable public static var dietaryFiber: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryFiber,
            displayTitle: "Fiber",
            displayUnit: .gram()
        )
    }
    
    /// A quantity sample type that measures the amount of folate (folic acid) consumed.
    @inlinable public static var dietaryFolate: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryFolate,
            displayTitle: "Folate",
            displayUnit: .gramUnit(with: .micro)
        )
    }
    
    /// A quantity sample type that measures the amount of iodine consumed.
    @inlinable public static var dietaryIodine: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryIodine,
            displayTitle: "Iodine",
            displayUnit: .gramUnit(with: .micro)
        )
    }
    
    /// A quantity sample type that measures the amount of iron consumed.
    @inlinable public static var dietaryIron: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryIron,
            displayTitle: "Iron",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of magnesium consumed.
    @inlinable public static var dietaryMagnesium: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryMagnesium,
            displayTitle: "Magnesium",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of manganese consumed.
    @inlinable public static var dietaryManganese: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryManganese,
            displayTitle: "Manganese",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of molybdenum consumed.
    @inlinable public static var dietaryMolybdenum: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryMolybdenum,
            displayTitle: "Molybdenum",
            displayUnit: .gramUnit(with: .micro)
        )
    }
    
    /// A quantity sample type that measures the amount of niacin (vitamin B3) consumed.
    @inlinable public static var dietaryNiacin: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryNiacin,
            displayTitle: "Niacin",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of pantothenic acid (vitamin B5) consumed.
    @inlinable public static var dietaryPantothenicAcid: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryPantothenicAcid,
            displayTitle: "Pantothenic Acid",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of phosphorus consumed.
    @inlinable public static var dietaryPhosphorus: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryPhosphorus,
            displayTitle: "Phosphorus",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of potassium consumed.
    @inlinable public static var dietaryPotassium: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryPotassium,
            displayTitle: "Potassium",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of protein consumed.
    @inlinable public static var dietaryProtein: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryProtein,
            displayTitle: "Protein",
            displayUnit: .gram()
        )
    }
    
    /// A quantity sample type that measures the amount of riboflavin (vitamin B2) consumed.
    @inlinable public static var dietaryRiboflavin: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryRiboflavin,
            displayTitle: "Riboflavin",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of selenium consumed.
    @inlinable public static var dietarySelenium: SampleType<HKQuantitySample> {
        .quantity(
            .dietarySelenium,
            displayTitle: "Selenium",
            displayUnit: .gramUnit(with: .micro)
        )
    }
    
    /// A quantity sample type that measures the amount of sodium consumed.
    @inlinable public static var dietarySodium: SampleType<HKQuantitySample> {
        .quantity(
            .dietarySodium,
            displayTitle: "Sodium",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of sugar consumed.
    @inlinable public static var dietarySugar: SampleType<HKQuantitySample> {
        .quantity(
            .dietarySugar,
            displayTitle: "Sugar",
            displayUnit: .gram()
        )
    }
    
    /// A quantity sample type that measures the amount of thiamin (vitamin B1) consumed.
    @inlinable public static var dietaryThiamin: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryThiamin,
            displayTitle: "Thiamin",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of vitamin A consumed.
    @inlinable public static var dietaryVitaminA: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryVitaminA,
            displayTitle: "Vitamin A",
            displayUnit: .gramUnit(with: .micro)
        )
    }
    
    /// A quantity sample type that measures the amount of cyanocobalamin (vitamin B12) consumed.
    @inlinable public static var dietaryVitaminB12: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryVitaminB12,
            displayTitle: "Vitamin B12",
            displayUnit: .gramUnit(with: .micro)
        )
    }
    
    /// A quantity sample type that measures the amount of pyridoxine (vitamin B6) consumed.
    @inlinable public static var dietaryVitaminB6: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryVitaminB6,
            displayTitle: "Vitamin B6",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of vitamin C consumed.
    @inlinable public static var dietaryVitaminC: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryVitaminC,
            displayTitle: "Vitamin C",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of vitamin D consumed.
    @inlinable public static var dietaryVitaminD: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryVitaminD,
            displayTitle: "Vitamin D",
            displayUnit: .gramUnit(with: .micro)
        )
    }
    
    /// A quantity sample type that measures the amount of vitamin E consumed.
    @inlinable public static var dietaryVitaminE: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryVitaminE,
            displayTitle: "Vitamin E",
            displayUnit: .gramUnit(with: .milli)
        )
    }
    
    /// A quantity sample type that measures the amount of vitamin K consumed.
    @inlinable public static var dietaryVitaminK: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryVitaminK,
            displayTitle: "Vitamin K",
            displayUnit: .gramUnit(with: .micro)
        )
    }
    
    /// A quantity sample type that measures the amount of water consumed.
    @inlinable public static var dietaryWater: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryWater,
            displayTitle: "Water",
            displayUnit: localeDependentUnit(us: .fluidOunceUS(), metric: .literUnit(with: .milli))
        )
    }
    
    /// A quantity sample type that measures the amount of zinc consumed.
    @inlinable public static var dietaryZinc: SampleType<HKQuantitySample> {
        .quantity(
            .dietaryZinc,
            displayTitle: "Zinc",
            displayUnit: .gramUnit(with: .milli)
        )
    }
}


// MARK: Alcohol Consumption

extension SampleType {
    /// A quantity sample type that measures the user’s blood alcohol content.
    @inlinable public static var bloodAlcoholContent: SampleType<HKQuantitySample> {
        .quantity(
            .bloodAlcoholContent,
            displayTitle: "Blood Alcohol Content",
            displayUnit: .percent()
        )
    }
    
    /// A quantity sample type that measures the number of standard alcoholic drinks that the user has consumed.
    @inlinable public static var numberOfAlcoholicBeverages: SampleType<HKQuantitySample> {
        .quantity(
            .numberOfAlcoholicBeverages,
            displayTitle: "Alcohol Consumption", // "Number of Alcoholic Beverages"?
            displayUnit: .count()
        )
    }
}


// MARK: Mobility

extension SampleType {
    /// A quantity sample type that measures the steadiness of the user’s gait.
    @inlinable public static var appleWalkingSteadiness: SampleType<HKQuantitySample> {
        .quantity(
            .appleWalkingSteadiness,
            displayTitle: "Walking Steadiness",
            displayUnit: .percent()
        )
    }
    
    /// A quantity sample type that stores the distance a user can walk during a six-minute walk test.
    @inlinable public static var sixMinuteWalkTestDistance: SampleType<HKQuantitySample> {
        .quantity(
            .sixMinuteWalkTestDistance,
            displayTitle: "Six-Minute Walk Distance",
            displayUnit: .meter()
        )
    }
    
    /// A quantity sample type that measures the user’s average speed when walking steadily over flat ground.
    @inlinable public static var walkingSpeed: SampleType<HKQuantitySample> {
        .quantity(
            .walkingSpeed,
            displayTitle: "Walking Speed",
            displayUnit: localeDependentUnit(us: .mile() / .hour(), metric: .meterUnit(with: .kilo) / .hour())
        )
    }
    
    /// A quantity sample type that measures the average length of the user’s step when walking steadily over flat ground.
    @inlinable public static var walkingStepLength: SampleType<HKQuantitySample> {
        .quantity(
            .walkingStepLength,
            displayTitle: "Walking Step Length",
            displayUnit: localeDependentUnit(us: .inch(), metric: .meterUnit(with: .centi))
        )
    }
    
    /// A quantity sample type that measures the percentage of steps in which one foot moves at a different speed than the other when walking on flat ground.
    @inlinable public static var walkingAsymmetryPercentage: SampleType<HKQuantitySample> {
        .quantity(
            .walkingAsymmetryPercentage,
            displayTitle: "Walking Asymmetry",
            displayUnit: .percent()
        )
    }
    
    /// A quantity sample type that measures the percentage of time when both of the user’s feet touch the ground while walking steadily over flat ground.
    @inlinable public static var walkingDoubleSupportPercentage: SampleType<HKQuantitySample> {
        .quantity(
            .walkingDoubleSupportPercentage,
            displayTitle: "Double Support Time",
            displayUnit: .percent()
        )
    }
    
    /// A quantity sample type measuring the user’s speed while climbing a flight of stairs.
    @inlinable public static var stairAscentSpeed: SampleType<HKQuantitySample> {
        .quantity(
            .stairAscentSpeed,
            displayTitle: "Stair Speed (Up)",
            displayUnit: localeDependentUnit(us: .foot() / .second(), metric: .meter() / .second())
        )
    }
    
    /// A quantity sample type measuring the user’s speed while descending a flight of stairs.
    @inlinable public static var stairDescentSpeed: SampleType<HKQuantitySample> {
        .quantity(
            .stairDescentSpeed,
            displayTitle: "Stair Speed (Down)",
            displayUnit: localeDependentUnit(us: .foot() / .second(), metric: .meter() / .second())
        )
    }
}


// MARK: UV Exposure

extension SampleType {
    /// A quantity sample type that measures the user’s exposure to UV radiation.
    @inlinable public static var uvExposure: SampleType<HKQuantitySample> {
        .quantity(
            .uvExposure,
            displayTitle: "UV Index",
            displayUnit: .count()
        )
    }
}


// MARK: Diving

extension SampleType {
    /// A quantity sample that records a person’s depth underwater.
    @inlinable public static var underwaterDepth: SampleType<HKQuantitySample> {
        .quantity(
            .underwaterDepth,
            displayTitle: "Underwater Depth",
            displayUnit: localeDependentUnit(us: .foot(), metric: .meter())
        )
    }
    /// A quantity sample that records the water temperature.
    @inlinable public static var waterTemperature: SampleType<HKQuantitySample> {
        .quantity(
            .waterTemperature,
            displayTitle: "Water Temperature",
            displayUnit: localeDependentUnit(us: .degreeFahrenheit(), metric: .degreeCelsius())
        )
    }
}

// swiftlint:enable file_length
