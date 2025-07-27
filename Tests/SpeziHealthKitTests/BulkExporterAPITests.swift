//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import Algorithms
import Spezi
@testable import SpeziHealthKit
@testable import SpeziHealthKitBulkExport
import SpeziTesting
import Testing


@Suite
struct BulkExporterAPITests {
    @Test
    func sessionStartDate() async throws {
        // we need to pass in the module, but for the input we're specifying it won't be accessed.
        let module = HealthKit()
        let cal = Calendar.current
        
        let endDate = try #require(cal.date(from: .init(year: 2025, month: 2, day: 11)))
        
        func startDate(for startDateDef: ExportSessionStartDate) async throws -> Date {
            try #require(await startDateDef.startDate(for: .heartRate, in: module, relativeTo: endDate))
        }
        
        do {
            let startDate = try await startDate(for: .last(numDays: 4))
            let expected = try #require(cal.date(from: .init(year: 2025, month: 2, day: 7)))
            #expect(startDate == expected)
        }
        do {
            let startDate = try await startDate(for: .last(numWeeks: 1))
            let expected = try #require(cal.date(from: .init(year: 2025, month: 2, day: 4)))
            #expect(startDate == expected)
        }
        do {
            let startDate = try await startDate(for: .last(numMonths: 2))
            let expected = try #require(cal.date(from: .init(year: 2024, month: 12, day: 11)))
            #expect(startDate == expected)
        }
        do {
            let startDate = try await startDate(for: .last(numYears: 3))
            let expected = try #require(cal.date(from: .init(year: 2022, month: 2, day: 11)))
            #expect(startDate == expected)
        }
        do {
            let startDate = try await startDate(for: .last(DateComponents(year: 2, month: 4)))
            let expected = try #require(cal.date(from: .init(year: 2022, month: 10, day: 11)))
            #expect(startDate == expected)
        }
    }
    
    
    @Test
    func sessionMgmt() async throws {
        let module = BulkHealthExporter()
        await withDependencyResolution(standard: TestStandard()) {
            module
        }
        #expect(await module.sessions.isEmpty)
        
        let sessionId = BulkExportSessionIdentifier("testId")
        let session = try await module.session(withId: sessionId, for: [], startDate: .oldestSample, using: .identity)
        
        let sessionsInModule: [any BulkExportSession] = await module.sessions
        let ourSession: [any BulkExportSession] = [session]
        #expect(sessionsInModule.elementsEqual(ourSession, by: { $0 == $1 }))
        let results = try await session.start()
        for await _ in results { }
        try await Task.sleep(for: .seconds(0.5))
        #expect(await session.state == .completed)
        #expect(await module.sessions.count == 1)
        #expect(await module.sessions.contains(where: { $0 == session }))
        try await module.deleteSessionRestorationInfo(for: sessionId)
        #expect(await session.state == .terminated)
        #expect(await module.sessions.isEmpty)
    }
    
    
    @Test
    func exportBatchTimeRanges() async throws {
        let cal = Calendar.current
        let healthKit = HealthKit()
        let bulkExporter = BulkHealthExporter()
        await withDependencyResolution(standard: TestStandard()) {
            healthKit
            bulkExporter
        }
        #expect(await bulkExporter.sessions.isEmpty)
        
        func makeDate(_ year: Int, _ month: Int, _ day: Int, location: SourceLocation = #_sourceLocation) throws -> Date {
            try #require(cal.date(from: .init(year: year, month: month, day: day)), sourceLocation: location)
        }
        
        var sessionDescriptor = ExportSessionDescriptor(
            sessionId: .init(UUID().uuidString),
            startDate: .last(.init(month: 6)),
            endDate: try makeDate(2025, 7, 26)
        )
        #expect(sessionDescriptor.pendingBatches.isEmpty)
        #expect(sessionDescriptor.completedBatches.isEmpty)
        #expect(try await sessionDescriptor.startDate.startDate(for: SampleType.heartRate, in: healthKit, relativeTo: sessionDescriptor.endDate) == makeDate(2025, 1, 26))
        #expect(try cal.startOfWeek(for: makeDate(2025, 1, 26)) == makeDate(2025, 1, 20))
        #expect(try cal.start(of: .week, for: makeDate(2025, 1, 26)) == makeDate(2025, 1, 20))
        
        func batches(for sampleType: SampleType<some Any>) -> [ExportBatch] {
            sessionDescriptor.pendingBatches.filter { $0.sampleType == sampleType }
        }
        // add some export batches
        await sessionDescriptor.add(sampleType: SampleType.heartRate, batchSize: .byMonth, healthKit: healthKit)
        let heartRateExportBatches = batches(for: .heartRate)
        #expect(heartRateExportBatches.count == 7)
        // adding the same input again shouldn't affect anything
        await sessionDescriptor.add(sampleType: SampleType.heartRate, batchSize: .byMonth, healthKit: healthKit)
        #expect(batches(for: .heartRate) == heartRateExportBatches)
        #expect(heartRateExportBatches == [
            .init(sampleType: SampleType.heartRate, timeRange: try makeDate(2025, 1, 26)..<makeDate(2025, 2, 1)),
            .init(sampleType: SampleType.heartRate, timeRange: try makeDate(2025, 2, 1)..<makeDate(2025, 3, 1)),
            .init(sampleType: SampleType.heartRate, timeRange: try makeDate(2025, 3, 1)..<makeDate(2025, 4, 1)),
            .init(sampleType: SampleType.heartRate, timeRange: try makeDate(2025, 4, 1)..<makeDate(2025, 5, 1)),
            .init(sampleType: SampleType.heartRate, timeRange: try makeDate(2025, 5, 1)..<makeDate(2025, 6, 1)),
            .init(sampleType: SampleType.heartRate, timeRange: try makeDate(2025, 6, 1)..<makeDate(2025, 7, 1)),
            .init(sampleType: SampleType.heartRate, timeRange: try makeDate(2025, 7, 1)..<makeDate(2025, 7, 26)),
        ])
        
        await sessionDescriptor.add(sampleType: .activeEnergyBurned, batchSize: .calendarComponent(.week, multiplier: 2), healthKit: healthKit)
        #expect(batches(for: .activeEnergyBurned).count == 14)
        #expect(batches(for: .activeEnergyBurned).starts(with: [
            .init(sampleType: SampleType.activeEnergyBurned, timeRange: try makeDate(2025, 1, 26)..<makeDate(2025, 2, 3)),
            .init(sampleType: SampleType.activeEnergyBurned, timeRange: try makeDate(2025, 2, 3)..<makeDate(2025, 2, 17)),
            .init(sampleType: SampleType.activeEnergyBurned, timeRange: try makeDate(2025, 2, 17)..<makeDate(2025, 3, 3)),
            .init(sampleType: SampleType.activeEnergyBurned, timeRange: try makeDate(2025, 3, 3)..<makeDate(2025, 3, 17)),
            .init(sampleType: SampleType.activeEnergyBurned, timeRange: try makeDate(2025, 3, 17)..<makeDate(2025, 3, 31)),
            .init(sampleType: SampleType.activeEnergyBurned, timeRange: try makeDate(2025, 3, 31)..<makeDate(2025, 4, 14)),
            .init(sampleType: SampleType.activeEnergyBurned, timeRange: try makeDate(2025, 4, 14)..<makeDate(2025, 4, 28)),
            .init(sampleType: SampleType.activeEnergyBurned, timeRange: try makeDate(2025, 4, 28)..<makeDate(2025, 5, 12)),
            .init(sampleType: SampleType.activeEnergyBurned, timeRange: try makeDate(2025, 5, 12)..<makeDate(2025, 5, 26)),
            .init(sampleType: SampleType.activeEnergyBurned, timeRange: try makeDate(2025, 5, 26)..<makeDate(2025, 6, 9)),
            .init(sampleType: SampleType.activeEnergyBurned, timeRange: try makeDate(2025, 6, 9)..<makeDate(2025, 6, 23)),
            .init(sampleType: SampleType.activeEnergyBurned, timeRange: try makeDate(2025, 6, 23)..<makeDate(2025, 7, 7)),
            .init(sampleType: SampleType.activeEnergyBurned, timeRange: try makeDate(2025, 7, 7)..<makeDate(2025, 7, 21)),
            .init(sampleType: SampleType.activeEnergyBurned, timeRange: try makeDate(2025, 7, 21)..<makeDate(2025, 7, 26)),
        ]))
    }
}


private actor TestStandard: Standard, HealthKitConstraint {
    func handleNewSamples<Sample>(_ addedSamples: some Collection<Sample>, ofType sampleType: SampleType<Sample>) {
        // ...
    }
    
    func handleDeletedObjects<Sample>(_ deletedObjects: some Collection<HKDeletedObject>, ofType sampleType: SampleType<Sample>) {
        // ...
    }
}
