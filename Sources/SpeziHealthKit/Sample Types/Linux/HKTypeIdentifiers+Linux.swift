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

public struct HKCategoryTypeIdentifier: Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// A category type that records abdominal cramps as a symptom.
    public static let abdominalCramps = Self(rawValue: "HKCategoryTypeIdentifierAbdominalCramps")

    /// A category type that records acne as a symptom.
    public static let acne = Self(rawValue: "HKCategoryTypeIdentifierAcne")

    /// A category type that records changes in appetite as a symptom.
    public static let appetiteChanges = Self(rawValue: "HKCategoryTypeIdentifierAppetiteChanges")

    /// A category sample type that counts the number of hours in the day during which the user has stood and moved for at least one minute per hour.
    public static let appleStandHour = Self(rawValue: "HKCategoryTypeIdentifierAppleStandHour")

    /// A category sample type that records an incident where the user showed a reduced score for their gait’s steadiness.
    public static let appleWalkingSteadinessEvent = Self(rawValue: "HKCategoryTypeIdentifierAppleWalkingSteadinessEvent")

    /// A category type that records bladder incontinence as a symptom.
    public static let bladderIncontinence = Self(rawValue: "HKCategoryTypeIdentifierBladderIncontinence")

    /// A category type that records bleeding after pregnancy as a symptom.
    public static let bleedingAfterPregnancy = Self(rawValue: "HKCategoryTypeIdentifierBleedingAfterPregnancy")

    /// A category type that records bleeding during pregnancy as a symptom.
    public static let bleedingDuringPregnancy = Self(rawValue: "HKCategoryTypeIdentifierBleedingDuringPregnancy")

    /// A category type that records bloating as a symptom.
    public static let bloating = Self(rawValue: "HKCategoryTypeIdentifierBloating")

    /// A category type that records breast pain as a symptom.
    public static let breastPain = Self(rawValue: "HKCategoryTypeIdentifierBreastPain")

    /// A category sample type that records the quality of the user’s cervical mucus.
    public static let cervicalMucusQuality = Self(rawValue: "HKCategoryTypeIdentifierCervicalMucusQuality")

    /// A category type that records chest tightness or pain as a symptom.
    public static let chestTightnessOrPain = Self(rawValue: "HKCategoryTypeIdentifierChestTightnessOrPain")

    /// A category type that records chills as a symptom.
    public static let chills = Self(rawValue: "HKCategoryTypeIdentifierChills")

    /// A category type that records constipation as a symptom.
    public static let constipation = Self(rawValue: "HKCategoryTypeIdentifierConstipation")

    /// A category sample type that records the use of contraceptives.
    public static let contraceptive = Self(rawValue: "HKCategoryTypeIdentifierContraceptive")

    /// A category type that records coughing as a symptom.
    public static let coughing = Self(rawValue: "HKCategoryTypeIdentifierCoughing")

    /// A category type that records diarrhea as a symptom.
    public static let diarrhea = Self(rawValue: "HKCategoryTypeIdentifierDiarrhea")

    /// A category type that records dizziness as a symptom.
    public static let dizziness = Self(rawValue: "HKCategoryTypeIdentifierDizziness")

    /// A category type that records dry skin as a symptom.
    public static let drySkin = Self(rawValue: "HKCategoryTypeIdentifierDrySkin")

    /// A category sample type that records exposure to potentially damaging sounds from the environment.
    public static let environmentalAudioExposureEvent = Self(rawValue: "HKCategoryTypeIdentifierAudioExposureEvent")

    /// A category type that records fainting as a symptom.
    public static let fainting = Self(rawValue: "HKCategoryTypeIdentifierFainting")

    /// A category type that records fatigue as a symptom.
    public static let fatigue = Self(rawValue: "HKCategoryTypeIdentifierFatigue")

    /// A category type that records fever as a symptom.
    public static let fever = Self(rawValue: "HKCategoryTypeIdentifierFever")

    /// A category type that records body ache as a symptom.
    public static let generalizedBodyAche = Self(rawValue: "HKCategoryTypeIdentifierGeneralizedBodyAche")

    /// A category type that records hair loss as a symptom.
    public static let hairLoss = Self(rawValue: "HKCategoryTypeIdentifierHairLoss")

    /// A category sample type for handwashing events.
    public static let handwashingEvent = Self(rawValue: "HKCategoryTypeIdentifierHandwashingEvent")

    /// A category type that records headache as a symptom.
    public static let headache = Self(rawValue: "HKCategoryTypeIdentifierHeadache")

    /// A category sample type that records exposure to potentially damaging sounds from headphones.
    public static let headphoneAudioExposureEvent = Self(rawValue: "HKCategoryTypeIdentifierHeadphoneAudioExposureEvent")

    /// A category type that records heartburn as a symptom.
    public static let heartburn = Self(rawValue: "HKCategoryTypeIdentifierHeartburn")

    /// A category sample type for high heart rate events.
    public static let highHeartRateEvent = Self(rawValue: "HKCategoryTypeIdentifierHighHeartRateEvent")

    /// A category type that records hot flashes as a symptom.
    public static let hotFlashes = Self(rawValue: "HKCategoryTypeIdentifierHotFlashes")

    /// A category sample that indicates an infrequent menstrual cycle.
    public static let infrequentMenstrualCycles = Self(rawValue: "HKCategoryTypeIdentifierInfrequentMenstrualCycles")

    /// A category sample type that records spotting outside the normal menstruation period.
    public static let intermenstrualBleeding = Self(rawValue: "HKCategoryTypeIdentifierIntermenstrualBleeding")

    /// A category sample type for irregular heart rhythm events.
    public static let irregularHeartRhythmEvent = Self(rawValue: "HKCategoryTypeIdentifierIrregularHeartRhythmEvent")

    /// A category sample that indicates an irregular menstrual cycle.
    public static let irregularMenstrualCycles = Self(rawValue: "HKCategoryTypeIdentifierIrregularMenstrualCycles")

    /// A category type that records lactation.
    public static let lactation = Self(rawValue: "HKCategoryTypeIdentifierLactation")

    /// A category type that records loss of smell as a symptom.
    public static let lossOfSmell = Self(rawValue: "HKCategoryTypeIdentifierLossOfSmell")

    /// A category type that records loss of taste as a symptom.
    public static let lossOfTaste = Self(rawValue: "HKCategoryTypeIdentifierLossOfTaste")

    /// An event that indicates the user’s VO2 max values consistently fall below a particular aerobic fitness threshold.
    public static let lowCardioFitnessEvent = Self(rawValue: "HKCategoryTypeIdentifierLowCardioFitnessEvent")

    /// A category type that records lower back pain as a symptom.
    public static let lowerBackPain = Self(rawValue: "HKCategoryTypeIdentifierLowerBackPain")

    /// A category sample type for low heart rate events.
    public static let lowHeartRateEvent = Self(rawValue: "HKCategoryTypeIdentifierLowHeartRateEvent")

    /// A category type that records memory lapse as a symptom.
    public static let memoryLapse = Self(rawValue: "HKCategoryTypeIdentifierMemoryLapse")

    /// A category sample type that records menstrual cycles.
    public static let menstrualFlow = Self(rawValue: "HKCategoryTypeIdentifierMenstrualFlow")

    /// A category sample type for recording a mindful session.
    public static let mindfulSession = Self(rawValue: "HKCategoryTypeIdentifierMindfulSession")

    /// A category type that records mood changes as a symptom.
    public static let moodChanges = Self(rawValue: "HKCategoryTypeIdentifierMoodChanges")

    /// A category type that records nausea as a symptom.
    public static let nausea = Self(rawValue: "HKCategoryTypeIdentifierNausea")

    /// A category type that records night sweats as a symptom.
    public static let nightSweats = Self(rawValue: "HKCategoryTypeIdentifierNightSweats")

    /// A category sample type that records the result of an ovulation home test.
    public static let ovulationTestResult = Self(rawValue: "HKCategoryTypeIdentifierOvulationTestResult")

    /// A category type that records pelvic pain as a symptom.
    public static let pelvicPain = Self(rawValue: "HKCategoryTypeIdentifierPelvicPain")

    /// A category sample that indicates persistent intermenstrual bleeding.
    public static let persistentIntermenstrualBleeding = Self(rawValue: "HKCategoryTypeIdentifierPersistentIntermenstrualBleeding")

    /// A category type that records pregnancy.
    public static let pregnancy = Self(rawValue: "HKCategoryTypeIdentifierPregnancy")

    /// A category type that represents the results from a home pregnancy test.
    public static let pregnancyTestResult = Self(rawValue: "HKCategoryTypeIdentifierPregnancyTestResult")

    /// A category type that represents the results from a home progesterone test.
    public static let progesteroneTestResult = Self(rawValue: "HKCategoryTypeIdentifierProgesteroneTestResult")

    /// A category sample that indicates a prolonged menstrual cycle.
    public static let prolongedMenstrualPeriods = Self(rawValue: "HKCategoryTypeIdentifierProlongedMenstrualPeriods")

    /// A category type that records a rapid, pounding, or fluttering heartbeat as a symptom.
    public static let rapidPoundingOrFlutteringHeartbeat = Self(rawValue: "HKCategoryTypeIdentifierRapidPoundingOrFlutteringHeartbeat")

    /// A category type that records runny nose as a symptom.
    public static let runnyNose = Self(rawValue: "HKCategoryTypeIdentifierRunnyNose")

    /// A category sample type that records sexual activity.
    public static let sexualActivity = Self(rawValue: "HKCategoryTypeIdentifierSexualActivity")

    /// A category type that records shortness of breath as a symptom.
    public static let shortnessOfBreath = Self(rawValue: "HKCategoryTypeIdentifierShortnessOfBreath")

    /// A category type that records sinus congestion as a symptom.
    public static let sinusCongestion = Self(rawValue: "HKCategoryTypeIdentifierSinusCongestion")

    /// A category type that records skipped heartbeat as a symptom.
    public static let skippedHeartbeat = Self(rawValue: "HKCategoryTypeIdentifierSkippedHeartbeat")

    /// A category sample type for sleep analysis information.
    public static let sleepAnalysis = Self(rawValue: "HKCategoryTypeIdentifierSleepAnalysis")

    /// A category type that records sleep apnea as a symptom.
    public static let sleepApneaEvent = Self(rawValue: "HKCategoryTypeIdentifierSleepApneaEvent")

    /// A category type that records sleep changes as a symptom.
    public static let sleepChanges = Self(rawValue: "HKCategoryTypeIdentifierSleepChanges")

    /// A category type that records sore throat as a symptom.
    public static let soreThroat = Self(rawValue: "HKCategoryTypeIdentifierSoreThroat")

    /// A category sample type for toothbrushing events.
    public static let toothbrushingEvent = Self(rawValue: "HKCategoryTypeIdentifierToothbrushingEvent")

    /// A category type that records vaginal dryness as a symptom.
    public static let vaginalDryness = Self(rawValue: "HKCategoryTypeIdentifierVaginalDryness")

    /// A category type that records vomiting as a symptom.
    public static let vomiting = Self(rawValue: "HKCategoryTypeIdentifierVomiting")

    /// A category type that records wheezing as a symptom.
    public static let wheezing = Self(rawValue: "HKCategoryTypeIdentifierWheezing")
}


