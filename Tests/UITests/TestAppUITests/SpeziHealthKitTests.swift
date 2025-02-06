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


final class HealthKitTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        MainActor.assumeIsolated {
            // After each test, we want the app to get fully reset.
            let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
            app.terminate()
            app.delete(app: "TestApp")
        }
    }
    
    
    @MainActor
    func testCollectSamples() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app)
        
        // At the beginning, we expect nothing to be collected
        assertCollectedSamplesSinceLaunch(in: app, [:])
        // Add a heart rate sample
        try addSample(.heartRate, in: app)
        // Since the CollectSample start setting for heart rate is .manual, it stil shouldn't be there
        assertCollectedSamplesSinceLaunch(in: app, [:])
        // We manually start the heart rate data collection, which should make the sample show up
        triggerDataCollection(in: app)
        assertCollectedSamplesSinceLaunch(in: app, [
            .heartRate: 1
        ])
        
        // Add an active energy burned sample
        try addSample(.activeEnergyBurned, in: app)
        // Since we have a continuous automatic query for these, it should show up immediately.
        assertCollectedSamplesSinceLaunch(in: app, [
            .heartRate: 1,
            .activeEnergyBurned: 1
        ])
        
        // Add a step count sample
        try addSample(.stepCount, in: app)
        // These are collected via an automatic background query, and should therefore also directly show up
        assertCollectedSamplesSinceLaunch(in: app, [
            .heartRate: 1,
            .activeEnergyBurned: 1,
            .stepCount: 1
        ])
        
        // Add a height sample. These aren't collected at all, and should never show up
        try addSample(.height, in: app)
        assertCollectedSamplesSinceLaunch(in: app, [
            .heartRate: 1,
            .activeEnergyBurned: 1,
            .stepCount: 1
        ])
        
        // Add another active energy burned sample. As before, this should show up immediately
        try addSample(.activeEnergyBurned, in: app)
        assertCollectedSamplesSinceLaunch(in: app, [
            .heartRate: 1,
            .activeEnergyBurned: 2,
            .stepCount: 1
        ])
        
        // i'm gonna do it again
        try addSample(.activeEnergyBurned, in: app)
        assertCollectedSamplesSinceLaunch(in: app, [
            .heartRate: 1,
            .activeEnergyBurned: 3,
            .stepCount: 1
        ])
        
        app.buttons["Register additional CollectSample instances"].tap()
        sleep(1) // give it some time to handle this.
    }
    
    
    @MainActor
    func testRepeatedHealthKitAuthorization() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app)
        
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
        
        func assertTableRow(_ title: String, _ value: String, file: StaticString = #filePath, line: UInt = #line) {
            let predicate = NSPredicate(format: "label MATCHES %@", "\(title).*\(value)")
            XCTAssert(
                app.staticTexts.matching(predicate).element.waitForExistence(timeout: 2),
                "Unable to find element '\(predicate)'",
                file: file,
                line: line
            )
        }
        
        assertTableRow("Move Mode", "1")
        assertTableRow("Blood Type", "2")
        assertTableRow("Date of Birth", "2022-10-11T[0-9]{2}:00:00Z")
        assertTableRow("Biological Sex", "1")
        assertTableRow("Skin Type", "1")
        assertTableRow("Wheelchair Use", "1")
    }
}


extension HealthKitTests {
    @MainActor
    private func launchAndHandleInitialStuff(_ app: XCUIApplication) throws {
        app.launch()
        if app.alerts["“TestApp” Would Like to Send You Notifications"].waitForExistence(timeout: 5) {
            app.alerts["“TestApp” Would Like to Send You Notifications"].buttons["Allow"].tap()
        }
        
        XCTAssert(app.buttons["Ask for authorization"].waitForExistence(timeout: 3))
        if app.buttons["Ask for authorization"].isEnabled {
            app.buttons["Ask for authorization"].tap()
            try app.handleHealthKitAuthorization()
        }
    }
    
    
    @MainActor
    private func addSample(_ sampleType: SampleType<HKQuantitySample>, in app: XCUIApplication) throws {
        app.navigationBars.images["plus"].tap()
        XCTAssert(app.buttons["Add Sample: \(sampleType.displayTitle)"].waitForExistence(timeout: 2))
        app.buttons["Add Sample: \(sampleType.displayTitle)"].tap()
    }
    
    
    @MainActor
    private func triggerDataCollection(in app: XCUIApplication) {
        XCTAssertTrue(app.buttons["Trigger data source collection"].exists)
        app.buttons["Trigger data source collection"].tap()
        XCTAssertTrue(app.buttons["Triggering data source collection"].waitForNonExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Trigger data source collection"].waitForExistence(timeout: 2))
    }
}


extension HealthKitTests {
    typealias NumSamplesByType = [SampleType<HKQuantitySample>: Int]
    
    @MainActor
    private func assertCollectedSamplesSinceLaunch(
        in app: XCUIApplication,
        _ expectedNumSamplesBySampleType: NumSamplesByType,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        func imp(try: Int) {
            // swiftlint:disable:next empty_count
            let staticTexts = app.staticTexts.count > 0
                ? app.staticTexts.allElementsBoundByIndex.compactMap { $0.exists ? $0.label : nil }
                : []
            guard `try` > 0 else {
                XCTFail("Unable to check (staticTexts: \(staticTexts))", file: file, line: line)
                return
            }
            guard staticTexts.count > 0 else { // swiftlint:disable:this empty_count
                sleep(2)
                imp(try: `try` - 1)
                return
            }
            let actual = staticTexts
                .filter { $0.wholeMatch(of: /HK[a-zA-Z]*/) != nil }
                .grouped(by: \.self)
                .mapValues(\.count)
            let expected = Dictionary(uniqueKeysWithValues: expectedNumSamplesBySampleType.map { ($0.hkSampleType.identifier, $1) })
            if expected != actual, `try` > 1 {
                // try again
                sleep(2)
                imp(try: `try` - 1)
                return
            } else {
                XCTAssertEqual(actual, expected, file: file, line: line)
            }
        }
        imp(try: 5)
    }
}


extension XCUIApplication {
    convenience init(launchArguments: [String]) {
        self.init()
        self.launchArguments.append(contentsOf: launchArguments)
    }
}
