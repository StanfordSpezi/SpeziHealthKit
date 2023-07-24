//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI

// TODO: Change back bundle ID to edu.stanford.HPDS.healthkit.testapp when done

@main
struct UITestsApp: App {
    @UIApplicationDelegateAdaptor(TestAppDelegate.self) var appDelegate
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HealthKitTestsView()
                    .navigationTitle("HealthKit")
                    .spezi(appDelegate)
            }
        }
    }
}
