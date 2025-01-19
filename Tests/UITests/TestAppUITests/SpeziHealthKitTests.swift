//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions
import XCTHealthKit


final class HealthKitTests: XCTestCase {
    @MainActor
    func testTest() throws {
        throw XCTSkip()
        let app = XCUIApplication()
        app.launch()
//        XCTAssert(app.textViews["DatePicker Testing Section".uppercased()].waitForExistence(timeout: 5))
//        let datePickers = app.datePickers.allElementsBoundByIndex
//        XCTAssertEqual(datePickers.count, 3)
//        datePickers[1].enterDate(DateComponents(year: 2024, month: 6, day: 2), assumingDatePickerStyle: .compact, in: app)
//        datePickers[2].enterTime(DateComponents(hour: 20, minute: 15), assumingDatePickerStyle: .compact, in: app)
        
        try launchHealthAppAndAddSomeSamples([
//            .init(sampleType: .steps, date: nil, enterSampleValueHandler: .enterSimpleNumericValue(520, inTextField: "Steps")),
            .init(sampleType: .steps, date: .init(year: 1998, month: 06, day: 02, hour: 20, minute: 15), enterSampleValueHandler: .enterSimpleNumericValue(1, inTextField: "Steps")),
        ])
        
        app.activate()
    }
    
    
    @MainActor
    func testHealthKit() throws { // swiftlint:disable:this function_body_length
//        throw XCTSkip()
        let app = XCUIApplication()
        app.launchArguments = ["--collectedSamplesOnly"]
        app.deleteAndLaunch(withSpringboardAppName: "TestApp")
        
//        try launchHealthAppAndAddSomeSamples([
//            .init(sampleType: .steps, date: nil, enterSampleValueHandler: .enterSimpleNumericValue(520, inTextField: "Steps"))
//        ])
        
        try exitAppAndOpenHealth(.electrocardiograms)
        try exitAppAndOpenHealth(.steps)
        try exitAppAndOpenHealth(.pushes)
        try exitAppAndOpenHealth(.restingHeartRate)
        try exitAppAndOpenHealth(.activeEnergy)
        
        app.activate()
        XCTAssert(app.buttons["Ask for authorization"].waitForExistence(timeout: 2))
        app.buttons["Ask for authorization"].tap()
        try app.handleHealthKitAuthorization()
        app.hkTypeIdentifierAssert(
            [
                .activeEnergy: 1,
                .steps: 1
            ]
        )
        
        XCTAssert(app.buttons["Trigger data source collection"].waitForExistence(timeout: 2))
        app.buttons["Trigger data source collection"].tap()
        app.hkTypeIdentifierAssert(
            [
                .activeEnergy: 1,
                .restingHeartRate: 1,
                .electrocardiograms: 1,
                .steps: 1,
                .pushes: 1
            ]
        )
        
//        try exitAppAndOpenHealth(.electrocardiograms)
        app.activate()
        app.hkTypeIdentifierAssert(
            [
                .activeEnergy: 1,
                .restingHeartRate: 1,
                .electrocardiograms: 2,
                .steps: 1,
                .pushes: 1
            ]
        )
        
//        try exitAppAndOpenHealth(.steps)
        app.activate()
        app.hkTypeIdentifierAssert(
            [
                .activeEnergy: 1,
                .restingHeartRate: 1,
                .electrocardiograms: 2,
                .steps: 2,
                .pushes: 1
            ]
        )
        
//        try exitAppAndOpenHealth(.pushes)
        app.activate()
        app.hkTypeIdentifierAssert(
            [
                .activeEnergy: 1,
                .restingHeartRate: 1,
                .electrocardiograms: 2,
                .steps: 2,
                .pushes: 2
            ]
        )
        
//        try exitAppAndOpenHealth(.restingHeartRate)
        app.activate()
        app.hkTypeIdentifierAssert(
            [
                .activeEnergy: 1,
                .restingHeartRate: 1,
                .electrocardiograms: 2,
                .steps: 2,
                .pushes: 2
            ]
        )
        
//        try exitAppAndOpenHealth(.activeEnergy)
        app.activate()
        app.hkTypeIdentifierAssert(
            [
                .activeEnergy: 2,
                .restingHeartRate: 1,
                .electrocardiograms: 2,
                .steps: 2,
                .pushes: 2
            ]
        )
        
        XCTAssert(app.buttons["Trigger data source collection"].waitForExistence(timeout: 2))
        app.buttons["Trigger data source collection"].tap()
        app.hkTypeIdentifierAssert(
            [
                .activeEnergy: 2,
                .restingHeartRate: 2,
                .electrocardiograms: 2,
                .steps: 2,
                .pushes: 2
            ]
        )
        
        // Relaunch App to test delivery after the app has been terminated.
        app.terminate()
        app.activate()
        XCTAssert(app.wait(for: .runningForeground, timeout: 10.0))
        XCTAssert(app.buttons["Trigger data source collection"].waitForExistence(timeout: 2))
        app.buttons["Trigger data source collection"].tap()
        app.hkTypeIdentifierAssert([:])
        
//        try exitAppAndOpenHealth(.electrocardiograms)
//        try exitAppAndOpenHealth(.steps)
//        try exitAppAndOpenHealth(.pushes)
//        try exitAppAndOpenHealth(.restingHeartRate)
//        try exitAppAndOpenHealth(.activeEnergy)
        app.activate()
        app.hkTypeIdentifierAssert(
            [
                .activeEnergy: 1,
                .electrocardiograms: 1,
                .steps: 1,
                .pushes: 1
            ]
        )
        
        XCTAssert(app.buttons["Trigger data source collection"].waitForExistence(timeout: 2))
        app.buttons["Trigger data source collection"].tap()
        app.hkTypeIdentifierAssert(
            [
                .activeEnergy: 1,
                .restingHeartRate: 1,
                .electrocardiograms: 1,
                .steps: 1,
                .pushes: 1
            ]
        )
    }
    
