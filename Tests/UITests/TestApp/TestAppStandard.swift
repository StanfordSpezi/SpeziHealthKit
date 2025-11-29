//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi
import SpeziHealthKit
import SpeziHealthKitBulkExport


/// An example Standard used for the configuration.
actor TestAppStandard: Standard, HealthKitConstraint {
    @Dependency(FakeHealthStore.self) private var fakeHealthStore
    @Dependency(BulkHealthExporter.self) private var bulkExporter
    
    nonisolated func configure() {
        let cliArgs = CommandLine.arguments
        if cliArgs.contains("--resetEverything") {
            Task {
                FakeHealthStore.reset()
                try FileManager.default.removeItem(at: .documentsDirectory)
                try FileManager.default.createDirectory(at: .documentsDirectory, withIntermediateDirectories: true)
                try await bulkExporter.deleteSessionRestorationInfo(for: .testApp)
            }
        }
    }
    
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
