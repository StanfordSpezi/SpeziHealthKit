//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest


final class BulkExporterTests: SpeziHealthKitTests {
    @MainActor
    func testBulkExport() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app, deleteAllHealthData: true)
        sleep(for: .seconds(1))
        app.buttons["Bulk Exporter"].tap()
        
        app.buttons["Request full access"].tap()
        try app.handleHealthKitAuthorization()
        
        app.buttons["Add Historical Data"].tap()
        XCTAssert(app.staticTexts["Adding Historical Samples…"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Adding Historical Samples…"].waitForNonExistence(timeout: 120))
        sleep(for: .seconds(1))
        
        XCTAssertEqual(try XCTUnwrap(app.numExportedSamples), 0)
        XCTAssertGreaterThan(try XCTUnwrap(app.numTestingSamples), 0)
        
        app.buttons["Start Bulk Export"].tap()
        XCTAssert(app.staticTexts["Completed 8 of 53 (0 failed)"].waitForExistence(timeout: 60))
        app.buttons["Pause"].tap()
        sleep(for: .seconds(2))
        app.buttons["Start"].tap()
        XCTAssert(app.staticTexts["State, completed"].waitForExistence(timeout: 180))
        XCTAssertEqual(try XCTUnwrap(app.numExportedSamples), try XCTUnwrap(app.numTestingSamples))
    }
    
    
    @MainActor
    func testBulkExportReset() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app, deleteAllHealthData: true)
        sleep(for: .seconds(1))
        
        app.buttons["Bulk Exporter"].tap()
        
        app.buttons["Request full access"].tap()
        try app.handleHealthKitAuthorization()
        
        app.buttons["Add Historical Data"].tap()
        XCTAssert(app.staticTexts["Adding Historical Samples…"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Adding Historical Samples…"].waitForNonExistence(timeout: 120))
        sleep(for: .seconds(1))
        
        XCTAssertEqual(try XCTUnwrap(app.numExportedSamples), 0)
        XCTAssertGreaterThan(try XCTUnwrap(app.numTestingSamples), 0)
        
        app.buttons["Start Bulk Export"].tap()
        sleep(for: .seconds(7))
        app.buttons["Pause"].tap()
        sleep(for: .seconds(1))
        let numExportedSamplesFirstSession = try XCTUnwrap(app.numExportedSamples)
        app.terminate()
        
        try launchAndHandleInitialStuff(app, deleteAllHealthData: false)
        app.buttons["Bulk Exporter"].tap()
        XCTAssertEqual(try XCTUnwrap(app.numExportedSamples), 0)
        XCTAssertGreaterThan(try XCTUnwrap(app.numTestingSamples), 0)
        
        app.buttons["Start Bulk Export"].tap()
        XCTAssert(app.staticTexts["State, completed"].waitForExistence(timeout: 180))
        XCTAssertEqual(try XCTUnwrap(app.numExportedSamples) + numExportedSamplesFirstSession, try XCTUnwrap(app.numTestingSamples))
    }
    
    
    @MainActor
    func testDeleteSessionRestorationInfo() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app, deleteAllHealthData: true)
        sleep(for: .seconds(1))
        
        app.buttons["Bulk Exporter"].tap()
        
        app.buttons["Request full access"].tap()
        try app.handleHealthKitAuthorization()
        
        app.buttons["Add Historical Data"].tap()
        XCTAssert(app.staticTexts["Adding Historical Samples…"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Adding Historical Samples…"].waitForNonExistence(timeout: 120))
        sleep(for: .seconds(1))
        
        XCTAssertEqual(try XCTUnwrap(app.numExportedSamples), 0)
        XCTAssertGreaterThan(try XCTUnwrap(app.numTestingSamples), 0)
        
        app.buttons["Start Bulk Export"].tap()
        sleep(for: .seconds(7))
        app.buttons["Pause"].tap()
        sleep(for: .seconds(1))
        app.terminate()
        
        try launchAndHandleInitialStuff(app, deleteAllHealthData: false)
        app.buttons["Bulk Exporter"].tap()
        XCTAssertEqual(try XCTUnwrap(app.numExportedSamples), 0)
        XCTAssertGreaterThan(try XCTUnwrap(app.numTestingSamples), 0)
        
        app.buttons["Reset ExportSession"].tap()
        
        app.buttons["Start Bulk Export"].tap()
        XCTAssert(app.staticTexts["State, completed"].waitForExistence(timeout: 60))
        XCTAssertEqual(try XCTUnwrap(app.numExportedSamples), try XCTUnwrap(app.numTestingSamples))
    }
}


extension XCUIApplication {
    var numExportedSamples: Int? {
        let value = self.staticTexts.matching(NSPredicate(format: "label MATCHES '# Exported Samples, .*'")).firstMatch.value
        return (value as? String).flatMap(Int.init)
    }
    
    var numTestingSamples: Int? {
        let value = self.staticTexts.matching(NSPredicate(format: "label MATCHES '# Expected Samples, .*'")).firstMatch.value
        return (value as? String).flatMap(Int.init)
    }
}
