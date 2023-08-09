//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Combine
import HealthKit
import SpeziHealthKit
import SwiftUI
import XCTSpezi


struct HealthKitTestsView: View {
    @EnvironmentObject var healthKitComponent: HealthKit
    @EnvironmentObject var standard: ExampleStandard
    
    
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
    
    
    private func askForAuthorization() {
        Task {
            try await healthKitComponent.askForAuthorization()
        }
    }
    
    private func triggerDataSourceCollection() {
        Task {
            await healthKitComponent.triggerDataSourceCollection()
        }
    }
}
