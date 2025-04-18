//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import Foundation
import HealthKit
import SpeziHealthKit
import SpeziHealthKitBulkExport
import SpeziViews
import SwiftUI


/// The `HKSample` metadata key we add to all samples created as testing data of historical samples.
///
/// This exists to make it easier for someone to delete these samples from their iPhone, should they accidentally run this on a real device.
let HKSampleMetadataKeyIsSpeziTestingData = "edu.stanford.spezi.healthkit.isTestingData"

extension NSPredicate {
    static var isSpeziTestingSample: NSPredicate {
        HKQuery.predicateForObjects(
            withMetadataKey: HKSampleMetadataKeyIsSpeziTestingData,
            operatorType: .equalTo,
            value: "YES"
        )
    }
}


struct BulkExportView: View {
    @Environment(HealthKit.self)
    private var healthKit
    @Environment(BulkHealthExporter.self)
    private var bulkExporter
    @Environment(\.calendar)
    private var cal
    
    // NOTE: we are intentionally using these specific sample types here, since they don't overlap with the `CollectSample` definitions.
    // Adding eg a ton of heart rate samples would slow down the app a lot, since they'd trigger the observer mechanism.
    private let sampleTypes = SampleTypesCollection(
        quantity: [.restingHeartRate, .height, .cyclingSpeed],
        correlation: [.bloodPressure]
    )
    
    private let timeRange: Range<Date> = {
        let cal = Calendar.current
        let startDate = cal.startOfYear(for: cal.date(from: .init(year: 2021, month: 1, day: 1))!) // swiftlint:disable:this force_unwrapping
        let endDate = cal.startOfYear(for: cal.date(from: .init(year: 2024, month: 1, day: 1))!) // swiftlint:disable:this force_unwrapping
        return startDate..<endDate
    }()
    
    @State private var viewState: ViewState = .idle
    @State private var numExportedSamples = 0
    @State private var numTestingSamples = 0
    @State private var session: (any BulkExportSessionProtocol)?
    
    var body: some View {
        Form {
            Section {
                healthKitActions
            }
            Section {
                exporterActions
            }
            Section("Bulk Export Session") {
                if let session {
                    LabeledContent("State", value: session.state.description)
                    LabeledContent("Status", value: "Completed \(session.completedBatches.count) of \(session.numTotalBatches) (\(session.failedBatches.count) failed)")
                    ProgressView(value: Double(session.numProcessedBatches) / Double(session.numTotalBatches)) {
                        Text("Completed \(session.completedBatches.count) of \(session.numTotalBatches) (\(session.failedBatches.count) failed)")
                        if let desc = session.progress?.currentBatchDescription {
                            Text("Current batch: \(desc)")
                        }
                    }
                    switch session.state {
                    case .paused, .done:
                        Button("Start") {
                            session.start(retryFailedBatches: true)
                        }
                    case .running:
                        Button("Pause") {
                            session.pause()
                        }
                    }
                } else {
                    Text("No Bulk Export Session")
                        .foregroundStyle(.secondary)
                }
                LabeledContent("# Exported Samples", value: String(numExportedSamples))
                    .accessibilityValue(String(numExportedSamples))
                LabeledContent("# Expected Samples", value: String(numTestingSamples))
                    .accessibilityValue(String(numTestingSamples))
            }
        }
        .task {
            await fetchNumTestingSamples()
        }
    }
    
    @ViewBuilder private var healthKitActions: some View {
        AsyncButton("Request full access", state: $viewState) {
            let sampleTypes: [HKSampleType] = self.sampleTypes.effectiveSampleTypesForAuthentication.map { $0.hkSampleType }
            try await healthKit.askForAuthorization(for: .init(
                read: sampleTypes,
                write: sampleTypes
            ))
        }
        AddHistoricalSamplesSection(timeRange: timeRange, sampleTypes: sampleTypes, viewState: $viewState) {
            await fetchNumTestingSamples()
        }
    }
    
    @ViewBuilder private var exporterActions: some View {
        let sessionId = BulkExportSessionIdentifier("testSession")
        AsyncButton("Start Bulk Export", state: $viewState) {
            switch try await bulkExporter.session(
                sessionId,
                for: sampleTypes,
                startDate: .oldestSample,
                // we intentionally give it a little delay, so that we can test the pause() functionality as part of the UI test.
                using: SamplesCounter(delay: .seconds(1)),
                startAutomatically: true
            ) {
            case let .newSession(session, stream):
                self.session = session
                Task {
                    for await numSamples in stream {
                        self.numExportedSamples += numSamples
                    }
                }
            case .existingSession(let session):
                self.session = session
            }
        }
        AsyncButton("Reset ExportSession", role: .destructive, state: $viewState) {
            try bulkExporter.deleteSessionRestorationInfo(for: sessionId)
        }
    }
    
