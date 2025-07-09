//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@_spi(Testing)
import SpeziHealthKit
import SpeziHealthKitUI
import SpeziViews
import SwiftUI


struct HealthKitTestsView: View {
    @Environment(HealthKit.self) var healthKit
    @Environment(FakeHealthStore.self) var fakeHealthStore
    
    @State private var allInitialSampleTypesAreAuthorized = false
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        Form { // swiftlint:disable:this closure_body_length
            Section {
                AsyncButton("Ask for authorization", state: $viewState) {
                    try? await healthKit.askForAuthorization()
                    await checkInitialSamplesAuthStatus()
                }
                .disabled(allInitialSampleTypesAreAuthorized)
                LabeledContent("isFullyAuthorized", value: "\(healthKit.isFullyAuthorized)")
                NavigationLink("Sleep Tests") {
                    SleepSessionTestsView()
                }
            }
            Section {
                NavigationLink("Collect Samples") {
                    CollectSamplesTestView()
                }
                NavigationLink("Samples Query") {
                    SamplesQueryView()
                }
                NavigationLink("Statistics Query") {
                    StatisticsQueryView()
                }
                NavigationLink("Characteristics") {
                    CharacteristicsView()
                }
                NavigationLink("Sleep Sessions") {
                    SleepSessionsView()
                }
                NavigationLink("Scored Assessments") {
                    ScoredAssessmentsView()
                }
                NavigationLink("Bulk Exporter") {
                    BulkExportView()
                }
                NavigationLink("Source Filtering") {
                    SourceFilteredQueryView()
                }
            }
        }
        .viewStateAlert(state: $viewState)
        .task {
            await checkInitialSamplesAuthStatus()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ActionsMenu(viewState: $viewState)
            }
        }
    }
    
    
    @MainActor
    private func checkInitialSamplesAuthStatus() async {
        let reqs = healthKit.initialConfigDataAccessRequirements
        let readFullyAuthd = await reqs.read.allSatisfy { @MainActor type in
            await healthKit.didAskForAuthorization(toRead: type)
        }
        let writeFullyAuthd = reqs.write.allSatisfy { type in
            healthKit.didAskForAuthorization(toWrite: type)
        }
        allInitialSampleTypesAreAuthorized = readFullyAuthd && writeFullyAuthd
    }
}


extension BackgroundDataCollectionLogEntry {
    var displayTitle: String {
        switch self {
        case .added: "Add"
        case .removed: "Delete"
        }
    }
}
