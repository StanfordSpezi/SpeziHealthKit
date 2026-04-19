//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


// NOTE: This file was automatically generated and should not be edited.
// swiftlint:disable all

public import Foundation
#if canImport(HealthKit)
public import HealthKit
#endif
private import SpeziFoundation



// MARK: Quantity Types

extension SampleType where Sample == HKQuantitySample {
    /// A quantity sample type that measures the number of steps the user has taken.
    @inlinable public static var stepCount: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.stepCount.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .stepCount,
                canonicalTitle: "Step Count",
                canonicalUnit: .count(),
                displayUnits: LocalizedUnit(metric: .count(), us: .count())
            )
        )
    }
    /// A quantity sample type that measures the distance the user has moved by walking or running.
    @inlinable public static var distanceWalkingRunning: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.distanceWalkingRunning.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .distanceWalkingRunning,
                canonicalTitle: "Distance Walking/Running",
                canonicalUnit: .meter(),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .kilo), us: .mile())
            )
        )
    }
    /// A quantity sample type that measures the amount of time the runner’s foot is in contact with the ground while running.
    @inlinable public static var runningGroundContactTime: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.runningGroundContactTime.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .runningGroundContactTime,
                canonicalTitle: "Ground Contact Time",
                canonicalUnit: .secondUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .secondUnit(with: .milli), us: .secondUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the rate of work required for the runner to maintain their speed.
    @inlinable public static var runningPower: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.runningPower.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .runningPower,
                canonicalTitle: "Running Power",
                canonicalUnit: .watt(),
                displayUnits: LocalizedUnit(metric: .watt(), us: .watt())
            )
        )
    }
    /// A quantity sample type that measures the runner’s speed.
    @inlinable public static var runningSpeed: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.runningSpeed.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .runningSpeed,
                canonicalTitle: "Running Speed",
                canonicalUnit: .meterUnit(with: .kilo) / .hour(),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .kilo) / .hour(), us: .mile() / .hour())
            )
        )
    }
    /// A quantity sample type that measures the distance covered by a single step while running.
    @inlinable public static var runningStrideLength: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.runningStrideLength.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .runningStrideLength,
                canonicalTitle: "Running Stride Length",
                canonicalUnit: .meter(),
                displayUnits: LocalizedUnit(metric: .meter(), us: .foot())
            )
        )
    }
    /// A quantity sample type measuring pelvis vertical range of motion during a single running stride.
    @inlinable public static var runningVerticalOscillation: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.runningVerticalOscillation.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .runningVerticalOscillation,
                canonicalTitle: "Running Vertical Oscillation",
                canonicalUnit: .meterUnit(with: .centi),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .centi), us: .inch())
            )
        )
    }
    /// A quantity sample type that measures the distance the user has moved by cycling.
    @inlinable public static var distanceCycling: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.distanceCycling.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .distanceCycling,
                canonicalTitle: "Cycling Distance",
                canonicalUnit: .meter(),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .kilo), us: .mile())
            )
        )
    }
    /// A quantity sample type that measures the number of pushes that the user has performed while using a wheelchair.
    @inlinable public static var pushCount: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.pushCount.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .pushCount,
                canonicalTitle: "Wheelchair Push Count",
                canonicalUnit: .count(),
                displayUnits: LocalizedUnit(metric: .count(), us: .count())
            )
        )
    }
    /// A quantity sample type that measures the distance the user has moved using a wheelchair.
    @inlinable public static var distanceWheelchair: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.distanceWheelchair.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .distanceWheelchair,
                canonicalTitle: "Wheelchair Distance",
                canonicalUnit: .meter(),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .kilo), us: .mile())
            )
        )
    }
    /// A quantity sample type that measures the number of strokes performed while swimming.
    @inlinable public static var swimmingStrokeCount: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.swimmingStrokeCount.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .swimmingStrokeCount,
                canonicalTitle: "Swimming Stroke Count",
                canonicalUnit: .count(),
                displayUnits: LocalizedUnit(metric: .count(), us: .count())
            )
        )
    }
    /// A quantity sample type that measures the distance the user has moved while swimming.
    @inlinable public static var distanceSwimming: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.distanceSwimming.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .distanceSwimming,
                canonicalTitle: "Swimming Distance",
                canonicalUnit: .meter(),
                displayUnits: LocalizedUnit(metric: .meter(), us: .yard(), uk: .yard())
            )
        )
    }
    /// A quantity sample type that measures the distance the user has traveled while skiing or snowboarding.
    @inlinable public static var distanceDownhillSnowSports: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.distanceDownhillSnowSports.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .distanceDownhillSnowSports,
                canonicalTitle: "Downhill Snow Sports Distance",
                canonicalUnit: .meter(),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .kilo), us: .mile())
            )
        )
    }
    /// A quantity sample type that measures the resting energy burned by the user.
    @inlinable public static var basalEnergyBurned: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.basalEnergyBurned.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .basalEnergyBurned,
                canonicalTitle: "Basal Energy Burned",
                canonicalUnit: .largeCalorie(),
                displayUnits: LocalizedUnit(metric: .largeCalorie(), us: .largeCalorie())
            )
        )
    }
    /// A quantity sample type that measures the amount of active energy the user has burned.
    @inlinable public static var activeEnergyBurned: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.activeEnergyBurned.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .activeEnergyBurned,
                canonicalTitle: "Active Energy Burned",
                canonicalUnit: .largeCalorie(),
                displayUnits: LocalizedUnit(metric: .largeCalorie(), us: .largeCalorie())
            )
        )
    }
    /// A quantity sample type that measures the number flights of stairs that the user has climbed.
    @inlinable public static var flightsClimbed: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.flightsClimbed.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .flightsClimbed,
                canonicalTitle: "Flights Climbed",
                canonicalUnit: .count(),
                displayUnits: LocalizedUnit(metric: .count(), us: .count())
            )
        )
    }
    /// A quantity sample type that measures the number of NikeFuel points the user has earned.
    @inlinable public static var nikeFuel: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.nikeFuel.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .nikeFuel,
                canonicalTitle: "NikeFuel",
                canonicalUnit: .count(),
                displayUnits: LocalizedUnit(metric: .count(), us: .count())
            )
        )
    }
    /// A quantity sample type that measures the amount of time the user spent exercising.
    @inlinable public static var appleExerciseTime: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.appleExerciseTime.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .appleExerciseTime,
                canonicalTitle: "Apple Exercise Time",
                canonicalUnit: .minute(),
                displayUnits: LocalizedUnit(metric: .minute(), us: .minute())
            )
        )
    }
    /// A quantity sample type that measures the amount of time the user has spent performing activities that involve full-body movements during the specified day.
    @inlinable public static var appleMoveTime: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.appleMoveTime.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .appleMoveTime,
                canonicalTitle: "Apple Move Time",
                canonicalUnit: .minute(),
                displayUnits: LocalizedUnit(metric: .minute(), us: .minute())
            )
        )
    }
    /// A quantity sample type that measures the amount of time the user has spent standing.
    @inlinable public static var appleStandTime: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.appleStandTime.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .appleStandTime,
                canonicalTitle: "Apple Stand Time",
                canonicalUnit: .minute(),
                displayUnits: LocalizedUnit(metric: .minute(), us: .minute())
            )
        )
    }
    /// A quantity sample that measures the maximal oxygen consumption during exercise.
    @inlinable public static var vo2Max: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.vo2Max.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .vo2Max,
                canonicalTitle: "VO2Max",
                canonicalUnit: .literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute()),
                displayUnits: LocalizedUnit(metric: .literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute()), us: .literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute()))
            )
        )
    }
    /// A quantity sample type that measures the user’s height.
    @inlinable public static var height: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.height.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .height,
                canonicalTitle: "Height",
                canonicalUnit: .meterUnit(with: .centi),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .centi), us: .foot())
            )
        )
    }
    /// A quantity sample type that measures the user’s weight.
    @inlinable public static var bodyMass: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.bodyMass.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .bodyMass,
                canonicalTitle: "Body Mass",
                canonicalUnit: .gramUnit(with: .kilo),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .kilo), us: .pound(), uk: .pound())
            )
        )
    }
    /// A quantity sample type that measures the user’s body mass index.
    @inlinable public static var bodyMassIndex: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.bodyMassIndex.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .bodyMassIndex,
                canonicalTitle: "BMI",
                canonicalUnit: .count(),
                displayUnits: LocalizedUnit(metric: .count(), us: .count())
            )
        )
    }
    /// A quantity sample type that measures the user’s lean body mass.
    @inlinable public static var leanBodyMass: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.leanBodyMass.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .leanBodyMass,
                canonicalTitle: "Lean Body Mass",
                canonicalUnit: .gramUnit(with: .kilo),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .kilo), us: .pound(), uk: .pound())
            )
        )
    }
    /// A quantity sample type that measures the user’s body fat percentage.
    @inlinable public static var bodyFatPercentage: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.bodyFatPercentage.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .bodyFatPercentage,
                canonicalTitle: "Body Fat Percentage",
                canonicalUnit: .percent(),
                displayUnits: LocalizedUnit(metric: .percent(), us: .percent())
            )
        )
    }
    /// A quantity sample type that measures the user’s waist circumference.
    @inlinable public static var waistCircumference: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.waistCircumference.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .waistCircumference,
                canonicalTitle: "Waist Circumference",
                canonicalUnit: .meterUnit(with: .centi),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .centi), us: .inch())
            )
        )
    }
    /// A quantity sample type that records the wrist temperature during sleep.
    @inlinable public static var appleSleepingWristTemperature: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.appleSleepingWristTemperature.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .appleSleepingWristTemperature,
                canonicalTitle: "Apple Sleeping Wrist Temperature",
                canonicalUnit: .degreeCelsius(),
                displayUnits: LocalizedUnit(metric: .degreeCelsius(), us: .degreeFahrenheit(), uk: .degreeCelsius())
            )
        )
    }
    /// A quantity sample type that records the user’s basal body temperature.
    @inlinable public static var basalBodyTemperature: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.basalBodyTemperature.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .basalBodyTemperature,
                canonicalTitle: "Basal Body Temperature",
                canonicalUnit: .degreeCelsius(),
                displayUnits: LocalizedUnit(metric: .degreeCelsius(), us: .degreeFahrenheit(), uk: .degreeCelsius())
            )
        )
    }
    /// A quantity sample type that measures audio exposure to sounds in the environment.
    @inlinable public static var environmentalAudioExposure: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.environmentalAudioExposure.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .environmentalAudioExposure,
                canonicalTitle: "Environmental Audio Exposure",
                canonicalUnit: .decibelAWeightedSoundPressureLevel(),
                displayUnits: LocalizedUnit(metric: .decibelAWeightedSoundPressureLevel(), us: .decibelAWeightedSoundPressureLevel())
            )
        )
    }
    /// A quantity sample type that measures audio exposure from headphones.
    @inlinable public static var headphoneAudioExposure: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.headphoneAudioExposure.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .headphoneAudioExposure,
                canonicalTitle: "Headphone Audio Exposure",
                canonicalUnit: .decibelAWeightedSoundPressureLevel(),
                displayUnits: LocalizedUnit(metric: .decibelAWeightedSoundPressureLevel(), us: .decibelAWeightedSoundPressureLevel())
            )
        )
    }
    /// A quantity sample type that measures the user’s heart rate.
    @inlinable public static var heartRate: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.heartRate.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .heartRate,
                canonicalTitle: "Heart Rate",
                canonicalUnit: .count() / .minute(),
                displayUnits: LocalizedUnit(metric: .count() / .minute(), us: .count() / .minute()),
                expectedValuesRange: 0...175
            )
        )
    }
    /// A quantity sample type that measures the user’s resting heart rate.
    @inlinable public static var restingHeartRate: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.restingHeartRate.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .restingHeartRate,
                canonicalTitle: "Resting Heart Rate",
                canonicalUnit: .count() / .minute(),
                displayUnits: LocalizedUnit(metric: .count() / .minute(), us: .count() / .minute())
            )
        )
    }
    /// A quantity sample type that measures the user’s heart rate while walking.
    @inlinable public static var walkingHeartRateAverage: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.walkingHeartRateAverage.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .walkingHeartRateAverage,
                canonicalTitle: "Walking Heart Rate Average",
                canonicalUnit: .count() / .minute(),
                displayUnits: LocalizedUnit(metric: .count() / .minute(), us: .count() / .minute())
            )
        )
    }
    /// A quantity sample type that measures the standard deviation of heartbeat intervals.
    @inlinable public static var heartRateVariabilitySDNN: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.heartRateVariabilitySDNN.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .heartRateVariabilitySDNN,
                canonicalTitle: "Heart Rate Variability SDNN",
                canonicalUnit: .secondUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .secondUnit(with: .milli), us: .secondUnit(with: .milli))
            )
        )
    }
    /// A quantity sample that records the reduction in heart rate from the peak exercise rate to the rate one minute after exercising ended.
    @inlinable public static var heartRateRecoveryOneMinute: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.heartRateRecoveryOneMinute.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .heartRateRecoveryOneMinute,
                canonicalTitle: "Heart Rate Recovery (1 min)",
                canonicalUnit: .count() / .minute(),
                displayUnits: LocalizedUnit(metric: .count() / .minute(), us: .count() / .minute())
            )
        )
    }
    /// A quantity type that measures an estimate of the percentage of time a person’s heart shows signs of atrial fibrillation (AFib) while wearing Apple Watch.
    @inlinable public static var atrialFibrillationBurden: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.atrialFibrillationBurden.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .atrialFibrillationBurden,
                canonicalTitle: "AFib Burden",
                canonicalUnit: .percent(),
                displayUnits: LocalizedUnit(metric: .percent(), us: .percent())
            )
        )
    }
    /// A quantity sample type that measures the user’s oxygen saturation.
    @inlinable public static var bloodOxygen: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.oxygenSaturation.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .oxygenSaturation,
                canonicalTitle: "Oxygen Saturation",
                canonicalUnit: .percent(),
                displayUnits: LocalizedUnit(metric: .percent(), us: .percent()),
                expectedValuesRange: 80...105
            )
        )
    }
    /// A quantity sample type that measures the user’s body temperature.
    @inlinable public static var bodyTemperature: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.bodyTemperature.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .bodyTemperature,
                canonicalTitle: "Body Temperature",
                canonicalUnit: .degreeCelsius(),
                displayUnits: LocalizedUnit(metric: .degreeCelsius(), us: .degreeFahrenheit(), uk: .degreeCelsius())
            )
        )
    }
    /// A quantity sample type that measures the user’s diastolic blood pressure.
    @inlinable public static var bloodPressureDiastolic: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.bloodPressureDiastolic.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .bloodPressureDiastolic,
                canonicalTitle: "Blood Pressure (Diastolic)",
                canonicalUnit: .millimeterOfMercury(),
                displayUnits: LocalizedUnit(metric: .millimeterOfMercury(), us: .millimeterOfMercury())
            )
        )
    }
    /// A quantity sample type that measures the user’s systolic blood pressure.
    @inlinable public static var bloodPressureSystolic: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.bloodPressureSystolic.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .bloodPressureSystolic,
                canonicalTitle: "Blood Pressure (Systolic)",
                canonicalUnit: .millimeterOfMercury(),
                displayUnits: LocalizedUnit(metric: .millimeterOfMercury(), us: .millimeterOfMercury())
            )
        )
    }
    /// A quantity sample type that measures the user’s respiratory rate.
    @inlinable public static var respiratoryRate: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.respiratoryRate.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .respiratoryRate,
                canonicalTitle: "Respiratory Rate",
                canonicalUnit: .count() / .minute(),
                displayUnits: LocalizedUnit(metric: .count() / .minute(), us: .count() / .minute())
            )
        )
    }
    /// A quantity sample type that measures the user’s blood glucose level.
    @inlinable public static var bloodGlucose: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.bloodGlucose.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .bloodGlucose,
                canonicalTitle: "Blood Glucose",
                canonicalUnit: .gramUnit(with: .milli) / .literUnit(with: .deci),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli) / .literUnit(with: .deci), us: .gramUnit(with: .milli) / .literUnit(with: .deci))
            )
        )
    }
    /// A quantity sample type that measures electrodermal activity.
    @inlinable public static var electrodermalActivity: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.electrodermalActivity.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .electrodermalActivity,
                canonicalTitle: "Electrodermal Activity",
                canonicalUnit: .siemenUnit(with: .micro),
                displayUnits: LocalizedUnit(metric: .siemenUnit(with: .micro), us: .siemenUnit(with: .micro))
            )
        )
    }
    /// A quantity sample type that measures the amount of air that can be forcibly exhaled from the lungs during the first second of a forced exhalation.
    @inlinable public static var forcedExpiratoryVolume1: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.forcedExpiratoryVolume1.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .forcedExpiratoryVolume1,
                canonicalTitle: "Forced Expiratory Volume (1 sec)",
                canonicalUnit: .liter(),
                displayUnits: LocalizedUnit(metric: .liter(), us: .liter())
            )
        )
    }
    /// A quantity sample type that measures the amount of air that can be forcibly exhaled from the lungs after taking the deepest breath possible.
    @inlinable public static var forcedVitalCapacity: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.forcedVitalCapacity.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .forcedVitalCapacity,
                canonicalTitle: "Forced Vital Capacity",
                canonicalUnit: .liter(),
                displayUnits: LocalizedUnit(metric: .liter(), us: .liter())
            )
        )
    }
    /// A quantity sample type that measures the number of puffs the user takes from their inhaler.
    @inlinable public static var inhalerUsage: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.inhalerUsage.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .inhalerUsage,
                canonicalTitle: "Inhaler Usage",
                canonicalUnit: .count(),
                displayUnits: LocalizedUnit(metric: .count(), us: .count())
            )
        )
    }
    /// A quantity sample that measures the amount of insulin delivered.
    @inlinable public static var insulinDelivery: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.insulinDelivery.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .insulinDelivery,
                canonicalTitle: "Insulin Delivery",
                canonicalUnit: .internationalUnit(),
                displayUnits: LocalizedUnit(metric: .internationalUnit(), us: .internationalUnit())
            )
        )
    }
    /// A quantity sample type that measures the number of times the user fell.
    @inlinable public static var numberOfTimesFallen: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.numberOfTimesFallen.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .numberOfTimesFallen,
                canonicalTitle: "Number of Times Fallen",
                canonicalUnit: .count(),
                displayUnits: LocalizedUnit(metric: .count(), us: .count())
            )
        )
    }
    /// A quantity sample type that measures the user’s maximum flow rate generated during a forceful exhalation.
    @inlinable public static var peakExpiratoryFlowRate: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.peakExpiratoryFlowRate.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .peakExpiratoryFlowRate,
                canonicalTitle: "Peak Expiratory Flow Rate",
                canonicalUnit: .liter() / .minute(),
                displayUnits: LocalizedUnit(metric: .liter() / .minute(), us: .liter() / .minute())
            )
        )
    }
    /// A quantity sample type that measures the user’s peripheral perfusion index.
    @inlinable public static var peripheralPerfusionIndex: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.peripheralPerfusionIndex.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .peripheralPerfusionIndex,
                canonicalTitle: "Peripheral Perfusion Index",
                canonicalUnit: .percent(),
                displayUnits: LocalizedUnit(metric: .percent(), us: .percent())
            )
        )
    }
    /// A quantity sample type that measures the amount of biotin (vitamin B7) consumed.
    @inlinable public static var dietaryBiotin: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryBiotin.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryBiotin,
                canonicalTitle: "Dietary Biotin Intake",
                canonicalUnit: .gramUnit(with: .micro),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .micro), us: .gramUnit(with: .micro))
            )
        )
    }
    /// A quantity sample type that measures the amount of caffeine consumed.
    @inlinable public static var dietaryCaffeine: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryCaffeine.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryCaffeine,
                canonicalTitle: "Dietary Caffeine Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of calcium consumed.
    @inlinable public static var dietaryCalcium: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryCalcium.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryCalcium,
                canonicalTitle: "Dietary Calcium Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of carbohydrates consumed.
    @inlinable public static var dietaryCarbohydrates: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryCarbohydrates.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryCarbohydrates,
                canonicalTitle: "Dietary Carbohydrates Intake",
                canonicalUnit: .gram(),
                displayUnits: LocalizedUnit(metric: .gram(), us: .gram())
            )
        )
    }
    /// A quantity sample type that measures the amount of chloride consumed.
    @inlinable public static var dietaryChloride: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryChloride.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryChloride,
                canonicalTitle: "Dietary Chloride Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of cholesterol consumed.
    @inlinable public static var dietaryCholesterol: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryCholesterol.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryCholesterol,
                canonicalTitle: "Dietary Cholesterol Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of chromium consumed.
    @inlinable public static var dietaryChromium: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryChromium.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryChromium,
                canonicalTitle: "Dietary Chromium Intake",
                canonicalUnit: .gramUnit(with: .micro),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .micro), us: .gramUnit(with: .micro))
            )
        )
    }
    /// A quantity sample type that measures the amount of copper consumed.
    @inlinable public static var dietaryCopper: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryCopper.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryCopper,
                canonicalTitle: "Dietary Copper Intake",
                canonicalUnit: .gramUnit(with: .micro),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .micro), us: .gramUnit(with: .micro))
            )
        )
    }
    /// A quantity sample type that measures the amount of energy consumed.
    @inlinable public static var dietaryEnergyConsumed: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryEnergyConsumed.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryEnergyConsumed,
                canonicalTitle: "Dietary Energy Consumed",
                canonicalUnit: .largeCalorie(),
                displayUnits: LocalizedUnit(metric: .largeCalorie(), us: .largeCalorie())
            )
        )
    }
    /// A quantity sample type that measures the amount of monounsaturated fat consumed.
    @inlinable public static var dietaryFatMonounsaturated: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryFatMonounsaturated.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryFatMonounsaturated,
                canonicalTitle: "Dietary Monounsaturated Fat Intake",
                canonicalUnit: .gram(),
                displayUnits: LocalizedUnit(metric: .gram(), us: .gram())
            )
        )
    }
    /// A quantity sample type that measures the amount of polyunsaturated fat consumed.
    @inlinable public static var dietaryFatPolyunsaturated: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryFatPolyunsaturated.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryFatPolyunsaturated,
                canonicalTitle: "Dietary Polyunsaturated Fat Intake",
                canonicalUnit: .gram(),
                displayUnits: LocalizedUnit(metric: .gram(), us: .gram())
            )
        )
    }
    /// A quantity sample type that measures the amount of saturated fat consumed.
    @inlinable public static var dietaryFatSaturated: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryFatSaturated.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryFatSaturated,
                canonicalTitle: "Dietary Saturated Fat Intake",
                canonicalUnit: .gram(),
                displayUnits: LocalizedUnit(metric: .gram(), us: .gram())
            )
        )
    }
    /// A quantity sample type that measures the total amount of fat consumed.
    @inlinable public static var dietaryFatTotal: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryFatTotal.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryFatTotal,
                canonicalTitle: "Dietary Total Fat Intake",
                canonicalUnit: .gram(),
                displayUnits: LocalizedUnit(metric: .gram(), us: .gram())
            )
        )
    }
    /// A quantity sample type that measures the amount of fiber consumed.
    @inlinable public static var dietaryFiber: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryFiber.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryFiber,
                canonicalTitle: "Dietary Fiber Intake",
                canonicalUnit: .gram(),
                displayUnits: LocalizedUnit(metric: .gram(), us: .gram())
            )
        )
    }
    /// A quantity sample type that measures the amount of folate (folic acid) consumed.
    @inlinable public static var dietaryFolate: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryFolate.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryFolate,
                canonicalTitle: "Dietary Folate Intake",
                canonicalUnit: .gramUnit(with: .micro),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .micro), us: .gramUnit(with: .micro))
            )
        )
    }
    /// A quantity sample type that measures the amount of iodine consumed.
    @inlinable public static var dietaryIodine: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryIodine.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryIodine,
                canonicalTitle: "Dietary Iodine Intake",
                canonicalUnit: .gramUnit(with: .micro),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .micro), us: .gramUnit(with: .micro))
            )
        )
    }
    /// A quantity sample type that measures the amount of iron consumed.
    @inlinable public static var dietaryIron: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryIron.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryIron,
                canonicalTitle: "Dietary Iron Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of magnesium consumed.
    @inlinable public static var dietaryMagnesium: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryMagnesium.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryMagnesium,
                canonicalTitle: "Dietary Magnesium Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of manganese consumed.
    @inlinable public static var dietaryManganese: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryManganese.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryManganese,
                canonicalTitle: "Dietary Manganese Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of molybdenum consumed.
    @inlinable public static var dietaryMolybdenum: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryMolybdenum.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryMolybdenum,
                canonicalTitle: "Dietary Molybdenum Intake",
                canonicalUnit: .gramUnit(with: .micro),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .micro), us: .gramUnit(with: .micro))
            )
        )
    }
    /// A quantity sample type that measures the amount of niacin (vitamin B3) consumed.
    @inlinable public static var dietaryNiacin: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryNiacin.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryNiacin,
                canonicalTitle: "Dietary Niacin Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of pantothenic acid (vitamin B5) consumed.
    @inlinable public static var dietaryPantothenicAcid: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryPantothenicAcid.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryPantothenicAcid,
                canonicalTitle: "Dietary Pantothenic Acid Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of phosphorus consumed.
    @inlinable public static var dietaryPhosphorus: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryPhosphorus.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryPhosphorus,
                canonicalTitle: "Dietary Phosphorus Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of potassium consumed.
    @inlinable public static var dietaryPotassium: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryPotassium.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryPotassium,
                canonicalTitle: "Dietary Potassium Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of protein consumed.
    @inlinable public static var dietaryProtein: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryProtein.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryProtein,
                canonicalTitle: "Dietary Protein Intake",
                canonicalUnit: .gram(),
                displayUnits: LocalizedUnit(metric: .gram(), us: .gram())
            )
        )
    }
    /// A quantity sample type that measures the amount of riboflavin (vitamin B2) consumed.
    @inlinable public static var dietaryRiboflavin: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryRiboflavin.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryRiboflavin,
                canonicalTitle: "Dietary Riboflavin Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of selenium consumed.
    @inlinable public static var dietarySelenium: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietarySelenium.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietarySelenium,
                canonicalTitle: "Dietary Selenium Intake",
                canonicalUnit: .gramUnit(with: .micro),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .micro), us: .gramUnit(with: .micro))
            )
        )
    }
    /// A quantity sample type that measures the amount of sodium consumed.
    @inlinable public static var dietarySodium: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietarySodium.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietarySodium,
                canonicalTitle: "Dietary Sodium Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of sugar consumed.
    @inlinable public static var dietarySugar: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietarySugar.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietarySugar,
                canonicalTitle: "Dietary Sugar Intake",
                canonicalUnit: .gram(),
                displayUnits: LocalizedUnit(metric: .gram(), us: .gram())
            )
        )
    }
    /// A quantity sample type that measures the amount of thiamin (vitamin B1) consumed.
    @inlinable public static var dietaryThiamin: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryThiamin.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryThiamin,
                canonicalTitle: "Dietary Thiamin Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of vitamin A consumed.
    @inlinable public static var dietaryVitaminA: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryVitaminA.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryVitaminA,
                canonicalTitle: "Dietary Vitamin A Intake",
                canonicalUnit: .gramUnit(with: .micro),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .micro), us: .gramUnit(with: .micro))
            )
        )
    }
    /// A quantity sample type that measures the amount of cyanocobalamin (vitamin B12) consumed.
    @inlinable public static var dietaryVitaminB12: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryVitaminB12.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryVitaminB12,
                canonicalTitle: "Dietary Vitamin B12 Intake",
                canonicalUnit: .gramUnit(with: .micro),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .micro), us: .gramUnit(with: .micro))
            )
        )
    }
    /// A quantity sample type that measures the amount of pyridoxine (vitamin B6) consumed.
    @inlinable public static var dietaryVitaminB6: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryVitaminB6.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryVitaminB6,
                canonicalTitle: "Dietary Vitamin B6 Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of vitamin C consumed.
    @inlinable public static var dietaryVitaminC: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryVitaminC.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryVitaminC,
                canonicalTitle: "Dietary Vitamin C Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of vitamin D consumed.
    @inlinable public static var dietaryVitaminD: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryVitaminD.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryVitaminD,
                canonicalTitle: "Dietary Vitamin D Intake",
                canonicalUnit: .gramUnit(with: .micro),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .micro), us: .gramUnit(with: .micro))
            )
        )
    }
    /// A quantity sample type that measures the amount of vitamin E consumed.
    @inlinable public static var dietaryVitaminE: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryVitaminE.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryVitaminE,
                canonicalTitle: "Dietary Vitamin E Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the amount of vitamin K consumed.
    @inlinable public static var dietaryVitaminK: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryVitaminK.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryVitaminK,
                canonicalTitle: "Dietary Vitamin K Intake",
                canonicalUnit: .gramUnit(with: .micro),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .micro), us: .gramUnit(with: .micro))
            )
        )
    }
    /// A quantity sample type that measures the amount of water consumed.
    @inlinable public static var dietaryWater: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryWater.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryWater,
                canonicalTitle: "Dietary Water Intake",
                canonicalUnit: .liter(),
                displayUnits: LocalizedUnit(metric: .literUnit(with: .milli), us: .fluidOunceUS())
            )
        )
    }
    /// A quantity sample type that measures the amount of zinc consumed.
    @inlinable public static var dietaryZinc: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dietaryZinc.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .dietaryZinc,
                canonicalTitle: "Dietary Zinc Intake",
                canonicalUnit: .gramUnit(with: .milli),
                displayUnits: LocalizedUnit(metric: .gramUnit(with: .milli), us: .gramUnit(with: .milli))
            )
        )
    }
    /// A quantity sample type that measures the user’s blood alcohol content.
    @inlinable public static var bloodAlcoholContent: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.bloodAlcoholContent.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .bloodAlcoholContent,
                canonicalTitle: "Blood Alcohol Content",
                canonicalUnit: .percent(),
                displayUnits: LocalizedUnit(metric: .percent(), us: .percent())
            )
        )
    }
    /// A quantity sample type that measures the number of standard alcoholic drinks that the user has consumed.
    @inlinable public static var numberOfAlcoholicBeverages: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.numberOfAlcoholicBeverages.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .numberOfAlcoholicBeverages,
                canonicalTitle: "Number of Alcoholic Beverages",
                canonicalUnit: .count(),
                displayUnits: LocalizedUnit(metric: .count(), us: .count())
            )
        )
    }
    /// A quantity sample type that measures the steadiness of the user’s gait.
    @inlinable public static var appleWalkingSteadiness: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.appleWalkingSteadiness.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .appleWalkingSteadiness,
                canonicalTitle: "Apple Walking Steadiness",
                canonicalUnit: .percent(),
                displayUnits: LocalizedUnit(metric: .percent(), us: .percent())
            )
        )
    }
    /// A quantity sample type that stores the distance a user can walk during a six-minute walk test.
    @inlinable public static var sixMinuteWalkTestDistance: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.sixMinuteWalkTestDistance.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .sixMinuteWalkTestDistance,
                canonicalTitle: "6 Minute Walk Test Distance",
                canonicalUnit: .meter(),
                displayUnits: LocalizedUnit(metric: .meter(), us: .meter())
            )
        )
    }
    /// A quantity sample type that measures the user’s average speed when walking steadily over flat ground.
    @inlinable public static var walkingSpeed: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.walkingSpeed.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .walkingSpeed,
                canonicalTitle: "Walking Speed",
                canonicalUnit: .meter() / .second(),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .kilo) / .hour(), us: .mile() / .hour())
            )
        )
    }
    /// A quantity sample type that measures the average length of the user’s step when walking steadily over flat ground.
    @inlinable public static var walkingStepLength: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.walkingStepLength.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .walkingStepLength,
                canonicalTitle: "Walking Step Length",
                canonicalUnit: .meterUnit(with: .centi),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .centi), us: .inch())
            )
        )
    }
    /// A quantity sample type that measures the percentage of steps in which one foot moves at a different speed than the other when walking on flat ground.
    @inlinable public static var walkingAsymmetryPercentage: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.walkingAsymmetryPercentage.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .walkingAsymmetryPercentage,
                canonicalTitle: "Walking Asymmetry Percentage",
                canonicalUnit: .percent(),
                displayUnits: LocalizedUnit(metric: .percent(), us: .percent())
            )
        )
    }
    /// A quantity sample type that measures the percentage of time when both of the user’s feet touch the ground while walking steadily over flat ground.
    @inlinable public static var walkingDoubleSupportPercentage: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.walkingDoubleSupportPercentage.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .walkingDoubleSupportPercentage,
                canonicalTitle: "Walking Double Support Percentage",
                canonicalUnit: .percent(),
                displayUnits: LocalizedUnit(metric: .percent(), us: .percent())
            )
        )
    }
    /// A quantity sample type measuring the user’s speed while climbing a flight of stairs.
    @inlinable public static var stairAscentSpeed: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.stairAscentSpeed.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .stairAscentSpeed,
                canonicalTitle: "Stair Ascent Speed",
                canonicalUnit: .meter() / .second(),
                displayUnits: LocalizedUnit(metric: .meter() / .second(), us: .foot() / .second())
            )
        )
    }
    /// A quantity sample type measuring the user’s speed while descending a flight of stairs.
    @inlinable public static var stairDescentSpeed: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.stairDescentSpeed.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .stairDescentSpeed,
                canonicalTitle: "Stair Descent Speed",
                canonicalUnit: .meter() / .second(),
                displayUnits: LocalizedUnit(metric: .meter() / .second(), us: .foot() / .second())
            )
        )
    }
    /// A quantity sample type that measures the user’s exposure to UV radiation.
    @inlinable public static var uvExposure: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.uvExposure.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .uvExposure,
                canonicalTitle: "UV Exposure",
                canonicalUnit: .count(),
                displayUnits: LocalizedUnit(metric: .count(), us: .count())
            )
        )
    }
    /// A quantity sample that records a person’s depth underwater.
    @inlinable public static var underwaterDepth: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.underwaterDepth.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .underwaterDepth,
                canonicalTitle: "Underwater Depth",
                canonicalUnit: .meter(),
                displayUnits: LocalizedUnit(metric: .meter(), us: .foot())
            )
        )
    }
    ///  A quantity sample that records the water temperature.
    @inlinable public static var waterTemperature: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.waterTemperature.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .waterTemperature,
                canonicalTitle: "Water Temperature",
                canonicalUnit: .degreeCelsius(),
                displayUnits: LocalizedUnit(metric: .degreeCelsius(), us: .degreeFahrenheit(), uk: .degreeCelsius())
            )
        )
    }
    /// A quantity sample that records breathing disturbances during sleep.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var appleSleepingBreathingDisturbances: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.appleSleepingBreathingDisturbances.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .appleSleepingBreathingDisturbances,
                canonicalTitle: "Apple Sleeping Breathing Disturbances",
                canonicalUnit: .count(),
                displayUnits: LocalizedUnit(metric: .count(), us: .count())
            )
        )
    }
    /// A quantity sample that records cross-country skiing speed.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var crossCountrySkiingSpeed: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.crossCountrySkiingSpeed.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .crossCountrySkiingSpeed,
                canonicalTitle: "Cross Country Skiing Speed",
                canonicalUnit: .meterUnit(with: .kilo) / .hour(),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .kilo) / .hour(), us: .mile() / .hour())
            )
        )
    }
    /// A quantity sample that records cycling cadence.
    @inlinable public static var cyclingCadence: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.cyclingCadence.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .cyclingCadence,
                canonicalTitle: "Cycling Cadence",
                canonicalUnit: .count() / .minute(),
                displayUnits: LocalizedUnit(metric: .count() / .minute(), us: .count() / .minute())
            )
        )
    }
    /// A quantity sample that records cycling functional threshold power.
    @inlinable public static var cyclingFunctionalThresholdPower: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.cyclingFunctionalThresholdPower.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .cyclingFunctionalThresholdPower,
                canonicalTitle: "Cycling Functional Threshold Power",
                canonicalUnit: .watt(),
                displayUnits: LocalizedUnit(metric: .watt(), us: .watt())
            )
        )
    }
    /// A quantity sample that records cycling power.
    @inlinable public static var cyclingPower: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.cyclingPower.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .cyclingPower,
                canonicalTitle: "Cycling Power",
                canonicalUnit: .watt(),
                displayUnits: LocalizedUnit(metric: .watt(), us: .watt())
            )
        )
    }
    /// A quantity sample that records cycling speed.
    @inlinable public static var cyclingSpeed: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.cyclingSpeed.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .cyclingSpeed,
                canonicalTitle: "Cycling Speed",
                canonicalUnit: .meterUnit(with: .kilo) / .hour(),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .kilo) / .hour(), us: .mile() / .hour())
            )
        )
    }
    /// A quantity sample that records cross-country skiing distance.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var distanceCrossCountrySkiing: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.distanceCrossCountrySkiing.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .distanceCrossCountrySkiing,
                canonicalTitle: "Cross-Country Skiing Speed",
                canonicalUnit: .meter(),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .kilo), us: .mile())
            )
        )
    }
    /// A quantity sample that records paddle sports distance.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var distancePaddleSports: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.distancePaddleSports.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .distancePaddleSports,
                canonicalTitle: "Paddle Sports Distance",
                canonicalUnit: .meter(),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .kilo), us: .mile())
            )
        )
    }
    /// A quantity sample that records rowing distance.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var distanceRowing: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.distanceRowing.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .distanceRowing,
                canonicalTitle: "Rowing Distance",
                canonicalUnit: .meter(),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .kilo), us: .mile())
            )
        )
    }
    /// A quantity sample that records skating sports distance.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var distanceSkatingSports: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.distanceSkatingSports.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .distanceSkatingSports,
                canonicalTitle: "Skating Sports Distance",
                canonicalUnit: .meter(),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .kilo), us: .mile())
            )
        )
    }
    /// A quantity sample that records environmental sound reduction.
    @inlinable public static var environmentalSoundReduction: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.environmentalSoundReduction.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .environmentalSoundReduction,
                canonicalTitle: "Environmental Sound Reduction",
                canonicalUnit: .decibelHearingLevel(),
                displayUnits: LocalizedUnit(metric: .decibelHearingLevel(), us: .decibelHearingLevel())
            )
        )
    }
    /// A quantity sample that records estimated physical effort during workouts.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var estimatedWorkoutEffortScore: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.estimatedWorkoutEffortScore.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .estimatedWorkoutEffortScore,
                canonicalTitle: "Estimated Workout Effort",
                canonicalUnit: .count(),
                displayUnits: LocalizedUnit(metric: .count(), us: .count())
            )
        )
    }
    /// A quantity sample that records paddle sports speed.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var paddleSportsSpeed: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.paddleSportsSpeed.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .paddleSportsSpeed,
                canonicalTitle: "Paddle Sports Speed",
                canonicalUnit: .meterUnit(with: .kilo) / .hour(),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .kilo) / .hour(), us: .mile() / .hour())
            )
        )
    }
    /// A quantity sample that records physical effort.
    @inlinable public static var physicalEffort: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.physicalEffort.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .physicalEffort,
                canonicalTitle: "Physical Effort",
                canonicalUnit: .kilocalorie() / (.gramUnit(with: .kilo) * .hour()),
                displayUnits: LocalizedUnit(metric: .kilocalorie() / (.gramUnit(with: .kilo) * .hour()), us: .kilocalorie() / (.gramUnit(with: .kilo) * .hour()))
            )
        )
    }
    /// A quantity sample that records rowing speed.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var rowingSpeed: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.rowingSpeed.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .rowingSpeed,
                canonicalTitle: "Rowing Speed",
                canonicalUnit: .meterUnit(with: .kilo) / .hour(),
                displayUnits: LocalizedUnit(metric: .meterUnit(with: .kilo) / .hour(), us: .mile() / .hour())
            )
        )
    }
    /// A quantity sample that records time spent in daylight.
    @inlinable public static var timeInDaylight: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.timeInDaylight.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .timeInDaylight,
                canonicalTitle: "Time in Daylight",
                canonicalUnit: .minute(),
                displayUnits: LocalizedUnit(metric: .minute(), us: .minute())
            )
        )
    }
    /// A quantity sample that records workout effort.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var workoutEffortScore: SampleType<HKQuantitySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.workoutEffortScore.rawValue,
            as: SampleType<HKQuantitySample>.self,
            default: .quantity(
                .workoutEffortScore,
                canonicalTitle: "Workout Effort",
                canonicalUnit: .count(),
                displayUnits: LocalizedUnit(metric: .count(), us: .count())
            )
        )
    }

    /// Returns the shared Quantity type for the specified HKQuantityType.
    @inlinable
    public init?(_ hkType: HKQuantityType) {
        self.init(HKQuantityTypeIdentifier(rawValue: hkType.identifier))
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
        } else if identifier == .nikeFuel {
            self = .nikeFuel
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

extension SampleType where Sample == HKQuantitySample {
    /// All well-known Quantity types.
    @inlinable public static var allKnownQuantities: Set<SampleType<HKQuantitySample>> {
        HKQuantityType._allKnownQuantities
    }
}

extension HKQuantityType {
    /// All well-known `HKQuantityType`s
    public static let allKnownQuantities: Set<HKQuantityType> = Set(
        HKQuantityTypeIdentifier.allKnownIdentifiers.map { HKQuantityType($0) }
    )
    
    /// The set of all well-known HKQuantityType instances.
    ///
    /// Stored here rather than in `SampleType` bc that type is generic and the static property would get re-computed on each access,
    /// which is expensive.
    @usableFromInline static let _allKnownQuantities: Set<SampleType<HKQuantitySample>> = {
        HKQuantityType.allKnownQuantities.compactMapIntoSet { $0.sampleType as? SampleType<HKQuantitySample> }
    }()
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
        identifiers.insert(Self.nikeFuel)
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
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.appleStandHour.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .appleStandHour,
                canonicalTitle: "Apple Stand Hour",
            )
        )
    }
    /// An event that indicates the user’s VO2 max values consistently fall below a particular aerobic fitness threshold.
    @inlinable public static var lowCardioFitnessEvent: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.lowCardioFitnessEvent.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .lowCardioFitnessEvent,
                canonicalTitle: "Low Cardio Fitness Event",
            )
        )
    }
    /// A category sample type that records menstrual cycles.
    @inlinable public static var menstrualFlow: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.menstrualFlow.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .menstrualFlow,
                canonicalTitle: "Menstrual Flow",
            )
        )
    }
    /// A category sample type that records spotting outside the normal menstruation period.
    @inlinable public static var intermenstrualBleeding: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.intermenstrualBleeding.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .intermenstrualBleeding,
                canonicalTitle: "Intermenstrual Bleeding",
            )
        )
    }
    /// A category sample that indicates an infrequent menstrual cycle.
    @inlinable public static var infrequentMenstrualCycles: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.infrequentMenstrualCycles.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .infrequentMenstrualCycles,
                canonicalTitle: "Infrequent Menstrual Cycles",
            )
        )
    }
    /// A category sample that indicates an irregular menstrual cycle.
    @inlinable public static var irregularMenstrualCycles: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.irregularMenstrualCycles.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .irregularMenstrualCycles,
                canonicalTitle: "Irregular Menstrual Cycles",
            )
        )
    }
    /// A category sample that indicates persistent intermenstrual bleeding.
    @inlinable public static var persistentIntermenstrualBleeding: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.persistentIntermenstrualBleeding.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .persistentIntermenstrualBleeding,
                canonicalTitle: "Persistent Intermenstrual Bleeding",
            )
        )
    }
    /// A category sample that indicates a prolonged menstrual cycle.
    @inlinable public static var prolongedMenstrualPeriods: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.prolongedMenstrualPeriods.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .prolongedMenstrualPeriods,
                canonicalTitle: "Prolonged Menstrual Periods",
            )
        )
    }
    /// A category sample type that records the quality of the user’s cervical mucus.
    @inlinable public static var cervicalMucusQuality: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.cervicalMucusQuality.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .cervicalMucusQuality,
                canonicalTitle: "Cervical Mucus Quality",
            )
        )
    }
    /// A category sample type that records the result of an ovulation home test.
    @inlinable public static var ovulationTestResult: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.ovulationTestResult.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .ovulationTestResult,
                canonicalTitle: "Ovulation Test Result",
            )
        )
    }
    /// A category type that represents the results from a home progesterone test.
    @inlinable public static var progesteroneTestResult: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.progesteroneTestResult.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .progesteroneTestResult,
                canonicalTitle: "Progesterone Test Result",
            )
        )
    }
    /// A category sample type that records sexual activity.
    @inlinable public static var sexualActivity: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.sexualActivity.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .sexualActivity,
                canonicalTitle: "Sexual Activity",
            )
        )
    }
    /// A category sample type that records the use of contraceptives.
    @inlinable public static var contraceptive: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.contraceptive.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .contraceptive,
                canonicalTitle: "Contraceptive",
            )
        )
    }
    /// A category type that records pregnancy.
    @inlinable public static var pregnancy: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.pregnancy.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .pregnancy,
                canonicalTitle: "Pregnancy",
            )
        )
    }
    /// A category type that represents the results from a home pregnancy test.
    @inlinable public static var pregnancyTestResult: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.pregnancyTestResult.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .pregnancyTestResult,
                canonicalTitle: "Pregnancy Test Result",
            )
        )
    }
    /// A category type that records lactation.
    @inlinable public static var lactation: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.lactation.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .lactation,
                canonicalTitle: "Lactation",
            )
        )
    }
    /// A category sample type that records exposure to potentially damaging sounds from the environment.
    @inlinable public static var environmentalAudioExposureEvent: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.environmentalAudioExposureEvent.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .environmentalAudioExposureEvent,
                canonicalTitle: "Environmental Audio Exposure Event",
            )
        )
    }
    /// A category sample type that records exposure to potentially damaging sounds from headphones.
    @inlinable public static var headphoneAudioExposureEvent: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.headphoneAudioExposureEvent.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .headphoneAudioExposureEvent,
                canonicalTitle: "Headphone Audio Exposure Event",
            )
        )
    }
    /// A category sample type for low heart rate events.
    @inlinable public static var lowHeartRateEvent: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.lowHeartRateEvent.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .lowHeartRateEvent,
                canonicalTitle: "Low Heart Rate Event",
            )
        )
    }
    /// A category sample type for high heart rate events.
    @inlinable public static var highHeartRateEvent: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.highHeartRateEvent.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .highHeartRateEvent,
                canonicalTitle: "High Heart Rate Event",
            )
        )
    }
    /// A category sample type for irregular heart rhythm events.
    @inlinable public static var irregularHeartRhythmEvent: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.irregularHeartRhythmEvent.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .irregularHeartRhythmEvent,
                canonicalTitle: "Irregular Heart Rhythm Event",
            )
        )
    }
    /// A category sample type that records an incident where the user showed a reduced score for their gait’s steadiness.
    @inlinable public static var appleWalkingSteadinessEvent: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.appleWalkingSteadinessEvent.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .appleWalkingSteadinessEvent,
                canonicalTitle: "Apple Walking Steadiness Event",
            )
        )
    }
    /// A category sample type for recording a mindful session.
    @inlinable public static var mindfulSession: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.mindfulSession.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .mindfulSession,
                canonicalTitle: "Mindful Session",
            )
        )
    }
    /// A category sample type for sleep analysis information.
    @inlinable public static var sleepAnalysis: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.sleepAnalysis.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .sleepAnalysis,
                canonicalTitle: "Sleep Analysis",
            )
        )
    }
    /// A category sample type for toothbrushing events.
    @inlinable public static var toothbrushingEvent: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.toothbrushingEvent.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .toothbrushingEvent,
                canonicalTitle: "Toothbrushing Event",
            )
        )
    }
    /// A category sample type for handwashing events.
    @inlinable public static var handwashingEvent: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.handwashingEvent.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .handwashingEvent,
                canonicalTitle: "Handwashing Event",
            )
        )
    }
    /// A category type that records abdominal cramps as a symptom.
    @inlinable public static var abdominalCramps: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.abdominalCramps.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .abdominalCramps,
                canonicalTitle: "Abdominal Cramps",
            )
        )
    }
    /// A category type that records bloating as a symptom.
    @inlinable public static var bloating: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.bloating.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .bloating,
                canonicalTitle: "Bloating",
            )
        )
    }
    /// A category type that records constipation as a symptom.
    @inlinable public static var constipation: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.constipation.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .constipation,
                canonicalTitle: "Constipation",
            )
        )
    }
    /// A category type that records diarrhea as a symptom.
    @inlinable public static var diarrhea: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.diarrhea.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .diarrhea,
                canonicalTitle: "Diarrhea",
            )
        )
    }
    /// A category type that records heartburn as a symptom.
    @inlinable public static var heartburn: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.heartburn.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .heartburn,
                canonicalTitle: "Heartburn",
            )
        )
    }
    /// A category type that records nausea as a symptom.
    @inlinable public static var nausea: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.nausea.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .nausea,
                canonicalTitle: "Nausea",
            )
        )
    }
    /// A category type that records vomiting as a symptom.
    @inlinable public static var vomiting: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.vomiting.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .vomiting,
                canonicalTitle: "Vomiting",
            )
        )
    }
    /// A category type that records changes in appetite as a symptom.
    @inlinable public static var appetiteChanges: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.appetiteChanges.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .appetiteChanges,
                canonicalTitle: "Appetite Changes",
            )
        )
    }
    /// A category type that records chills as a symptom.
    @inlinable public static var chills: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.chills.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .chills,
                canonicalTitle: "Chills",
            )
        )
    }
    /// A category type that records dizziness as a symptom.
    @inlinable public static var dizziness: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.dizziness.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .dizziness,
                canonicalTitle: "Dizziness",
            )
        )
    }
    /// A category type that records fainting as a symptom.
    @inlinable public static var fainting: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.fainting.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .fainting,
                canonicalTitle: "Fainting",
            )
        )
    }
    /// A category type that records fatigue as a symptom.
    @inlinable public static var fatigue: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.fatigue.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .fatigue,
                canonicalTitle: "Fatigue",
            )
        )
    }
    /// A category type that records fever as a symptom.
    @inlinable public static var fever: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.fever.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .fever,
                canonicalTitle: "Fever",
            )
        )
    }
    /// A category type that records body ache as a symptom.
    @inlinable public static var generalizedBodyAche: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.generalizedBodyAche.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .generalizedBodyAche,
                canonicalTitle: "Generalized Body Ache",
            )
        )
    }
    /// A category type that records hot flashes as a symptom.
    @inlinable public static var hotFlashes: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.hotFlashes.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .hotFlashes,
                canonicalTitle: "Hot Flashes",
            )
        )
    }
    /// A category type that records chest tightness or pain as a symptom.
    @inlinable public static var chestTightnessOrPain: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.chestTightnessOrPain.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .chestTightnessOrPain,
                canonicalTitle: "Chest Tightness/Pain",
            )
        )
    }
    /// A category type that records coughing as a symptom.
    @inlinable public static var coughing: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.coughing.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .coughing,
                canonicalTitle: "Coughing",
            )
        )
    }
    /// A category type that records a rapid, pounding, or fluttering heartbeat as a symptom.
    @inlinable public static var rapidPoundingOrFlutteringHeartbeat: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.rapidPoundingOrFlutteringHeartbeat.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .rapidPoundingOrFlutteringHeartbeat,
                canonicalTitle: "Rapid/Pounding/Fluttering Heartbeat",
            )
        )
    }
    /// A category type that records shortness of breath as a symptom.
    @inlinable public static var shortnessOfBreath: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.shortnessOfBreath.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .shortnessOfBreath,
                canonicalTitle: "Shortness of Breath",
            )
        )
    }
    /// A category type that records skipped heartbeat as a symptom.
    @inlinable public static var skippedHeartbeat: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.skippedHeartbeat.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .skippedHeartbeat,
                canonicalTitle: "Skipped Heartbeat",
            )
        )
    }
    /// A category type that records wheezing as a symptom.
    @inlinable public static var wheezing: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.wheezing.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .wheezing,
                canonicalTitle: "Wheezing",
            )
        )
    }
    /// A category type that records lower back pain as a symptom.
    @inlinable public static var lowerBackPain: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.lowerBackPain.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .lowerBackPain,
                canonicalTitle: "Lower Back Pain",
            )
        )
    }
    /// A category type that records headache as a symptom.
    @inlinable public static var headache: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.headache.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .headache,
                canonicalTitle: "Headache",
            )
        )
    }
    /// A category type that records memory lapse as a symptom.
    @inlinable public static var memoryLapse: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.memoryLapse.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .memoryLapse,
                canonicalTitle: "Memory Lapse",
            )
        )
    }
    /// A category type that records mood changes as a symptom.
    @inlinable public static var moodChanges: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.moodChanges.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .moodChanges,
                canonicalTitle: "Mood Changes",
            )
        )
    }
    /// A category type that records loss of smell as a symptom.
    @inlinable public static var lossOfSmell: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.lossOfSmell.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .lossOfSmell,
                canonicalTitle: "Loss of Smell",
            )
        )
    }
    /// A category type that records loss of taste as a symptom.
    @inlinable public static var lossOfTaste: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.lossOfTaste.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .lossOfTaste,
                canonicalTitle: "Loss of Taste",
            )
        )
    }
    /// A category type that records runny nose as a symptom.
    @inlinable public static var runnyNose: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.runnyNose.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .runnyNose,
                canonicalTitle: "Runny Nose",
            )
        )
    }
    /// A category type that records sore throat as a symptom.
    @inlinable public static var soreThroat: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.soreThroat.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .soreThroat,
                canonicalTitle: "Sore Throat",
            )
        )
    }
    /// A category type that records sinus congestion as a symptom.
    @inlinable public static var sinusCongestion: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.sinusCongestion.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .sinusCongestion,
                canonicalTitle: "Sinus Congestion",
            )
        )
    }
    /// A category type that records breast pain as a symptom.
    @inlinable public static var breastPain: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.breastPain.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .breastPain,
                canonicalTitle: "Breast Pain",
            )
        )
    }
    /// A category type that records pelvic pain as a symptom.
    @inlinable public static var pelvicPain: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.pelvicPain.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .pelvicPain,
                canonicalTitle: "Pelvic Pain",
            )
        )
    }
    /// A category type that records vaginal dryness as a symptom.
    @inlinable public static var vaginalDryness: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.vaginalDryness.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .vaginalDryness,
                canonicalTitle: "Vaginal Dryness",
            )
        )
    }
    /// A category type that records bleeding during pregnancy as a symptom.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var bleedingDuringPregnancy: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.bleedingDuringPregnancy.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .bleedingDuringPregnancy,
                canonicalTitle: "Bleeding During Pregnancy",
            )
        )
    }
    /// A category type that records bleeding after pregnancy as a symptom.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var bleedingAfterPregnancy: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.bleedingAfterPregnancy.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .bleedingAfterPregnancy,
                canonicalTitle: "Bleeding After Pregnancy",
            )
        )
    }
    /// A category type that records acne as a symptom.
    @inlinable public static var acne: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.acne.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .acne,
                canonicalTitle: "Acne",
            )
        )
    }
    /// A category type that records dry skin as a symptom.
    @inlinable public static var drySkin: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.drySkin.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .drySkin,
                canonicalTitle: "Dry Skin",
            )
        )
    }
    /// A category type that records hair loss as a symptom.
    @inlinable public static var hairLoss: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.hairLoss.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .hairLoss,
                canonicalTitle: "Hair Loss",
            )
        )
    }
    /// A category type that records night sweats as a symptom.
    @inlinable public static var nightSweats: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.nightSweats.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .nightSweats,
                canonicalTitle: "Night Sweats",
            )
        )
    }
    /// A category type that records sleep changes as a symptom.
    @inlinable public static var sleepChanges: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.sleepChanges.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .sleepChanges,
                canonicalTitle: "Sleep Changes",
            )
        )
    }
    /// A category type that records sleep apnea as a symptom.
    @available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
    @inlinable public static var sleepApneaEvent: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.sleepApneaEvent.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .sleepApneaEvent,
                canonicalTitle: "Sleep Apnea Event",
            )
        )
    }
    /// A category type that records bladder incontinence as a symptom.
    @inlinable public static var bladderIncontinence: SampleType<HKCategorySample> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.bladderIncontinence.rawValue,
            as: SampleType<HKCategorySample>.self,
            default: .category(
                .bladderIncontinence,
                canonicalTitle: "Bladder Incontinence",
            )
        )
    }

    /// Returns the shared Category type for the specified HKCategoryType.
    @inlinable
    public init?(_ hkType: HKCategoryType) {
        self.init(HKCategoryTypeIdentifier(rawValue: hkType.identifier))
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

extension SampleType where Sample == HKCategorySample {
    /// All well-known Category types.
    @inlinable public static var allKnownCategories: Set<SampleType<HKCategorySample>> {
        HKCategoryType._allKnownCategories
    }
}

extension HKCategoryType {
    /// All well-known `HKCategoryType`s
    public static let allKnownCategories: Set<HKCategoryType> = Set(
        HKCategoryTypeIdentifier.allKnownIdentifiers.map { HKCategoryType($0) }
    )
    
    /// The set of all well-known HKCategoryType instances.
    ///
    /// Stored here rather than in `SampleType` bc that type is generic and the static property would get re-computed on each access,
    /// which is expensive.
    @usableFromInline static let _allKnownCategories: Set<SampleType<HKCategorySample>> = {
        HKCategoryType.allKnownCategories.compactMapIntoSet { $0.sampleType as? SampleType<HKCategorySample> }
    }()
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
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.bloodPressure.rawValue,
            as: SampleType<HKCorrelation>.self,
            default: .correlation(
                .bloodPressure,
                canonicalTitle: "Blood Pressure",
                associatedQuantityTypes: [.bloodPressureDiastolic, .bloodPressureSystolic]
            )
        )
    }
    /// Food correlation types combine any number of nutritional samples into a single food object.
    @inlinable public static var food: SampleType<HKCorrelation> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.food.rawValue,
            as: SampleType<HKCorrelation>.self,
            default: .correlation(
                .food,
                canonicalTitle: "Food",
                associatedQuantityTypes: [.dietaryEnergyConsumed, .dietaryCarbohydrates, .dietaryFiber, .dietarySugar, .dietaryFatTotal, .dietaryFatMonounsaturated, .dietaryFatPolyunsaturated, .dietaryFatSaturated, .dietaryCholesterol, .dietaryProtein, .dietaryVitaminA, .dietaryThiamin, .dietaryRiboflavin, .dietaryNiacin, .dietaryPantothenicAcid, .dietaryVitaminB6, .dietaryBiotin, .dietaryVitaminB12, .dietaryVitaminC, .dietaryVitaminD, .dietaryVitaminE, .dietaryVitaminK, .dietaryFolate, .dietaryCalcium, .dietaryChloride, .dietaryIron, .dietaryMagnesium, .dietaryPhosphorus, .dietaryPotassium, .dietarySodium, .dietaryZinc, .dietaryWater, .dietaryCaffeine, .dietaryChromium, .dietaryCopper, .dietaryIodine, .dietaryManganese, .dietaryMolybdenum, .dietarySelenium]
            )
        )
    }

    /// Returns the shared Correlation type for the specified HKCorrelationType.
    @inlinable
    public init?(_ hkType: HKCorrelationType) {
        self.init(HKCorrelationTypeIdentifier(rawValue: hkType.identifier))
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

extension SampleType where Sample == HKCorrelation {
    /// All well-known Correlation types.
    @inlinable public static var allKnownCorrelations: Set<SampleType<HKCorrelation>> {
        HKCorrelationType._allKnownCorrelations
    }
}

extension HKCorrelationType {
    /// All well-known `HKCorrelationType`s
    public static let allKnownCorrelations: Set<HKCorrelationType> = Set(
        HKCorrelationTypeIdentifier.allKnownIdentifiers.map { HKCorrelationType($0) }
    )
    
    /// The set of all well-known HKCorrelationType instances.
    ///
    /// Stored here rather than in `SampleType` bc that type is generic and the static property would get re-computed on each access,
    /// which is expensive.
    @usableFromInline static let _allKnownCorrelations: Set<SampleType<HKCorrelation>> = {
        HKCorrelationType.allKnownCorrelations.compactMapIntoSet { $0.sampleType as? SampleType<HKCorrelation> }
    }()
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
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.allergyRecord.rawValue,
            as: SampleType<HKClinicalRecord>.self,
            default: .clinical(
                .allergyRecord,
                canonicalTitle: "Allergy Record",
            )
        )
    }
    /// A type identifier for records of clinical notes.
    @inlinable public static var clinicalNoteRecord: SampleType<HKClinicalRecord> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.clinicalNoteRecord.rawValue,
            as: SampleType<HKClinicalRecord>.self,
            default: .clinical(
                .clinicalNoteRecord,
                canonicalTitle: "Clinical Note Record",
            )
        )
    }
    /// A type identifier for records of a condition, problem, diagnosis, or other event.
    @inlinable public static var conditionRecord: SampleType<HKClinicalRecord> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.conditionRecord.rawValue,
            as: SampleType<HKClinicalRecord>.self,
            default: .clinical(
                .conditionRecord,
                canonicalTitle: "Condition Record",
            )
        )
    }
    /// A type identifier for records of the current or historical administration of vaccines.
    @inlinable public static var immunizationRecord: SampleType<HKClinicalRecord> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.immunizationRecord.rawValue,
            as: SampleType<HKClinicalRecord>.self,
            default: .clinical(
                .immunizationRecord,
                canonicalTitle: "Immunization Record",
            )
        )
    }
    /// A type identifier for records of lab results.
    @inlinable public static var labResultRecord: SampleType<HKClinicalRecord> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.labResultRecord.rawValue,
            as: SampleType<HKClinicalRecord>.self,
            default: .clinical(
                .labResultRecord,
                canonicalTitle: "Lab Result Record",
            )
        )
    }
    /// A type identifier for records of medication.
    @inlinable public static var medicationRecord: SampleType<HKClinicalRecord> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.medicationRecord.rawValue,
            as: SampleType<HKClinicalRecord>.self,
            default: .clinical(
                .medicationRecord,
                canonicalTitle: "Medication Record",
            )
        )
    }
    /// A type identifier for records of procedures.
    @inlinable public static var procedureRecord: SampleType<HKClinicalRecord> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.procedureRecord.rawValue,
            as: SampleType<HKClinicalRecord>.self,
            default: .clinical(
                .procedureRecord,
                canonicalTitle: "Procedure Record",
            )
        )
    }
    /// A type identifier for records of vital signs.
    @inlinable public static var vitalSignRecord: SampleType<HKClinicalRecord> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.vitalSignRecord.rawValue,
            as: SampleType<HKClinicalRecord>.self,
            default: .clinical(
                .vitalSignRecord,
                canonicalTitle: "Vital Sign Record",
            )
        )
    }
    /// A type identifier for records containing information about the user’s insurance coverage.
    @inlinable public static var coverageRecord: SampleType<HKClinicalRecord> {
        SampleTypeCache.get(
            identifier: Sample._SampleType._Identifier.coverageRecord.rawValue,
            as: SampleType<HKClinicalRecord>.self,
            default: .clinical(
                .coverageRecord,
                canonicalTitle: "Coverage Record",
            )
        )
    }

    /// Returns the shared Clinical Record type for the specified HKClinicalType.
    @inlinable
    public init?(_ hkType: HKClinicalType) {
        self.init(HKClinicalTypeIdentifier(rawValue: hkType.identifier))
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

extension SampleType where Sample == HKClinicalRecord {
    /// All well-known Clinical Record types.
    @inlinable public static var allKnownClinicalRecords: Set<SampleType<HKClinicalRecord>> {
        HKClinicalType._allKnownClinicalRecords
    }
}

extension HKClinicalType {
    /// All well-known `HKClinicalType`s
    public static let allKnownClinicalRecords: Set<HKClinicalType> = Set(
        HKClinicalTypeIdentifier.allKnownIdentifiers.map { HKClinicalType($0) }
    )
    
    /// The set of all well-known HKClinicalType instances.
    ///
    /// Stored here rather than in `SampleType` bc that type is generic and the static property would get re-computed on each access,
    /// which is expensive.
    @usableFromInline static let _allKnownClinicalRecords: Set<SampleType<HKClinicalRecord>> = {
        HKClinicalType.allKnownClinicalRecords.compactMapIntoSet { $0.sampleType as? SampleType<HKClinicalRecord> }
    }()
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
        types.formUnion(HKCharacteristicTypeIdentifier.allKnownIdentifiers.map { HKCharacteristicType($0) })
        // types.formUnion(SampleType<HKQuantitySample>.otherSampleTypes.map(\.hkSampleType))
        types.insert(SampleType.electrocardiogram.hkSampleType)
        types.insert(SampleType.audiogram.hkSampleType)
        types.insert(SampleType.workout.hkSampleType)
        types.insert(SampleType.visionPrescription.hkSampleType)
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            types.insert(SampleType.stateOfMind.hkSampleType)
        }
        types.insert(SampleType.heartbeatSeries.hkSampleType)
        types.insert(SampleType.workoutRoute.hkSampleType)
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            types.insert(SampleType.gad7.hkSampleType)
        }
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            types.insert(SampleType.phq9.hkSampleType)
        }
        return types
    }()
}


