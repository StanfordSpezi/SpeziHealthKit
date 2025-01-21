//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import SpeziViews
import SwiftUI


struct HealthKitTestsView: View {
    @Environment(HealthKit.self) var healthKit
    @Environment(HealthKitStore.self) var healthKitStore
    
    @State private var allInitialSampleTypesAreAuthorized = false
    @State private var viewState: ViewState = .idle
    
    @HealthKitQuery(.bloodOxygen, timeRange: .today)
    private var bloodOxygenSamples
    
    var body: some View {
        Form {
            Section {
                AsyncButton("Ask for authorization", state: $viewState) {
                    try? await healthKit.askForAuthorization()
                    await checkInitialSamplesAuthStatus()
                }
                .disabled(allInitialSampleTypesAreAuthorized)
                AsyncButton("Trigger data source collection", state: $viewState) {
                    await healthKit.triggerDataSourceCollection()
                    try await Task.sleep(for: .seconds(10))
                }
            }
            Section {
                AsyncButton("Add 1 BloodOxygen Sample", state: $viewState) {
                    try await addTestData([.init(
                        sampleType: .bloodOxygen,
                        samples: [.init(date: .now, value: 87, unit: .percent())]
                    )])
                }
                AsyncButton("Add test data to HealthKit", state: $viewState) {
                    let bpm: HKUnit = .count() / .minute()
                    try await addTestData([
                        .init(sampleType: .heartRate, samples: [
                            .init(date: .init(year: 2025, month: 1, day: 15, hour: 11, minute: 00), value: 78, unit: bpm),
                            .init(date: .init(year: 2025, month: 1, day: 15, hour: 11, minute: 10), value: 89, unit: bpm),
                            .init(date: .init(year: 2025, month: 1, day: 15, hour: 11, minute: 20), value: 92, unit: bpm),
                            .init(date: .init(year: 2025, month: 1, day: 15, hour: 11, minute: 30), value: 91, unit: bpm),
                            .init(date: .init(year: 2025, month: 1, day: 15, hour: 11, minute: 40), value: 92, unit: bpm),
                            .init(date: .init(year: 2025, month: 1, day: 15, hour: 11, minute: 50), value: 90, unit: bpm),
                            .init(date: .init(year: 2025, month: 1, day: 15, hour: 12, minute: 00), value: 87, unit: bpm)
                        ]),
                        .init(sampleType: .bloodOxygen, samples: [
                            .init(date: .init(year: 2025, month: 1, day: 15, hour: 11, minute: 00), value: 0.99, unit: .percent()),
                            .init(date: .init(year: 2025, month: 1, day: 15, hour: 17, minute: 10), value: 0.98, unit: .percent()),
                            .init(date: .init(year: 2025, month: 1, day: 15, hour: 11, minute: 20), value: 0.99, unit: .percent()),
                            .init(date: .init(year: 2025, month: 1, day: 15, hour: 11, minute: 30), value: 0.99, unit: .percent()),
                            .init(date: .init(year: 2025, month: 1, day: 15, hour: 11, minute: 40), value: 0.97, unit: .percent()),
                            .init(date: .init(year: 2025, month: 1, day: 15, hour: 11, minute: 50), value: 0.99, unit: .percent()),
                            .init(date: .init(year: 2025, month: 1, day: 15, hour: 12, minute: 00), value: 0.98, unit: .percent())
                        ]),
                        .init(sampleType: .stepCount, samples: [
                            .init(date: .init(year: 2022, month: 10, day: 11, hour: 8, minute: 52), duration: 0, value: 1, unit: .count())
                        ]),
                        .init(sampleType: .height, samples: [
                            .init(date: .init(year: 2025, month: 1, day: 15), value: 187, unit: .meterUnit(with: .centi))
                        ])
                    ])
                }
                AsyncButton("Delete test data from HealthKit", state: $viewState) {
                    try await deleteTestData()
                }
                .tint(.red)
            }
//            Section {
//                NavigationLink("Samples Query") {
//                    SamplesQueriesView()
//                }
//            }
            Section("Collected Samples Since App Launch") {
                ForEach(healthKitStore.samples, id: \.self) { element in
                    Text(element.sampleType.identifier)
                }
            }.accessibilityIdentifier("CollectedSamplessssssssss")
            if !HealthKitStore.collectedSamplesOnly {
                Section("Background Persistance Log") {
                    ForEach(healthKitStore.backgroundPersistance, id: \.self) { logEntry in
                        makeRow(for: logEntry)
                    }
                }
            }
        }
        .viewStateAlert(state: $viewState)
        .task {
            await checkInitialSamplesAuthStatus()
        }
    }
    
    
    @MainActor
    private func checkInitialSamplesAuthStatus() async {
        let reqs = healthKit._initialConfigDataAccessRequirements
        let readFullyAuthd = await reqs.read.allSatisfy { @MainActor type in
            await healthKit.askedForAuthorization(toRead: type)
        }
        let writeFullyAuthd = reqs.write.allSatisfy { type in
            healthKit.askedForAuthorization(toWrite: type)
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
                let _ = ()
            }
        }
    }
    
    
    private struct TestDataDefinition {
        struct Sample {
            let date: Date
            let duration: TimeInterval
            let value: Double
            let unit: HKUnit
            
            init(date: Date, duration: TimeInterval = 0, value: Double, unit: HKUnit) {
                self.date = date
                self.duration = duration
                self.value = value
                self.unit = unit
            }
            
            init(date components: DateComponents, duration: TimeInterval = 0, value: Double, unit: HKUnit) {
                self.date = Calendar.current.date(from: components)!
                self.duration = duration
                self.value = value
                self.unit = unit
            }
        }
        let sampleType: SampleType<HKQuantitySample>
        let samples: [Sample]
    }
    
    
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
        print("Will add \(samples.count) samples to HealthKit")
        try await healthKit.askForAuthorization(for: .init(write: samples.mapIntoSet(\.sampleType)))
        for sample in samples {
            try await healthKit.healthStore.save(sample)
        }
