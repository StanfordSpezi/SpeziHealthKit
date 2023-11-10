//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import SwiftUI


struct HealthKitTestsView: View {
    @Environment(HealthKit.self) var healthKitComponent
    @Environment(ExampleStandard.self) var standard

    
    var body: some View {
        Button("Ask for authorization") {
            askForAuthorization()
        }
            .disabled(healthKitComponent.authorized)
        Button("Trigger data source collection") {
            triggerDataSourceCollection()
        }
        HStack {
            List(standard.addedResponses, id: \.self) { element in
                Text(element.sampleType.identifier)
            }
        }
    }
    
    @MainActor
    private func askForAuthorization() {
        Task {
            try await healthKitComponent.askForAuthorization()
        }
    }
    
    @MainActor
    private func triggerDataSourceCollection() {
        Task {
            await healthKitComponent.triggerDataSourceCollection()
        }
    }
}