public struct HKCharacteristicTypeIdentifier: Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The activity move mode characteristic.
    public static let activityMoveMode = Self(rawValue: "HKCharacteristicTypeIdentifierActivityMoveMode")

    /// The characteristic representing the user's biological sex.
    public static let biologicalSex = Self(rawValue: "HKCharacteristicTypeIdentifierBiologicalSex")

    /// The characteristic representing the user's blood type.
    public static let bloodType = Self(rawValue: "HKCharacteristicTypeIdentifierBloodType")

    /// The characteristic representing the user's date of birth.
    public static let dateOfBirth = Self(rawValue: "HKCharacteristicTypeIdentifierDateOfBirth")

    /// The characteristic representing the user's skin type.
    public static let fitzpatrickSkinType = Self(rawValue: "HKCharacteristicTypeIdentifierFitzpatrickSkinType")

    /// The characteristic representing the user's wheelchair use status.
    public static let wheelchairUse = Self(rawValue: "HKCharacteristicTypeIdentifierWheelchairUse")
}


public struct HKClinicalTypeIdentifier: Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// A type identifier for records of allergic or intolerant reactions.
    public static let allergyRecord = Self(rawValue: "HKClinicalTypeIdentifierAllergyRecord")

    /// A type identifier for records of clinical notes.
    public static let clinicalNoteRecord = Self(rawValue: "HKClinicalTypeIdentifierClinicalNoteRecord")

    /// A type identifier for records of a condition, problem, diagnosis, or other event.
    public static let conditionRecord = Self(rawValue: "HKClinicalTypeIdentifierConditionRecord")

    /// A type identifier for records containing information about the user’s insurance coverage.
    public static let coverageRecord = Self(rawValue: "HKClinicalTypeIdentifierCoverageRecord")

    /// A type identifier for records of the current or historical administration of vaccines.
    public static let immunizationRecord = Self(rawValue: "HKClinicalTypeIdentifierImmunizationRecord")

    /// A type identifier for records of lab results.
    public static let labResultRecord = Self(rawValue: "HKClinicalTypeIdentifierLabResultRecord")

    /// A type identifier for records of medication.
    public static let medicationRecord = Self(rawValue: "HKClinicalTypeIdentifierMedicationRecord")

    /// A type identifier for records of procedures.
    public static let procedureRecord = Self(rawValue: "HKClinicalTypeIdentifierProcedureRecord")

    /// A type identifier for records of vital signs.
    public static let vitalSignRecord = Self(rawValue: "HKClinicalTypeIdentifierVitalSignRecord")
}


