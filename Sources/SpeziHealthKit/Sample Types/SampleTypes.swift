//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


// NOTE: This file was automatically generated and should not be edited.
// swiftlint:disable all

import HealthKit


/// Selects one of the specified units, based on the current locale.
@inlinable func localeDependentUnit(
    us: @autoclosure () -> HKUnit,
    uk: @autoclosure () -> HKUnit? = nil,
    metric: @autoclosure () -> HKUnit
) -> HKUnit {
    switch Locale.current.measurementSystem {
    case .us: us()
    case .uk: uk() ?? metric()
    case .metric: metric()
    default: metric()
    }
}



// MARK: Quantity Types

extension SampleType where Sample == HKQuantitySample {
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
            displayUnit: .literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute())
        )
    }
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
    /// A quantity sample type that records the user’s basal body temperature.
    @inlinable public static var basalBodyTemperature: SampleType<HKQuantitySample> {
        .quantity(
            .basalBodyTemperature,
            displayTitle: "Basal Body Temperature",
            displayUnit: localeDependentUnit(us: .degreeFahrenheit(), metric: .degreeCelsius())
        )
    }
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
            displayUnit: .count() / .minute()
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
            displayTitle: "Alcohol Consumption",
            displayUnit: .count()
        )
    }
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
    /// A quantity sample type that measures the user’s exposure to UV radiation.
    @inlinable public static var uvExposure: SampleType<HKQuantitySample> {
        .quantity(
            .uvExposure,
            displayTitle: "UV Index",
            displayUnit: .count()
        )
    }
    /// A quantity sample that records a person’s depth underwater.
    @inlinable public static var underwaterDepth: SampleType<HKQuantitySample> {
        .quantity(
            .underwaterDepth,
            displayTitle: "Underwater Depth",
            displayUnit: localeDependentUnit(us: .foot(), metric: .meter())
        )
    }
    ///  A quantity sample that records the water temperature.
    @inlinable public static var waterTemperature: SampleType<HKQuantitySample> {
        .quantity(
            .waterTemperature,
            displayTitle: "Water Temperature",
            displayUnit: localeDependentUnit(us: .degreeFahrenheit(), metric: .degreeCelsius())
        )
    }
    /// A quantity sample that records breathing disturbances during sleep.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var appleSleepingBreathingDisturbances: SampleType<HKQuantitySample> {
        .quantity(
            .appleSleepingBreathingDisturbances,
            displayTitle: "Sleeping Breathing Disturbances",
            displayUnit: .count()
        )
    }
    /// A quantity sample that records cross-country skiing speed.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var crossCountrySkiingSpeed: SampleType<HKQuantitySample> {
        .quantity(
            .crossCountrySkiingSpeed,
            displayTitle: "Cross-Country Skiing Speed",
            displayUnit: localeDependentUnit(us: .mile() / .hour(), metric: .meterUnit(with: .kilo) / .hour())
        )
    }
    /// A quantity sample that records cycling cadence.
    @inlinable public static var cyclingCadence: SampleType<HKQuantitySample> {
        .quantity(
            .cyclingCadence,
            displayTitle: "Cycling Cadence",
            displayUnit: .count() / .minute()
        )
    }
    /// A quantity sample that records cycling functional threshold power.
    @inlinable public static var cyclingFunctionalThresholdPower: SampleType<HKQuantitySample> {
        .quantity(
            .cyclingFunctionalThresholdPower,
            displayTitle: "Cycling Functional Threshold Power",
            displayUnit: .watt()
        )
    }
    /// A quantity sample that records cycling power.
    @inlinable public static var cyclingPower: SampleType<HKQuantitySample> {
        .quantity(
            .cyclingPower,
            displayTitle: "Cycling Power",
            displayUnit: .watt()
        )
    }
    /// A quantity sample that records cycling speed.
    @inlinable public static var cyclingSpeed: SampleType<HKQuantitySample> {
        .quantity(
            .cyclingSpeed,
            displayTitle: "Cycling Speed",
            displayUnit: localeDependentUnit(us: .mile() / .hour(), metric: .meterUnit(with: .kilo) / .hour())
        )
    }
    /// A quantity sample that records cross-country skiing distance.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var distanceCrossCountrySkiing: SampleType<HKQuantitySample> {
        .quantity(
            .distanceCrossCountrySkiing,
            displayTitle: "Cross-Country Skiing Distance",
            displayUnit: localeDependentUnit(us: .mile(), metric: .meterUnit(with: .kilo))
        )
    }
    /// A quantity sample that records paddle sports distance.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var distancePaddleSports: SampleType<HKQuantitySample> {
        .quantity(
            .distancePaddleSports,
            displayTitle: "Paddle Sports Distance",
            displayUnit: localeDependentUnit(us: .mile(), metric: .meterUnit(with: .kilo))
        )
    }
    /// A quantity sample that records rowing distance.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var distanceRowing: SampleType<HKQuantitySample> {
        .quantity(
            .distanceRowing,
            displayTitle: "Rowing Distance",
            displayUnit: localeDependentUnit(us: .mile(), metric: .meterUnit(with: .kilo))
        )
    }
    /// A quantity sample that records skating sports distance.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var distanceSkatingSports: SampleType<HKQuantitySample> {
        .quantity(
            .distanceSkatingSports,
            displayTitle: "Skating Sports Distance",
            displayUnit: localeDependentUnit(us: .mile(), metric: .meterUnit(with: .kilo))
        )
    }
    /// A quantity sample that records environmental sound reduction.
    @inlinable public static var environmentalSoundReduction: SampleType<HKQuantitySample> {
        .quantity(
            .environmentalSoundReduction,
            displayTitle: "Environmental Sound Reduction",
            displayUnit: .decibelHearingLevel()
        )
    }
    /// A quantity sample that records estimated physical effort during workouts.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var estimatedWorkoutEffortScore: SampleType<HKQuantitySample> {
        .quantity(
            .estimatedWorkoutEffortScore,
            displayTitle: "Estimated Workout Effort Score",
            displayUnit: .count()
        )
    }
    /// A quantity sample that records paddle sports speed.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var paddleSportsSpeed: SampleType<HKQuantitySample> {
        .quantity(
            .paddleSportsSpeed,
            displayTitle: "Paddle Sports Speed",
            displayUnit: localeDependentUnit(us: .mile() / .hour(), metric: .meterUnit(with: .kilo) / .hour())
        )
    }
    /// A quantity sample that records physical effort.
    @inlinable public static var physicalEffort: SampleType<HKQuantitySample> {
        .quantity(
            .physicalEffort,
            displayTitle: "Physical Effort",
            displayUnit: .kilocalorie() / (.gramUnit(with: .kilo) * .hour())
        )
    }
    /// A quantity sample that records rowing speed.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var rowingSpeed: SampleType<HKQuantitySample> {
        .quantity(
            .rowingSpeed,
            displayTitle: "Rowing Speed",
            displayUnit: localeDependentUnit(us: .mile() / .hour(), metric: .meterUnit(with: .kilo) / .hour())
        )
    }
    /// A quantity sample that records time spent in daylight.
    @inlinable public static var timeInDaylight: SampleType<HKQuantitySample> {
        .quantity(
            .timeInDaylight,
            displayTitle: "Time In Daylight",
            displayUnit: .minute()
        )
    }
    /// A quantity sample that records workout effort.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var workoutEffortScore: SampleType<HKQuantitySample> {
        .quantity(
            .workoutEffortScore,
            displayTitle: "Workout Effort Score",
            displayUnit: .count()
        )
    }

    /// Returns the shared Quantity type for the specified identifier.
    public init?(_ identifier: HKQuantityTypeIdentifier) where Sample == HKQuantitySample {
        if identifier == .stepCount {
            self = .stepCount
        } else if identifier == .distanceWalkingRunning {
            self = .distanceWalkingRunning
        } else if identifier == .runningGroundContactTime {
            self = .runningGroundContactTime
        } else if identifier == .runningPower {
            self = .runningPower
        } else if identifier == .runningSpeed {
            self = .runningSpeed
        } else if identifier == .runningStrideLength {
            self = .runningStrideLength
        } else if identifier == .runningVerticalOscillation {
            self = .runningVerticalOscillation
        } else if identifier == .distanceCycling {
            self = .distanceCycling
        } else if identifier == .pushCount {
            self = .pushCount
        } else if identifier == .distanceWheelchair {
            self = .distanceWheelchair
        } else if identifier == .swimmingStrokeCount {
            self = .swimmingStrokeCount
        } else if identifier == .distanceSwimming {
            self = .distanceSwimming
        } else if identifier == .distanceDownhillSnowSports {
            self = .distanceDownhillSnowSports
        } else if identifier == .basalEnergyBurned {
            self = .basalEnergyBurned
        } else if identifier == .activeEnergyBurned {
            self = .activeEnergyBurned
        } else if identifier == .flightsClimbed {
            self = .flightsClimbed
        } else if identifier == .appleExerciseTime {
            self = .appleExerciseTime
        } else if identifier == .appleMoveTime {
            self = .appleMoveTime
        } else if identifier == .appleStandTime {
            self = .appleStandTime
        } else if identifier == .vo2Max {
            self = .vo2Max
        } else if identifier == .height {
            self = .height
        } else if identifier == .bodyMass {
            self = .bodyMass
        } else if identifier == .bodyMassIndex {
            self = .bodyMassIndex
        } else if identifier == .leanBodyMass {
            self = .leanBodyMass
        } else if identifier == .bodyFatPercentage {
            self = .bodyFatPercentage
        } else if identifier == .waistCircumference {
            self = .waistCircumference
        } else if identifier == .appleSleepingWristTemperature {
            self = .appleSleepingWristTemperature
        } else if identifier == .basalBodyTemperature {
            self = .basalBodyTemperature
        } else if identifier == .environmentalAudioExposure {
            self = .environmentalAudioExposure
        } else if identifier == .headphoneAudioExposure {
            self = .headphoneAudioExposure
        } else if identifier == .heartRate {
            self = .heartRate
        } else if identifier == .restingHeartRate {
            self = .restingHeartRate
        } else if identifier == .walkingHeartRateAverage {
            self = .walkingHeartRateAverage
        } else if identifier == .heartRateVariabilitySDNN {
            self = .heartRateVariabilitySDNN
        } else if identifier == .heartRateRecoveryOneMinute {
            self = .heartRateRecoveryOneMinute
        } else if identifier == .atrialFibrillationBurden {
            self = .atrialFibrillationBurden
        } else if identifier == .oxygenSaturation {
            self = .bloodOxygen
        } else if identifier == .bodyTemperature {
            self = .bodyTemperature
        } else if identifier == .bloodPressureDiastolic {
            self = .bloodPressureDiastolic
        } else if identifier == .bloodPressureSystolic {
            self = .bloodPressureSystolic
        } else if identifier == .respiratoryRate {
            self = .respiratoryRate
        } else if identifier == .bloodGlucose {
            self = .bloodGlucose
        } else if identifier == .electrodermalActivity {
            self = .electrodermalActivity
        } else if identifier == .forcedExpiratoryVolume1 {
            self = .forcedExpiratoryVolume1
        } else if identifier == .forcedVitalCapacity {
            self = .forcedVitalCapacity
        } else if identifier == .inhalerUsage {
            self = .inhalerUsage
        } else if identifier == .insulinDelivery {
            self = .insulinDelivery
        } else if identifier == .numberOfTimesFallen {
            self = .numberOfTimesFallen
        } else if identifier == .peakExpiratoryFlowRate {
            self = .peakExpiratoryFlowRate
        } else if identifier == .peripheralPerfusionIndex {
            self = .peripheralPerfusionIndex
        } else if identifier == .dietaryBiotin {
            self = .dietaryBiotin
        } else if identifier == .dietaryCaffeine {
            self = .dietaryCaffeine
        } else if identifier == .dietaryCalcium {
            self = .dietaryCalcium
        } else if identifier == .dietaryCarbohydrates {
            self = .dietaryCarbohydrates
        } else if identifier == .dietaryChloride {
            self = .dietaryChloride
        } else if identifier == .dietaryCholesterol {
            self = .dietaryCholesterol
        } else if identifier == .dietaryChromium {
            self = .dietaryChromium
        } else if identifier == .dietaryCopper {
            self = .dietaryCopper
        } else if identifier == .dietaryEnergyConsumed {
            self = .dietaryEnergyConsumed
        } else if identifier == .dietaryFatMonounsaturated {
            self = .dietaryFatMonounsaturated
        } else if identifier == .dietaryFatPolyunsaturated {
            self = .dietaryFatPolyunsaturated
        } else if identifier == .dietaryFatSaturated {
            self = .dietaryFatSaturated
        } else if identifier == .dietaryFatTotal {
            self = .dietaryFatTotal
        } else if identifier == .dietaryFiber {
            self = .dietaryFiber
        } else if identifier == .dietaryFolate {
            self = .dietaryFolate
        } else if identifier == .dietaryIodine {
            self = .dietaryIodine
        } else if identifier == .dietaryIron {
            self = .dietaryIron
        } else if identifier == .dietaryMagnesium {
            self = .dietaryMagnesium
        } else if identifier == .dietaryManganese {
            self = .dietaryManganese
        } else if identifier == .dietaryMolybdenum {
            self = .dietaryMolybdenum
        } else if identifier == .dietaryNiacin {
            self = .dietaryNiacin
        } else if identifier == .dietaryPantothenicAcid {
            self = .dietaryPantothenicAcid
        } else if identifier == .dietaryPhosphorus {
            self = .dietaryPhosphorus
        } else if identifier == .dietaryPotassium {
            self = .dietaryPotassium
        } else if identifier == .dietaryProtein {
            self = .dietaryProtein
        } else if identifier == .dietaryRiboflavin {
            self = .dietaryRiboflavin
        } else if identifier == .dietarySelenium {
            self = .dietarySelenium
        } else if identifier == .dietarySodium {
            self = .dietarySodium
        } else if identifier == .dietarySugar {
            self = .dietarySugar
        } else if identifier == .dietaryThiamin {
            self = .dietaryThiamin
        } else if identifier == .dietaryVitaminA {
            self = .dietaryVitaminA
        } else if identifier == .dietaryVitaminB12 {
            self = .dietaryVitaminB12
        } else if identifier == .dietaryVitaminB6 {
            self = .dietaryVitaminB6
        } else if identifier == .dietaryVitaminC {
            self = .dietaryVitaminC
        } else if identifier == .dietaryVitaminD {
            self = .dietaryVitaminD
        } else if identifier == .dietaryVitaminE {
            self = .dietaryVitaminE
        } else if identifier == .dietaryVitaminK {
            self = .dietaryVitaminK
        } else if identifier == .dietaryWater {
            self = .dietaryWater
        } else if identifier == .dietaryZinc {
            self = .dietaryZinc
        } else if identifier == .bloodAlcoholContent {
            self = .bloodAlcoholContent
        } else if identifier == .numberOfAlcoholicBeverages {
            self = .numberOfAlcoholicBeverages
        } else if identifier == .appleWalkingSteadiness {
            self = .appleWalkingSteadiness
        } else if identifier == .sixMinuteWalkTestDistance {
            self = .sixMinuteWalkTestDistance
        } else if identifier == .walkingSpeed {
            self = .walkingSpeed
        } else if identifier == .walkingStepLength {
            self = .walkingStepLength
        } else if identifier == .walkingAsymmetryPercentage {
            self = .walkingAsymmetryPercentage
        } else if identifier == .walkingDoubleSupportPercentage {
            self = .walkingDoubleSupportPercentage
        } else if identifier == .stairAscentSpeed {
            self = .stairAscentSpeed
        } else if identifier == .stairDescentSpeed {
            self = .stairDescentSpeed
        } else if identifier == .uvExposure {
            self = .uvExposure
        } else if identifier == .underwaterDepth {
            self = .underwaterDepth
        } else if identifier == .waterTemperature {
            self = .waterTemperature
        } else if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *), identifier == .appleSleepingBreathingDisturbances {
            self = .appleSleepingBreathingDisturbances
        } else if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *), identifier == .crossCountrySkiingSpeed {
            self = .crossCountrySkiingSpeed
        } else if identifier == .cyclingCadence {
            self = .cyclingCadence
        } else if identifier == .cyclingFunctionalThresholdPower {
            self = .cyclingFunctionalThresholdPower
        } else if identifier == .cyclingPower {
            self = .cyclingPower
        } else if identifier == .cyclingSpeed {
            self = .cyclingSpeed
        } else if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *), identifier == .distanceCrossCountrySkiing {
            self = .distanceCrossCountrySkiing
        } else if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *), identifier == .distancePaddleSports {
            self = .distancePaddleSports
        } else if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *), identifier == .distanceRowing {
            self = .distanceRowing
        } else if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *), identifier == .distanceSkatingSports {
            self = .distanceSkatingSports
        } else if identifier == .environmentalSoundReduction {
            self = .environmentalSoundReduction
        } else if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *), identifier == .estimatedWorkoutEffortScore {
            self = .estimatedWorkoutEffortScore
        } else if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *), identifier == .paddleSportsSpeed {
            self = .paddleSportsSpeed
        } else if identifier == .physicalEffort {
            self = .physicalEffort
        } else if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *), identifier == .rowingSpeed {
            self = .rowingSpeed
        } else if identifier == .timeInDaylight {
            self = .timeInDaylight
        } else if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *), identifier == .workoutEffortScore {
            self = .workoutEffortScore
        } else {
            return nil
        }
    }
}

