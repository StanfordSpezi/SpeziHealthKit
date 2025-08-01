//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest

final class AuthorizationTests: SpeziHealthKitTests {
    @MainActor
    func testRepeatedHealthKitAuthorization() throws {
        let app = XCUIApplication(launchArguments: ["--collectedSamplesOnly"])
        try launchAndHandleInitialStuff(app, deleteAllHealthData: true)
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