public struct HKCorrelationTypeIdentifier: Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The sample type representing blood pressure correlation samples
    public static let bloodPressure = Self(rawValue: "HKCorrelationTypeIdentifierBloodPressure")

    /// Food correlation types combine any number of nutritional samples into a single food object.
    public static let food = Self(rawValue: "HKCorrelationTypeIdentifierFood")
}


public struct HKQuantityTypeIdentifier: Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// A quantity sample type that measures the amount of active energy the user has burned.
    public static let activeEnergyBurned = Self(rawValue: "HKQuantityTypeIdentifierActiveEnergyBurned")

    /// A quantity sample type that measures the amount of time the user spent exercising.
    public static let appleExerciseTime = Self(rawValue: "HKQuantityTypeIdentifierAppleExerciseTime")

    /// A quantity sample type that measures the amount of time the user has spent performing activities that involve full-body movements during the specified day.
    public static let appleMoveTime = Self(rawValue: "HKQuantityTypeIdentifierAppleMoveTime")

    /// A quantity sample that records breathing disturbances during sleep.
    public static let appleSleepingBreathingDisturbances = Self(rawValue: "HKQuantityTypeIdentifierAppleSleepingBreathingDisturbances")

    /// A quantity sample type that records the wrist temperature during sleep.
    public static let appleSleepingWristTemperature = Self(rawValue: "HKQuantityTypeIdentifierAppleSleepingWristTemperature")

    /// A quantity sample type that measures the amount of time the user has spent standing.
    public static let appleStandTime = Self(rawValue: "HKQuantityTypeIdentifierAppleStandTime")

    /// A quantity sample type that measures the steadiness of the user’s gait.
    public static let appleWalkingSteadiness = Self(rawValue: "HKQuantityTypeIdentifierAppleWalkingSteadiness")

    /// A quantity type that measures an estimate of the percentage of time a person’s heart shows signs of atrial fibrillation (AFib) while wearing Apple Watch.
    public static let atrialFibrillationBurden = Self(rawValue: "HKQuantityTypeIdentifierAtrialFibrillationBurden")

    /// A quantity sample type that records the user’s basal body temperature.
    public static let basalBodyTemperature = Self(rawValue: "HKQuantityTypeIdentifierBasalBodyTemperature")

    /// A quantity sample type that measures the resting energy burned by the user.
    public static let basalEnergyBurned = Self(rawValue: "HKQuantityTypeIdentifierBasalEnergyBurned")

    /// A quantity sample type that measures the user’s blood alcohol content.
    public static let bloodAlcoholContent = Self(rawValue: "HKQuantityTypeIdentifierBloodAlcoholContent")

    /// A quantity sample type that measures the user’s blood glucose level.
    public static let bloodGlucose = Self(rawValue: "HKQuantityTypeIdentifierBloodGlucose")

    /// A quantity sample type that measures the user’s diastolic blood pressure.
    public static let bloodPressureDiastolic = Self(rawValue: "HKQuantityTypeIdentifierBloodPressureDiastolic")

    /// A quantity sample type that measures the user’s systolic blood pressure.
    public static let bloodPressureSystolic = Self(rawValue: "HKQuantityTypeIdentifierBloodPressureSystolic")

    /// A quantity sample type that measures the user’s body fat percentage.
    public static let bodyFatPercentage = Self(rawValue: "HKQuantityTypeIdentifierBodyFatPercentage")

    /// A quantity sample type that measures the user’s weight.
    public static let bodyMass = Self(rawValue: "HKQuantityTypeIdentifierBodyMass")

    /// A quantity sample type that measures the user’s body mass index.
    public static let bodyMassIndex = Self(rawValue: "HKQuantityTypeIdentifierBodyMassIndex")

    /// A quantity sample type that measures the user’s body temperature.
    public static let bodyTemperature = Self(rawValue: "HKQuantityTypeIdentifierBodyTemperature")

    /// A quantity sample that records cross-country skiing speed.
    public static let crossCountrySkiingSpeed = Self(rawValue: "HKQuantityTypeIdentifierCrossCountrySkiingSpeed")

    /// A quantity sample that records cycling cadence.
    public static let cyclingCadence = Self(rawValue: "HKQuantityTypeIdentifierCyclingCadence")

    /// A quantity sample that records cycling functional threshold power.
    public static let cyclingFunctionalThresholdPower = Self(rawValue: "HKQuantityTypeIdentifierCyclingFunctionalThresholdPower")

    /// A quantity sample that records cycling power.
    public static let cyclingPower = Self(rawValue: "HKQuantityTypeIdentifierCyclingPower")

    /// A quantity sample that records cycling speed.
    public static let cyclingSpeed = Self(rawValue: "HKQuantityTypeIdentifierCyclingSpeed")

    /// A quantity sample type that measures the amount of biotin (vitamin B7) consumed.
    public static let dietaryBiotin = Self(rawValue: "HKQuantityTypeIdentifierDietaryBiotin")

    /// A quantity sample type that measures the amount of caffeine consumed.
    public static let dietaryCaffeine = Self(rawValue: "HKQuantityTypeIdentifierDietaryCaffeine")

    /// A quantity sample type that measures the amount of calcium consumed.
    public static let dietaryCalcium = Self(rawValue: "HKQuantityTypeIdentifierDietaryCalcium")

    /// A quantity sample type that measures the amount of carbohydrates consumed.
    public static let dietaryCarbohydrates = Self(rawValue: "HKQuantityTypeIdentifierDietaryCarbohydrates")

    /// A quantity sample type that measures the amount of chloride consumed.
    public static let dietaryChloride = Self(rawValue: "HKQuantityTypeIdentifierDietaryChloride")

    /// A quantity sample type that measures the amount of cholesterol consumed.
    public static let dietaryCholesterol = Self(rawValue: "HKQuantityTypeIdentifierDietaryCholesterol")

    /// A quantity sample type that measures the amount of chromium consumed.
    public static let dietaryChromium = Self(rawValue: "HKQuantityTypeIdentifierDietaryChromium")

    /// A quantity sample type that measures the amount of copper consumed.
    public static let dietaryCopper = Self(rawValue: "HKQuantityTypeIdentifierDietaryCopper")

    /// A quantity sample type that measures the amount of energy consumed.
    public static let dietaryEnergyConsumed = Self(rawValue: "HKQuantityTypeIdentifierDietaryEnergyConsumed")

    /// A quantity sample type that measures the amount of monounsaturated fat consumed.
    public static let dietaryFatMonounsaturated = Self(rawValue: "HKQuantityTypeIdentifierDietaryFatMonounsaturated")

    /// A quantity sample type that measures the amount of polyunsaturated fat consumed.
    public static let dietaryFatPolyunsaturated = Self(rawValue: "HKQuantityTypeIdentifierDietaryFatPolyunsaturated")

    /// A quantity sample type that measures the amount of saturated fat consumed.
    public static let dietaryFatSaturated = Self(rawValue: "HKQuantityTypeIdentifierDietaryFatSaturated")

    /// A quantity sample type that measures the total amount of fat consumed.
    public static let dietaryFatTotal = Self(rawValue: "HKQuantityTypeIdentifierDietaryFatTotal")

    /// A quantity sample type that measures the amount of fiber consumed.
    public static let dietaryFiber = Self(rawValue: "HKQuantityTypeIdentifierDietaryFiber")

    /// A quantity sample type that measures the amount of folate (folic acid) consumed.
    public static let dietaryFolate = Self(rawValue: "HKQuantityTypeIdentifierDietaryFolate")

    /// A quantity sample type that measures the amount of iodine consumed.
    public static let dietaryIodine = Self(rawValue: "HKQuantityTypeIdentifierDietaryIodine")

    /// A quantity sample type that measures the amount of iron consumed.
    public static let dietaryIron = Self(rawValue: "HKQuantityTypeIdentifierDietaryIron")

    /// A quantity sample type that measures the amount of magnesium consumed.
    public static let dietaryMagnesium = Self(rawValue: "HKQuantityTypeIdentifierDietaryMagnesium")

    /// A quantity sample type that measures the amount of manganese consumed.
    public static let dietaryManganese = Self(rawValue: "HKQuantityTypeIdentifierDietaryManganese")

    /// A quantity sample type that measures the amount of molybdenum consumed.
    public static let dietaryMolybdenum = Self(rawValue: "HKQuantityTypeIdentifierDietaryMolybdenum")

    /// A quantity sample type that measures the amount of niacin (vitamin B3) consumed.
    public static let dietaryNiacin = Self(rawValue: "HKQuantityTypeIdentifierDietaryNiacin")

    /// A quantity sample type that measures the amount of pantothenic acid (vitamin B5) consumed.
    public static let dietaryPantothenicAcid = Self(rawValue: "HKQuantityTypeIdentifierDietaryPantothenicAcid")

    /// A quantity sample type that measures the amount of phosphorus consumed.
    public static let dietaryPhosphorus = Self(rawValue: "HKQuantityTypeIdentifierDietaryPhosphorus")

    /// A quantity sample type that measures the amount of potassium consumed.
    public static let dietaryPotassium = Self(rawValue: "HKQuantityTypeIdentifierDietaryPotassium")

    /// A quantity sample type that measures the amount of protein consumed.
    public static let dietaryProtein = Self(rawValue: "HKQuantityTypeIdentifierDietaryProtein")

    /// A quantity sample type that measures the amount of riboflavin (vitamin B2) consumed.
    public static let dietaryRiboflavin = Self(rawValue: "HKQuantityTypeIdentifierDietaryRiboflavin")

    /// A quantity sample type that measures the amount of selenium consumed.
    public static let dietarySelenium = Self(rawValue: "HKQuantityTypeIdentifierDietarySelenium")

    /// A quantity sample type that measures the amount of sodium consumed.
    public static let dietarySodium = Self(rawValue: "HKQuantityTypeIdentifierDietarySodium")

    /// A quantity sample type that measures the amount of sugar consumed.
    public static let dietarySugar = Self(rawValue: "HKQuantityTypeIdentifierDietarySugar")

    /// A quantity sample type that measures the amount of thiamin (vitamin B1) consumed.
    public static let dietaryThiamin = Self(rawValue: "HKQuantityTypeIdentifierDietaryThiamin")

    /// A quantity sample type that measures the amount of vitamin A consumed.
    public static let dietaryVitaminA = Self(rawValue: "HKQuantityTypeIdentifierDietaryVitaminA")

    /// A quantity sample type that measures the amount of pyridoxine (vitamin B6) consumed.
    public static let dietaryVitaminB6 = Self(rawValue: "HKQuantityTypeIdentifierDietaryVitaminB6")

    /// A quantity sample type that measures the amount of cyanocobalamin (vitamin B12) consumed.
    public static let dietaryVitaminB12 = Self(rawValue: "HKQuantityTypeIdentifierDietaryVitaminB12")

    /// A quantity sample type that measures the amount of vitamin C consumed.
    public static let dietaryVitaminC = Self(rawValue: "HKQuantityTypeIdentifierDietaryVitaminC")

    /// A quantity sample type that measures the amount of vitamin D consumed.
    public static let dietaryVitaminD = Self(rawValue: "HKQuantityTypeIdentifierDietaryVitaminD")

    /// A quantity sample type that measures the amount of vitamin E consumed.
    public static let dietaryVitaminE = Self(rawValue: "HKQuantityTypeIdentifierDietaryVitaminE")

    /// A quantity sample type that measures the amount of vitamin K consumed.
    public static let dietaryVitaminK = Self(rawValue: "HKQuantityTypeIdentifierDietaryVitaminK")

    /// A quantity sample type that measures the amount of water consumed.
    public static let dietaryWater = Self(rawValue: "HKQuantityTypeIdentifierDietaryWater")

    /// A quantity sample type that measures the amount of zinc consumed.
    public static let dietaryZinc = Self(rawValue: "HKQuantityTypeIdentifierDietaryZinc")

    /// A quantity sample that records cross-country skiing distance.
    public static let distanceCrossCountrySkiing = Self(rawValue: "HKQuantityTypeIdentifierDistanceCrossCountrySkiing")

    /// A quantity sample type that measures the distance the user has moved by cycling.
    public static let distanceCycling = Self(rawValue: "HKQuantityTypeIdentifierDistanceCycling")

    /// A quantity sample type that measures the distance the user has traveled while skiing or snowboarding.
    public static let distanceDownhillSnowSports = Self(rawValue: "HKQuantityTypeIdentifierDistanceDownhillSnowSports")

    /// A quantity sample that records paddle sports distance.
    public static let distancePaddleSports = Self(rawValue: "HKQuantityTypeIdentifierDistancePaddleSports")

    /// A quantity sample that records rowing distance.
    public static let distanceRowing = Self(rawValue: "HKQuantityTypeIdentifierDistanceRowing")

    /// A quantity sample that records skating sports distance.
    public static let distanceSkatingSports = Self(rawValue: "HKQuantityTypeIdentifierDistanceSkatingSports")

    /// A quantity sample type that measures the distance the user has moved while swimming.
    public static let distanceSwimming = Self(rawValue: "HKQuantityTypeIdentifierDistanceSwimming")

    /// A quantity sample type that measures the distance the user has moved by walking or running.
    public static let distanceWalkingRunning = Self(rawValue: "HKQuantityTypeIdentifierDistanceWalkingRunning")

    /// A quantity sample type that measures the distance the user has moved using a wheelchair.
    public static let distanceWheelchair = Self(rawValue: "HKQuantityTypeIdentifierDistanceWheelchair")

    /// A quantity sample type that measures electrodermal activity.
    public static let electrodermalActivity = Self(rawValue: "HKQuantityTypeIdentifierElectrodermalActivity")

    /// A quantity sample type that measures audio exposure to sounds in the environment.
    public static let environmentalAudioExposure = Self(rawValue: "HKQuantityTypeIdentifierEnvironmentalAudioExposure")

    /// A quantity sample that records environmental sound reduction.
    public static let environmentalSoundReduction = Self(rawValue: "HKQuantityTypeIdentifierEnvironmentalSoundReduction")

    /// A quantity sample that records estimated physical effort during workouts.
    public static let estimatedWorkoutEffortScore = Self(rawValue: "HKQuantityTypeIdentifierEstimatedWorkoutEffortScore")

    /// A quantity sample type that measures the number flights of stairs that the user has climbed.
    public static let flightsClimbed = Self(rawValue: "HKQuantityTypeIdentifierFlightsClimbed")

    /// A quantity sample type that measures the amount of air that can be forcibly exhaled from the lungs during the first second of a forced exhalation.
    public static let forcedExpiratoryVolume1 = Self(rawValue: "HKQuantityTypeIdentifierForcedExpiratoryVolume1")

    /// A quantity sample type that measures the amount of air that can be forcibly exhaled from the lungs after taking the deepest breath possible.
    public static let forcedVitalCapacity = Self(rawValue: "HKQuantityTypeIdentifierForcedVitalCapacity")

    /// A quantity sample type that measures audio exposure from headphones.
    public static let headphoneAudioExposure = Self(rawValue: "HKQuantityTypeIdentifierHeadphoneAudioExposure")

    /// A quantity sample type that measures the user’s heart rate.
    public static let heartRate = Self(rawValue: "HKQuantityTypeIdentifierHeartRate")

    /// A quantity sample that records the reduction in heart rate from the peak exercise rate to the rate one minute after exercising ended.
    public static let heartRateRecoveryOneMinute = Self(rawValue: "HKQuantityTypeIdentifierHeartRateRecoveryOneMinute")

    /// A quantity sample type that measures the standard deviation of heartbeat intervals.
    public static let heartRateVariabilitySDNN = Self(rawValue: "HKQuantityTypeIdentifierHeartRateVariabilitySDNN")

    /// A quantity sample type that measures the user’s height.
    public static let height = Self(rawValue: "HKQuantityTypeIdentifierHeight")

    /// A quantity sample type that measures the number of puffs the user takes from their inhaler.
    public static let inhalerUsage = Self(rawValue: "HKQuantityTypeIdentifierInhalerUsage")

    /// A quantity sample that measures the amount of insulin delivered.
    public static let insulinDelivery = Self(rawValue: "HKQuantityTypeIdentifierInsulinDelivery")

    /// A quantity sample type that measures the user’s lean body mass.
    public static let leanBodyMass = Self(rawValue: "HKQuantityTypeIdentifierLeanBodyMass")

    /// A quantity sample type that measures the number of standard alcoholic drinks that the user has consumed.
    public static let numberOfAlcoholicBeverages = Self(rawValue: "HKQuantityTypeIdentifierNumberOfAlcoholicBeverages")

    /// A quantity sample type that measures the number of times the user fell.
    public static let numberOfTimesFallen = Self(rawValue: "HKQuantityTypeIdentifierNumberOfTimesFallen")

    /// A quantity sample type that measures the user’s oxygen saturation.
    public static let oxygenSaturation = Self(rawValue: "HKQuantityTypeIdentifierOxygenSaturation")

    /// A quantity sample that records paddle sports speed.
    public static let paddleSportsSpeed = Self(rawValue: "HKQuantityTypeIdentifierPaddleSportsSpeed")

    /// A quantity sample type that measures the user’s maximum flow rate generated during a forceful exhalation.
    public static let peakExpiratoryFlowRate = Self(rawValue: "HKQuantityTypeIdentifierPeakExpiratoryFlowRate")

    /// A quantity sample type that measures the user’s peripheral perfusion index.
    public static let peripheralPerfusionIndex = Self(rawValue: "HKQuantityTypeIdentifierPeripheralPerfusionIndex")

    /// A quantity sample that records physical effort.
    public static let physicalEffort = Self(rawValue: "HKQuantityTypeIdentifierPhysicalEffort")

    /// A quantity sample type that measures the number of pushes that the user has performed while using a wheelchair.
    public static let pushCount = Self(rawValue: "HKQuantityTypeIdentifierPushCount")

    /// A quantity sample type that measures the user’s respiratory rate.
    public static let respiratoryRate = Self(rawValue: "HKQuantityTypeIdentifierRespiratoryRate")

    /// A quantity sample type that measures the user’s resting heart rate.
    public static let restingHeartRate = Self(rawValue: "HKQuantityTypeIdentifierRestingHeartRate")

    /// A quantity sample that records rowing speed.
    public static let rowingSpeed = Self(rawValue: "HKQuantityTypeIdentifierRowingSpeed")

    /// A quantity sample type that measures the amount of time the runner’s foot is in contact with the ground while running.
    public static let runningGroundContactTime = Self(rawValue: "HKQuantityTypeIdentifierRunningGroundContactTime")

    /// A quantity sample type that measures the rate of work required for the runner to maintain their speed.
    public static let runningPower = Self(rawValue: "HKQuantityTypeIdentifierRunningPower")

    /// A quantity sample type that measures the runner’s speed.
    public static let runningSpeed = Self(rawValue: "HKQuantityTypeIdentifierRunningSpeed")

    /// A quantity sample type that measures the distance covered by a single step while running.
    public static let runningStrideLength = Self(rawValue: "HKQuantityTypeIdentifierRunningStrideLength")

    /// A quantity sample type measuring pelvis vertical range of motion during a single running stride.
    public static let runningVerticalOscillation = Self(rawValue: "HKQuantityTypeIdentifierRunningVerticalOscillation")

    /// A quantity sample type that stores the distance a user can walk during a six-minute walk test.
    public static let sixMinuteWalkTestDistance = Self(rawValue: "HKQuantityTypeIdentifierSixMinuteWalkTestDistance")

    /// A quantity sample type measuring the user’s speed while climbing a flight of stairs.
    public static let stairAscentSpeed = Self(rawValue: "HKQuantityTypeIdentifierStairAscentSpeed")

    /// A quantity sample type measuring the user’s speed while descending a flight of stairs.
    public static let stairDescentSpeed = Self(rawValue: "HKQuantityTypeIdentifierStairDescentSpeed")

    /// A quantity sample type that measures the number of steps the user has taken.
    public static let stepCount = Self(rawValue: "HKQuantityTypeIdentifierStepCount")

    /// A quantity sample type that measures the number of strokes performed while swimming.
    public static let swimmingStrokeCount = Self(rawValue: "HKQuantityTypeIdentifierSwimmingStrokeCount")

    /// A quantity sample that records time spent in daylight.
    public static let timeInDaylight = Self(rawValue: "HKQuantityTypeIdentifierTimeInDaylight")

    /// A quantity sample that records a person’s depth underwater.
    public static let underwaterDepth = Self(rawValue: "HKQuantityTypeIdentifierUnderwaterDepth")

    /// A quantity sample type that measures the user’s exposure to UV radiation.
    public static let uvExposure = Self(rawValue: "HKQuantityTypeIdentifierUVExposure")

    /// A quantity sample that measures the maximal oxygen consumption during exercise.
    public static let vo2Max = Self(rawValue: "HKQuantityTypeIdentifierVO2Max")

    /// A quantity sample type that measures the user’s waist circumference.
    public static let waistCircumference = Self(rawValue: "HKQuantityTypeIdentifierWaistCircumference")

    /// A quantity sample type that measures the percentage of steps in which one foot moves at a different speed than the other when walking on flat ground.
    public static let walkingAsymmetryPercentage = Self(rawValue: "HKQuantityTypeIdentifierWalkingAsymmetryPercentage")

    /// A quantity sample type that measures the percentage of time when both of the user’s feet touch the ground while walking steadily over flat ground.
    public static let walkingDoubleSupportPercentage = Self(rawValue: "HKQuantityTypeIdentifierWalkingDoubleSupportPercentage")

    /// A quantity sample type that measures the user’s heart rate while walking.
    public static let walkingHeartRateAverage = Self(rawValue: "HKQuantityTypeIdentifierWalkingHeartRateAverage")

    /// A quantity sample type that measures the user’s average speed when walking steadily over flat ground.
    public static let walkingSpeed = Self(rawValue: "HKQuantityTypeIdentifierWalkingSpeed")

    /// A quantity sample type that measures the average length of the user’s step when walking steadily over flat ground.
    public static let walkingStepLength = Self(rawValue: "HKQuantityTypeIdentifierWalkingStepLength")

    ///  A quantity sample that records the water temperature.
    public static let waterTemperature = Self(rawValue: "HKQuantityTypeIdentifierWaterTemperature")

    /// A quantity sample that records workout effort.
    public static let workoutEffortScore = Self(rawValue: "HKQuantityTypeIdentifierWorkoutEffortScore")
}


