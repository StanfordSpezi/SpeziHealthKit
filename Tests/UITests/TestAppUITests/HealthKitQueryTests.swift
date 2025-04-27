//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest


final class HealthKitQueryTests: SpeziHealthKitTests {
    @MainActor
    func testHealthKitQuery() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app)
        
        for _ in 0..<7 {
            try addSample(.stepCount, in: app)
        }
        
        XCTAssert(app.buttons["Samples Query"].wait(for: \.isHittable, toEqual: true, timeout: 2))
        app.buttons["Samples Query"].tap()
        
        XCTAssert(app.staticTexts.element(matching: NSPredicate(format: "label MATCHES %@", "Step Count *152")).waitForExistence(timeout: 3))
    }
    
    
    @MainActor
    func testHealthKitStatisticsQuery() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app)
        
        for _ in 0..<7 {
            try addSample(.stepCount, in: app)
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
    func testCharacteristicsQuery() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app)
        
        try launchHealthAppAndEnterCharacteristics(.init(
            bloodType: .aNegative,
            dateOfBirth: .init(year: 2022, month: 10, day: 11),
            biologicalSex: .female,
            skinType: .I,
            wheelchairUse: .no
        ))
        
        app.activate()
        XCTAssert(app.buttons["Characteristics"].waitForExistence(timeout: 2))
        app.buttons["Characteristics"].tap()
        
        app.assertTableRow("Move Mode", "1")
        app.assertTableRow("Blood Type", "2")
        app.assertTableRow("Date of Birth", "2022-10-11T[0-9]{2}:00:00Z")
        app.assertTableRow("Biological Sex", "1")
        app.assertTableRow("Skin Type", "1")
        app.assertTableRow("Wheelchair Use", "1")
    }
    
    
    @MainActor
    func testScoredAssessments() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app)
        
        usleep(500_000) // we need to wait a little so that the permissions sheet is properly dismissed
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
            usleep(500_000) // i sleep
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
}
