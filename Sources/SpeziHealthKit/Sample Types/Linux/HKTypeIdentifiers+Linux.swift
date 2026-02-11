//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// THIS FILE IS AUTO-GENERATED! DO NOT EDIT!!!
// swiftlint:disable all

#if !canImport(HealthKit)

public struct HKCharacteristicTypeIdentifier: Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public static let activityMoveMode = Self(rawValue: "HKCharacteristicTypeIdentifierActivityMoveMode")
    public static let biologicalSex = Self(rawValue: "HKCharacteristicTypeIdentifierBiologicalSex")
    public static let bloodType = Self(rawValue: "HKCharacteristicTypeIdentifierBloodType")
    public static let dateOfBirth = Self(rawValue: "HKCharacteristicTypeIdentifierDateOfBirth")
    public static let fitzpatrickSkinType = Self(rawValue: "HKCharacteristicTypeIdentifierFitzpatrickSkinType")
    public static let wheelchairUse = Self(rawValue: "HKCharacteristicTypeIdentifierWheelchairUse")
}


public struct HKClinicalTypeIdentifier: Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public static let allergyRecord = Self(rawValue: "HKClinicalTypeIdentifierAllergyRecord")
    public static let clinicalNoteRecord = Self(rawValue: "HKClinicalTypeIdentifierClinicalNoteRecord")
    public static let conditionRecord = Self(rawValue: "HKClinicalTypeIdentifierConditionRecord")
    public static let immunizationRecord = Self(rawValue: "HKClinicalTypeIdentifierImmunizationRecord")
    public static let labResultRecord = Self(rawValue: "HKClinicalTypeIdentifierLabResultRecord")
    public static let medicationRecord = Self(rawValue: "HKClinicalTypeIdentifierMedicationRecord")
    public static let procedureRecord = Self(rawValue: "HKClinicalTypeIdentifierProcedureRecord")
    public static let vitalSignRecord = Self(rawValue: "HKClinicalTypeIdentifierVitalSignRecord")
    public static let coverageRecord = Self(rawValue: "HKClinicalTypeIdentifierCoverageRecord")
}


public struct HKScoredAssessmentTypeIdentifier: Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public static let GAD7 = Self(rawValue: "HKScoredAssessmentTypeIdentifierGAD7")
    public static let PHQ9 = Self(rawValue: "HKScoredAssessmentTypeIdentifierPHQ9")
}


