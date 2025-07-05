//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import SpeziHealthKitUI
import SpeziViews
import SwiftUI


struct SourceFilteredQueryView: View {
    @HealthKitQuery(.stepCount, timeRange: .ever, source: .any)
    private var allSteps
    
    @HealthKitQuery(.stepCount, timeRange: .ever, source: .named("TestApp"))
    private var ourSteps
    
    @HealthKitQuery(.stepCount, timeRange: .ever, source: .named("Health"))
    private var healthAppSteps
    
    @Environment(HealthKit.self) private var healthKit
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        Form {
            Section {
                LabeledContent("Sample Counts Add Up", value: (allSteps.count == ourSteps.count + healthAppSteps.count).description)
            }
            makeSection("All", samples: allSteps)
            makeSection("Our", samples: ourSteps)
            makeSection("Health.app", samples: healthAppSteps)
        }
        .viewStateAlert(state: $viewState)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ActionsMenu(viewState: $viewState)
            }
        }
    }
    
    @ViewBuilder
    private func makeSection(_ title: String, samples: some Collection<HKQuantitySample>) -> some View {
        if !samples.isEmpty {
            Section(title) {
                LabeledContent("# \(title) Samples", value: samples.count, format: .number)
                let sources = samples
                    .mapIntoSet(\.sourceRevision.source)
                    .sorted(using: KeyPathComparator(\.name))
                ForEach(sources, id: \.self) { source in
                    LabeledContent("\(title) Source") {
                        VStack(alignment: .trailing) {
                            Text(source.name)
                                .accessibilityIdentifier("\(title) Source Name: \(source.name)")
                            Text(source.bundleIdentifier)
                                .accessibilityIdentifier("\(title) Source BundleId: \(source.bundleIdentifier)")
                        }
                        .font(.footnote)
                    }
                }
            }
        }
    }
}