extension HKQuantityType {
    /// All well-known `HKQuantityType`s
    public static let allKnownQuantities: Set<HKQuantityType> = Set(
        HKQuantityTypeIdentifier.allKnownIdentifiers.map { HKQuantityType($0) }
    )
}

extension HKQuantityTypeIdentifier {
    /// All well-known `HKQuantityTypeIdentifier`s
    public static let allKnownIdentifiers: Set<HKQuantityTypeIdentifier> = {
        var identifiers = Set<HKQuantityTypeIdentifier>()
        identifiers.insert(Self.stepCount)
        identifiers.insert(Self.distanceWalkingRunning)
        identifiers.insert(Self.runningGroundContactTime)
        identifiers.insert(Self.runningPower)
        identifiers.insert(Self.runningSpeed)
        identifiers.insert(Self.runningStrideLength)
        identifiers.insert(Self.runningVerticalOscillation)
        identifiers.insert(Self.distanceCycling)
        identifiers.insert(Self.pushCount)
        identifiers.insert(Self.distanceWheelchair)
        identifiers.insert(Self.swimmingStrokeCount)
        identifiers.insert(Self.distanceSwimming)
        identifiers.insert(Self.distanceDownhillSnowSports)
        identifiers.insert(Self.basalEnergyBurned)
        identifiers.insert(Self.activeEnergyBurned)
        identifiers.insert(Self.flightsClimbed)
        identifiers.insert(Self.appleExerciseTime)
        identifiers.insert(Self.appleMoveTime)
        identifiers.insert(Self.appleStandTime)
        identifiers.insert(Self.vo2Max)
        identifiers.insert(Self.height)
        identifiers.insert(Self.bodyMass)
        identifiers.insert(Self.bodyMassIndex)
        identifiers.insert(Self.leanBodyMass)
        identifiers.insert(Self.bodyFatPercentage)
        identifiers.insert(Self.waistCircumference)
        identifiers.insert(Self.appleSleepingWristTemperature)
        identifiers.insert(Self.basalBodyTemperature)
        identifiers.insert(Self.environmentalAudioExposure)
        identifiers.insert(Self.headphoneAudioExposure)
        identifiers.insert(Self.heartRate)
        identifiers.insert(Self.restingHeartRate)
        identifiers.insert(Self.walkingHeartRateAverage)
        identifiers.insert(Self.heartRateVariabilitySDNN)
        identifiers.insert(Self.heartRateRecoveryOneMinute)
        identifiers.insert(Self.atrialFibrillationBurden)
        identifiers.insert(Self.oxygenSaturation)
        identifiers.insert(Self.bodyTemperature)
        identifiers.insert(Self.bloodPressureDiastolic)
        identifiers.insert(Self.bloodPressureSystolic)
        identifiers.insert(Self.respiratoryRate)
        identifiers.insert(Self.bloodGlucose)
        identifiers.insert(Self.electrodermalActivity)
        identifiers.insert(Self.forcedExpiratoryVolume1)
        identifiers.insert(Self.forcedVitalCapacity)
        identifiers.insert(Self.inhalerUsage)
        identifiers.insert(Self.insulinDelivery)
        identifiers.insert(Self.numberOfTimesFallen)
        identifiers.insert(Self.peakExpiratoryFlowRate)
        identifiers.insert(Self.peripheralPerfusionIndex)
        identifiers.insert(Self.dietaryBiotin)
        identifiers.insert(Self.dietaryCaffeine)
        identifiers.insert(Self.dietaryCalcium)
        identifiers.insert(Self.dietaryCarbohydrates)
        identifiers.insert(Self.dietaryChloride)
        identifiers.insert(Self.dietaryCholesterol)
        identifiers.insert(Self.dietaryChromium)
        identifiers.insert(Self.dietaryCopper)
        identifiers.insert(Self.dietaryEnergyConsumed)
        identifiers.insert(Self.dietaryFatMonounsaturated)
        identifiers.insert(Self.dietaryFatPolyunsaturated)
        identifiers.insert(Self.dietaryFatSaturated)
        identifiers.insert(Self.dietaryFatTotal)
        identifiers.insert(Self.dietaryFiber)
        identifiers.insert(Self.dietaryFolate)
        identifiers.insert(Self.dietaryIodine)
        identifiers.insert(Self.dietaryIron)
        identifiers.insert(Self.dietaryMagnesium)
        identifiers.insert(Self.dietaryManganese)
        identifiers.insert(Self.dietaryMolybdenum)
        identifiers.insert(Self.dietaryNiacin)
        identifiers.insert(Self.dietaryPantothenicAcid)
        identifiers.insert(Self.dietaryPhosphorus)
        identifiers.insert(Self.dietaryPotassium)
        identifiers.insert(Self.dietaryProtein)
        identifiers.insert(Self.dietaryRiboflavin)
        identifiers.insert(Self.dietarySelenium)
        identifiers.insert(Self.dietarySodium)
        identifiers.insert(Self.dietarySugar)
        identifiers.insert(Self.dietaryThiamin)
        identifiers.insert(Self.dietaryVitaminA)
        identifiers.insert(Self.dietaryVitaminB12)
        identifiers.insert(Self.dietaryVitaminB6)
        identifiers.insert(Self.dietaryVitaminC)
        identifiers.insert(Self.dietaryVitaminD)
        identifiers.insert(Self.dietaryVitaminE)
        identifiers.insert(Self.dietaryVitaminK)
        identifiers.insert(Self.dietaryWater)
        identifiers.insert(Self.dietaryZinc)
        identifiers.insert(Self.bloodAlcoholContent)
        identifiers.insert(Self.numberOfAlcoholicBeverages)
        identifiers.insert(Self.appleWalkingSteadiness)
        identifiers.insert(Self.sixMinuteWalkTestDistance)
        identifiers.insert(Self.walkingSpeed)
        identifiers.insert(Self.walkingStepLength)
        identifiers.insert(Self.walkingAsymmetryPercentage)
        identifiers.insert(Self.walkingDoubleSupportPercentage)
        identifiers.insert(Self.stairAscentSpeed)
        identifiers.insert(Self.stairDescentSpeed)
        identifiers.insert(Self.uvExposure)
        identifiers.insert(Self.underwaterDepth)
        identifiers.insert(Self.waterTemperature)
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            identifiers.insert(Self.appleSleepingBreathingDisturbances)
        }
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            identifiers.insert(Self.crossCountrySkiingSpeed)
        }
        identifiers.insert(Self.cyclingCadence)
        identifiers.insert(Self.cyclingFunctionalThresholdPower)
        identifiers.insert(Self.cyclingPower)
        identifiers.insert(Self.cyclingSpeed)
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            identifiers.insert(Self.distanceCrossCountrySkiing)
        }
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            identifiers.insert(Self.distancePaddleSports)
        }
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            identifiers.insert(Self.distanceRowing)
        }
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            identifiers.insert(Self.distanceSkatingSports)
        }
        identifiers.insert(Self.environmentalSoundReduction)
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            identifiers.insert(Self.estimatedWorkoutEffortScore)
        }
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            identifiers.insert(Self.paddleSportsSpeed)
        }
        identifiers.insert(Self.physicalEffort)
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            identifiers.insert(Self.rowingSpeed)
        }
        identifiers.insert(Self.timeInDaylight)
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            identifiers.insert(Self.workoutEffortScore)
        }
        return identifiers
    }()
}

