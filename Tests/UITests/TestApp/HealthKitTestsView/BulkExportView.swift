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


actor BoxedSet<T: Hashable> {
    private(set) var storage = Set<T>()
    
    init() {}
    
    func insert(_ element: T) -> Bool {
        storage.insert(element).inserted
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
    private let sampleTypes: Set<SampleType<HKQuantitySample>> = [.restingHeartRate, .height, .cyclingSpeed]
    
    private let timeRange: Range<Date> = {
        let cal = Calendar.current
        let startDate = cal.startOfYear(for: cal.date(from: .init(year: 2021, month: 1, day: 1))!) // swiftlint:disable:this force_unwrapping
        let endDate = cal.startOfYear(for: cal.date(from: .init(year: 2024, month: 1, day: 1))!) // swiftlint:disable:this force_unwrapping
        return startDate..<endDate
    }()
    
    @State private var viewState: ViewState = .idle
    @State private var numExportedSamples = 0
    @State private var numTestingSamples = 0
    @State private var session: (any BulkHealthExporter.ExportSessionProtocol)?
    
    var body: some View {
        Form {
            Section {
                actionsSectionContent
            }
            Section {
                AddHistoricalSamplesSection(timeRange: timeRange, sampleTypes: sampleTypes, viewState: $viewState) {
                    await fetchNumTestingSamples()
                }
            }
            Section("Bulk Export Session") {
                if let session {
                    LabeledContent("State", value: session.state.description)
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
    
    @ViewBuilder private var actionsSectionContent: some View {
        AsyncButton("Request full access", state: $viewState) {
            try await healthKit.askForAuthorization(for: .init(
                read: sampleTypes.map(\.hkSampleType),
                write: sampleTypes.map(\.hkSampleType)
            ))
        }
        
        AsyncButton("Start Bulk Export", state: $viewState) {
            if false {
                session = try await bulkExporter.session(
                    "testSession",
                    for: sampleTypes.mapIntoSet { .quantity($0) },
                    using: SamplesCounter(),
                    startAutomatically: true
                ) { numSamples in
                    await MainActor.run {
                        self.numExportedSamples += numSamples
                    }
                    return true
                }
            } else {
                let seenSamples = BoxedSet<HKSample>()
                session = try await bulkExporter.session(
                    "testSession",
                    for: sampleTypes.mapIntoSet { .quantity($0) },
                    using: .identity
                ) { samples in
                    for sample in samples {
                        let didInsert = await seenSamples.insert(sample)
                        precondition(didInsert)
                    }
                    await MainActor.run {
                        self.numExportedSamples += samples.count
                    }
                    return true
                }
            }
        }
    }
    
    private func fetchNumTestingSamples() async {
        var numSamples = 0
        for sampleType in sampleTypes {
            let samples = (try? await healthKit.query(sampleType, timeRange: .init(timeRange), predicate: .isSpeziTestingSample)) ?? []
            numSamples += samples.count
            _ = consume samples
        }
        numTestingSamples = numSamples
    }
}


private struct AddHistoricalSamplesSection: View {
    @Environment(HealthKit.self) private var healthKit
    @Environment(\.calendar) private var cal
    
    let timeRange: Range<Date>
    let sampleTypes: Set<SampleType<HKQuantitySample>>
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
            for sampleType in sampleTypes {
                let samples = try await healthKit.query(sampleType, timeRange: .ever, predicate: .isSpeziTestingSample)
                try await healthKit.healthStore.delete(samples)
            }
        }
    }
    
    
    private func addHistoricalSamples() async throws {
        try await healthKit.askForAuthorization(for: .init(
            write: sampleTypes.map(\.hkSampleType)
        ))
        
        let hours = Array(sequence(first: cal.rangeOfHour(for: timeRange.lowerBound)) { hour in
            let next = cal.rangeOfHour(for: cal.startOfNextHour(for: hour.lowerBound))
            return next.overlaps(timeRange) ? next.clamped(to: timeRange) : nil
        })
        
        await MainActor.run {
            self.addHistoricalSamplesProgress = 0
        }
        let expectedNumTotalSamples = sampleTypes.count * cal.countDistinctHours(from: timeRange.lowerBound, to: timeRange.upperBound)
        var numSamplesAddedSoFar = 0
        
        @Sendable nonisolated func imp(
            _ sampleType: SampleType<HKQuantitySample>,
            makeQuantity: (_ lastQuantity: HKQuantity?) -> HKQuantity
        ) async throws {
            var prevSample: HKQuantitySample?
            for hour in hours {
                let sample = HKQuantitySample(
                    type: sampleType.hkSampleType,
                    quantity: makeQuantity(prevSample?.quantity),
                    start: hour.lowerBound,
                    end: hour.lowerBound.addingTimeInterval(60 * 30),
                    metadata: [
                        "edu.stanford.spezi.healthkit.isTestingData": "YES"
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
            for sampleType in sampleTypes {
                taskGroup.addTask { @Sendable in
                    let unit = sampleType.displayUnit
                    try await imp(sampleType) { lastQuantity in
                        if let lastQuantity {
                            HKQuantity(unit: unit, doubleValue: lastQuantity.doubleValue(for: unit) * .random(in: 0.85...1.15))
                        } else {
                            HKQuantity(unit: unit, doubleValue: .random(in: 1...99))
                        }
                    }
                }
            }
        }
    }
}


private struct SamplesCounter: BulkHealthExporter.BatchProcessor {
    func process<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) async throws -> Int {
        samples.count
    }
}


extension BulkHealthExporter.ExportSessionState {
    var description: String {
        switch self {
        case .scheduled:
            "scheduled"
        case .running:
            "running"
        case .paused:
            "paused"
        case .done:
            "done"
        }
    }
}
