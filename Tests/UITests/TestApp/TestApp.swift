//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


@main
struct UITestsApp: App {
    @UIApplicationDelegateAdaptor(TestAppDelegate.self) var appDelegate
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HealthKitTestsView()
                    .navigationTitle("HealthKit")
                    .spezi(appDelegate)
                    .task {
                        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                    }
            }
        }
    }
}
