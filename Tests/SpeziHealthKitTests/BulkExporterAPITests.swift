//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

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
}


private actor TestStandard: Standard, HealthKitConstraint {
    func handleNewSamples<Sample>(_ addedSamples: some Collection<Sample>, ofType sampleType: SampleType<Sample>) {
        // ...
    }
    
    func handleDeletedObjects<Sample>(_ deletedObjects: some Collection<HKDeletedObject>, ofType sampleType: SampleType<Sample>) {
        // ...
    }
}
