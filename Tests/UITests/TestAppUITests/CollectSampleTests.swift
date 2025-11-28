//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import SpeziHealthKit
import XCTest
import XCTestExtensions
import XCTHealthKit


final class CollectSampleTests: SpeziHealthKitTests {
    @MainActor
    func testCollectSamples() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app, resetEverything: true, deleteAllHealthData: true)
        
        app.buttons["Collect Samples"].tap()
        
        // At the beginning, we expect nothing to be collected
        assertCollectedSamplesSinceLaunch(in: app, [:])
        // Add a heart rate sample
        addSample(.heartRate, in: app)
        // Since the CollectSample start setting for heart rate is .manual, it stil shouldn't be there
        assertCollectedSamplesSinceLaunch(in: app, [:])
        // We manually start the heart rate data collection, which should make the sample show up
        triggerDataCollection(in: app)
        assertCollectedSamplesSinceLaunch(in: app, [
            .heartRate: 1
        ])
        
        // Add an active energy burned sample
        addSample(.activeEnergyBurned, in: app)
        // Since we have a continuous automatic query for these, it should show up immediately.
        assertCollectedSamplesSinceLaunch(in: app, [
            .heartRate: 1,
            .activeEnergyBurned: 1
        ])
        
        // Add a step count sample
        addSample(.stepCount, in: app)
        // These are collected via an automatic background query, and should therefore also directly show up
        assertCollectedSamplesSinceLaunch(in: app, [
            .heartRate: 1,
            .activeEnergyBurned: 1,
            .stepCount: 1
        ])
        
        // Add a height sample. These aren't collected at all, and should never show up
        addSample(.height, in: app)
        assertCollectedSamplesSinceLaunch(in: app, [
            .heartRate: 1,
            .activeEnergyBurned: 1,
            .stepCount: 1
        ])
        
        // Add another active energy burned sample. As before, this should show up immediately
        addSample(.activeEnergyBurned, in: app)
        assertCollectedSamplesSinceLaunch(in: app, [
            .heartRate: 1,
            .activeEnergyBurned: 2,
            .stepCount: 1
        ])
        
        // i'm gonna do it again
        addSample(.activeEnergyBurned, in: app)
        assertCollectedSamplesSinceLaunch(in: app, [
            .heartRate: 1,
            .activeEnergyBurned: 3,
            .stepCount: 1
        ])
        
        app.buttons["Register more CollectSample instances"].tap()
        sleep(for: .seconds(1)) // give it some time to handle this.
    }
}