public struct HKQuantityTypeIdentifier: Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public static let stepCount = Self(rawValue: "HKQuantityTypeIdentifierStepCount")
    public static let distanceWalkingRunning = Self(rawValue: "HKQuantityTypeIdentifierDistanceWalkingRunning")
    public static let runningGroundContactTime = Self(rawValue: "HKQuantityTypeIdentifierRunningGroundContactTime")
    public static let runningPower = Self(rawValue: "HKQuantityTypeIdentifierRunningPower")
    public static let runningSpeed = Self(rawValue: "HKQuantityTypeIdentifierRunningSpeed")
    public static let runningStrideLength = Self(rawValue: "HKQuantityTypeIdentifierRunningStrideLength")
    public static let runningVerticalOscillation = Self(rawValue: "HKQuantityTypeIdentifierRunningVerticalOscillation")
    public static let distanceCycling = Self(rawValue: "HKQuantityTypeIdentifierDistanceCycling")
    public static let pushCount = Self(rawValue: "HKQuantityTypeIdentifierPushCount")
    public static let distanceWheelchair = Self(rawValue: "HKQuantityTypeIdentifierDistanceWheelchair")
    public static let swimmingStrokeCount = Self(rawValue: "HKQuantityTypeIdentifierSwimmingStrokeCount")
    public static let distanceSwimming = Self(rawValue: "HKQuantityTypeIdentifierDistanceSwimming")
    public static let distanceDownhillSnowSports = Self(rawValue: "HKQuantityTypeIdentifierDistanceDownhillSnowSports")
    public static let basalEnergyBurned = Self(rawValue: "HKQuantityTypeIdentifierBasalEnergyBurned")
    public static let activeEnergyBurned = Self(rawValue: "HKQuantityTypeIdentifierActiveEnergyBurned")
    public static let flightsClimbed = Self(rawValue: "HKQuantityTypeIdentifierFlightsClimbed")
    public static let appleExerciseTime = Self(rawValue: "HKQuantityTypeIdentifierAppleExerciseTime")
    public static let appleMoveTime = Self(rawValue: "HKQuantityTypeIdentifierAppleMoveTime")
    public static let appleStandTime = Self(rawValue: "HKQuantityTypeIdentifierAppleStandTime")
    public static let vo2Max = Self(rawValue: "HKQuantityTypeIdentifierVO2Max")
    public static let height = Self(rawValue: "HKQuantityTypeIdentifierHeight")
    public static let bodyMass = Self(rawValue: "HKQuantityTypeIdentifierBodyMass")
    public static let bodyMassIndex = Self(rawValue: "HKQuantityTypeIdentifierBodyMassIndex")
    public static let leanBodyMass = Self(rawValue: "HKQuantityTypeIdentifierLeanBodyMass")
    public static let bodyFatPercentage = Self(rawValue: "HKQuantityTypeIdentifierBodyFatPercentage")
    public static let waistCircumference = Self(rawValue: "HKQuantityTypeIdentifierWaistCircumference")
    public static let appleSleepingWristTemperature = Self(rawValue: "HKQuantityTypeIdentifierAppleSleepingWristTemperature")
    public static let basalBodyTemperature = Self(rawValue: "HKQuantityTypeIdentifierBasalBodyTemperature")
    public static let environmentalAudioExposure = Self(rawValue: "HKQuantityTypeIdentifierEnvironmentalAudioExposure")
    public static let headphoneAudioExposure = Self(rawValue: "HKQuantityTypeIdentifierHeadphoneAudioExposure")
    public static let heartRate = Self(rawValue: "HKQuantityTypeIdentifierHeartRate")
    public static let restingHeartRate = Self(rawValue: "HKQuantityTypeIdentifierRestingHeartRate")
    public static let walkingHeartRateAverage = Self(rawValue: "HKQuantityTypeIdentifierWalkingHeartRateAverage")
    public static let heartRateVariabilitySDNN = Self(rawValue: "HKQuantityTypeIdentifierHeartRateVariabilitySDNN")
    public static let heartRateRecoveryOneMinute = Self(rawValue: "HKQuantityTypeIdentifierHeartRateRecoveryOneMinute")
    public static let atrialFibrillationBurden = Self(rawValue: "HKQuantityTypeIdentifierAtrialFibrillationBurden")
    public static let oxygenSaturation = Self(rawValue: "HKQuantityTypeIdentifierOxygenSaturation")
    public static let bodyTemperature = Self(rawValue: "HKQuantityTypeIdentifierBodyTemperature")
    public static let bloodPressureDiastolic = Self(rawValue: "HKQuantityTypeIdentifierBloodPressureDiastolic")
    public static let bloodPressureSystolic = Self(rawValue: "HKQuantityTypeIdentifierBloodPressureSystolic")
    public static let respiratoryRate = Self(rawValue: "HKQuantityTypeIdentifierRespiratoryRate")
    public static let bloodGlucose = Self(rawValue: "HKQuantityTypeIdentifierBloodGlucose")
    public static let electrodermalActivity = Self(rawValue: "HKQuantityTypeIdentifierElectrodermalActivity")
    public static let forcedExpiratoryVolume1 = Self(rawValue: "HKQuantityTypeIdentifierForcedExpiratoryVolume1")
    public static let forcedVitalCapacity = Self(rawValue: "HKQuantityTypeIdentifierForcedVitalCapacity")
    public static let inhalerUsage = Self(rawValue: "HKQuantityTypeIdentifierInhalerUsage")
    public static let insulinDelivery = Self(rawValue: "HKQuantityTypeIdentifierInsulinDelivery")
    public static let numberOfTimesFallen = Self(rawValue: "HKQuantityTypeIdentifierNumberOfTimesFallen")
    public static let peakExpiratoryFlowRate = Self(rawValue: "HKQuantityTypeIdentifierPeakExpiratoryFlowRate")
    public static let peripheralPerfusionIndex = Self(rawValue: "HKQuantityTypeIdentifierPeripheralPerfusionIndex")
    public static let dietaryBiotin = Self(rawValue: "HKQuantityTypeIdentifierDietaryBiotin")
    public static let dietaryCaffeine = Self(rawValue: "HKQuantityTypeIdentifierDietaryCaffeine")
    public static let dietaryCalcium = Self(rawValue: "HKQuantityTypeIdentifierDietaryCalcium")
    public static let dietaryCarbohydrates = Self(rawValue: "HKQuantityTypeIdentifierDietaryCarbohydrates")
    public static let dietaryChloride = Self(rawValue: "HKQuantityTypeIdentifierDietaryChloride")
    public static let dietaryCholesterol = Self(rawValue: "HKQuantityTypeIdentifierDietaryCholesterol")
    public static let dietaryChromium = Self(rawValue: "HKQuantityTypeIdentifierDietaryChromium")
    public static let dietaryCopper = Self(rawValue: "HKQuantityTypeIdentifierDietaryCopper")
    public static let dietaryEnergyConsumed = Self(rawValue: "HKQuantityTypeIdentifierDietaryEnergyConsumed")
    public static let dietaryFatMonounsaturated = Self(rawValue: "HKQuantityTypeIdentifierDietaryFatMonounsaturated")
    public static let dietaryFatPolyunsaturated = Self(rawValue: "HKQuantityTypeIdentifierDietaryFatPolyunsaturated")
    public static let dietaryFatSaturated = Self(rawValue: "HKQuantityTypeIdentifierDietaryFatSaturated")
    public static let dietaryFatTotal = Self(rawValue: "HKQuantityTypeIdentifierDietaryFatTotal")
    public static let dietaryFiber = Self(rawValue: "HKQuantityTypeIdentifierDietaryFiber")
    public static let dietaryFolate = Self(rawValue: "HKQuantityTypeIdentifierDietaryFolate")
    public static let dietaryIodine = Self(rawValue: "HKQuantityTypeIdentifierDietaryIodine")
    public static let dietaryIron = Self(rawValue: "HKQuantityTypeIdentifierDietaryIron")
    public static let dietaryMagnesium = Self(rawValue: "HKQuantityTypeIdentifierDietaryMagnesium")
    public static let dietaryManganese = Self(rawValue: "HKQuantityTypeIdentifierDietaryManganese")
    public static let dietaryMolybdenum = Self(rawValue: "HKQuantityTypeIdentifierDietaryMolybdenum")
    public static let dietaryNiacin = Self(rawValue: "HKQuantityTypeIdentifierDietaryNiacin")
    public static let dietaryPantothenicAcid = Self(rawValue: "HKQuantityTypeIdentifierDietaryPantothenicAcid")
    public static let dietaryPhosphorus = Self(rawValue: "HKQuantityTypeIdentifierDietaryPhosphorus")
    public static let dietaryPotassium = Self(rawValue: "HKQuantityTypeIdentifierDietaryPotassium")
    public static let dietaryProtein = Self(rawValue: "HKQuantityTypeIdentifierDietaryProtein")
    public static let dietaryRiboflavin = Self(rawValue: "HKQuantityTypeIdentifierDietaryRiboflavin")
    public static let dietarySelenium = Self(rawValue: "HKQuantityTypeIdentifierDietarySelenium")
    public static let dietarySodium = Self(rawValue: "HKQuantityTypeIdentifierDietarySodium")
    public static let dietarySugar = Self(rawValue: "HKQuantityTypeIdentifierDietarySugar")
    public static let dietaryThiamin = Self(rawValue: "HKQuantityTypeIdentifierDietaryThiamin")
    public static let dietaryVitaminA = Self(rawValue: "HKQuantityTypeIdentifierDietaryVitaminA")
    public static let dietaryVitaminB12 = Self(rawValue: "HKQuantityTypeIdentifierDietaryVitaminB12")
    public static let dietaryVitaminB6 = Self(rawValue: "HKQuantityTypeIdentifierDietaryVitaminB6")
    public static let dietaryVitaminC = Self(rawValue: "HKQuantityTypeIdentifierDietaryVitaminC")
    public static let dietaryVitaminD = Self(rawValue: "HKQuantityTypeIdentifierDietaryVitaminD")
    public static let dietaryVitaminE = Self(rawValue: "HKQuantityTypeIdentifierDietaryVitaminE")
    public static let dietaryVitaminK = Self(rawValue: "HKQuantityTypeIdentifierDietaryVitaminK")
    public static let dietaryWater = Self(rawValue: "HKQuantityTypeIdentifierDietaryWater")
    public static let dietaryZinc = Self(rawValue: "HKQuantityTypeIdentifierDietaryZinc")
    public static let bloodAlcoholContent = Self(rawValue: "HKQuantityTypeIdentifierBloodAlcoholContent")
    public static let numberOfAlcoholicBeverages = Self(rawValue: "HKQuantityTypeIdentifierNumberOfAlcoholicBeverages")
    public static let appleWalkingSteadiness = Self(rawValue: "HKQuantityTypeIdentifierAppleWalkingSteadiness")
    public static let sixMinuteWalkTestDistance = Self(rawValue: "HKQuantityTypeIdentifierSixMinuteWalkTestDistance")
    public static let walkingSpeed = Self(rawValue: "HKQuantityTypeIdentifierWalkingSpeed")
    public static let walkingStepLength = Self(rawValue: "HKQuantityTypeIdentifierWalkingStepLength")
    public static let walkingAsymmetryPercentage = Self(rawValue: "HKQuantityTypeIdentifierWalkingAsymmetryPercentage")
    public static let walkingDoubleSupportPercentage = Self(rawValue: "HKQuantityTypeIdentifierWalkingDoubleSupportPercentage")
    public static let stairAscentSpeed = Self(rawValue: "HKQuantityTypeIdentifierStairAscentSpeed")
    public static let stairDescentSpeed = Self(rawValue: "HKQuantityTypeIdentifierStairDescentSpeed")
    public static let uvExposure = Self(rawValue: "HKQuantityTypeIdentifierUVExposure")
    public static let underwaterDepth = Self(rawValue: "HKQuantityTypeIdentifierUnderwaterDepth")
    public static let waterTemperature = Self(rawValue: "HKQuantityTypeIdentifierWaterTemperature")
    public static let appleSleepingBreathingDisturbances = Self(rawValue: "HKQuantityTypeIdentifierAppleSleepingBreathingDisturbances")
    public static let crossCountrySkiingSpeed = Self(rawValue: "HKQuantityTypeIdentifierCrossCountrySkiingSpeed")
    public static let cyclingCadence = Self(rawValue: "HKQuantityTypeIdentifierCyclingCadence")
    public static let cyclingFunctionalThresholdPower = Self(rawValue: "HKQuantityTypeIdentifierCyclingFunctionalThresholdPower")
    public static let cyclingPower = Self(rawValue: "HKQuantityTypeIdentifierCyclingPower")
    public static let cyclingSpeed = Self(rawValue: "HKQuantityTypeIdentifierCyclingSpeed")
    public static let distanceCrossCountrySkiing = Self(rawValue: "HKQuantityTypeIdentifierDistanceCrossCountrySkiing")
    public static let distancePaddleSports = Self(rawValue: "HKQuantityTypeIdentifierDistancePaddleSports")
    public static let distanceRowing = Self(rawValue: "HKQuantityTypeIdentifierDistanceRowing")
    public static let distanceSkatingSports = Self(rawValue: "HKQuantityTypeIdentifierDistanceSkatingSports")
    public static let environmentalSoundReduction = Self(rawValue: "HKQuantityTypeIdentifierEnvironmentalSoundReduction")
    public static let estimatedWorkoutEffortScore = Self(rawValue: "HKQuantityTypeIdentifierEstimatedWorkoutEffortScore")
    public static let paddleSportsSpeed = Self(rawValue: "HKQuantityTypeIdentifierPaddleSportsSpeed")
    public static let physicalEffort = Self(rawValue: "HKQuantityTypeIdentifierPhysicalEffort")
    public static let rowingSpeed = Self(rawValue: "HKQuantityTypeIdentifierRowingSpeed")
    public static let timeInDaylight = Self(rawValue: "HKQuantityTypeIdentifierTimeInDaylight")
    public static let workoutEffortScore = Self(rawValue: "HKQuantityTypeIdentifierWorkoutEffortScore")
}