public struct HKScoredAssessmentTypeIdentifier: Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The GAD-7 (generalized anxiery disorder 7) score type
    public static let GAD7 = Self(rawValue: "HKScoredAssessmentTypeIdentifierGAD7")

    /// The PHQ-9 (nine-item Patient Health Questionnaire) score type
    public static let PHQ9 = Self(rawValue: "HKScoredAssessmentTypeIdentifierPHQ9")
}


public struct HKDocumentTypeIdentifier: Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The CDA Document type identifier, used when requesting permission to read or share CDA documents.
    public static let CDA = Self(rawValue: "HKDocumentTypeIdentifierCDA")
}


public let HKActivitySummaryTypeIdentifier = "HKActivitySummaryTypeIdentifier"

/// The audiogram sample type
public let HKAudiogramSampleTypeIdentifier = "HKDataTypeIdentifierAudiogram"

/// The heartbeat series sample type
public let HKDataTypeIdentifierHeartbeatSeries = "HKDataTypeIdentifierHeartbeatSeries"

/// The state of mind sample type
public let HKDataTypeIdentifierStateOfMind = "HKDataTypeStateOfMind"

/// The electrocardiogram sample type
public let HKElectrocardiogramTypeIdentifier = "HKDataTypeIdentifierElectrocardiogram"

/// The vision prescription sample type
public let HKVisionPrescriptionTypeIdentifier = "HKVisionPrescriptionTypeIdentifier"

/// The workout route sample type
public let HKWorkoutRouteTypeIdentifier = "HKWorkoutRouteTypeIdentifier"

/// The workout sample type
public let HKWorkoutTypeIdentifier = "HKWorkoutTypeIdentifier"


#endif // !canImport(HealthKit)