// MARK: Other Sample Types

extension SampleType where Sample == HKElectrocardiogram {
    /// The electrocardiogram sample type
    @inlinable public static var electrocardiogram: SampleType<HKElectrocardiogram> {
        SampleTypeCache.get(
            identifier: HKSampleType.electrocardiogramType().identifier,
            as: SampleType<HKElectrocardiogram>.self,
            default: .init(HKSampleType.electrocardiogramType(), canonicalTitle: "ECG", variant: .other)
        )
    }
}

extension SampleType where Sample == HKAudiogramSample {
    /// The audiogram sample type
    @inlinable public static var audiogram: SampleType<HKAudiogramSample> {
        SampleTypeCache.get(
            identifier: HKSampleType.audiogramSampleType().identifier,
            as: SampleType<HKAudiogramSample>.self,
            default: .init(HKSampleType.audiogramSampleType(), canonicalTitle: "Audiogram", variant: .other)
        )
    }
}

extension SampleType where Sample == HKWorkout {
    /// The workout sample type
    @inlinable public static var workout: SampleType<HKWorkout> {
        SampleTypeCache.get(
            identifier: HKSampleType.workoutType().identifier,
            as: SampleType<HKWorkout>.self,
            default: .init(HKSampleType.workoutType(), canonicalTitle: "Workout", variant: .other)
        )
    }
}

