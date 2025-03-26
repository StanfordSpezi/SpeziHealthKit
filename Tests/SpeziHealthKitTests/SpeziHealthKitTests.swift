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
import XCTest


final class SpeziHealthKitTests: XCTestCase {
    func testTimeRanges() {
        XCTAssertEqual(HealthKitQueryTimeRange.last(hours: 1), .currentHour)
        XCTAssertEqual(HealthKitQueryTimeRange.last(days: 1), .today)
        XCTAssertEqual(HealthKitQueryTimeRange.last(weeks: 1), .currentWeek)
        XCTAssertEqual(HealthKitQueryTimeRange.last(months: 1), .currentMonth)
        XCTAssertEqual(HealthKitQueryTimeRange.last(years: 1), .currentYear)
    }
    
    func testWellKnownIdentifiers() {
        XCTAssertEqual(HKQuantityType.allKnownQuantities.count, HKQuantityTypeIdentifier.allKnownIdentifiers.count)
        XCTAssertEqual(HKCorrelationType.allKnownCorrelations.count, HKCorrelationTypeIdentifier.allKnownIdentifiers.count)
        XCTAssertEqual(HKCategoryType.allKnownCategories.count, HKCategoryTypeIdentifier.allKnownIdentifiers.count)
        XCTAssertEqual(HKObjectType.allKnownObjectTypes.count, 198)
    }
    
    
    func testQueryAnchorCoding() throws {
        func imp(_ anchor: QueryAnchor, line: UInt = #line) throws {
            let encoded = try JSONEncoder().encode(anchor)
            let decoded = try JSONDecoder().decode(QueryAnchor.self, from: encoded)
            XCTAssertEqual(anchor, decoded, line: line)
        }
        try imp(QueryAnchor(HKQueryAnchor(fromValue: 5734987678924)))
        try imp(QueryAnchor())
    }
}
