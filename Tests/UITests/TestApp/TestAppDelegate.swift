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
        Configuration(standard: ExampleStandard()) {
            HealthKit {
                CollectSample(
                    HKQuantityType.electrocardiogramType(),
                    deliverySetting: .background(.manual)
                )
                CollectSample(
                    HKQuantityType(.stepCount),
                    deliverySetting: .background(.automatic)
                )
                CollectSample(
                    HKQuantityType(.pushCount),
                    deliverySetting: .anchorQuery(.manual)
                )
                CollectSample(
                    HKQuantityType(.activeEnergyBurned),
                    deliverySetting: .anchorQuery(.automatic)
                )
                CollectSample(
                    HKQuantityType(.restingHeartRate),
                    deliverySetting: .manual()
                )
            }
        }
    }
}