extension SampleType where Sample == HKVisionPrescription {
    /// The vision prescription sample type
    @inlinable public static var visionPrescription: SampleType<HKVisionPrescription> {
        SampleTypeCache.get(
            identifier: HKSampleType.visionPrescriptionType().identifier,
            as: SampleType<HKVisionPrescription>.self,
            default: .init(HKSampleType.visionPrescriptionType(), canonicalTitle: "Vision Prescription", variant: .other)
        )
    }
}

@available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
extension SampleType where Sample == HKStateOfMind {
    /// The state of mind sample type
    @inlinable public static var stateOfMind: SampleType<HKStateOfMind> {
        SampleTypeCache.get(
            identifier: HKSampleType.stateOfMindType().identifier,
            as: SampleType<HKStateOfMind>.self,
            default: .init(HKSampleType.stateOfMindType(), canonicalTitle: "State of Mind", variant: .other)
        )
    }
}

extension SampleType where Sample == HKHeartbeatSeriesSample {
    /// The heartbeat series sample type
    @inlinable public static var heartbeatSeries: SampleType<HKHeartbeatSeriesSample> {
        SampleTypeCache.get(
            identifier: HKSeriesType.heartbeat().identifier,
            as: SampleType<HKHeartbeatSeriesSample>.self,
            default: .init(HKSeriesType.heartbeat(), canonicalTitle: "Heartbeat Series", variant: .other)
        )
    }
}

