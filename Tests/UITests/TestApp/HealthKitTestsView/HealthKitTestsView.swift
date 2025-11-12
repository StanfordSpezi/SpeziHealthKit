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
    enum TestView: String, CaseIterable {
        case collectSamples = "Collect Samples"
        case collectStatisticsQuery = "Collect Statistics Query"
        case samplesQuery = "Samples Query"
        case statisticsQuery = "Statistics Query"
        case characteristicsQuery = "Characteristics Query"
        case sleepSessions = "Sleep Sessions"
        case scoredAssessments = "Scored Assessments"
        case bulkExporter = "Bulk Exporter"
        case sourceFiltering = "Source Filtering"
        case deferredAuthorization = "Deferred Authorization"
        case localizedSampleTypeNames = "Localized Sample Type Names"
    }
    
    @Environment(HealthKit.self) var healthKit
    @Environment(FakeHealthStore.self) var fakeHealthStore
    
    @State private var allInitialSampleTypesAreAuthorized = false
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        Form {
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
                ForEach(TestView.allCases, id: \.self) { testView in
                    NavigationLink(testView.rawValue, value: testView)
                }
            }
        }
        .navigationDestination(for: TestView.self) { testView in
            switch testView {
            case .collectSamples:
                CollectSamplesTestView()
            case .collectStatisticsQuery:
                CollectStatisticsQueryView()
            case .samplesQuery:
                SamplesQueryView()
            case .statisticsQuery:
                StatisticsQueryView()
            case .characteristicsQuery:
                CharacteristicsView()
            case .sleepSessions:
                SleepSessionsView()
            case .scoredAssessments:
                ScoredAssessmentsView()
            case .bulkExporter:
                BulkExportView()
            case .sourceFiltering:
                SourceFilteredQueryView()
            case .deferredAuthorization:
                DeferredAuthorizationTests(viewState: $viewState)
            case .localizedSampleTypeNames:
                LocalizedSampleTypeNames()
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
