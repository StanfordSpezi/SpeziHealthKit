//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziHealthKit


class TestAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: HealthKitTestAppStandard()) {
            HealthKit {
                CollectSample( //
                    .electrocardiogram,
                    delivery: .background(.manual)
                )
                CollectSample( //
                    .stepCount,
                    delivery: .background(.automatic)
                )
                CollectSample(
                    .pushCount,
                    delivery: .continuous(.manual)
                )
                CollectSample( //
                    .activeEnergyBurned,
                    delivery: .continuous(.automatic)
                )
                CollectSample( //
                    .restingHeartRate,
                    delivery: .manual()
                )
                
//                CollectSample(.bloodOxygen, delivery: .continuous(.automatic))
//                RequestWriteAccess(quantity: [.oxygenSaturation])
            }
        }
    }
}
