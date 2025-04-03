//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
@testable import SpeziHealthKit
import SpeziHealthKitUI
import Testing


@Suite("SpeziHealthKitTests")
struct SpeziHealthKitTests {
    @Test("Equal Time Ranges")
    func equalTimeRanges() {
        #expect(HealthKitQueryTimeRange.last(hours: 1) == .currentHour)
        #expect(HealthKitQueryTimeRange.last(days: 1) == .today)
        #expect(HealthKitQueryTimeRange.last(weeks: 1) == .currentWeek)
        #expect(HealthKitQueryTimeRange.last(months: 1) == .currentMonth)
        #expect(HealthKitQueryTimeRange.last(years: 1) == .currentYear)
    }

    @Test("Equal Well Known Identifiers")
    func equalWellKnownIdentifiers() {
        #expect(HKQuantityType.allKnownQuantities.count == HKQuantityTypeIdentifier.allKnownIdentifiers.count)
        #expect(HKCorrelationType.allKnownCorrelations.count == HKCorrelationTypeIdentifier.allKnownIdentifiers.count)
        #expect(HKCategoryType.allKnownCategories.count == HKCategoryTypeIdentifier.allKnownIdentifiers.count)
        #expect(HKObjectType.allKnownObjectTypes.count == 198)
    }


    @Test("Query anchors codable", arguments: [
        QueryAnchor(HKQueryAnchor(fromValue: 5734987678924)),
        QueryAnchor()
    ])
    func equalQueryAnchorCoding2(_ anchor: QueryAnchor) throws {
        let encoded = try JSONEncoder().encode(anchor)
        let decoded = try JSONDecoder().decode(QueryAnchor.self, from: encoded)
        #expect(anchor == decoded)
    }
}