public struct HKCorrelationTypeIdentifier: Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public static let bloodPressure = Self(rawValue: "HKCorrelationTypeIdentifierBloodPressure")
    public static let food = Self(rawValue: "HKCorrelationTypeIdentifierFood")
}


public struct HKCategoryTypeIdentifier: Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public static let appleStandHour = Self(rawValue: "HKCategoryTypeIdentifierAppleStandHour")
    public static let lowCardioFitnessEvent = Self(rawValue: "HKCategoryTypeIdentifierLowCardioFitnessEvent")
    public static let menstrualFlow = Self(rawValue: "HKCategoryTypeIdentifierMenstrualFlow")
    public static let intermenstrualBleeding = Self(rawValue: "HKCategoryTypeIdentifierIntermenstrualBleeding")
    public static let infrequentMenstrualCycles = Self(rawValue: "HKCategoryTypeIdentifierInfrequentMenstrualCycles")
    public static let irregularMenstrualCycles = Self(rawValue: "HKCategoryTypeIdentifierIrregularMenstrualCycles")
    public static let persistentIntermenstrualBleeding = Self(rawValue: "HKCategoryTypeIdentifierPersistentIntermenstrualBleeding")
    public static let prolongedMenstrualPeriods = Self(rawValue: "HKCategoryTypeIdentifierProlongedMenstrualPeriods")
    public static let cervicalMucusQuality = Self(rawValue: "HKCategoryTypeIdentifierCervicalMucusQuality")
    public static let ovulationTestResult = Self(rawValue: "HKCategoryTypeIdentifierOvulationTestResult")
    public static let progesteroneTestResult = Self(rawValue: "HKCategoryTypeIdentifierProgesteroneTestResult")
    public static let sexualActivity = Self(rawValue: "HKCategoryTypeIdentifierSexualActivity")
    public static let contraceptive = Self(rawValue: "HKCategoryTypeIdentifierContraceptive")
    public static let pregnancy = Self(rawValue: "HKCategoryTypeIdentifierPregnancy")
    public static let pregnancyTestResult = Self(rawValue: "HKCategoryTypeIdentifierPregnancyTestResult")
    public static let lactation = Self(rawValue: "HKCategoryTypeIdentifierLactation")
    public static let environmentalAudioExposureEvent = Self(rawValue: "HKCategoryTypeIdentifierAudioExposureEvent")
    public static let headphoneAudioExposureEvent = Self(rawValue: "HKCategoryTypeIdentifierHeadphoneAudioExposureEvent")
    public static let lowHeartRateEvent = Self(rawValue: "HKCategoryTypeIdentifierLowHeartRateEvent")
    public static let highHeartRateEvent = Self(rawValue: "HKCategoryTypeIdentifierHighHeartRateEvent")
    public static let irregularHeartRhythmEvent = Self(rawValue: "HKCategoryTypeIdentifierIrregularHeartRhythmEvent")
    public static let appleWalkingSteadinessEvent = Self(rawValue: "HKCategoryTypeIdentifierAppleWalkingSteadinessEvent")
    public static let mindfulSession = Self(rawValue: "HKCategoryTypeIdentifierMindfulSession")
    public static let sleepAnalysis = Self(rawValue: "HKCategoryTypeIdentifierSleepAnalysis")
    public static let toothbrushingEvent = Self(rawValue: "HKCategoryTypeIdentifierToothbrushingEvent")
    public static let handwashingEvent = Self(rawValue: "HKCategoryTypeIdentifierHandwashingEvent")
    public static let abdominalCramps = Self(rawValue: "HKCategoryTypeIdentifierAbdominalCramps")
    public static let bloating = Self(rawValue: "HKCategoryTypeIdentifierBloating")
    public static let constipation = Self(rawValue: "HKCategoryTypeIdentifierConstipation")
    public static let diarrhea = Self(rawValue: "HKCategoryTypeIdentifierDiarrhea")
    public static let heartburn = Self(rawValue: "HKCategoryTypeIdentifierHeartburn")
    public static let nausea = Self(rawValue: "HKCategoryTypeIdentifierNausea")
    public static let vomiting = Self(rawValue: "HKCategoryTypeIdentifierVomiting")
    public static let appetiteChanges = Self(rawValue: "HKCategoryTypeIdentifierAppetiteChanges")
    public static let chills = Self(rawValue: "HKCategoryTypeIdentifierChills")
    public static let dizziness = Self(rawValue: "HKCategoryTypeIdentifierDizziness")
    public static let fainting = Self(rawValue: "HKCategoryTypeIdentifierFainting")
    public static let fatigue = Self(rawValue: "HKCategoryTypeIdentifierFatigue")
    public static let fever = Self(rawValue: "HKCategoryTypeIdentifierFever")
    public static let generalizedBodyAche = Self(rawValue: "HKCategoryTypeIdentifierGeneralizedBodyAche")
    public static let hotFlashes = Self(rawValue: "HKCategoryTypeIdentifierHotFlashes")
    public static let chestTightnessOrPain = Self(rawValue: "HKCategoryTypeIdentifierChestTightnessOrPain")
    public static let coughing = Self(rawValue: "HKCategoryTypeIdentifierCoughing")
    public static let rapidPoundingOrFlutteringHeartbeat = Self(rawValue: "HKCategoryTypeIdentifierRapidPoundingOrFlutteringHeartbeat")
    public static let shortnessOfBreath = Self(rawValue: "HKCategoryTypeIdentifierShortnessOfBreath")
    public static let skippedHeartbeat = Self(rawValue: "HKCategoryTypeIdentifierSkippedHeartbeat")
    public static let wheezing = Self(rawValue: "HKCategoryTypeIdentifierWheezing")
    public static let lowerBackPain = Self(rawValue: "HKCategoryTypeIdentifierLowerBackPain")
    public static let headache = Self(rawValue: "HKCategoryTypeIdentifierHeadache")
    public static let memoryLapse = Self(rawValue: "HKCategoryTypeIdentifierMemoryLapse")
    public static let moodChanges = Self(rawValue: "HKCategoryTypeIdentifierMoodChanges")
    public static let lossOfSmell = Self(rawValue: "HKCategoryTypeIdentifierLossOfSmell")
    public static let lossOfTaste = Self(rawValue: "HKCategoryTypeIdentifierLossOfTaste")
    public static let runnyNose = Self(rawValue: "HKCategoryTypeIdentifierRunnyNose")
    public static let soreThroat = Self(rawValue: "HKCategoryTypeIdentifierSoreThroat")
    public static let sinusCongestion = Self(rawValue: "HKCategoryTypeIdentifierSinusCongestion")
    public static let breastPain = Self(rawValue: "HKCategoryTypeIdentifierBreastPain")
    public static let pelvicPain = Self(rawValue: "HKCategoryTypeIdentifierPelvicPain")
    public static let vaginalDryness = Self(rawValue: "HKCategoryTypeIdentifierVaginalDryness")
    public static let bleedingDuringPregnancy = Self(rawValue: "HKCategoryTypeIdentifierBleedingDuringPregnancy")
    public static let bleedingAfterPregnancy = Self(rawValue: "HKCategoryTypeIdentifierBleedingAfterPregnancy")
    public static let acne = Self(rawValue: "HKCategoryTypeIdentifierAcne")
    public static let drySkin = Self(rawValue: "HKCategoryTypeIdentifierDrySkin")
    public static let hairLoss = Self(rawValue: "HKCategoryTypeIdentifierHairLoss")
    public static let nightSweats = Self(rawValue: "HKCategoryTypeIdentifierNightSweats")
    public static let sleepChanges = Self(rawValue: "HKCategoryTypeIdentifierSleepChanges")
    public static let sleepApneaEvent = Self(rawValue: "HKCategoryTypeIdentifierSleepApneaEvent")
    public static let bladderIncontinence = Self(rawValue: "HKCategoryTypeIdentifierBladderIncontinence")
}


public struct HKDocumentTypeIdentifier: Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public static let CDA = Self(rawValue: "HKDocumentTypeIdentifierCDA")
}


public let HKElectrocardiogramTypeIdentifier = "HKDataTypeIdentifierElectrocardiogram"

public let HKAudiogramSampleTypeIdentifier = "HKDataTypeIdentifierAudiogram"

public let HKWorkoutTypeIdentifier = "HKWorkoutTypeIdentifier"

public let HKVisionPrescriptionTypeIdentifier = "HKVisionPrescriptionTypeIdentifier"

public let HKDataTypeIdentifierStateOfMind = "HKDataTypeStateOfMind"

public let HKDataTypeIdentifierHeartbeatSeries = "HKDataTypeIdentifierHeartbeatSeries"

public let HKWorkoutRouteTypeIdentifier = "HKWorkoutRouteTypeIdentifier"

public let HKActivitySummaryTypeIdentifier = "HKActivitySummaryTypeIdentifier"


#endif // !canImport(HealthKit)
