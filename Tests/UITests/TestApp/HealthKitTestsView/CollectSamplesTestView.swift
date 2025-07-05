//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziHealthKit
import SpeziHealthKitUI
import SpeziViews
import SwiftUI


struct CollectSamplesTestView: View {
    @Environment(HealthKit.self) var healthKit
    @Environment(FakeHealthStore.self) var fakeHealthStore
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        Form {
            Section("Collected Samples Since App Launch") {
                let samplesBySampleType = fakeHealthStore.samples.grouped(by: \.sampleType.identifier)
                ForEach(samplesBySampleType.sorted(using: KeyPathComparator(\.key)), id: \.key) { (entry: (String, [HKSample])) in
                    let (sampleTypeIdentifier, samples) = entry
                    HStack {
                        Text(sampleTypeIdentifier)
                            .accessibilityLabel("")
                        Spacer()
                        Text(String(samples.count))
                            .accessibilityLabel("")
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(sampleTypeIdentifier), \(samples.count)" as String)
                }
            }.accessibilityIdentifier("CollectedSamples")
            if !FakeHealthStore.collectedSamplesOnly {
                Section("Background Persistance Log") {
                    ForEach(fakeHealthStore.backgroundPersistance) { logEntry in
                        makeRow(for: logEntry)
                    }
                }
            }
        }
        .viewStateAlert(state: $viewState)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ActionsMenu(viewState: $viewState)
            }
        }
    }
    
    
    @ViewBuilder
    private func makeRow(for logEntry: BackgroundDataCollectionLogEntry) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(logEntry.displayTitle.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(logEntry.id.uuidString).font(.caption2.monospaced())
            }
            switch logEntry {
            case let .added(id: _, type, date, quantity):
                Text(type)
                    .font(.caption.monospaced())
                HStack {
                    if date.lowerBound == date.upperBound {
                        Text(date.lowerBound.formatted(date: .abbreviated, time: .shortened))
                    } else {
                        let start = date.lowerBound.formatted(date: .abbreviated, time: .shortened)
                        let endUsesOnlyTime = date.upperBound.timeIntervalSince(date.lowerBound) < 60 * 60 * 24
                        let end = date.upperBound.formatted(date: endUsesOnlyTime ? .omitted : .abbreviated, time: .shortened)
                        Text("\(start) – \(end)")
                    }
                    if let quantity {
                        Spacer()
                        Text(quantity)
                    }
                }
            case .removed:
                EmptyView()
            }
        }
    }
}
