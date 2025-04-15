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


final class BulkExporterTests: XCTestCase {
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
    func testBulkExport() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app)
        sleep(1)
        app.buttons["Bulk Exporter"].tap()
        
        app.buttons["Request full access"].tap()
        try app.handleHealthKitAuthorization()
        
        app.buttons["Add Historical Data"].tap()
        XCTAssert(app.staticTexts["Adding Historical Samples…"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Adding Historical Samples…"].waitForNonExistence(timeout: 60))
        
        var numExportedSamples: Int? {
            let value = app.staticTexts.matching(NSPredicate(format: "label MATCHES '# Exported Samples, .*'")).firstMatch.value
            return (value as? String).flatMap(Int.init)
        }
        var numTestingSamples: Int? {
            let value = app.staticTexts.matching(NSPredicate(format: "label MATCHES '# Expected Samples, .*'")).firstMatch.value
            return (value as? String).flatMap(Int.init)
        }
        
        XCTAssertEqual(try XCTUnwrap(numExportedSamples), 0)
        XCTAssertGreaterThan(try XCTUnwrap(numTestingSamples), 0)
        
        app.buttons["Start Bulk Export"].tap()
        XCTAssert(app.staticTexts["State, done"].waitForExistence(timeout: 15))
        
        XCTAssertEqual(try XCTUnwrap(numExportedSamples), try XCTUnwrap(numTestingSamples))
    }
}
