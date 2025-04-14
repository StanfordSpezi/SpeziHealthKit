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
import HealthKitOnFHIR
import ModelsR4
import SpeziHealthKit
import SpeziViews
import SwiftUI


struct BulkExportView: View {
    private struct AddSamplesProgress {
        var currentIdx = 0
        var numTotal = 0
    }
    
    @Environment(HealthKit.self)
    private var healthKit
    @Environment(BulkHealthExporter.self)
    private var bulkExporter
    @Environment(\.calendar)
    private var cal
    
    private let sampleTypes: Set<SampleType<HKQuantitySample>> = [.heartRate, .stepCount, .activeEnergyBurned]
    
    @State private var viewState: ViewState = .idle
    @State private var addHistoricalSamplesProgress: AddSamplesProgress?
    
    var body: some View {
        Form {
            Section {
                actionsSectionContent
            }
            Section {
                EmptyView()
            }
        }
    }
    
    @ViewBuilder private var actionsSectionContent: some View {
        AsyncButton("Request full access", state: $viewState) {
            try await healthKit.askForAuthorization(for: .init(
                read: HKQuantityType.allKnownQuantities
            ))
        }
        AsyncButton("Add Historical Samples", state: $viewState) {
            try await addHistoricalSamples()
        }
        if let progress = addHistoricalSamplesProgress {
            HStack {
                ProgressView(value: Double(progress.currentIdx) / Double(progress.numTotal))
                    .progressViewStyle(.linear)
                Text("\(progress.currentIdx) of \(progress.numTotal)")
                    .monospacedDigit()
            }
        }
        AsyncButton("Start Bulk Export", state: $viewState) {
            try await bulkExporter.session(
                "testSession",
                for: [.quantity(.heartRate)],
                using: .jsonFile(compressUsingZlib: false),
                startAutomatically: false
            ) { url in
                do {
                    print("DID CREATE EXPORT: \(url)")
                    let data = try Data(contentsOf: url)
                    let resources = try JSONDecoder().decode([ResourceProxy].self, from: data)
                    print("#resources: \(resources.count)")
                    return true
                } catch {
                    print("ERROR: \(error)")
                    return false
                }
            }
        }
    }
    
    private nonisolated func addHistoricalSamples() async throws { // swiftlint:disable:this function_body_length
        let cal = await self.cal
        let sampleTypes = await self.sampleTypes
        try await healthKit.askForAuthorization(for: .init(
            write: sampleTypes.map(\.hkSampleType)
        ))
        
        let startDate = cal.startOfYear(for: cal.date(from: .init(year: 2020, month: 1, day: 1))!) // swiftlint:disable:this force_unwrapping
        let endDate = Date.now
        let totalRange = startDate..<endDate
        
        let years = Array(sequence(first: cal.rangeOfYear(for: startDate)) { year in
            let next = cal.rangeOfYear(for: cal.startOfNextYear(for: year.lowerBound))
            return next.overlaps(totalRange) ? next.clamped(to: totalRange) : nil
        })
        
        let hours = Array(sequence(first: cal.rangeOfHour(for: startDate)) { hour in
            let next = cal.rangeOfHour(for: cal.startOfNextHour(for: hour.lowerBound))
            return next.overlaps(totalRange) ? next.clamped(to: totalRange) : nil
        })
        
        await MainActor.run {
            self.addHistoricalSamplesProgress = .init(
                currentIdx: 0,
                numTotal: sampleTypes.count * cal.countDistinctHours(from: startDate, to: endDate)
            )
        }
        
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
                    self.addHistoricalSamplesProgress!.currentIdx += 1 // swiftlint:disable:this force_unwrapping
                }
            }
        }
        
        defer {
            _Concurrency.Task { @MainActor in
                addHistoricalSamplesProgress = nil
            }
        }
        
        @Sendable nonisolated func imp2(_ sampleType: SampleType<HKQuantitySample>) async throws {
            let unit = sampleType.displayUnit
            try await imp(sampleType) { lastQuantity in
                if let lastQuantity {
                    HKQuantity(unit: unit, doubleValue: lastQuantity.doubleValue(for: unit) * .random(in: 0.85...1.15))
                } else {
                    HKQuantity(unit: unit, doubleValue: .random(in: 1...99))
                }
            }
        }
        
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for sampleType in sampleTypes {
                taskGroup.addTask {
                    try await imp2(sampleType)
                }
            }
            for try await _ in taskGroup {
            }
        }
    }
}


private struct JSONFileExportFormat: BulkHealthExporter.BatchProcessor {
    typealias Output = URL
    
    private let compressUsingZlib: Bool
    
    fileprivate init(compressUsingZlib: Bool) {
        self.compressUsingZlib = compressUsingZlib
    }
    
    func process<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) async throws -> URL {
        let resources = try samples.mapIntoResourceProxies()
        let encoded = try JSONEncoder().encode(resources)
        let jsonUrl = URL(filePath: NSTemporaryDirectory() + UUID().uuidString + ".json")
        try encoded.write(to: jsonUrl)
        if compressUsingZlib {
            let fm = FileManager.default
            let zlibUrl = try fm.archiveFile(at: jsonUrl, using: .zlib)
            try fm.removeItem(at: jsonUrl)
            return zlibUrl
        } else {
            print(try Data(contentsOf: jsonUrl))
            return jsonUrl
        }
    }
}


extension BulkHealthExporter.BatchProcessor where Self == JSONFileExportFormat {
    fileprivate static func jsonFile(compressUsingZlib: Bool) -> some BulkHealthExporter.BatchProcessor<URL> {
        JSONFileExportFormat(compressUsingZlib: compressUsingZlib)
    }
}