// MARK: Category Types

extension SampleType where Sample == HKCategorySample {
    /// A category sample type that counts the number of hours in the day during which the user has stood and moved for at least one minute per hour.
    @inlinable public static var appleStandHour: SampleType<HKCategorySample> {
        .category(
            .appleStandHour,
            displayTitle: "Stand Hours"
        )
    }
    /// An event that indicates the user’s VO2 max values consistently fall below a particular aerobic fitness threshold.
    @inlinable public static var lowCardioFitnessEvent: SampleType<HKCategorySample> {
        .category(
            .lowCardioFitnessEvent,
            displayTitle: "Low Cardio Fitness Event"
        )
    }
    /// A category sample type that records menstrual cycles.
    @inlinable public static var menstrualFlow: SampleType<HKCategorySample> {
        .category(
            .menstrualFlow,
            displayTitle: "Menstrual Cycles"
        )
    }
    /// A category sample type that records spotting outside the normal menstruation period.
    @inlinable public static var intermenstrualBleeding: SampleType<HKCategorySample> {
        .category(
            .intermenstrualBleeding,
            displayTitle: "Spotting"
        )
    }
    /// A category sample that indicates an infrequent menstrual cycle.
    @inlinable public static var infrequentMenstrualCycles: SampleType<HKCategorySample> {
        .category(
            .infrequentMenstrualCycles,
            displayTitle: "Infrequent Periods"
        )
    }
    /// A category sample that indicates an irregular menstrual cycle.
    @inlinable public static var irregularMenstrualCycles: SampleType<HKCategorySample> {
        .category(
            .irregularMenstrualCycles,
            displayTitle: "Irregular Cycles"
        )
    }
    /// A category sample that indicates persistent intermenstrual bleeding.
    @inlinable public static var persistentIntermenstrualBleeding: SampleType<HKCategorySample> {
        .category(
            .persistentIntermenstrualBleeding,
            displayTitle: "Persistent Spotting"
        )
    }
    /// A category sample that indicates a prolonged menstrual cycle.
    @inlinable public static var prolongedMenstrualPeriods: SampleType<HKCategorySample> {
        .category(
            .prolongedMenstrualPeriods,
            displayTitle: "Prolonged Periods"
        )
    }
    /// A category sample type that records the quality of the user’s cervical mucus.
    @inlinable public static var cervicalMucusQuality: SampleType<HKCategorySample> {
        .category(
            .cervicalMucusQuality,
            displayTitle: "Cervical Mucus Quality"
        )
    }
    /// A category sample type that records the result of an ovulation home test.
    @inlinable public static var ovulationTestResult: SampleType<HKCategorySample> {
        .category(
            .ovulationTestResult,
            displayTitle: "Ovulation Test Result"
        )
    }
    /// A category type that represents the results from a home progesterone test.
    @inlinable public static var progesteroneTestResult: SampleType<HKCategorySample> {
        .category(
            .progesteroneTestResult,
            displayTitle: "Progesterone Test Result"
        )
    }
    /// A category sample type that records sexual activity.
    @inlinable public static var sexualActivity: SampleType<HKCategorySample> {
        .category(
            .sexualActivity,
            displayTitle: "Sexual Activity"
        )
    }
    /// A category sample type that records the use of contraceptives.
    @inlinable public static var contraceptive: SampleType<HKCategorySample> {
        .category(
            .contraceptive,
            displayTitle: "Contraceptives"
        )
    }
    /// A category type that records pregnancy.
    @inlinable public static var pregnancy: SampleType<HKCategorySample> {
        .category(
            .pregnancy,
            displayTitle: "Pregnancy"
        )
    }
    /// A category type that represents the results from a home pregnancy test.
    @inlinable public static var pregnancyTestResult: SampleType<HKCategorySample> {
        .category(
            .pregnancyTestResult,
            displayTitle: "Pregnancy Test Result"
        )
    }
    /// A category type that records lactation.
    @inlinable public static var lactation: SampleType<HKCategorySample> {
        .category(
            .lactation,
            displayTitle: "Lactation"
        )
    }
    /// A category sample type that records exposure to potentially damaging sounds from the environment.
    @inlinable public static var environmentalAudioExposureEvent: SampleType<HKCategorySample> {
        .category(
            .environmentalAudioExposureEvent,
            displayTitle: "Environmental Audio Exposure Event"
        )
    }
    /// A category sample type that records exposure to potentially damaging sounds from headphones.
    @inlinable public static var headphoneAudioExposureEvent: SampleType<HKCategorySample> {
        .category(
            .headphoneAudioExposureEvent,
            displayTitle: "Headphone Audio Exposure Event"
        )
    }
    /// A category sample type for low heart rate events.
    @inlinable public static var lowHeartRateEvent: SampleType<HKCategorySample> {
        .category(
            .lowHeartRateEvent,
            displayTitle: "Low Heart Rate Event"
        )
    }
    /// A category sample type for high heart rate events.
    @inlinable public static var highHeartRateEvent: SampleType<HKCategorySample> {
        .category(
            .highHeartRateEvent,
            displayTitle: "High Heart Rate Event"
        )
    }
    /// A category sample type for irregular heart rhythm events.
    @inlinable public static var irregularHeartRhythmEvent: SampleType<HKCategorySample> {
        .category(
            .irregularHeartRhythmEvent,
            displayTitle: "Irregular Heart Rythm Event"
        )
    }
    /// A category sample type that records an incident where the user showed a reduced score for their gait’s steadiness.
    @inlinable public static var appleWalkingSteadinessEvent: SampleType<HKCategorySample> {
        .category(
            .appleWalkingSteadinessEvent,
            displayTitle: "Walking Steadiness Event"
        )
    }
    /// A category sample type for recording a mindful session.
    @inlinable public static var mindfulSession: SampleType<HKCategorySample> {
        .category(
            .mindfulSession,
            displayTitle: "Mindful Session"
        )
    }
    /// A category sample type for sleep analysis information.
    @inlinable public static var sleepAnalysis: SampleType<HKCategorySample> {
        .category(
            .sleepAnalysis,
            displayTitle: "Sleep Analysis"
        )
    }
    /// A category sample type for toothbrushing events.
    @inlinable public static var toothbrushingEvent: SampleType<HKCategorySample> {
        .category(
            .toothbrushingEvent,
            displayTitle: "Toothbrushing Event"
        )
    }
    /// A category sample type for handwashing events.
    @inlinable public static var handwashingEvent: SampleType<HKCategorySample> {
        .category(
            .handwashingEvent,
            displayTitle: "Handwashing Event"
        )
    }
    /// A category type that records abdominal cramps as a symptom.
    @inlinable public static var abdominalCramps: SampleType<HKCategorySample> {
        .category(
            .abdominalCramps,
            displayTitle: "Abdominal Cramps"
        )
    }
    /// A category type that records bloating as a symptom.
    @inlinable public static var bloating: SampleType<HKCategorySample> {
        .category(
            .bloating,
            displayTitle: "Bloating"
        )
    }
    /// A category type that records constipation as a symptom.
    @inlinable public static var constipation: SampleType<HKCategorySample> {
        .category(
            .constipation,
            displayTitle: "Constipation"
        )
    }
    /// A category type that records diarrhea as a symptom.
    @inlinable public static var diarrhea: SampleType<HKCategorySample> {
        .category(
            .diarrhea,
            displayTitle: "Diarrhea"
        )
    }
    /// A category type that records heartburn as a symptom.
    @inlinable public static var heartburn: SampleType<HKCategorySample> {
        .category(
            .heartburn,
            displayTitle: "Heartburn"
        )
    }
    /// A category type that records nausea as a symptom.
    @inlinable public static var nausea: SampleType<HKCategorySample> {
        .category(
            .nausea,
            displayTitle: "Nausea"
        )
    }
    /// A category type that records vomiting as a symptom.
    @inlinable public static var vomiting: SampleType<HKCategorySample> {
        .category(
            .vomiting,
            displayTitle: "Vomiting"
        )
    }
    /// A category type that records changes in appetite as a symptom.
    @inlinable public static var appetiteChanges: SampleType<HKCategorySample> {
        .category(
            .appetiteChanges,
            displayTitle: "Appetite Changes"
        )
    }
    /// A category type that records chills as a symptom.
    @inlinable public static var chills: SampleType<HKCategorySample> {
        .category(
            .chills,
            displayTitle: "Chills"
        )
    }
    /// A category type that records dizziness as a symptom.
    @inlinable public static var dizziness: SampleType<HKCategorySample> {
        .category(
            .dizziness,
            displayTitle: "Dizziness"
        )
    }
    /// A category type that records fainting as a symptom.
    @inlinable public static var fainting: SampleType<HKCategorySample> {
        .category(
            .fainting,
            displayTitle: "Fainting"
        )
    }
    /// A category type that records fatigue as a symptom.
    @inlinable public static var fatigue: SampleType<HKCategorySample> {
        .category(
            .fatigue,
            displayTitle: "Fatigue"
        )
    }
    /// A category type that records fever as a symptom.
    @inlinable public static var fever: SampleType<HKCategorySample> {
        .category(
            .fever,
            displayTitle: "Fever"
        )
    }
    /// A category type that records body ache as a symptom.
    @inlinable public static var generalizedBodyAche: SampleType<HKCategorySample> {
        .category(
            .generalizedBodyAche,
            displayTitle: "Generalized Body Ache"
        )
    }
    /// A category type that records hot flashes as a symptom.
    @inlinable public static var hotFlashes: SampleType<HKCategorySample> {
        .category(
            .hotFlashes,
            displayTitle: "Hot Flashes"
        )
    }
    /// A category type that records chest tightness or pain as a symptom.
    @inlinable public static var chestTightnessOrPain: SampleType<HKCategorySample> {
        .category(
            .chestTightnessOrPain,
            displayTitle: "Chest Tightness or Pain"
        )
    }
    /// A category type that records coughing as a symptom.
    @inlinable public static var coughing: SampleType<HKCategorySample> {
        .category(
            .coughing,
            displayTitle: "Coughing"
        )
    }
    /// A category type that records a rapid, pounding, or fluttering heartbeat as a symptom.
    @inlinable public static var rapidPoundingOrFlutteringHeartbeat: SampleType<HKCategorySample> {
        .category(
            .rapidPoundingOrFlutteringHeartbeat,
            displayTitle: "Rapid Pounding or Fluttering Heartbeat"
        )
    }
    /// A category type that records shortness of breath as a symptom.
    @inlinable public static var shortnessOfBreath: SampleType<HKCategorySample> {
        .category(
            .shortnessOfBreath,
            displayTitle: "Shortness of Breath"
        )
    }
    /// A category type that records skipped heartbeat as a symptom.
    @inlinable public static var skippedHeartbeat: SampleType<HKCategorySample> {
        .category(
            .skippedHeartbeat,
            displayTitle: "Skipped Heartbeat"
        )
    }
    /// A category type that records wheezing as a symptom.
    @inlinable public static var wheezing: SampleType<HKCategorySample> {
        .category(
            .wheezing,
            displayTitle: "Wheezing"
        )
    }
    /// A category type that records lower back pain as a symptom.
    @inlinable public static var lowerBackPain: SampleType<HKCategorySample> {
        .category(
            .lowerBackPain,
            displayTitle: "Lower Back Pain"
        )
    }
    /// A category type that records headache as a symptom.
    @inlinable public static var headache: SampleType<HKCategorySample> {
        .category(
            .headache,
            displayTitle: "Headache"
        )
    }
    /// A category type that records memory lapse as a symptom.
    @inlinable public static var memoryLapse: SampleType<HKCategorySample> {
        .category(
            .memoryLapse,
            displayTitle: "Memory Lapse"
        )
    }
    /// A category type that records mood changes as a symptom.
    @inlinable public static var moodChanges: SampleType<HKCategorySample> {
        .category(
            .moodChanges,
            displayTitle: "Mood Changes"
        )
    }
    /// A category type that records loss of smell as a symptom.
    @inlinable public static var lossOfSmell: SampleType<HKCategorySample> {
        .category(
            .lossOfSmell,
            displayTitle: "Loss of Smell"
        )
    }
    /// A category type that records loss of taste as a symptom.
    @inlinable public static var lossOfTaste: SampleType<HKCategorySample> {
        .category(
            .lossOfTaste,
            displayTitle: "Loss of Taste"
        )
    }
    /// A category type that records runny nose as a symptom.
    @inlinable public static var runnyNose: SampleType<HKCategorySample> {
        .category(
            .runnyNose,
            displayTitle: "Runny Nose"
        )
    }
    /// A category type that records sore throat as a symptom.
    @inlinable public static var soreThroat: SampleType<HKCategorySample> {
        .category(
            .soreThroat,
            displayTitle: "Sore Throat"
        )
    }
    /// A category type that records sinus congestion as a symptom.
    @inlinable public static var sinusCongestion: SampleType<HKCategorySample> {
        .category(
            .sinusCongestion,
            displayTitle: "Sinus Congestion"
        )
    }
    /// A category type that records breast pain as a symptom.
    @inlinable public static var breastPain: SampleType<HKCategorySample> {
        .category(
            .breastPain,
            displayTitle: "Breast Pain"
        )
    }
    /// A category type that records pelvic pain as a symptom.
    @inlinable public static var pelvicPain: SampleType<HKCategorySample> {
        .category(
            .pelvicPain,
            displayTitle: "Pelvic Pain"
        )
    }
    /// A category type that records vaginal dryness as a symptom.
    @inlinable public static var vaginalDryness: SampleType<HKCategorySample> {
        .category(
            .vaginalDryness,
            displayTitle: "Vaginal Dryness"
        )
    }
    /// A category type that records bleeding during pregnancy as a symptom.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var bleedingDuringPregnancy: SampleType<HKCategorySample> {
        .category(
            .bleedingDuringPregnancy,
            displayTitle: "Bleeding During Pregnancy"
        )
    }
    /// A category type that records bleeding after pregnancy as a symptom.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var bleedingAfterPregnancy: SampleType<HKCategorySample> {
        .category(
            .bleedingAfterPregnancy,
            displayTitle: "Bleeding After Pregnancy"
        )
    }
    /// A category type that records acne as a symptom.
    @inlinable public static var acne: SampleType<HKCategorySample> {
        .category(
            .acne,
            displayTitle: "Acne"
        )
    }
    /// A category type that records dry skin as a symptom.
    @inlinable public static var drySkin: SampleType<HKCategorySample> {
        .category(
            .drySkin,
            displayTitle: "Dry Skin"
        )
    }
    /// A category type that records hair loss as a symptom.
    @inlinable public static var hairLoss: SampleType<HKCategorySample> {
        .category(
            .hairLoss,
            displayTitle: "Hair Loss"
        )
    }
    /// A category type that records night sweats as a symptom.
    @inlinable public static var nightSweats: SampleType<HKCategorySample> {
        .category(
            .nightSweats,
            displayTitle: "Night Sweats"
        )
    }
    /// A category type that records sleep changes as a symptom.
    @inlinable public static var sleepChanges: SampleType<HKCategorySample> {
        .category(
            .sleepChanges,
            displayTitle: "Sleep Changes"
        )
    }
    /// A category type that records sleep apnea as a symptom.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var sleepApneaEvent: SampleType<HKCategorySample> {
        .category(
            .sleepApneaEvent,
            displayTitle: "Sleep Apnea"
        )
    }
    /// A category type that records bladder incontinence as a symptom.
    @inlinable public static var bladderIncontinence: SampleType<HKCategorySample> {
        .category(
            .bladderIncontinence,
            displayTitle: "Bladder Incontinence"
        )
    }

    /// Returns the shared Category type for the specified identifier.
    public init?(_ identifier: HKCategoryTypeIdentifier) where Sample == HKCategorySample {
        if identifier == .appleStandHour {
            self = .appleStandHour
        } else if identifier == .lowCardioFitnessEvent {
            self = .lowCardioFitnessEvent
        } else if identifier == .menstrualFlow {
            self = .menstrualFlow
        } else if identifier == .intermenstrualBleeding {
            self = .intermenstrualBleeding
        } else if identifier == .infrequentMenstrualCycles {
            self = .infrequentMenstrualCycles
        } else if identifier == .irregularMenstrualCycles {
            self = .irregularMenstrualCycles
        } else if identifier == .persistentIntermenstrualBleeding {
            self = .persistentIntermenstrualBleeding
        } else if identifier == .prolongedMenstrualPeriods {
            self = .prolongedMenstrualPeriods
        } else if identifier == .cervicalMucusQuality {
            self = .cervicalMucusQuality
        } else if identifier == .ovulationTestResult {
            self = .ovulationTestResult
        } else if identifier == .progesteroneTestResult {
            self = .progesteroneTestResult
        } else if identifier == .sexualActivity {
            self = .sexualActivity
        } else if identifier == .contraceptive {
            self = .contraceptive
        } else if identifier == .pregnancy {
            self = .pregnancy
        } else if identifier == .pregnancyTestResult {
            self = .pregnancyTestResult
        } else if identifier == .lactation {
            self = .lactation
        } else if identifier == .environmentalAudioExposureEvent {
            self = .environmentalAudioExposureEvent
        } else if identifier == .headphoneAudioExposureEvent {
            self = .headphoneAudioExposureEvent
        } else if identifier == .lowHeartRateEvent {
            self = .lowHeartRateEvent
        } else if identifier == .highHeartRateEvent {
            self = .highHeartRateEvent
        } else if identifier == .irregularHeartRhythmEvent {
            self = .irregularHeartRhythmEvent
        } else if identifier == .appleWalkingSteadinessEvent {
            self = .appleWalkingSteadinessEvent
        } else if identifier == .mindfulSession {
            self = .mindfulSession
        } else if identifier == .sleepAnalysis {
            self = .sleepAnalysis
        } else if identifier == .toothbrushingEvent {
            self = .toothbrushingEvent
        } else if identifier == .handwashingEvent {
            self = .handwashingEvent
        } else if identifier == .abdominalCramps {
            self = .abdominalCramps
        } else if identifier == .bloating {
            self = .bloating
        } else if identifier == .constipation {
            self = .constipation
        } else if identifier == .diarrhea {
            self = .diarrhea
        } else if identifier == .heartburn {
            self = .heartburn
        } else if identifier == .nausea {
            self = .nausea
        } else if identifier == .vomiting {
            self = .vomiting
        } else if identifier == .appetiteChanges {
            self = .appetiteChanges
        } else if identifier == .chills {
            self = .chills
        } else if identifier == .dizziness {
            self = .dizziness
        } else if identifier == .fainting {
            self = .fainting
        } else if identifier == .fatigue {
            self = .fatigue
        } else if identifier == .fever {
            self = .fever
        } else if identifier == .generalizedBodyAche {
            self = .generalizedBodyAche
        } else if identifier == .hotFlashes {
            self = .hotFlashes
        } else if identifier == .chestTightnessOrPain {
            self = .chestTightnessOrPain
        } else if identifier == .coughing {
            self = .coughing
        } else if identifier == .rapidPoundingOrFlutteringHeartbeat {
            self = .rapidPoundingOrFlutteringHeartbeat
        } else if identifier == .shortnessOfBreath {
            self = .shortnessOfBreath
        } else if identifier == .skippedHeartbeat {
            self = .skippedHeartbeat
        } else if identifier == .wheezing {
            self = .wheezing
        } else if identifier == .lowerBackPain {
            self = .lowerBackPain
        } else if identifier == .headache {
            self = .headache
        } else if identifier == .memoryLapse {
            self = .memoryLapse
        } else if identifier == .moodChanges {
            self = .moodChanges
        } else if identifier == .lossOfSmell {
            self = .lossOfSmell
        } else if identifier == .lossOfTaste {
            self = .lossOfTaste
        } else if identifier == .runnyNose {
            self = .runnyNose
        } else if identifier == .soreThroat {
            self = .soreThroat
        } else if identifier == .sinusCongestion {
            self = .sinusCongestion
        } else if identifier == .breastPain {
            self = .breastPain
        } else if identifier == .pelvicPain {
            self = .pelvicPain
        } else if identifier == .vaginalDryness {
            self = .vaginalDryness
        } else if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *), identifier == .bleedingDuringPregnancy {
            self = .bleedingDuringPregnancy
        } else if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *), identifier == .bleedingAfterPregnancy {
            self = .bleedingAfterPregnancy
        } else if identifier == .acne {
            self = .acne
        } else if identifier == .drySkin {
            self = .drySkin
        } else if identifier == .hairLoss {
            self = .hairLoss
        } else if identifier == .nightSweats {
            self = .nightSweats
        } else if identifier == .sleepChanges {
            self = .sleepChanges
        } else if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *), identifier == .sleepApneaEvent {
            self = .sleepApneaEvent
        } else if identifier == .bladderIncontinence {
            self = .bladderIncontinence
        } else {
            return nil
        }
    }
}