extension SampleType where Sample == HKWorkoutRoute {
    /// The workout route sample type
    @inlinable public static var workoutRoute: SampleType<HKWorkoutRoute> {
        SampleTypeCache.get(
            identifier: HKSeriesType.workoutRoute().identifier,
            as: SampleType<HKWorkoutRoute>.self,
            default: .init(HKSeriesType.workoutRoute(), canonicalTitle: "Workout Route", variant: .other)
        )
    }
}

@available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
extension SampleType where Sample == HKGAD7Assessment {
    /// The GAD-7 (generalized anxiety disorder 7) score type
    @inlinable public static var gad7: SampleType<HKGAD7Assessment> {
        SampleTypeCache.get(
            identifier: HKScoredAssessmentType(.GAD7).identifier,
            as: SampleType<HKGAD7Assessment>.self,
            default: .init(HKScoredAssessmentType(.GAD7), canonicalTitle: "GAD-7", variant: .other)
        )
    }
}

@available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
extension SampleType where Sample == HKPHQ9Assessment {
    /// The PHQ-9 (nine-item Patient Health Questionnaire) score type
    @inlinable public static var phq9: SampleType<HKPHQ9Assessment> {
        SampleTypeCache.get(
            identifier: HKScoredAssessmentType(.PHQ9).identifier,
            as: SampleType<HKPHQ9Assessment>.self,
            default: .init(HKScoredAssessmentType(.PHQ9), canonicalTitle: "PHQ-9", variant: .other)
        )
    }
}