    func testRepeatedHealthKitAuthorization() throws {
        throw XCTSkip()
        let app = XCUIApplication()
        app.deleteAndLaunch(withSpringboardAppName: "TestApp")
        
        app.activate()
        XCTAssert(app.buttons["Ask for authorization"].waitForExistence(timeout: 2))
        XCTAssert(app.buttons["Ask for authorization"].isEnabled)
        app.buttons["Ask for authorization"].tap()
        
        try app.handleHealthKitAuthorization()
        
        // Wait for button to become disabled
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in
                !app.buttons["Ask for authorization"].isEnabled
            },
            object: .none
        )
        wait(for: [expectation], timeout: 2)
        
        XCTAssert(!app.buttons["Ask for authorization"].isEnabled)
    }
}


extension XCUIApplication {
    fileprivate func hkTypeIdentifierAssert(_ hkTypeIdentifiers: [HealthAppSampleType: Int]) {
        XCTAssert(wait(for: .runningForeground, timeout: 10.0))
        sleep(5)
//        
//        guard numberOfHKTypeIdentifiers() != hkTypeIdentifiers else {
//            return
//        }
//        
//        print("Wait 5 more seconds for HealthAppDataType to appear on screen ...")
//        sleep(5)
//        
//        guard numberOfHKTypeIdentifiers() != hkTypeIdentifiers else {
//            return
//        }
//        
//        print("Wait 10 more seconds for HealthAppDataType to appear on screen ...")
//        sleep(10)
        
        XCTAssertEqual(
            numberOfHKTypeIdentifiers(),
            hkTypeIdentifiers
        )
    }
    
    private func numberOfHKTypeIdentifiers() -> [HealthAppSampleType: Int] {
        print("ALL STATIC TEXTS: \(self.debugDescription)")
        var observations: [HealthAppSampleType: Int] = [:]
        for sampleType in HealthAppSampleType.all {
            let numberOfHKTypeNames = staticTexts
                .allElementsBoundByIndex
                .filter {
                    $0.label.contains(sampleType.sampleType.identifier)
                }
                .count
            if numberOfHKTypeNames > 0 {
                observations[sampleType] = numberOfHKTypeNames
            }
        }
        fatalError()
        return observations
    }
}