extension HKCategoryType {
    /// All well-known `HKCategoryType`s
    public static let allKnownCategories: Set<HKCategoryType> = Set(
        HKCategoryTypeIdentifier.allKnownIdentifiers.map { HKCategoryType($0) }
    )
}

extension HKCategoryTypeIdentifier {
    /// All well-known `HKCategoryTypeIdentifier`s
    public static let allKnownIdentifiers: Set<HKCategoryTypeIdentifier> = {
        var identifiers = Set<HKCategoryTypeIdentifier>()
        identifiers.insert(Self.appleStandHour)
        identifiers.insert(Self.lowCardioFitnessEvent)
        identifiers.insert(Self.menstrualFlow)
        identifiers.insert(Self.intermenstrualBleeding)
        identifiers.insert(Self.infrequentMenstrualCycles)
        identifiers.insert(Self.irregularMenstrualCycles)
        identifiers.insert(Self.persistentIntermenstrualBleeding)
        identifiers.insert(Self.prolongedMenstrualPeriods)
        identifiers.insert(Self.cervicalMucusQuality)
        identifiers.insert(Self.ovulationTestResult)
        identifiers.insert(Self.progesteroneTestResult)
        identifiers.insert(Self.sexualActivity)
        identifiers.insert(Self.contraceptive)
        identifiers.insert(Self.pregnancy)
        identifiers.insert(Self.pregnancyTestResult)
        identifiers.insert(Self.lactation)
        identifiers.insert(Self.environmentalAudioExposureEvent)
        identifiers.insert(Self.headphoneAudioExposureEvent)
        identifiers.insert(Self.lowHeartRateEvent)
        identifiers.insert(Self.highHeartRateEvent)
        identifiers.insert(Self.irregularHeartRhythmEvent)
        identifiers.insert(Self.appleWalkingSteadinessEvent)
        identifiers.insert(Self.mindfulSession)
        identifiers.insert(Self.sleepAnalysis)
        identifiers.insert(Self.toothbrushingEvent)
        identifiers.insert(Self.handwashingEvent)
        identifiers.insert(Self.abdominalCramps)
        identifiers.insert(Self.bloating)
        identifiers.insert(Self.constipation)
        identifiers.insert(Self.diarrhea)
        identifiers.insert(Self.heartburn)
        identifiers.insert(Self.nausea)
        identifiers.insert(Self.vomiting)
        identifiers.insert(Self.appetiteChanges)
        identifiers.insert(Self.chills)
        identifiers.insert(Self.dizziness)
        identifiers.insert(Self.fainting)
        identifiers.insert(Self.fatigue)
        identifiers.insert(Self.fever)
        identifiers.insert(Self.generalizedBodyAche)
        identifiers.insert(Self.hotFlashes)
        identifiers.insert(Self.chestTightnessOrPain)
        identifiers.insert(Self.coughing)
        identifiers.insert(Self.rapidPoundingOrFlutteringHeartbeat)
        identifiers.insert(Self.shortnessOfBreath)
        identifiers.insert(Self.skippedHeartbeat)
        identifiers.insert(Self.wheezing)
        identifiers.insert(Self.lowerBackPain)
        identifiers.insert(Self.headache)
        identifiers.insert(Self.memoryLapse)
        identifiers.insert(Self.moodChanges)
        identifiers.insert(Self.lossOfSmell)
        identifiers.insert(Self.lossOfTaste)
        identifiers.insert(Self.runnyNose)
        identifiers.insert(Self.soreThroat)
        identifiers.insert(Self.sinusCongestion)
        identifiers.insert(Self.breastPain)
        identifiers.insert(Self.pelvicPain)
        identifiers.insert(Self.vaginalDryness)
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            identifiers.insert(Self.bleedingDuringPregnancy)
        }
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            identifiers.insert(Self.bleedingAfterPregnancy)
        }
        identifiers.insert(Self.acne)
        identifiers.insert(Self.drySkin)
        identifiers.insert(Self.hairLoss)
        identifiers.insert(Self.nightSweats)
        identifiers.insert(Self.sleepChanges)
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            identifiers.insert(Self.sleepApneaEvent)
        }
        identifiers.insert(Self.bladderIncontinence)
        return identifiers
    }()
}

