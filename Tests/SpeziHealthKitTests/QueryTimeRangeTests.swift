//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import XCTest
import HealthKit



final class QueryTimeRangeTests: XCTestCase {
    func testTimeRanges() {
        XCTAssertEqual(HealthKitQueryTimeRange.last(hours: 1), .currentHour)
        XCTAssertEqual(HealthKitQueryTimeRange.last(days: 1), .today)
        XCTAssertEqual(HealthKitQueryTimeRange.last(weeks: 1), .currentWeek)
        XCTAssertEqual(HealthKitQueryTimeRange.last(months: 1), .currentMonth)
        XCTAssertEqual(HealthKitQueryTimeRange.last(years: 1), .currentYear)
    }
    
    
    @MainActor
    func testHealthDataAvailability() async throws {
        XCTAssertTrue(HKHealthStore.isHealthDataAvailable())
        let healthStore = HKHealthStore()
        try await healthStore.requestAuthorization(toShare: [], read: [HKQuantityType(.heartRate)])
    }
}
