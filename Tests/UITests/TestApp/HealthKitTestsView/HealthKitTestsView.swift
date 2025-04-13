//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import SpeziHealthKitUI
import SpeziViews
import SwiftUI


struct HealthKitTestsView: View {
    @Environment(HealthKit.self) var healthKit
    @Environment(FakeHealthStore.self) var fakeHealthStore
    
    @State private var allInitialSampleTypesAreAuthorized = false
    @State private var viewState: ViewState = .idle
    
    @HealthKitQuery(.bloodOxygen, timeRange: .today)
    private var bloodOxygenSamples
    
    var body: some View {
        Form { // swiftlint:disable:this closure_body_length
            Section {
                AsyncButton("Ask for authorization", state: $viewState) {
                    try? await healthKit.askForAuthorization()
                    await checkInitialSamplesAuthStatus()
                }
                .disabled(allInitialSampleTypesAreAuthorized)
                AsyncButton("Trigger data source collection", state: $viewState) {
                    let start = ContinuousClock.now
                    await healthKit.triggerDataSourceCollection()
                    try await Task.sleep(until: start + .seconds(2)) // pretend that the data source triggering takes at least 2 seconds.
                }
                AsyncButton("Register additional CollectSample instances") {
                    // we have matching ones for these in the AppDelegate, and we now add the resp reverse, to check the subsumption.
                    await healthKit.addHealthDataCollector(CollectSample(.stairAscentSpeed, continueInBackground: false))
                    await healthKit.addHealthDataCollector(CollectSample(.stairDescentSpeed, continueInBackground: true))
                }
                LabeledContent("isFullyAuthorized", value: "\(healthKit.isFullyAuthorized)")
            }
            Section {
                NavigationLink("Bulk Exporter") {
                    BulkExportView()
                }
            }
            Section {
                NavigationLink("Samples Query") {
                    SamplesQueryView()
                }
                NavigationLink("Statistics Query") {
                    StatisticsQueryView()
                }
                NavigationLink("Characteristics") {
                    CharacteristicsView()
                }
            }
            Section("Collected Samples Since App Launch") {
                ForEach(fakeHealthStore.samples, id: \.self) { element in
                    Text(element.sampleType.identifier)
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
        .task {
            await checkInitialSamplesAuthStatus()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                addTestDataToolbarItem
            }
        }
    }
    
    
    private var addTestDataToolbarItem: some View {
        let testData: [TestDataDefinition] = [
            .init(sampleType: .heartRate, samples: [
                .init(date: .now, value: 87, unit: .count() / .minute())
            ]),
            .init(sampleType: .activeEnergyBurned, samples: [
                .init(date: .now, value: 71.2, unit: .largeCalorie())
            ]),
            .init(sampleType: .stepCount, samples: [
                .init(date: .now, value: 152, unit: .count())
            ]),
            .init(sampleType: .height, samples: [
                .init(date: .now, value: 187, unit: .meterUnit(with: .centi))
            ])
        ]
        return Menu {
            AsyncButton("Delete Test Data from HealthKit", role: .destructive, state: $viewState) {
                try await deleteTestData()
            }
            Divider()
            ForEach(testData, id: \.self) { entry in
                AsyncButton("Add Sample: \(entry.sampleType.displayTitle)", state: $viewState) {
                    try await addTestData([entry])
                }
            }
        } label: {
            Image(systemName: "plus")
                .accessibilityLabel("Add")
        }
        .accessibilityIdentifier("Add")
    }
    
    
    @MainActor
    private func checkInitialSamplesAuthStatus() async {
        let reqs = healthKit._initialConfigDataAccessRequirements
        let readFullyAuthd = await reqs.read.allSatisfy { @MainActor type in
            await healthKit.didAskForAuthorization(toRead: type)
        }
        let writeFullyAuthd = reqs.write.allSatisfy { type in
            healthKit.didAskForAuthorization(toWrite: type)
        }
        allInitialSampleTypesAreAuthorized = readFullyAuthd && writeFullyAuthd
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
    
    
    // MARK: Test Data Handling
    
    private func addTestData(_ definitions: [TestDataDefinition]) async throws {
        let samples: [HKQuantitySample] = definitions.flatMap { definition in
            definition.samples.map { sampleInput in
                let date = sampleInput.date
                return HKQuantitySample(
                    type: definition.sampleType.hkSampleType,
                    quantity: HKQuantity(unit: sampleInput.unit, doubleValue: sampleInput.value),
                    start: date,
                    end: date.addingTimeInterval(sampleInput.duration)
                )
            }
        }
        try await healthKit.askForAuthorization(for: .init(write: samples.mapIntoSet(\.sampleType)))
        for sample in samples {
            // NOTE: for some reason, this works but calling the overload that takes an array doesn't...
            try await healthKit.healthStore.save(sample)
        }
    }
    
    
    private func deleteTestData() async throws {
        for sampleType in HKSampleType.allKnownObjectTypes.compactMap({ $0 as? HKSampleType }) {
            let descriptor = HKSampleQueryDescriptor(
                predicates: [
                    HKSamplePredicate<HKSample>.sample(
                        type: sampleType,
                        predicate: HKQuery.predicateForObjects(from: HKSource.default())
                    )
                ],
                sortDescriptors: []
            )
            do {
                let samples = (try? await descriptor.result(for: healthKit.healthStore)) ?? []
                try await healthKit.healthStore.delete(samples)
            } catch {
                throw error
            }
        }
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