    private func fetchNumTestingSamples() async {
        func imp<Sample>(_ sampleType: some AnySampleType<Sample>) async -> Int {
            let sampleType = SampleType(sampleType)
            let samples = (try? await healthKit.query(sampleType, timeRange: .init(timeRange), predicate: .isSpeziTestingSample)) ?? []
            defer {
                _ = consume samples
            }
            return samples.count
        }
        var numSamples = 0
        for sampleType in sampleTypes {
            numSamples += await imp(sampleType)
        }
        numTestingSamples = numSamples
    }
}


private struct AddHistoricalSamplesSection: View {
    @Environment(HealthKit.self) private var healthKit
    @Environment(\.calendar) private var cal
    
    let timeRange: Range<Date>
    let sampleTypes: SampleTypesCollection
    @Binding var viewState: ViewState
    let didAddSamples: @MainActor () async -> Void
    @State private var addHistoricalSamplesProgress: Double?
    
    var body: some View {
        AsyncButton("Add Historical Data", state: $viewState) {
            try await addHistoricalSamples()
            await didAddSamples()
        }
        if let progress = addHistoricalSamplesProgress {
            ProgressView("Adding Historical Samples…", value: progress)
        }
        AsyncButton("Delete Spezi-created Historical Testing Data", role: .destructive, state: $viewState) {
            func imp<Sample>(_ sampleType: some AnySampleType<Sample>) async throws {
                let sampleType = SampleType(sampleType)
                let samples = try await healthKit.query(sampleType, timeRange: .ever, predicate: .isSpeziTestingSample)
                try await healthKit.healthStore.delete(samples)
            }
            for sampleType in sampleTypes {
                try await imp(sampleType)
            }
        }
    }
    
    
    private func addHistoricalSamples() async throws { // swiftlint:disable:this function_body_length
        try await healthKit.askForAuthorization(for: .init(
            write: sampleTypes
        ))
        
        let days = Array(sequence(first: cal.rangeOfDay(for: timeRange.lowerBound)) { day in
            let next = cal.rangeOfDay(for: cal.startOfNextDay(for: day.lowerBound))
            return next.overlaps(timeRange) ? next.clamped(to: timeRange) : nil
        })
        let numDays = days.count
        precondition(numDays == cal.countDistinctDays(from: timeRange.lowerBound, to: timeRange.upperBound) - 1)
        
        await MainActor.run {
            self.addHistoricalSamplesProgress = 0
        }
        var expectedNumTotalSamples = 0
        var numSamplesAddedSoFar = 0
        
        @Sendable nonisolated func imp(
            _ sampleType: SampleType<HKQuantitySample>,
            makeQuantity: (_ lastQuantity: HKQuantity?) -> HKQuantity
        ) async throws {
            var prevSample: HKQuantitySample?
            for day in days {
                let sample = HKQuantitySample(
                    type: sampleType.hkSampleType,
                    quantity: makeQuantity(prevSample?.quantity),
                    start: day.lowerBound,
                    end: day.lowerBound.addingTimeInterval(60 * 30),
                    metadata: [
                        HKSampleMetadataKeyIsSpeziTestingData: "YES"
                    ]
                )
                try await healthKit.healthStore.save(sample)
                prevSample = sample
                await MainActor.run {
                    numSamplesAddedSoFar += 1
                    self.addHistoricalSamplesProgress = Double(numSamplesAddedSoFar) / Double(expectedNumTotalSamples)
                }
            }
        }
        
        defer {
            _Concurrency.Task { @MainActor in
                addHistoricalSamplesProgress = nil
            }
        }
        
        try await withThrowingDiscardingTaskGroup(returning: Void.self) { taskGroup in
            let addQuantitySample = { @Sendable (sampleType: SampleType<HKQuantitySample>) async throws in
                let unit = sampleType.displayUnit
                try await imp(sampleType) { lastQuantity in
                    if let lastQuantity {
                        HKQuantity(unit: unit, doubleValue: lastQuantity.doubleValue(for: unit) * .random(in: 0.85...1.15))
                    } else {
                        HKQuantity(unit: unit, doubleValue: .random(in: 1...99))
                    }
                }
            }
            for sampleType in sampleTypes {
                taskGroup.addTask { @Sendable in
                    switch WrappedSampleType(sampleType) {
                    case .quantity(let sampleType):
                        await MainActor.run {
                            expectedNumTotalSamples += numDays
                        }
                        try await addQuantitySample(sampleType)
                    case .correlation(let sampleType):
                        await MainActor.run {
                            expectedNumTotalSamples += numDays * sampleType.associatedQuantityTypes.count
                        }
                        for sampleType in sampleType.associatedQuantityTypes {
                            try await addQuantitySample(sampleType)
                        }
                    default:
                        print("ERROR: unhandled sample type: \(sampleType)")
                    }
                }
            }
        }
    }
}


private struct SamplesCounter: BatchProcessor {
    let delay: Duration?
    
    func process<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) async throws -> Int {
        if let delay {
            try await _Concurrency.Task.sleep(for: delay)
        }
        return samples.count
    }
}


extension BulkExportSessionState {
    var description: String {
        switch self {
        case .running:
            "running"
        case .paused:
            "paused"
        case .done:
            "done"
        }
    }
}
