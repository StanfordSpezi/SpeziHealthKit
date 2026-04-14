//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
@testable import SpeziHealthKitFHIR
import Testing


@MainActor // to work around https://github.com/apple/FHIRModels/issues/36
struct HKElectrocardiogramTests {
    @Test
    func electrocardiogramCategoryTests() {
        #expect(HKElectrocardiogram.SymptomsStatus.notSet.display == "not set")
        #expect(HKElectrocardiogram.SymptomsStatus.none.display == "none")
        #expect(HKElectrocardiogram.SymptomsStatus.present.display == "present")
        
        #expect(HKElectrocardiogram.Classification.notSet.display == "not set")
        #expect(HKElectrocardiogram.Classification.sinusRhythm.display == "sinus rhythm")
        #expect(HKElectrocardiogram.Classification.atrialFibrillation.display == "atrial fibrillation")
        #expect(HKElectrocardiogram.Classification.inconclusiveLowHeartRate.display == "inconclusive low heart rate")
        #expect(HKElectrocardiogram.Classification.inconclusiveHighHeartRate.display == "inconclusive high heart rate")
        #expect(HKElectrocardiogram.Classification.inconclusivePoorReading.display == "inconclusive poor reading")
        #expect(HKElectrocardiogram.Classification.inconclusiveOther.display == "inconclusive other")
        #expect(HKElectrocardiogram.Classification.unrecognized.display == "unrecognized")
    }
}
