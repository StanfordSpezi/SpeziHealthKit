//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest
import XCTHealthKit


final class HealthKitQueryTests: SpeziHealthKitTests {
    @MainActor
    func testHmmm() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app, resetEverything: true, deleteAllHealthData: true)
    }
    
    
    @MainActor
    func testHealthKitQuery() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app, resetEverything: true, deleteAllHealthData: true)
        
        for _ in 0..<7 {
            addSample(.stepCount, in: app)
        }
        
        XCTAssert(app.buttons["Samples Query"].wait(for: \.isHittable, toEqual: true, timeout: 2))
        app.buttons["Samples Query"].tap()
        XCTAssert(app.staticTexts["Steps, 152"].waitForExistence(timeout: 3))
    }
    
    
    @MainActor
    func testHealthKitStatisticsQuery() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app, resetEverything: true, deleteAllHealthData: true)
        
        for _ in 0..<7 {
            addSample(.stepCount, in: app)
        }
        
        XCTAssert(app.buttons["Samples Query"].wait(for: \.isHittable, toEqual: true, timeout: 2))
        app.buttons["Statistics Query"].tap()
        
        let now = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        let fmt = { String(format: "%02d", $0) }
        let todayPred = NSPredicate(
            format: "label MATCHES %@",
            "Steps on \(fmt(try XCTUnwrap(now.year)))-\(fmt(try XCTUnwrap(now.month)))-\(fmt(try XCTUnwrap(now.day))).*"
        )
        XCTAssert(app.staticTexts.element(matching: todayPred).waitForExistence(timeout: 2))
    }
    
    @MainActor
    func testHealthKitCollectStatisticsQuery() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app, resetEverything: true, deleteAllHealthData: true)
        
        for _ in 0..<3 {
            addSample(.stepCount, in: app)
        }
        addSample(.heartRate, in: app)
        
        XCTAssert(app.buttons["Collect Statistics Query"].wait(for: \.isHittable, toEqual: true, timeout: 2))
        app.buttons["Collect Statistics Query"].tap()
        
        XCTAssert(app.buttons["Trigger Statistics Queries"].wait(for: \.isHittable, toEqual: true, timeout: 2))
        app.buttons["Trigger Statistics Queries"].tap()
        sleep(for: .seconds(1))
        
        let now = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        let fmt = { String(format: "%02d", $0) }
        let todayPred = NSPredicate(
            format: "label MATCHES %@",
            "Steps on \(fmt(try XCTUnwrap(now.year)))-\(fmt(try XCTUnwrap(now.month)))-\(fmt(try XCTUnwrap(now.day))).*"
        )
        XCTAssert(app.staticTexts.element(matching: todayPred).waitForExistence(timeout: 2))
        
        func assertHRRow(_ identifier: String) {
            let value = app.staticTexts["hr-value-\(identifier)"]
            XCTAssert(value.waitForExistence(timeout: 2))
            XCTAssertEqual(value.label, "87 count/min")
        }
        
        assertHRRow("average")
        assertHRRow("minimum")
        assertHRRow("maximum")
    }
    
    
    @MainActor
    func testCharacteristicsQuery() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app, resetEverything: true, deleteAllHealthData: true)
        
        let dateOfBirthComponents = DateComponents(
            calendar: .init(identifier: .gregorian),
            timeZone: .current,
            era: 1,
            year: 2022,
            month: 10,
            day: 11
        )
        let dateOfBirth = try XCTUnwrap(Calendar.current.date(from: dateOfBirthComponents))
        
        try launchHealthAppAndEnterCharacteristics(.init(
            bloodType: .oPositive,
            dateOfBirth: dateOfBirthComponents,
            biologicalSex: .female,
            skinType: .I,
            wheelchairUse: .no
        ))
        
        app.activate()
        XCTAssert(app.buttons["Characteristics Query"].waitForExistence(timeout: 2))
        app.buttons["Characteristics Query"].tap()
        
        app.assertTableRow("Move Mode", "1")
        app.assertTableRow("Blood Type", "O+")
        app.assertTableRow("Date of Birth", dateOfBirth.formatted(.iso8601))
        app.assertTableRow("Date of Birth is Midnight", "true")
        app.assertTableRow("Date of Birth Components", dateOfBirthComponents.description)
        app.assertTableRow("Biological Sex", "1")
        app.assertTableRow("Skin Type", "1")
        app.assertTableRow("Wheelchair Use", "1")
    }
    
    
    @MainActor
    func testScoredAssessments() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app, resetEverything: true, deleteAllHealthData: true)
        
        sleep(for: .seconds(0.5)) // we need to wait a little so that the permissions sheet is properly dismissed
        app.buttons["Scored Assessments"].tap()
        
        XCTAssert(app.staticTexts["No GAD-7 Assessments"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["No PHQ-9 Assessments"].waitForExistence(timeout: 2))
        
        func addScore(_ name: String) {
            let menuButton = app.navigationBars.images["plus"]
            XCTAssert(menuButton.waitForExistence(timeout: 1))
            menuButton.tap()
            let addSampleButton = app.buttons["Add Sample: \(name)"]
            XCTAssert(addSampleButton.waitForExistence(timeout: 2))
            addSampleButton.tap()
            sleep(for: .seconds(0.5)) // i sleep
        }
        
        addScore("GAD-7")
        XCTAssert(app.staticTexts["No GAD-7 Assessments"].waitForNonExistence(timeout: 2))
        app.assertTableRow("Date", "2025-04-25")
        app.assertTableRow("Risk", "2")
        app.assertTableRow("Answers", "2;3;0;1;1;0;2")
        
        addScore("PHQ-9")
        XCTAssert(app.staticTexts["No PHQ-9 Assessments"].waitForNonExistence(timeout: 2))
        app.assertTableRow("Date", "2025-04-27")
        app.assertTableRow("Risk", "3")
        app.assertTableRow("Answers", "2;3;0;1;1;0;2;3;1")
    }
    
    
    @MainActor
    func testSleepSession() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app, resetEverything: true, deleteAllHealthData: true)
        
        sleep(for: .seconds(0.5)) // we need to wait a little so that the permissions sheet is properly dismissed
        app.buttons["Sleep Sessions"].tap()
        
        sleep(for: .seconds(2)) // give it a bit to fetch and process the data
        
        if app.staticTexts["No Sleep Data"].waitForExistence(timeout: 1) {
            app.navigationBars.buttons["Add Samples"].tap()
        }
        XCTAssert(app.staticTexts["Tracked Time"].waitForExistence(timeout: 2))
        
        XCTAssert(app.staticTexts["Tracked Time, 7:35:30"].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["Time Awake, 0:19:00"].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["Time Asleep, 7:16:30"].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["#Samples, 31"].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["Time: Core Sleep, 4:42:30"].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["Time: Deep Sleep, 1:02:00"].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["Time: REM Sleep, 1:32:00"].waitForExistence(timeout: 1))
    }
    
    
    @MainActor
    func testSleepSession2() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app, resetEverything: true, deleteAllHealthData: true)
        sleep(for: .seconds(0.5)) // we need to wait a little so that the permissions sheet is properly dismissed
        app.buttons["Sleep Tests"].tap()
        XCTAssert(app.staticTexts["Success"].waitForExistence(timeout: 5))
    }
    
    
    @MainActor
    func testDeferredAuthorization() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly", "--disable-blood-type-auth-request"])
        try launchAndHandleInitialStuff(app, resetEverything: true, deleteAllHealthData: true)
        addSample(.distanceCycling, in: app)
        try launchHealthAppAndEnterCharacteristics(.init(
            bloodType: .oPositive
        ))
        
