//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi
import SpeziFoundation
import SwiftUI


@main
struct UITestsApp: App {
    @UIApplicationDelegateAdaptor(TestAppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HealthKitTestsView()
                    .navigationTitle("HealthKit")
            }
            .spezi(appDelegate)
        }
    }
    
    init() {
        let cliArgs = CommandLine.arguments
        if cliArgs.contains("--resetEverything") {
            do {
                FakeHealthStore.reset()
                try FileManager.default.removeItem(at: .documentsDirectory)
                try FileManager.default.createDirectory(at: .documentsDirectory, withIntermediateDirectories: true)
            } catch {
                fatalError("\(error)")
            }
        }
    }
}