// MARK: Correlation Types

extension SampleType where Sample == HKCorrelation {
    /// The sample type representing blood pressure correlation samples
    @inlinable public static var bloodPressure: SampleType<HKCorrelation> {
        .correlation(
            .bloodPressure,
            displayTitle: "Blood Pressure",
            associatedQuantityTypes: [.bloodPressureDiastolic, .bloodPressureSystolic]
        )
    }
    /// Food correlation types combine any number of nutritional samples into a single food object.
    @inlinable public static var food: SampleType<HKCorrelation> {
        .correlation(
            .food,
            displayTitle: "Food",
            associatedQuantityTypes: [.dietaryEnergyConsumed, .dietaryCarbohydrates, .dietaryFiber, .dietarySugar, .dietaryFatTotal, .dietaryFatMonounsaturated, .dietaryFatPolyunsaturated, .dietaryFatSaturated, .dietaryCholesterol, .dietaryProtein, .dietaryVitaminA, .dietaryThiamin, .dietaryRiboflavin, .dietaryNiacin, .dietaryPantothenicAcid, .dietaryVitaminB6, .dietaryBiotin, .dietaryVitaminB12, .dietaryVitaminC, .dietaryVitaminD, .dietaryVitaminE, .dietaryVitaminK, .dietaryFolate, .dietaryCalcium, .dietaryChloride, .dietaryIron, .dietaryMagnesium, .dietaryPhosphorus, .dietaryPotassium, .dietarySodium, .dietaryZinc, .dietaryWater, .dietaryCaffeine, .dietaryChromium, .dietaryCopper, .dietaryIodine, .dietaryManganese, .dietaryMolybdenum, .dietarySelenium]
        )
    }