extension SampleType {
    /// All currently-known "other" sample types, which are not quantity, correlation, category, or clinical samples.
    ///
    /// - Note: `SampleType<T>.otherSampleTypes` will always return the same value, regardless of the concrete sample type chosen for `T`.
    public static var otherSampleTypes: [any AnySampleType] {
        var retval: [any AnySampleType] = []
        retval.append(SpeziHealthKit.SampleType.electrocardiogram)
        retval.append(SpeziHealthKit.SampleType.audiogram)
        retval.append(SpeziHealthKit.SampleType.workout)
        retval.append(SpeziHealthKit.SampleType.visionPrescription)
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            retval.append(SpeziHealthKit.SampleType.stateOfMind)
        }
        retval.append(SpeziHealthKit.SampleType.heartbeatSeries)
        retval.append(SpeziHealthKit.SampleType.workoutRoute)
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            retval.append(SpeziHealthKit.SampleType.gad7)
        }
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *) {
            retval.append(SpeziHealthKit.SampleType.phq9)
        }
        return retval
    }
}


extension HKCharacteristicTypeIdentifier {
    /// All well-known `HKCharacteristicTypeIdentifier`s
    public static let allKnownIdentifiers: Set<HKCharacteristicTypeIdentifier> = [
        .activityMoveMode,
        .biologicalSex,
        .bloodType,
        .dateOfBirth,
        .fitzpatrickSkinType,
        .wheelchairUse
    ]
}
