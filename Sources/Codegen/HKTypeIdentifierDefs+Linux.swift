//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


// NOTE: This file was automatically generated and should not be edited.
// swiftlint:disable all

#if canImport(HealthKit)

import HealthKit


public enum SampleTypeIdentifierDefinition: Sendable {
    /// Definition of a HK type identifier constant (eg a global variable or a static property)
    public struct IdentifierConstDef: Sendable {
        /// The name of the definition's identifier, in its respective context.
        public let identifierName: String
        /// The definition's raw value.
        public let rawValue: String
        /// The definition's documentation.
        public let docComment: String
    }

    case staticProperty(parentStruct: String, IdentifierConstDef)
    case globalVariable(IdentifierConstDef)
}



extension SampleTypeIdentifierDefinition {
    @available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2, *)
    public static let definitions: [SampleTypeIdentifierDefinition] = [
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "stepCount",
                rawValue: HKQuantityTypeIdentifier.stepCount.rawValue,
                docComment: "A quantity sample type that measures the number of steps the user has taken."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "distanceWalkingRunning",
                rawValue: HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
                docComment: "A quantity sample type that measures the distance the user has moved by walking or running."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "runningGroundContactTime",
                rawValue: HKQuantityTypeIdentifier.runningGroundContactTime.rawValue,
                docComment: "A quantity sample type that measures the amount of time the runner’s foot is in contact with the ground while running."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "runningPower",
                rawValue: HKQuantityTypeIdentifier.runningPower.rawValue,
                docComment: "A quantity sample type that measures the rate of work required for the runner to maintain their speed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "runningSpeed",
                rawValue: HKQuantityTypeIdentifier.runningSpeed.rawValue,
                docComment: "A quantity sample type that measures the runner’s speed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "runningStrideLength",
                rawValue: HKQuantityTypeIdentifier.runningStrideLength.rawValue,
                docComment: "A quantity sample type that measures the distance covered by a single step while running."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "runningVerticalOscillation",
                rawValue: HKQuantityTypeIdentifier.runningVerticalOscillation.rawValue,
                docComment: "A quantity sample type measuring pelvis vertical range of motion during a single running stride."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "distanceCycling",
                rawValue: HKQuantityTypeIdentifier.distanceCycling.rawValue,
                docComment: "A quantity sample type that measures the distance the user has moved by cycling."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "pushCount",
                rawValue: HKQuantityTypeIdentifier.pushCount.rawValue,
                docComment: "A quantity sample type that measures the number of pushes that the user has performed while using a wheelchair."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "distanceWheelchair",
                rawValue: HKQuantityTypeIdentifier.distanceWheelchair.rawValue,
                docComment: "A quantity sample type that measures the distance the user has moved using a wheelchair."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "swimmingStrokeCount",
                rawValue: HKQuantityTypeIdentifier.swimmingStrokeCount.rawValue,
                docComment: "A quantity sample type that measures the number of strokes performed while swimming."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "distanceSwimming",
                rawValue: HKQuantityTypeIdentifier.distanceSwimming.rawValue,
                docComment: "A quantity sample type that measures the distance the user has moved while swimming."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "distanceDownhillSnowSports",
                rawValue: HKQuantityTypeIdentifier.distanceDownhillSnowSports.rawValue,
                docComment: "A quantity sample type that measures the distance the user has traveled while skiing or snowboarding."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "basalEnergyBurned",
                rawValue: HKQuantityTypeIdentifier.basalEnergyBurned.rawValue,
                docComment: "A quantity sample type that measures the resting energy burned by the user."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "activeEnergyBurned",
                rawValue: HKQuantityTypeIdentifier.activeEnergyBurned.rawValue,
                docComment: "A quantity sample type that measures the amount of active energy the user has burned."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "flightsClimbed",
                rawValue: HKQuantityTypeIdentifier.flightsClimbed.rawValue,
                docComment: "A quantity sample type that measures the number flights of stairs that the user has climbed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "nikeFuel",
                rawValue: HKQuantityTypeIdentifier.nikeFuel.rawValue,
                docComment: "A quantity sample type that measures the number of NikeFuel points the user has earned."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "appleExerciseTime",
                rawValue: HKQuantityTypeIdentifier.appleExerciseTime.rawValue,
                docComment: "A quantity sample type that measures the amount of time the user spent exercising."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "appleMoveTime",
                rawValue: HKQuantityTypeIdentifier.appleMoveTime.rawValue,
                docComment: "A quantity sample type that measures the amount of time the user has spent performing activities that involve full-body movements during the specified day."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "appleStandTime",
                rawValue: HKQuantityTypeIdentifier.appleStandTime.rawValue,
                docComment: "A quantity sample type that measures the amount of time the user has spent standing."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "vo2Max",
                rawValue: HKQuantityTypeIdentifier.vo2Max.rawValue,
                docComment: "A quantity sample that measures the maximal oxygen consumption during exercise."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "height",
                rawValue: HKQuantityTypeIdentifier.height.rawValue,
                docComment: "A quantity sample type that measures the user’s height."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "bodyMass",
                rawValue: HKQuantityTypeIdentifier.bodyMass.rawValue,
                docComment: "A quantity sample type that measures the user’s weight."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "bodyMassIndex",
                rawValue: HKQuantityTypeIdentifier.bodyMassIndex.rawValue,
                docComment: "A quantity sample type that measures the user’s body mass index."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "leanBodyMass",
                rawValue: HKQuantityTypeIdentifier.leanBodyMass.rawValue,
                docComment: "A quantity sample type that measures the user’s lean body mass."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "bodyFatPercentage",
                rawValue: HKQuantityTypeIdentifier.bodyFatPercentage.rawValue,
                docComment: "A quantity sample type that measures the user’s body fat percentage."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "waistCircumference",
                rawValue: HKQuantityTypeIdentifier.waistCircumference.rawValue,
                docComment: "A quantity sample type that measures the user’s waist circumference."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "appleSleepingWristTemperature",
                rawValue: HKQuantityTypeIdentifier.appleSleepingWristTemperature.rawValue,
                docComment: "A quantity sample type that records the wrist temperature during sleep."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "basalBodyTemperature",
                rawValue: HKQuantityTypeIdentifier.basalBodyTemperature.rawValue,
                docComment: "A quantity sample type that records the user’s basal body temperature."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "environmentalAudioExposure",
                rawValue: HKQuantityTypeIdentifier.environmentalAudioExposure.rawValue,
                docComment: "A quantity sample type that measures audio exposure to sounds in the environment."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "headphoneAudioExposure",
                rawValue: HKQuantityTypeIdentifier.headphoneAudioExposure.rawValue,
                docComment: "A quantity sample type that measures audio exposure from headphones."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "heartRate",
                rawValue: HKQuantityTypeIdentifier.heartRate.rawValue,
                docComment: "A quantity sample type that measures the user’s heart rate."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "restingHeartRate",
                rawValue: HKQuantityTypeIdentifier.restingHeartRate.rawValue,
                docComment: "A quantity sample type that measures the user’s resting heart rate."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "walkingHeartRateAverage",
                rawValue: HKQuantityTypeIdentifier.walkingHeartRateAverage.rawValue,
                docComment: "A quantity sample type that measures the user’s heart rate while walking."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "heartRateVariabilitySDNN",
                rawValue: HKQuantityTypeIdentifier.heartRateVariabilitySDNN.rawValue,
                docComment: "A quantity sample type that measures the standard deviation of heartbeat intervals."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "heartRateRecoveryOneMinute",
                rawValue: HKQuantityTypeIdentifier.heartRateRecoveryOneMinute.rawValue,
                docComment: "A quantity sample that records the reduction in heart rate from the peak exercise rate to the rate one minute after exercising ended."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "atrialFibrillationBurden",
                rawValue: HKQuantityTypeIdentifier.atrialFibrillationBurden.rawValue,
                docComment: "A quantity type that measures an estimate of the percentage of time a person’s heart shows signs of atrial fibrillation (AFib) while wearing Apple Watch."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "oxygenSaturation",
                rawValue: HKQuantityTypeIdentifier.oxygenSaturation.rawValue,
                docComment: "A quantity sample type that measures the user’s oxygen saturation."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "bodyTemperature",
                rawValue: HKQuantityTypeIdentifier.bodyTemperature.rawValue,
                docComment: "A quantity sample type that measures the user’s body temperature."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "bloodPressureDiastolic",
                rawValue: HKQuantityTypeIdentifier.bloodPressureDiastolic.rawValue,
                docComment: "A quantity sample type that measures the user’s diastolic blood pressure."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "bloodPressureSystolic",
                rawValue: HKQuantityTypeIdentifier.bloodPressureSystolic.rawValue,
                docComment: "A quantity sample type that measures the user’s systolic blood pressure."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "respiratoryRate",
                rawValue: HKQuantityTypeIdentifier.respiratoryRate.rawValue,
                docComment: "A quantity sample type that measures the user’s respiratory rate."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "bloodGlucose",
                rawValue: HKQuantityTypeIdentifier.bloodGlucose.rawValue,
                docComment: "A quantity sample type that measures the user’s blood glucose level."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "electrodermalActivity",
                rawValue: HKQuantityTypeIdentifier.electrodermalActivity.rawValue,
                docComment: "A quantity sample type that measures electrodermal activity."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "forcedExpiratoryVolume1",
                rawValue: HKQuantityTypeIdentifier.forcedExpiratoryVolume1.rawValue,
                docComment: "A quantity sample type that measures the amount of air that can be forcibly exhaled from the lungs during the first second of a forced exhalation."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "forcedVitalCapacity",
                rawValue: HKQuantityTypeIdentifier.forcedVitalCapacity.rawValue,
                docComment: "A quantity sample type that measures the amount of air that can be forcibly exhaled from the lungs after taking the deepest breath possible."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "inhalerUsage",
                rawValue: HKQuantityTypeIdentifier.inhalerUsage.rawValue,
                docComment: "A quantity sample type that measures the number of puffs the user takes from their inhaler."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "insulinDelivery",
                rawValue: HKQuantityTypeIdentifier.insulinDelivery.rawValue,
                docComment: "A quantity sample that measures the amount of insulin delivered."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "numberOfTimesFallen",
                rawValue: HKQuantityTypeIdentifier.numberOfTimesFallen.rawValue,
                docComment: "A quantity sample type that measures the number of times the user fell."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "peakExpiratoryFlowRate",
                rawValue: HKQuantityTypeIdentifier.peakExpiratoryFlowRate.rawValue,
                docComment: "A quantity sample type that measures the user’s maximum flow rate generated during a forceful exhalation."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "peripheralPerfusionIndex",
                rawValue: HKQuantityTypeIdentifier.peripheralPerfusionIndex.rawValue,
                docComment: "A quantity sample type that measures the user’s peripheral perfusion index."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryBiotin",
                rawValue: HKQuantityTypeIdentifier.dietaryBiotin.rawValue,
                docComment: "A quantity sample type that measures the amount of biotin (vitamin B7) consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryCaffeine",
                rawValue: HKQuantityTypeIdentifier.dietaryCaffeine.rawValue,
                docComment: "A quantity sample type that measures the amount of caffeine consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryCalcium",
                rawValue: HKQuantityTypeIdentifier.dietaryCalcium.rawValue,
                docComment: "A quantity sample type that measures the amount of calcium consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryCarbohydrates",
                rawValue: HKQuantityTypeIdentifier.dietaryCarbohydrates.rawValue,
                docComment: "A quantity sample type that measures the amount of carbohydrates consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryChloride",
                rawValue: HKQuantityTypeIdentifier.dietaryChloride.rawValue,
                docComment: "A quantity sample type that measures the amount of chloride consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryCholesterol",
                rawValue: HKQuantityTypeIdentifier.dietaryCholesterol.rawValue,
                docComment: "A quantity sample type that measures the amount of cholesterol consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryChromium",
                rawValue: HKQuantityTypeIdentifier.dietaryChromium.rawValue,
                docComment: "A quantity sample type that measures the amount of chromium consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryCopper",
                rawValue: HKQuantityTypeIdentifier.dietaryCopper.rawValue,
                docComment: "A quantity sample type that measures the amount of copper consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryEnergyConsumed",
                rawValue: HKQuantityTypeIdentifier.dietaryEnergyConsumed.rawValue,
                docComment: "A quantity sample type that measures the amount of energy consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryFatMonounsaturated",
                rawValue: HKQuantityTypeIdentifier.dietaryFatMonounsaturated.rawValue,
                docComment: "A quantity sample type that measures the amount of monounsaturated fat consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryFatPolyunsaturated",
                rawValue: HKQuantityTypeIdentifier.dietaryFatPolyunsaturated.rawValue,
                docComment: "A quantity sample type that measures the amount of polyunsaturated fat consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryFatSaturated",
                rawValue: HKQuantityTypeIdentifier.dietaryFatSaturated.rawValue,
                docComment: "A quantity sample type that measures the amount of saturated fat consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryFatTotal",
                rawValue: HKQuantityTypeIdentifier.dietaryFatTotal.rawValue,
                docComment: "A quantity sample type that measures the total amount of fat consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryFiber",
                rawValue: HKQuantityTypeIdentifier.dietaryFiber.rawValue,
                docComment: "A quantity sample type that measures the amount of fiber consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryFolate",
                rawValue: HKQuantityTypeIdentifier.dietaryFolate.rawValue,
                docComment: "A quantity sample type that measures the amount of folate (folic acid) consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryIodine",
                rawValue: HKQuantityTypeIdentifier.dietaryIodine.rawValue,
                docComment: "A quantity sample type that measures the amount of iodine consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryIron",
                rawValue: HKQuantityTypeIdentifier.dietaryIron.rawValue,
                docComment: "A quantity sample type that measures the amount of iron consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryMagnesium",
                rawValue: HKQuantityTypeIdentifier.dietaryMagnesium.rawValue,
                docComment: "A quantity sample type that measures the amount of magnesium consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryManganese",
                rawValue: HKQuantityTypeIdentifier.dietaryManganese.rawValue,
                docComment: "A quantity sample type that measures the amount of manganese consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryMolybdenum",
                rawValue: HKQuantityTypeIdentifier.dietaryMolybdenum.rawValue,
                docComment: "A quantity sample type that measures the amount of molybdenum consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryNiacin",
                rawValue: HKQuantityTypeIdentifier.dietaryNiacin.rawValue,
                docComment: "A quantity sample type that measures the amount of niacin (vitamin B3) consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryPantothenicAcid",
                rawValue: HKQuantityTypeIdentifier.dietaryPantothenicAcid.rawValue,
                docComment: "A quantity sample type that measures the amount of pantothenic acid (vitamin B5) consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryPhosphorus",
                rawValue: HKQuantityTypeIdentifier.dietaryPhosphorus.rawValue,
                docComment: "A quantity sample type that measures the amount of phosphorus consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryPotassium",
                rawValue: HKQuantityTypeIdentifier.dietaryPotassium.rawValue,
                docComment: "A quantity sample type that measures the amount of potassium consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryProtein",
                rawValue: HKQuantityTypeIdentifier.dietaryProtein.rawValue,
                docComment: "A quantity sample type that measures the amount of protein consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryRiboflavin",
                rawValue: HKQuantityTypeIdentifier.dietaryRiboflavin.rawValue,
                docComment: "A quantity sample type that measures the amount of riboflavin (vitamin B2) consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietarySelenium",
                rawValue: HKQuantityTypeIdentifier.dietarySelenium.rawValue,
                docComment: "A quantity sample type that measures the amount of selenium consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietarySodium",
                rawValue: HKQuantityTypeIdentifier.dietarySodium.rawValue,
                docComment: "A quantity sample type that measures the amount of sodium consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietarySugar",
                rawValue: HKQuantityTypeIdentifier.dietarySugar.rawValue,
                docComment: "A quantity sample type that measures the amount of sugar consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryThiamin",
                rawValue: HKQuantityTypeIdentifier.dietaryThiamin.rawValue,
                docComment: "A quantity sample type that measures the amount of thiamin (vitamin B1) consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryVitaminA",
                rawValue: HKQuantityTypeIdentifier.dietaryVitaminA.rawValue,
                docComment: "A quantity sample type that measures the amount of vitamin A consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryVitaminB12",
                rawValue: HKQuantityTypeIdentifier.dietaryVitaminB12.rawValue,
                docComment: "A quantity sample type that measures the amount of cyanocobalamin (vitamin B12) consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryVitaminB6",
                rawValue: HKQuantityTypeIdentifier.dietaryVitaminB6.rawValue,
                docComment: "A quantity sample type that measures the amount of pyridoxine (vitamin B6) consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryVitaminC",
                rawValue: HKQuantityTypeIdentifier.dietaryVitaminC.rawValue,
                docComment: "A quantity sample type that measures the amount of vitamin C consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryVitaminD",
                rawValue: HKQuantityTypeIdentifier.dietaryVitaminD.rawValue,
                docComment: "A quantity sample type that measures the amount of vitamin D consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryVitaminE",
                rawValue: HKQuantityTypeIdentifier.dietaryVitaminE.rawValue,
                docComment: "A quantity sample type that measures the amount of vitamin E consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryVitaminK",
                rawValue: HKQuantityTypeIdentifier.dietaryVitaminK.rawValue,
                docComment: "A quantity sample type that measures the amount of vitamin K consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryWater",
                rawValue: HKQuantityTypeIdentifier.dietaryWater.rawValue,
                docComment: "A quantity sample type that measures the amount of water consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dietaryZinc",
                rawValue: HKQuantityTypeIdentifier.dietaryZinc.rawValue,
                docComment: "A quantity sample type that measures the amount of zinc consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "bloodAlcoholContent",
                rawValue: HKQuantityTypeIdentifier.bloodAlcoholContent.rawValue,
                docComment: "A quantity sample type that measures the user’s blood alcohol content."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "numberOfAlcoholicBeverages",
                rawValue: HKQuantityTypeIdentifier.numberOfAlcoholicBeverages.rawValue,
                docComment: "A quantity sample type that measures the number of standard alcoholic drinks that the user has consumed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "appleWalkingSteadiness",
                rawValue: HKQuantityTypeIdentifier.appleWalkingSteadiness.rawValue,
                docComment: "A quantity sample type that measures the steadiness of the user’s gait."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "sixMinuteWalkTestDistance",
                rawValue: HKQuantityTypeIdentifier.sixMinuteWalkTestDistance.rawValue,
                docComment: "A quantity sample type that stores the distance a user can walk during a six-minute walk test."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "walkingSpeed",
                rawValue: HKQuantityTypeIdentifier.walkingSpeed.rawValue,
                docComment: "A quantity sample type that measures the user’s average speed when walking steadily over flat ground."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "walkingStepLength",
                rawValue: HKQuantityTypeIdentifier.walkingStepLength.rawValue,
                docComment: "A quantity sample type that measures the average length of the user’s step when walking steadily over flat ground."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "walkingAsymmetryPercentage",
                rawValue: HKQuantityTypeIdentifier.walkingAsymmetryPercentage.rawValue,
                docComment: "A quantity sample type that measures the percentage of steps in which one foot moves at a different speed than the other when walking on flat ground."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "walkingDoubleSupportPercentage",
                rawValue: HKQuantityTypeIdentifier.walkingDoubleSupportPercentage.rawValue,
                docComment: "A quantity sample type that measures the percentage of time when both of the user’s feet touch the ground while walking steadily over flat ground."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "stairAscentSpeed",
                rawValue: HKQuantityTypeIdentifier.stairAscentSpeed.rawValue,
                docComment: "A quantity sample type measuring the user’s speed while climbing a flight of stairs."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "stairDescentSpeed",
                rawValue: HKQuantityTypeIdentifier.stairDescentSpeed.rawValue,
                docComment: "A quantity sample type measuring the user’s speed while descending a flight of stairs."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "uvExposure",
                rawValue: HKQuantityTypeIdentifier.uvExposure.rawValue,
                docComment: "A quantity sample type that measures the user’s exposure to UV radiation."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "underwaterDepth",
                rawValue: HKQuantityTypeIdentifier.underwaterDepth.rawValue,
                docComment: "A quantity sample that records a person’s depth underwater."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "waterTemperature",
                rawValue: HKQuantityTypeIdentifier.waterTemperature.rawValue,
                docComment: " A quantity sample that records the water temperature."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "appleSleepingBreathingDisturbances",
                rawValue: HKQuantityTypeIdentifier.appleSleepingBreathingDisturbances.rawValue,
                docComment: "A quantity sample that records breathing disturbances during sleep."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "crossCountrySkiingSpeed",
                rawValue: HKQuantityTypeIdentifier.crossCountrySkiingSpeed.rawValue,
                docComment: "A quantity sample that records cross-country skiing speed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "cyclingCadence",
                rawValue: HKQuantityTypeIdentifier.cyclingCadence.rawValue,
                docComment: "A quantity sample that records cycling cadence."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "cyclingFunctionalThresholdPower",
                rawValue: HKQuantityTypeIdentifier.cyclingFunctionalThresholdPower.rawValue,
                docComment: "A quantity sample that records cycling functional threshold power."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "cyclingPower",
                rawValue: HKQuantityTypeIdentifier.cyclingPower.rawValue,
                docComment: "A quantity sample that records cycling power."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "cyclingSpeed",
                rawValue: HKQuantityTypeIdentifier.cyclingSpeed.rawValue,
                docComment: "A quantity sample that records cycling speed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "distanceCrossCountrySkiing",
                rawValue: HKQuantityTypeIdentifier.distanceCrossCountrySkiing.rawValue,
                docComment: "A quantity sample that records cross-country skiing distance."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "distancePaddleSports",
                rawValue: HKQuantityTypeIdentifier.distancePaddleSports.rawValue,
                docComment: "A quantity sample that records paddle sports distance."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "distanceRowing",
                rawValue: HKQuantityTypeIdentifier.distanceRowing.rawValue,
                docComment: "A quantity sample that records rowing distance."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "distanceSkatingSports",
                rawValue: HKQuantityTypeIdentifier.distanceSkatingSports.rawValue,
                docComment: "A quantity sample that records skating sports distance."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "environmentalSoundReduction",
                rawValue: HKQuantityTypeIdentifier.environmentalSoundReduction.rawValue,
                docComment: "A quantity sample that records environmental sound reduction."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "estimatedWorkoutEffortScore",
                rawValue: HKQuantityTypeIdentifier.estimatedWorkoutEffortScore.rawValue,
                docComment: "A quantity sample that records estimated physical effort during workouts."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "paddleSportsSpeed",
                rawValue: HKQuantityTypeIdentifier.paddleSportsSpeed.rawValue,
                docComment: "A quantity sample that records paddle sports speed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "physicalEffort",
                rawValue: HKQuantityTypeIdentifier.physicalEffort.rawValue,
                docComment: "A quantity sample that records physical effort."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "rowingSpeed",
                rawValue: HKQuantityTypeIdentifier.rowingSpeed.rawValue,
                docComment: "A quantity sample that records rowing speed."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "timeInDaylight",
                rawValue: HKQuantityTypeIdentifier.timeInDaylight.rawValue,
                docComment: "A quantity sample that records time spent in daylight."
            )
        ),
        .staticProperty(
            parentStruct: "HKQuantityTypeIdentifier",
            IdentifierConstDef(
                identifierName: "workoutEffortScore",
                rawValue: HKQuantityTypeIdentifier.workoutEffortScore.rawValue,
                docComment: "A quantity sample that records workout effort."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "appleStandHour",
                rawValue: HKCategoryTypeIdentifier.appleStandHour.rawValue,
                docComment: "A category sample type that counts the number of hours in the day during which the user has stood and moved for at least one minute per hour."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "lowCardioFitnessEvent",
                rawValue: HKCategoryTypeIdentifier.lowCardioFitnessEvent.rawValue,
                docComment: "An event that indicates the user’s VO2 max values consistently fall below a particular aerobic fitness threshold."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "menstrualFlow",
                rawValue: HKCategoryTypeIdentifier.menstrualFlow.rawValue,
                docComment: "A category sample type that records menstrual cycles."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "intermenstrualBleeding",
                rawValue: HKCategoryTypeIdentifier.intermenstrualBleeding.rawValue,
                docComment: "A category sample type that records spotting outside the normal menstruation period."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "infrequentMenstrualCycles",
                rawValue: HKCategoryTypeIdentifier.infrequentMenstrualCycles.rawValue,
                docComment: "A category sample that indicates an infrequent menstrual cycle."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "irregularMenstrualCycles",
                rawValue: HKCategoryTypeIdentifier.irregularMenstrualCycles.rawValue,
                docComment: "A category sample that indicates an irregular menstrual cycle."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "persistentIntermenstrualBleeding",
                rawValue: HKCategoryTypeIdentifier.persistentIntermenstrualBleeding.rawValue,
                docComment: "A category sample that indicates persistent intermenstrual bleeding."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "prolongedMenstrualPeriods",
                rawValue: HKCategoryTypeIdentifier.prolongedMenstrualPeriods.rawValue,
                docComment: "A category sample that indicates a prolonged menstrual cycle."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "cervicalMucusQuality",
                rawValue: HKCategoryTypeIdentifier.cervicalMucusQuality.rawValue,
                docComment: "A category sample type that records the quality of the user’s cervical mucus."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "ovulationTestResult",
                rawValue: HKCategoryTypeIdentifier.ovulationTestResult.rawValue,
                docComment: "A category sample type that records the result of an ovulation home test."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "progesteroneTestResult",
                rawValue: HKCategoryTypeIdentifier.progesteroneTestResult.rawValue,
                docComment: "A category type that represents the results from a home progesterone test."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "sexualActivity",
                rawValue: HKCategoryTypeIdentifier.sexualActivity.rawValue,
                docComment: "A category sample type that records sexual activity."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "contraceptive",
                rawValue: HKCategoryTypeIdentifier.contraceptive.rawValue,
                docComment: "A category sample type that records the use of contraceptives."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "pregnancy",
                rawValue: HKCategoryTypeIdentifier.pregnancy.rawValue,
                docComment: "A category type that records pregnancy."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "pregnancyTestResult",
                rawValue: HKCategoryTypeIdentifier.pregnancyTestResult.rawValue,
                docComment: "A category type that represents the results from a home pregnancy test."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "lactation",
                rawValue: HKCategoryTypeIdentifier.lactation.rawValue,
                docComment: "A category type that records lactation."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "environmentalAudioExposureEvent",
                rawValue: HKCategoryTypeIdentifier.environmentalAudioExposureEvent.rawValue,
                docComment: "A category sample type that records exposure to potentially damaging sounds from the environment."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "headphoneAudioExposureEvent",
                rawValue: HKCategoryTypeIdentifier.headphoneAudioExposureEvent.rawValue,
                docComment: "A category sample type that records exposure to potentially damaging sounds from headphones."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "lowHeartRateEvent",
                rawValue: HKCategoryTypeIdentifier.lowHeartRateEvent.rawValue,
                docComment: "A category sample type for low heart rate events."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "highHeartRateEvent",
                rawValue: HKCategoryTypeIdentifier.highHeartRateEvent.rawValue,
                docComment: "A category sample type for high heart rate events."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "irregularHeartRhythmEvent",
                rawValue: HKCategoryTypeIdentifier.irregularHeartRhythmEvent.rawValue,
                docComment: "A category sample type for irregular heart rhythm events."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "appleWalkingSteadinessEvent",
                rawValue: HKCategoryTypeIdentifier.appleWalkingSteadinessEvent.rawValue,
                docComment: "A category sample type that records an incident where the user showed a reduced score for their gait’s steadiness."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "mindfulSession",
                rawValue: HKCategoryTypeIdentifier.mindfulSession.rawValue,
                docComment: "A category sample type for recording a mindful session."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "sleepAnalysis",
                rawValue: HKCategoryTypeIdentifier.sleepAnalysis.rawValue,
                docComment: "A category sample type for sleep analysis information."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "toothbrushingEvent",
                rawValue: HKCategoryTypeIdentifier.toothbrushingEvent.rawValue,
                docComment: "A category sample type for toothbrushing events."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "handwashingEvent",
                rawValue: HKCategoryTypeIdentifier.handwashingEvent.rawValue,
                docComment: "A category sample type for handwashing events."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "abdominalCramps",
                rawValue: HKCategoryTypeIdentifier.abdominalCramps.rawValue,
                docComment: "A category type that records abdominal cramps as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "bloating",
                rawValue: HKCategoryTypeIdentifier.bloating.rawValue,
                docComment: "A category type that records bloating as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "constipation",
                rawValue: HKCategoryTypeIdentifier.constipation.rawValue,
                docComment: "A category type that records constipation as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "diarrhea",
                rawValue: HKCategoryTypeIdentifier.diarrhea.rawValue,
                docComment: "A category type that records diarrhea as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "heartburn",
                rawValue: HKCategoryTypeIdentifier.heartburn.rawValue,
                docComment: "A category type that records heartburn as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "nausea",
                rawValue: HKCategoryTypeIdentifier.nausea.rawValue,
                docComment: "A category type that records nausea as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "vomiting",
                rawValue: HKCategoryTypeIdentifier.vomiting.rawValue,
                docComment: "A category type that records vomiting as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "appetiteChanges",
                rawValue: HKCategoryTypeIdentifier.appetiteChanges.rawValue,
                docComment: "A category type that records changes in appetite as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "chills",
                rawValue: HKCategoryTypeIdentifier.chills.rawValue,
                docComment: "A category type that records chills as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dizziness",
                rawValue: HKCategoryTypeIdentifier.dizziness.rawValue,
                docComment: "A category type that records dizziness as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "fainting",
                rawValue: HKCategoryTypeIdentifier.fainting.rawValue,
                docComment: "A category type that records fainting as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "fatigue",
                rawValue: HKCategoryTypeIdentifier.fatigue.rawValue,
                docComment: "A category type that records fatigue as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "fever",
                rawValue: HKCategoryTypeIdentifier.fever.rawValue,
                docComment: "A category type that records fever as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "generalizedBodyAche",
                rawValue: HKCategoryTypeIdentifier.generalizedBodyAche.rawValue,
                docComment: "A category type that records body ache as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "hotFlashes",
                rawValue: HKCategoryTypeIdentifier.hotFlashes.rawValue,
                docComment: "A category type that records hot flashes as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "chestTightnessOrPain",
                rawValue: HKCategoryTypeIdentifier.chestTightnessOrPain.rawValue,
                docComment: "A category type that records chest tightness or pain as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "coughing",
                rawValue: HKCategoryTypeIdentifier.coughing.rawValue,
                docComment: "A category type that records coughing as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "rapidPoundingOrFlutteringHeartbeat",
                rawValue: HKCategoryTypeIdentifier.rapidPoundingOrFlutteringHeartbeat.rawValue,
                docComment: "A category type that records a rapid, pounding, or fluttering heartbeat as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "shortnessOfBreath",
                rawValue: HKCategoryTypeIdentifier.shortnessOfBreath.rawValue,
                docComment: "A category type that records shortness of breath as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "skippedHeartbeat",
                rawValue: HKCategoryTypeIdentifier.skippedHeartbeat.rawValue,
                docComment: "A category type that records skipped heartbeat as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "wheezing",
                rawValue: HKCategoryTypeIdentifier.wheezing.rawValue,
                docComment: "A category type that records wheezing as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "lowerBackPain",
                rawValue: HKCategoryTypeIdentifier.lowerBackPain.rawValue,
                docComment: "A category type that records lower back pain as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "headache",
                rawValue: HKCategoryTypeIdentifier.headache.rawValue,
                docComment: "A category type that records headache as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "memoryLapse",
                rawValue: HKCategoryTypeIdentifier.memoryLapse.rawValue,
                docComment: "A category type that records memory lapse as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "moodChanges",
                rawValue: HKCategoryTypeIdentifier.moodChanges.rawValue,
                docComment: "A category type that records mood changes as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "lossOfSmell",
                rawValue: HKCategoryTypeIdentifier.lossOfSmell.rawValue,
                docComment: "A category type that records loss of smell as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "lossOfTaste",
                rawValue: HKCategoryTypeIdentifier.lossOfTaste.rawValue,
                docComment: "A category type that records loss of taste as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "runnyNose",
                rawValue: HKCategoryTypeIdentifier.runnyNose.rawValue,
                docComment: "A category type that records runny nose as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "soreThroat",
                rawValue: HKCategoryTypeIdentifier.soreThroat.rawValue,
                docComment: "A category type that records sore throat as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "sinusCongestion",
                rawValue: HKCategoryTypeIdentifier.sinusCongestion.rawValue,
                docComment: "A category type that records sinus congestion as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "breastPain",
                rawValue: HKCategoryTypeIdentifier.breastPain.rawValue,
                docComment: "A category type that records breast pain as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "pelvicPain",
                rawValue: HKCategoryTypeIdentifier.pelvicPain.rawValue,
                docComment: "A category type that records pelvic pain as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "vaginalDryness",
                rawValue: HKCategoryTypeIdentifier.vaginalDryness.rawValue,
                docComment: "A category type that records vaginal dryness as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "bleedingDuringPregnancy",
                rawValue: HKCategoryTypeIdentifier.bleedingDuringPregnancy.rawValue,
                docComment: "A category type that records bleeding during pregnancy as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "bleedingAfterPregnancy",
                rawValue: HKCategoryTypeIdentifier.bleedingAfterPregnancy.rawValue,
                docComment: "A category type that records bleeding after pregnancy as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "acne",
                rawValue: HKCategoryTypeIdentifier.acne.rawValue,
                docComment: "A category type that records acne as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "drySkin",
                rawValue: HKCategoryTypeIdentifier.drySkin.rawValue,
                docComment: "A category type that records dry skin as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "hairLoss",
                rawValue: HKCategoryTypeIdentifier.hairLoss.rawValue,
                docComment: "A category type that records hair loss as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "nightSweats",
                rawValue: HKCategoryTypeIdentifier.nightSweats.rawValue,
                docComment: "A category type that records night sweats as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "sleepChanges",
                rawValue: HKCategoryTypeIdentifier.sleepChanges.rawValue,
                docComment: "A category type that records sleep changes as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "sleepApneaEvent",
                rawValue: HKCategoryTypeIdentifier.sleepApneaEvent.rawValue,
                docComment: "A category type that records sleep apnea as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCategoryTypeIdentifier",
            IdentifierConstDef(
                identifierName: "bladderIncontinence",
                rawValue: HKCategoryTypeIdentifier.bladderIncontinence.rawValue,
                docComment: "A category type that records bladder incontinence as a symptom."
            )
        ),
        .staticProperty(
            parentStruct: "HKCorrelationTypeIdentifier",
            IdentifierConstDef(
                identifierName: "bloodPressure",
                rawValue: HKCorrelationTypeIdentifier.bloodPressure.rawValue,
                docComment: "The sample type representing blood pressure correlation samples"
            )
        ),
        .staticProperty(
            parentStruct: "HKCorrelationTypeIdentifier",
            IdentifierConstDef(
                identifierName: "food",
                rawValue: HKCorrelationTypeIdentifier.food.rawValue,
                docComment: "Food correlation types combine any number of nutritional samples into a single food object."
            )
        ),
        .staticProperty(
            parentStruct: "HKCharacteristicTypeIdentifier",
            IdentifierConstDef(
                identifierName: "activityMoveMode",
                rawValue: HKCharacteristicTypeIdentifier.activityMoveMode.rawValue,
                docComment: "The activity move mode characteristic."
            )
        ),
        .staticProperty(
            parentStruct: "HKCharacteristicTypeIdentifier",
            IdentifierConstDef(
                identifierName: "biologicalSex",
                rawValue: HKCharacteristicTypeIdentifier.biologicalSex.rawValue,
                docComment: "The characteristic representing the user's biological sex."
            )
        ),
        .staticProperty(
            parentStruct: "HKCharacteristicTypeIdentifier",
            IdentifierConstDef(
                identifierName: "bloodType",
                rawValue: HKCharacteristicTypeIdentifier.bloodType.rawValue,
                docComment: "The characteristic representing the user's blood type."
            )
        ),
        .staticProperty(
            parentStruct: "HKCharacteristicTypeIdentifier",
            IdentifierConstDef(
                identifierName: "dateOfBirth",
                rawValue: HKCharacteristicTypeIdentifier.dateOfBirth.rawValue,
                docComment: "The characteristic representing the user's date of birth."
            )
        ),
        .staticProperty(
            parentStruct: "HKCharacteristicTypeIdentifier",
            IdentifierConstDef(
                identifierName: "fitzpatrickSkinType",
                rawValue: HKCharacteristicTypeIdentifier.fitzpatrickSkinType.rawValue,
                docComment: "The characteristic representing the user's skin type."
            )
        ),
        .staticProperty(
            parentStruct: "HKCharacteristicTypeIdentifier",
            IdentifierConstDef(
                identifierName: "wheelchairUse",
                rawValue: HKCharacteristicTypeIdentifier.wheelchairUse.rawValue,
                docComment: "The characteristic representing the user's wheelchair use status."
            )
        ),
        .staticProperty(
            parentStruct: "HKClinicalTypeIdentifier",
            IdentifierConstDef(
                identifierName: "allergyRecord",
                rawValue: HKClinicalTypeIdentifier.allergyRecord.rawValue,
                docComment: "A type identifier for records of allergic or intolerant reactions."
            )
        ),
        .staticProperty(
            parentStruct: "HKClinicalTypeIdentifier",
            IdentifierConstDef(
                identifierName: "clinicalNoteRecord",
                rawValue: HKClinicalTypeIdentifier.clinicalNoteRecord.rawValue,
                docComment: "A type identifier for records of clinical notes."
            )
        ),
        .staticProperty(
            parentStruct: "HKClinicalTypeIdentifier",
            IdentifierConstDef(
                identifierName: "conditionRecord",
                rawValue: HKClinicalTypeIdentifier.conditionRecord.rawValue,
                docComment: "A type identifier for records of a condition, problem, diagnosis, or other event."
            )
        ),
        .staticProperty(
            parentStruct: "HKClinicalTypeIdentifier",
            IdentifierConstDef(
                identifierName: "immunizationRecord",
                rawValue: HKClinicalTypeIdentifier.immunizationRecord.rawValue,
                docComment: "A type identifier for records of the current or historical administration of vaccines."
            )
        ),
        .staticProperty(
            parentStruct: "HKClinicalTypeIdentifier",
            IdentifierConstDef(
                identifierName: "labResultRecord",
                rawValue: HKClinicalTypeIdentifier.labResultRecord.rawValue,
                docComment: "A type identifier for records of lab results."
            )
        ),
        .staticProperty(
            parentStruct: "HKClinicalTypeIdentifier",
            IdentifierConstDef(
                identifierName: "medicationRecord",
                rawValue: HKClinicalTypeIdentifier.medicationRecord.rawValue,
                docComment: "A type identifier for records of medication."
            )
        ),
        .staticProperty(
            parentStruct: "HKClinicalTypeIdentifier",
            IdentifierConstDef(
                identifierName: "procedureRecord",
                rawValue: HKClinicalTypeIdentifier.procedureRecord.rawValue,
                docComment: "A type identifier for records of procedures."
            )
        ),
        .staticProperty(
            parentStruct: "HKClinicalTypeIdentifier",
            IdentifierConstDef(
                identifierName: "vitalSignRecord",
                rawValue: HKClinicalTypeIdentifier.vitalSignRecord.rawValue,
                docComment: "A type identifier for records of vital signs."
            )
        ),
        .staticProperty(
            parentStruct: "HKClinicalTypeIdentifier",
            IdentifierConstDef(
                identifierName: "coverageRecord",
                rawValue: HKClinicalTypeIdentifier.coverageRecord.rawValue,
                docComment: "A type identifier for records containing information about the user’s insurance coverage."
            )
        ),
        .globalVariable(IdentifierConstDef(
            identifierName: "HKElectrocardiogramTypeIdentifier",
            rawValue: HKSampleType.electrocardiogramType().identifier,
            docComment: "The electrocardiogram sample type"
        )),
        .globalVariable(IdentifierConstDef(
            identifierName: "HKAudiogramSampleTypeIdentifier",
            rawValue: HKSampleType.audiogramSampleType().identifier,
            docComment: "The audiogram sample type"
        )),
        .globalVariable(IdentifierConstDef(
            identifierName: "HKWorkoutTypeIdentifier",
            rawValue: HKSampleType.workoutType().identifier,
            docComment: "The workout sample type"
        )),
        .globalVariable(IdentifierConstDef(
            identifierName: "HKVisionPrescriptionTypeIdentifier",
            rawValue: HKSampleType.visionPrescriptionType().identifier,
            docComment: "The vision prescription sample type"
        )),
        .globalVariable(IdentifierConstDef(
            identifierName: "HKDataTypeIdentifierStateOfMind",
            rawValue: HKSampleType.stateOfMindType().identifier,
            docComment: "The state of mind sample type"
        )),
        .globalVariable(IdentifierConstDef(
            identifierName: "HKDataTypeIdentifierHeartbeatSeries",
            rawValue: HKSeriesType.heartbeat().identifier,
            docComment: "The heartbeat series sample type"
        )),
        .globalVariable(IdentifierConstDef(
            identifierName: "HKWorkoutRouteTypeIdentifier",
            rawValue: HKSeriesType.workoutRoute().identifier,
            docComment: "The workout route sample type"
        )),
        .staticProperty(
            parentStruct: "HKScoredAssessmentTypeIdentifier",
            IdentifierConstDef(
                identifierName: "GAD7",
                rawValue: HKScoredAssessmentType(.GAD7).identifier,
                docComment: "The GAD-7 (generalized anxiety disorder 7) score type"
            )
        ),
        .staticProperty(
            parentStruct: "HKScoredAssessmentTypeIdentifier",
            IdentifierConstDef(
                identifierName: "PHQ9",
                rawValue: HKScoredAssessmentType(.PHQ9).identifier,
                docComment: "The PHQ-9 (nine-item Patient Health Questionnaire) score type"
            )
        ),
    ]
}

#endif
