//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import HealthKit
import Spezi
import SpeziHealthKit


/// An example Standard used for the configuration.
actor HealthKitTestAppStandard: Standard, HealthKitConstraint {
    @Dependency(HealthKitStore.self) private var healthKitStore
    
    func add(sample: HKSample) async {
        await healthKitStore.add(sample: sample)
    }
    
    func remove(sample: HKDeletedObject) async {
        await healthKitStore.remove(sample: sample)
    }
}
