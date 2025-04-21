//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziFoundation
@testable import SpeziHealthKitBulkExport
import Testing


@Suite
struct CalendarUtilsTests {
    @Test
    func yearRanges() throws {
        let cal = Calendar.current
        let start = try #require(cal.date(from: .init(year: 2021, month: 5, day: 7)))
        let end = try #require(cal.date(from: .init(year: 2025, month: 4, day: 18)))
        let ranges = Array(cal.ranges(of: .year, startingAt: start, in: start..<end, clampToLimits: true))
        let expected = [
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2021, month: 5, day: 7))),
                try #require(cal.date(from: .init(year: 2022, month: 1, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2022, month: 1, day: 1))),
                try #require(cal.date(from: .init(year: 2023, month: 1, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2023, month: 1, day: 1))),
                try #require(cal.date(from: .init(year: 2024, month: 1, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2024, month: 1, day: 1))),
                try #require(cal.date(from: .init(year: 2025, month: 1, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2025, month: 1, day: 1))),
                try #require(cal.date(from: .init(year: 2025, month: 4, day: 18)))
            ))
        ]
        #expect(ranges == expected)
    }
    
    
    @Test
    func yearRangesNoLimitClamping() throws {
        let cal = Calendar.current
        let start = try #require(cal.date(from: .init(year: 2021, month: 5, day: 7)))
        let end = try #require(cal.date(from: .init(year: 2025, month: 4, day: 18)))
        let ranges = Array(cal.ranges(of: .year, startingAt: start, in: start..<end, clampToLimits: false))
        let expected = [
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2021, month: 1, day: 1))),
                try #require(cal.date(from: .init(year: 2022, month: 1, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2022, month: 1, day: 1))),
                try #require(cal.date(from: .init(year: 2023, month: 1, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2023, month: 1, day: 1))),
                try #require(cal.date(from: .init(year: 2024, month: 1, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2024, month: 1, day: 1))),
                try #require(cal.date(from: .init(year: 2025, month: 1, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2025, month: 1, day: 1))),
                try #require(cal.date(from: .init(year: 2026, month: 1, day: 1)))
            ))
        ]
        #expect(ranges == expected)
    }
    
    
    @Test
    func monthRanges() throws {
        let cal = Calendar.current
        let start = try #require(cal.date(from: .init(year: 2024, month: 10, day: 7)))
        let end = try #require(cal.date(from: .init(year: 2025, month: 4, day: 18)))
        let ranges = Array(cal.ranges(of: .month, startingAt: start, in: start..<end, clampToLimits: true))
        let expected = [
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2024, month: 10, day: 7))),
                try #require(cal.date(from: .init(year: 2024, month: 11, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2024, month: 11, day: 1))),
                try #require(cal.date(from: .init(year: 2024, month: 12, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2024, month: 12, day: 1))),
                try #require(cal.date(from: .init(year: 2025, month: 1, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2025, month: 1, day: 1))),
                try #require(cal.date(from: .init(year: 2025, month: 2, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2025, month: 2, day: 1))),
                try #require(cal.date(from: .init(year: 2025, month: 3, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2025, month: 3, day: 1))),
                try #require(cal.date(from: .init(year: 2025, month: 4, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2025, month: 4, day: 1))),
                try #require(cal.date(from: .init(year: 2025, month: 4, day: 18)))
            ))
        ]
        #expect(ranges == expected)
    }
    
    
    @Test
    func monthRangesNoClamping() throws {
        let cal = Calendar.current
        let start = try #require(cal.date(from: .init(year: 2024, month: 10, day: 7)))
        let end = try #require(cal.date(from: .init(year: 2025, month: 4, day: 18)))
        let ranges = Array(cal.ranges(of: .month, startingAt: start, in: start..<end, clampToLimits: false))
        let expected = [
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2024, month: 10, day: 1))),
                try #require(cal.date(from: .init(year: 2024, month: 11, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2024, month: 11, day: 1))),
                try #require(cal.date(from: .init(year: 2024, month: 12, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2024, month: 12, day: 1))),
                try #require(cal.date(from: .init(year: 2025, month: 1, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2025, month: 1, day: 1))),
                try #require(cal.date(from: .init(year: 2025, month: 2, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2025, month: 2, day: 1))),
                try #require(cal.date(from: .init(year: 2025, month: 3, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2025, month: 3, day: 1))),
                try #require(cal.date(from: .init(year: 2025, month: 4, day: 1)))
            )),
            Range<Date>(uncheckedBounds: (
                try #require(cal.date(from: .init(year: 2025, month: 4, day: 1))),
                try #require(cal.date(from: .init(year: 2025, month: 5, day: 1)))
            ))
        ]
        #expect(ranges == expected)
    }
}
