//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziHealthKit
import XCTest
import XCTestExtensions
import XCTHealthKit


class SpeziHealthKitTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
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
    func launchAndHandleInitialStuff(_ app: XCUIApplication) throws {
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
    func addSample(_ sampleType: SampleType<HKQuantitySample>, in app: XCUIApplication) throws {
        let menuButton = app.navigationBars.images["plus"]
        XCTAssert(menuButton.waitForExistence(timeout: 1))
        menuButton.tap()
        let addSampleButton = app.buttons["Add Sample: \(sampleType.displayTitle)"]
        XCTAssert(addSampleButton.waitForExistence(timeout: 2))
        addSampleButton.tap()
        usleep(500_000) // i sleep
    }
    
    
    @MainActor
    func triggerDataCollection(in app: XCUIApplication) {
        XCTAssertTrue(app.buttons["Trigger data source collection"].exists)
        app.buttons["Trigger data source collection"].tap()
        XCTAssertTrue(app.buttons["Triggering data source collection"].waitForNonExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Trigger data source collection"].waitForExistence(timeout: 2))
    }
}


extension SpeziHealthKitTests {
    typealias NumSamplesByType = [SampleType<HKQuantitySample>: Int]
    
    @MainActor
    func assertCollectedSamplesSinceLaunch(
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
    
    func assertTableRow(_ title: String, _ pattern: String, file: StaticString = #filePath, line: UInt = #line) {
        let predicate = NSPredicate(format: "label MATCHES %@", "\(title).*\(pattern)")
        XCTAssert(
            self.staticTexts.matching(predicate).element.waitForExistence(timeout: 2),
            "Unable to find element '\(predicate)'",
            file: file,
            line: line
        )
    }
}
