//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziHealthKit
import SpeziHealthKitBulkExport


class TestAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: HealthKitTestAppStandard()) { // swiftlint:disable:this closure_body_length
            HealthKit {
                CollectSample(
                    .electrocardiogram,
                    start: .manual,
                    continueInBackground: true
                )
                CollectSample(
                    .stepCount,
                    start: .automatic,
                    continueInBackground: true
                )
                CollectSample(
                    .pushCount,
                    start: .manual
                )
                CollectSample(
                    .activeEnergyBurned
                )
                CollectSample(.heartRate, start: .manual)
                CollectSample(.heartRate, start: .manual)
                
                CollectSample(.stairAscentSpeed, continueInBackground: true)
                CollectSample(.stairDescentSpeed, continueInBackground: false)
                CollectSample(.workout)
                CollectSample(.bloodPressure, start: .automatic)
                
                RequestReadAccess(
                    quantity: [.bloodOxygen],
                    category: [.sleepAnalysis],
                    characteristic: [.activityMoveMode, .biologicalSex, .bloodType, .dateOfBirth, .fitzpatrickSkinType, .wheelchairUse],
                    other: [SampleType.workout, SampleType.audiogram, SampleType.gad7, SampleType.phq9]
                )
                
                RequestWriteAccess(
                    quantity: [.heartRate, .bloodOxygen, .stepCount, .height, .activeEnergyBurned, .pushCount],
                    category: [.sleepAnalysis],
                    other: [SampleType.gad7, SampleType.phq9]
                )
            }
            
            BulkHealthExporter()
        }
    }
}
