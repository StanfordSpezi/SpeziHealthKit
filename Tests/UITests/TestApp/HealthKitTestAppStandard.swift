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
    @Dependency(FakeHealthStore.self) private var fakeHealthStore
    
    func handleNewSamples<Sample>(
        _ addedSamples: some Collection<Sample>,
        ofType sampleType: SampleType<Sample>
    ) async {
        for sample in addedSamples {
            await fakeHealthStore.add(sample)
        }
    }
    
    func handleDeletedObjects<Sample>(
        _ deletedObjects: some Collection<HKDeletedObject>,
        ofType sampleType: SampleType<Sample>
    ) async {
        for object in deletedObjects {
            await fakeHealthStore.remove(object)
        }
    }
}