//        app.delete(app: "TestApp")
        try launchAndHandleInitialStuff(app, resetEverything: true, askForAuthorization: false, deleteAllHealthData: false)
        
        XCTAssert(app.buttons["Deferred Authorization"].waitForExistence(timeout: 2))
        app.buttons["Deferred Authorization"].tap()
        
        app.assertTableRow("Blood Type", "n/a")
        app.assertTableRow("#cyclingSamples", "0")
        app.assertTableRow("#km cycled", "0")
        
        app.buttons["Request Blood Type"].tap()
        app.handleHealthKitAuthorization()
        app.assertTableRow("Blood Type", "O+")
        
        app.buttons["Request Cycling Distance"].tap()
        app.handleHealthKitAuthorization()
        app.assertTableRow("#cyclingSamples", "1")
        app.assertTableRow("#km cycled", "52")
    }
    
    
    // named like this bc XCTest runs its tests in alphabetical order and we need this to be the last one
    // (it'll manually add samples via the Health app, which we can't easily remove, and we don't want these
    // to mess up the other tests, which operate under the assumption that there exist no such samples).
    @MainActor
    func testXXXXXSourceFiltering() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app, resetEverything: true, deleteAllHealthData: true)
        app.terminate()
        
        let healthApp = XCUIApplication.healthApp
        healthApp.launch()
        if healthApp.staticTexts["Health Details"].waitForExistence(timeout: 2) {
            for label in ["close", "Close"] {
                let button = healthApp.navigationBars.buttons[label]
                if button.exists {
                    button.tap()
                    break
                }
            }
        }
        
        try launchAndAddSamples(healthApp: .healthApp, [
            .steps()
        ])
        
        try launchAndHandleInitialStuff(app, resetEverything: true, deleteAllHealthData: false)
        sleep(for: .seconds(0.5)) // we need to wait a little so that the permissions sheet is properly dismissed
        
        app.buttons["Source Filtering"].tap()
        sleep(for: .seconds(2))
        XCTAssert(app.staticTexts["Sample Counts Add Up, true"].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["# All Samples, 1"].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["# Our Samples"].waitForNonExistence(timeout: 1))
        XCTAssert(app.staticTexts["# Health.app Samples, 1"].waitForExistence(timeout: 1))
        
        app.navigationBars.buttons["HealthKit"].tap()
        addSample(.stepCount, in: app)
        
        app.buttons["Source Filtering"].tap()
        sleep(for: .seconds(2))
        XCTAssert(app.staticTexts["Sample Counts Add Up, true"].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["# All Samples, 2"].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["# Our Samples, 1"].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["# Health.app Samples, 1"].waitForExistence(timeout: 1))
    }
}
