//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import SpeziFoundation


extension HKQuantityType {
    public static let allKnownQuantities: Set<HKQuantityType> = Set(HKQuantityTypeIdentifier.allKnownIdentifiers.map { HKQuantityType($0) })
}



extension HKQuantityTypeIdentifier {
    public static let allKnownIdentifiers = Set<Self> {
        Self.appleSleepingWristTemperature
        Self.bodyFatPercentage
        Self.bodyMass
        Self.bodyMassIndex
        Self.electrodermalActivity
        Self.height
        Self.leanBodyMass
        Self.waistCircumference
        Self.activeEnergyBurned
        Self.appleExerciseTime
        Self.appleMoveTime
        Self.appleStandTime
        Self.basalEnergyBurned
        if #available(iOS 18, macOS 15, *) {
            Self.crossCountrySkiingSpeed
        }
        Self.cyclingCadence
        Self.cyclingFunctionalThresholdPower
        Self.cyclingPower
        Self.cyclingSpeed
        if #available(iOS 18, macOS 15, *) {
            Self.distanceCrossCountrySkiing
        }
        Self.distanceCycling
        Self.distanceDownhillSnowSports
        if #available(iOS 18, macOS 15, *) {
            Self.distancePaddleSports
        }
        if #available(iOS 18, macOS 15, *) {
            Self.distanceRowing
        }
        if #available(iOS 18, macOS 15, *) {
            Self.distanceSkatingSports
        }
        Self.distanceSwimming
        Self.distanceWalkingRunning
        Self.distanceWheelchair
        if #available(iOS 18, macOS 15, *) {
            Self.estimatedWorkoutEffortScore
        }
        Self.flightsClimbed
        Self.nikeFuel
        if #available(iOS 18, macOS 15, *) {
            Self.paddleSportsSpeed
        }
        Self.physicalEffort
        Self.pushCount
        if #available(iOS 18, macOS 15, *) {
            Self.rowingSpeed
        }
        Self.runningPower
        Self.runningSpeed
        Self.stepCount
        Self.swimmingStrokeCount
        Self.underwaterDepth
        if #available(iOS 18, macOS 15, *) {
            Self.workoutEffortScore
        }
        Self.environmentalAudioExposure
        Self.environmentalSoundReduction
        Self.headphoneAudioExposure
        Self.atrialFibrillationBurden
        Self.heartRate
        Self.heartRateRecoveryOneMinute
        Self.heartRateVariabilitySDNN
        Self.peripheralPerfusionIndex
        Self.restingHeartRate
        Self.vo2Max
        Self.walkingHeartRateAverage
        Self.appleWalkingSteadiness
        Self.runningGroundContactTime
        Self.runningStrideLength
        Self.runningVerticalOscillation
        Self.sixMinuteWalkTestDistance
        Self.stairAscentSpeed
        Self.stairDescentSpeed
        Self.walkingAsymmetryPercentage
        Self.walkingDoubleSupportPercentage
        Self.walkingSpeed
        Self.walkingStepLength
        Self.dietaryBiotin
        Self.dietaryCaffeine
        Self.dietaryCalcium
        Self.dietaryCarbohydrates
        Self.dietaryChloride
        Self.dietaryCholesterol
        Self.dietaryChromium
        Self.dietaryCopper
        Self.dietaryEnergyConsumed
        Self.dietaryFatMonounsaturated
        Self.dietaryFatPolyunsaturated
        Self.dietaryFatSaturated
        Self.dietaryFatTotal
        Self.dietaryFiber
        Self.dietaryFolate
        Self.dietaryIodine
        Self.dietaryIron
        Self.dietaryMagnesium
        Self.dietaryManganese
        Self.dietaryMolybdenum
        Self.dietaryNiacin
        Self.dietaryPantothenicAcid
        Self.dietaryPhosphorus
        Self.dietaryPotassium
        Self.dietaryProtein
        Self.dietaryRiboflavin
        Self.dietarySelenium
        Self.dietarySodium
        Self.dietarySugar
        Self.dietaryThiamin
        Self.dietaryVitaminA
        Self.dietaryVitaminB12
        Self.dietaryVitaminB6
        Self.dietaryVitaminC
        Self.dietaryVitaminD
        Self.dietaryVitaminE
        Self.dietaryVitaminK
        Self.dietaryWater
        Self.dietaryZinc
        Self.bloodAlcoholContent
        Self.bloodPressureDiastolic
        Self.bloodPressureSystolic
        Self.insulinDelivery
        Self.numberOfAlcoholicBeverages
        Self.numberOfTimesFallen
        Self.timeInDaylight
        Self.uvExposure
        Self.waterTemperature
        Self.basalBodyTemperature
        if #available(iOS 18, macOS 15, *) {
            Self.appleSleepingBreathingDisturbances
        }
        Self.forcedExpiratoryVolume1
        Self.forcedVitalCapacity
        Self.inhalerUsage
        Self.oxygenSaturation
        Self.peakExpiratoryFlowRate
        Self.respiratoryRate
        Self.bloodGlucose
        Self.bodyTemperature
    }
}