    /// Returns the shared Correlation type for the specified identifier.
    public init?(_ identifier: HKCorrelationTypeIdentifier) where Sample == HKCorrelation {
        if identifier == .bloodPressure {
            self = .bloodPressure
        } else if identifier == .food {
            self = .food
        } else {
            return nil
        }
    }
}

extension HKCorrelationType {
    /// All well-known `HKCorrelationType`s
    public static let allKnownCorrelations: Set<HKCorrelationType> = Set(
        HKCorrelationTypeIdentifier.allKnownIdentifiers.map { HKCorrelationType($0) }
    )
}

extension HKCorrelationTypeIdentifier {
    /// All well-known `HKCorrelationTypeIdentifier`s
    public static let allKnownIdentifiers: Set<HKCorrelationTypeIdentifier> = {
        var identifiers = Set<HKCorrelationTypeIdentifier>()
        identifiers.insert(Self.bloodPressure)
        identifiers.insert(Self.food)
        return identifiers
    }()
}

// MARK: Clinical Record Types

@available(watchOS, unavailable)
extension SampleType where Sample == HKClinicalRecord {
    /// A type identifier for records of allergic or intolerant reactions.
    @inlinable public static var allergyRecord: SampleType<HKClinicalRecord> {
        .clinical(
            .allergyRecord,
            displayTitle: "Allergy Record"
        )
    }
    /// A type identifier for records of clinical notes.
    @inlinable public static var clinicalNoteRecord: SampleType<HKClinicalRecord> {
        .clinical(
            .clinicalNoteRecord,
            displayTitle: "Clinical Note Record"
        )
    }
    /// A type identifier for records of a condition, problem, diagnosis, or other event.
    @inlinable public static var conditionRecord: SampleType<HKClinicalRecord> {
        .clinical(
            .conditionRecord,
            displayTitle: "Condition Record"
        )
    }
    /// A type identifier for records of the current or historical administration of vaccines.
    @inlinable public static var immunizationRecord: SampleType<HKClinicalRecord> {
        .clinical(
            .immunizationRecord,
            displayTitle: "Immunization Record"
        )
    }
    /// A type identifier for records of lab results.
    @inlinable public static var labResultRecord: SampleType<HKClinicalRecord> {
        .clinical(
            .labResultRecord,
            displayTitle: "Lab Result Record"
        )
    }
    /// A type identifier for records of medication.
    @inlinable public static var medicationRecord: SampleType<HKClinicalRecord> {
        .clinical(
            .medicationRecord,
            displayTitle: "Medication Record"
        )
    }
    /// A type identifier for records of procedures.
    @inlinable public static var procedureRecord: SampleType<HKClinicalRecord> {
        .clinical(
            .procedureRecord,
            displayTitle: "Procedure Record"
        )
    }
    /// A type identifier for records of vital signs.
    @inlinable public static var vitalSignRecord: SampleType<HKClinicalRecord> {
        .clinical(
            .vitalSignRecord,
            displayTitle: "Vital Sign Record"
        )
    }
    /// A type identifier for records containing information about the user’s insurance coverage.
    @inlinable public static var coverageRecord: SampleType<HKClinicalRecord> {
        .clinical(
            .coverageRecord,
            displayTitle: "Coverage Record"
        )
    }

