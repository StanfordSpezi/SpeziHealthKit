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
    
//    @State var dataChanges: [HKSample] = []
//    @State var cancellable: AnyCancellable?
    
    
    var body: some View {
        Button("Ask for authorization") {
            askForAuthorization()
        }
        .disabled(healthKitComponent.authorized)
        
        Button("Trigger data source collection") {
            triggerDataSourceCollection()
        }
        HStack {
//            List(dataChanges, id: \.self) { element in
            
            List(standard.addedResponses, id: \.self) { element in
                Text(element.sampleType.identifier)
            }
        }
//            .task {
//                self.dataChanges = await standard.addedResponses //.map { $0.id }
//                cancellable = standard.objectWillChange.sink {
//                    Task { @MainActor in
//                        self.dataChanges = await standard.addedResponses //.map { $0.id }
//                    }
//                }
//            }
//            .onDisappear {
//                cancellable?.cancel()
//            }
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
