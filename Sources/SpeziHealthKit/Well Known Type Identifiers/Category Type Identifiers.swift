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


extension HKCategoryType {
    public static let allKnownCategories: Set<HKCategoryType> = Set(HKCategoryTypeIdentifier.allKnownIdentifiers.map { HKCategoryType($0) })
}

extension HKCategoryTypeIdentifier {
    public static let allKnownIdentifiers = Set<Self> {
        Self.appleStandHour
        Self.environmentalAudioExposureEvent
        Self.headphoneAudioExposureEvent
        Self.highHeartRateEvent
        Self.irregularHeartRhythmEvent
        Self.lowCardioFitnessEvent
        Self.lowHeartRateEvent
        Self.mindfulSession
        Self.appleWalkingSteadinessEvent
        Self.handwashingEvent
        Self.toothbrushingEvent
        if #available(iOS 18, macOS 15, *) {
            Self.bleedingAfterPregnancy
        }
        if #available(iOS 18, macOS 15, *) {
            Self.bleedingDuringPregnancy
        }
        Self.cervicalMucusQuality
        Self.contraceptive
        Self.infrequentMenstrualCycles
        Self.intermenstrualBleeding
        Self.irregularMenstrualCycles
        Self.lactation
        Self.menstrualFlow
        Self.ovulationTestResult
        Self.persistentIntermenstrualBleeding
        Self.pregnancy
        Self.pregnancyTestResult
        Self.progesteroneTestResult
        Self.prolongedMenstrualPeriods
        Self.sexualActivity
        if #available(iOS 18, macOS 15, *) {
            Self.sleepApneaEvent
        }
        Self.sleepAnalysis
        Self.abdominalCramps
        Self.acne
        Self.appetiteChanges
        Self.bladderIncontinence
        Self.bloating
        Self.breastPain
        Self.chestTightnessOrPain
        Self.chills
        Self.constipation
        Self.coughing
        Self.diarrhea
        Self.dizziness
        Self.drySkin
        Self.fainting
        Self.fatigue
        Self.fever
        Self.generalizedBodyAche
        Self.hairLoss
        Self.headache
        Self.heartburn
        Self.hotFlashes
        Self.lossOfSmell
        Self.lossOfTaste
        Self.lowerBackPain
        Self.memoryLapse
        Self.moodChanges
        Self.nausea
        Self.nightSweats
        Self.pelvicPain
        Self.rapidPoundingOrFlutteringHeartbeat
        Self.runnyNose
        Self.shortnessOfBreath
        Self.sinusCongestion
        Self.skippedHeartbeat
        Self.sleepChanges
        Self.soreThroat
        Self.vaginalDryness
        Self.vomiting
        Self.wheezing
    }
}