//        try await healthKit.healthStore.save(samples)
        print("Did add \(samples.count) samples to HealthKit")
    }
    
    
    private func deleteTestData() async throws {
        var errors: [any Error] = []
        for sampleType in HKSampleType.allKnownObjectTypes.compactMap({ $0 as? HKSampleType }) {
            let descriptor = HKSampleQueryDescriptor(
                predicates: [HKSamplePredicate<HKSample>.sample(
                    type: sampleType,
                    predicate: HKQuery.predicateForObjects(from: HKSource.default())
                )],
                sortDescriptors: []
            )
            do {
                let samples = (try? await descriptor.result(for: healthKit.healthStore)) ?? []
                print("WOULD DELETE SAMPLES FOR \(sampleType) (#=\(samples.count))")
                try await healthKit.healthStore.delete(samples)
            } catch {
                print("ERROR TRYING TO DELETE DATA OF TYPE \(sampleType): \(error)")
                errors.append(error)
            }
        }
        
        struct MultiError: Error {
            let errors: [any Error]
        }
        
        if !errors.isEmpty {
            throw MultiError(errors: errors)
        }
    }
}




private extension BackgroundDataCollectionLogEntry {
    var id: UUID {
        switch self {
        case .added(let id, _, _, _), .removed(let id):
            id
        }
    }
    var displayTitle: String {
        switch self {
        case .added: "Add"
        case .removed: "Delete"
        }
    }
}


extension Calendar {
    func makeNoon(_ date: Date) -> Date {
        self.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
    }
    
    func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        self.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }
}


extension Sequence {
    @_disfavoredOverload
    func allSatisfy(_ predicate: @Sendable (Element) async -> Bool) async -> Bool {
        for element in self {
            if await !predicate(element) {
                return false
            }
        }
        return true
    }
}
