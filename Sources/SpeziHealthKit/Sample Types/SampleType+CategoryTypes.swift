//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


// MARK: Activity

extension SampleType {
    /// A category sample type that counts the number of hours in the day during which the user has stood and moved for at least one minute per hour.
    @inlinable public static var appleStandHour: SampleType<HKCategorySample> {
        .category(.appleStandHour, displayTitle: "Stand Hours")
    }
    
    /// An event that indicates the user’s VO2 max values consistently fall below a particular aerobic fitness threshold.
    @inlinable public static var lowCardioFitnessEvent: SampleType<HKCategorySample> {
        .category(.lowCardioFitnessEvent, displayTitle: "Low Cardio Fitness Event")
    }
}


// MARK: Reproductive Health

extension SampleType {
    /// A category sample type that records menstrual cycles.
    @inlinable public static var menstrualFlow: SampleType<HKCategorySample> {
        .category(.menstrualFlow, displayTitle: "Menstrual Cycles")
    }
    
    /// A category sample type that records spotting outside the normal menstruation period.
    @inlinable public static var intermenstrualBleeding: SampleType<HKCategorySample> {
        .category(.intermenstrualBleeding, displayTitle: "Spotting")
    }
    
    /// A category sample that indicates an infrequent menstrual cycle.
    @inlinable public static var infrequentMenstrualCycles: SampleType<HKCategorySample> {
        .category(.infrequentMenstrualCycles, displayTitle: "Infrequent Periods")
    }
    
    /// A category sample that indicates an irregular menstrual cycle.
    @inlinable public static var irregularMenstrualCycles: SampleType<HKCategorySample> {
        .category(.irregularMenstrualCycles, displayTitle: "Irregular Cycles")
    }
    
    /// A category sample that indicates persistent intermenstrual bleeding.
    @inlinable public static var persistentIntermenstrualBleeding: SampleType<HKCategorySample> {
        .category(.persistentIntermenstrualBleeding, displayTitle: "Persistent Spotting")
    }
    
    /// A category sample that indicates a prolonged menstrual cycle.
    @inlinable public static var prolongedMenstrualPeriods: SampleType<HKCategorySample> {
        .category(.prolongedMenstrualPeriods, displayTitle: "Prolonged Periods")
    }
    
    /// A category sample type that records the quality of the user’s cervical mucus.
    @inlinable public static var cervicalMucusQuality: SampleType<HKCategorySample> {
        .category(.cervicalMucusQuality, displayTitle: "Cervical Mucus Quality")
    }
    
    /// A category sample type that records the result of an ovulation home test.
    @inlinable public static var ovulationTestResult: SampleType<HKCategorySample> {
        .category(.ovulationTestResult, displayTitle: "Ovulation Test Result")
    }
    
    /// A category type that represents the results from a home progesterone test.
    @inlinable public static var progesteroneTestResult: SampleType<HKCategorySample> {
        .category(.progesteroneTestResult, displayTitle: "Progesterone Test Result")
    }
    
    /// A category sample type that records sexual activity.
    @inlinable public static var sexualActivity: SampleType<HKCategorySample> {
        .category(.sexualActivity, displayTitle: "Sexual Activity")
    }
    
    /// A category sample type that records the use of contraceptives.
    @inlinable public static var contraceptive: SampleType<HKCategorySample> {
        .category(.contraceptive, displayTitle: "Contraceptives")
    }
    
    /// A category type that records pregnancy.
    @inlinable public static var pregnancy: SampleType<HKCategorySample> {
        .category(.pregnancy, displayTitle: "Pregnancy")
    }
    
    /// A category type that represents the results from a home pregnancy test.
    @inlinable public static var pregnancyTestResult: SampleType<HKCategorySample> {
        .category(.pregnancyTestResult, displayTitle: "Pregnancy Test Result")
    }
    
    /// A category type that records lactation.
    @inlinable public static var lactation: SampleType<HKCategorySample> {
        .category(.lactation, displayTitle: "Lactation")
    }
}


// MARK: Hearing

extension SampleType {
    /// A category sample type that records exposure to potentially damaging sounds from the environment.
    @inlinable public static var environmentalAudioExposureEvent: SampleType<HKCategorySample> {
        .category(.environmentalAudioExposureEvent, displayTitle: "Environmental Audio Exposure Event")
    }
    
    /// A category sample type that records exposure to potentially damaging sounds from headphones.
    @inlinable public static var headphoneAudioExposureEvent: SampleType<HKCategorySample> {
        .category(.headphoneAudioExposureEvent, displayTitle: "Headphone Audio Exposure Event")
    }
}


// MARK: Vital Signs

extension SampleType {
    /// A category sample type for low heart rate events.
    @inlinable public static var lowHeartRateEvent: SampleType<HKCategorySample> {
        .category(.lowHeartRateEvent, displayTitle: "Low Heart Rate Event")
    }
    /// A category sample type for high heart rate events.
    @inlinable public static var highHeartRateEvent: SampleType<HKCategorySample> {
        .category(.highHeartRateEvent, displayTitle: "High Heart Rate Event")
    }
    /// A category sample type for irregular heart rhythm events.
    @inlinable public static var irregularHeartRhythmEvent: SampleType<HKCategorySample> {
        .category(.irregularHeartRhythmEvent, displayTitle: "Irregular Heart Rythm Event")
    }
}


// MARK: Mobility

extension SampleType {
    /// A category sample type that records an incident where the user showed a reduced score for their gait’s steadiness.
    @inlinable public static var appleWalkingSteadinessEvent: SampleType<HKCategorySample> {
        .category(.appleWalkingSteadinessEvent, displayTitle: "Walking Steadiness Event")
    }
}


// MARK: Mindfulness and Sleep

extension SampleType {
    /// A category sample type for recording a mindful session.
    @inlinable public static var mindfulSession: SampleType<HKCategorySample> {
        .category(.mindfulSession, displayTitle: "Mindful Session")
    }
    
    /// A category sample type for sleep analysis information.
    @inlinable public static var sleepAnalysis: SampleType<HKCategorySample> {
        .category(.sleepAnalysis, displayTitle: "Sleep Analysis")
    }
}


// MARK: Self Care

extension SampleType {
    /// A category sample type for toothbrushing events.
    @inlinable public static var toothbrushingEvent: SampleType<HKCategorySample> {
        .category(.toothbrushingEvent, displayTitle: "Toothbrushing Event")
    }
    /// A category sample type for handwashing events.
    @inlinable public static var handwashingEvent: SampleType<HKCategorySample> {
        .category(.handwashingEvent, displayTitle: "Handwashing Event")
    }
}