    /// Returns the shared Clinical Record type for the specified identifier.
    public init?(_ identifier: HKClinicalTypeIdentifier) where Sample == HKClinicalRecord {
        if identifier == .allergyRecord {
            self = .allergyRecord
        } else if identifier == .clinicalNoteRecord {
            self = .clinicalNoteRecord
        } else if identifier == .conditionRecord {
            self = .conditionRecord
        } else if identifier == .immunizationRecord {
            self = .immunizationRecord
        } else if identifier == .labResultRecord {
            self = .labResultRecord
        } else if identifier == .medicationRecord {
            self = .medicationRecord
        } else if identifier == .procedureRecord {
            self = .procedureRecord
        } else if identifier == .vitalSignRecord {
            self = .vitalSignRecord
        } else if identifier == .coverageRecord {
            self = .coverageRecord
        } else {
            return nil
        }
    }
}

extension HKClinicalType {
    /// All well-known `HKClinicalType`s
    public static let allKnownClinicalRecords: Set<HKClinicalType> = Set(
        HKClinicalTypeIdentifier.allKnownIdentifiers.map { HKClinicalType($0) }
    )
}

extension HKClinicalTypeIdentifier {
    /// All well-known `HKClinicalTypeIdentifier`s
    public static let allKnownIdentifiers: Set<HKClinicalTypeIdentifier> = {
        var identifiers = Set<HKClinicalTypeIdentifier>()
        identifiers.insert(Self.allergyRecord)
        identifiers.insert(Self.clinicalNoteRecord)
        identifiers.insert(Self.conditionRecord)
        identifiers.insert(Self.immunizationRecord)
        identifiers.insert(Self.labResultRecord)
        identifiers.insert(Self.medicationRecord)
        identifiers.insert(Self.procedureRecord)
        identifiers.insert(Self.vitalSignRecord)
        identifiers.insert(Self.coverageRecord)
        return identifiers
    }()
}

extension HKObjectType {
    /// All well-known `HKObjectType`s
    public static let allKnownObjectTypes: Set<HKObjectType> = {
        var types = Set<HKObjectType>()
        types.formUnion(HKQuantityType.allKnownQuantities)
        types.formUnion(HKCategoryType.allKnownCategories)
        types.formUnion(HKCorrelationType.allKnownCorrelations)
        types.formUnion(HKClinicalType.allKnownClinicalRecords)
        return types
    }()
}
