//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
@testable import SpeziHealthKitFHIR
import ModelsR4
import Testing


@Suite
struct TimeZoneTests { // swiftlint:disable:this type_body_length
    func createDateInTimeZone(_ components: DateComponents, timeZone: TimeZone) throws -> Date {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return try #require(calendar.date(from: components))
    }
    
    func getTimeZoneDate(_ components: DateComponents, timeZoneName: String) throws -> Date {
        let timeZone = try #require(TimeZone(identifier: timeZoneName))
        return try createDateInTimeZone(components, timeZone: timeZone)
    }
    
    func createDatesFor(timeZone: String) throws -> (start: Date, end: Date) {
        let startComponents = DateComponents(year: 2024, month: 12, day: 1, hour: 9, minute: 00, second: 0)
        let endComponents = DateComponents(year: 2024, month: 12, day: 1, hour: 10, minute: 45, second: 0)
        return (
            try getTimeZoneDate(startComponents, timeZoneName: timeZone),
            try getTimeZoneDate(endComponents, timeZoneName: timeZone)
        )
    }
    
    func createDSTDatesFor(timeZone: String) throws -> (start: Date, end: Date) {
        let startComponents = DateComponents(year: 2024, month: 4, day: 1, hour: 9, minute: 00, second: 0)
        let endComponents = DateComponents(year: 2024, month: 4, day: 1, hour: 10, minute: 45, second: 0)
        return (
            try getTimeZoneDate(startComponents, timeZoneName: timeZone),
            try getTimeZoneDate(endComponents, timeZoneName: timeZone)
        )
    }
    
    func createObservationFrom(
        type quantityType: HKQuantityType,
        quantity: HKQuantity,
        start: Date,
        end: Date,
        metadata: [String: Any] = [:]
    ) throws -> Observation {
        let quantitySample = HKQuantitySample(
            type: quantityType,
            quantity: quantity,
            start: start,
            end: end,
            metadata: metadata
        )
        return try #require(quantitySample.resource().get(if: Observation.self))
    }
    
    /// Tests specifying the pacific standard time zone (-08:00) in metadata with a different start and end date (results in a FHIR `Period`)
    @Test
    func pstTimeZonePeriod() throws {
        let timeZone = "America/Los_Angeles"
        let (startDate, endDate) = try createDatesFor(timeZone: timeZone)
        
        let observation = try createObservationFrom(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 42),
            start: startDate,
            end: endDate,
            metadata: [HKMetadataKeyTimeZone: timeZone]
        )
        
        guard case let .period(period) = observation.effective else {
            Issue.record("Expected period effective type")
            return
        }
        
        #expect(try #require(period.start?.value).asNSDate() == startDate)
        #expect(try #require(period.end?.value).asNSDate() == endDate)
    }

    /// Tests specifying the pacific standard time zone (-8:00) in metadata with the same start and end date (results in a FHIR `DateTime`)
    @Test
    func pstTimeZoneDateTime() throws {
        let timeZone = "America/Los_Angeles"
        let (startDate, _) = try createDatesFor(timeZone: timeZone)
        
        let observation = try createObservationFrom(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 42),
            start: startDate,
            end: startDate,
            metadata: [HKMetadataKeyTimeZone: timeZone]
        )
        
        guard case let .dateTime(dateTime) = observation.effective else {
            Issue.record("Expected dateTime effective type")
            return
        }
        
        #expect(try #require(dateTime.value).asNSDate() == startDate)
    }
    
    /// Tests specifying the pacific daylight time zone (-7:00) in metadata with a different start and end date (results in a FHIR `Period`)
    @Test
    func pdtTimeZonePeriod() throws {
        let timeZone = "America/Los_Angeles"
        let (startDate, endDate) = try createDSTDatesFor(timeZone: timeZone)
        
        let observation = try createObservationFrom(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 42),
            start: startDate,
            end: endDate,
            metadata: [HKMetadataKeyTimeZone: timeZone]
        )
        
        guard case let .period(period) = observation.effective else {
            Issue.record("Expected period effective type")
            return
        }
        
        let startTimestamp = try #require(period.start?.value?.description)
        let endTimestamp = try #require(period.end?.value?.description)
        
        #expect(startTimestamp == "2024-04-01T09:00:00-07:00", "Start timestamp should match expected format with timezone")
        #expect(endTimestamp == "2024-04-01T10:45:00-07:00", "End timestamp should match expected format with timezone")
    }
    
    /// Tests specifying the pacific daylight time zone (-7:00) in metadata with the same start and end date  (results in a FHIR `DateTime`)
    @Test
    func pdtTimeZoneDateTime() throws {
        let timeZone = "America/Los_Angeles"
        let (startDate, _) = try createDSTDatesFor(timeZone: timeZone)
        
        let observation = try createObservationFrom(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 42),
            start: startDate,
            end: startDate,
            metadata: [HKMetadataKeyTimeZone: timeZone]
        )
        
        guard case let .dateTime(dateTime) = observation.effective else {
            Issue.record("Expected dateTime effective type")
            return
        }
        
        let timestamp = try #require(dateTime.value?.description)
        #expect(timestamp == "2024-04-01T09:00:00-07:00", "Timestamp should match expected format with timezone during DST")
    }
    
    /// Tests specifying eastern standard time (-5:00) in metadata with an HKSample that defines a period with a different start and end date (results in a FHIR `Period`)
    @Test
    func estTimeZonePeriod() throws {
        let timeZone = "America/New_York"
        let (startDate, endDate) = try createDatesFor(timeZone: timeZone)
        
        let observation = try createObservationFrom(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 42),
            start: startDate,
            end: endDate,
            metadata: [HKMetadataKeyTimeZone: timeZone]
        )
        
        guard case let .period(period) = observation.effective else {
            Issue.record("Expected period effective type")
            return
        }

        #expect(try #require(period.start?.value).asNSDate() == startDate)
        #expect(try #require(period.end?.value).asNSDate() == endDate)
    }
    
    /// Tests specifying eastern standard time (-5:00) in metadata with the same start and end date (results in a FHIR `DateTime`)
    @Test
    func estTimeZoneDateTime() throws {
        let timeZone = "America/New_York"
        let (startDate, _) = try createDatesFor(timeZone: timeZone)
        
        let observation = try createObservationFrom(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 42),
            start: startDate,
            end: startDate,
            metadata: [HKMetadataKeyTimeZone: timeZone]
        )
        
        guard case let .dateTime(dateTime) = observation.effective else {
            Issue.record("Expected dateTime effective type")
            return
        }
        
        #expect(try #require(dateTime.value).asNSDate() == startDate)
    }
    
    /// Tests specifying indian standard time (+5:30) in metadata with a different start and end date (results in a FHIR `Period`)
    @Test
    func istTimeZonePeriod() throws {
        let timeZone = "Asia/Calcutta"
        let (startDate, endDate) = try createDatesFor(timeZone: timeZone)
        
        let observation = try createObservationFrom(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 42),
            start: startDate,
            end: endDate,
            metadata: [HKMetadataKeyTimeZone: timeZone]
        )
        
        guard case let .period(period) = observation.effective else {
            Issue.record("Expected period effective type")
            return
        }
        
        let startTimestamp = try #require(period.start?.value?.description)
        let endTimestamp = try #require(period.end?.value?.description)
        
        #expect(startTimestamp == "2024-12-01T09:00:00+05:30", "Start timestamp should match expected format with timezone")
        #expect(endTimestamp == "2024-12-01T10:45:00+05:30", "End timestamp should match expected format with timezone")
    }
    
    /// Tests specifying indian standard time (+5:30) in metadata with the same start and end date  (results in a FHIR `DateTime`)
    @Test
    func istTimeZoneDateTime() throws {
        let timeZone = "Asia/Calcutta"
        let (startDate, _) = try createDatesFor(timeZone: timeZone)
        
        let observation = try createObservationFrom(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 42),
            start: startDate,
            end: startDate,
            metadata: [HKMetadataKeyTimeZone: timeZone]
        )
        
        guard case let .dateTime(dateTime) = observation.effective else {
            Issue.record("Expected dateTime effective type")
            return
        }
        
        let timestamp = try #require(dateTime.value?.description)
        
        #expect(timestamp == "2024-12-01T09:00:00+05:30", "Timestamp should match expected format with timezone")
    }
    
    /// Tests that the current time zone is added if a time zone is not specified in metadata with a different start and end date (results in a FHIR `Period`)
    @Test
    func defaultTimeZonePeriod() throws {
        let startDate: Date = try {
            let dateComponents = DateComponents(year: 2024, month: 12, day: 1, hour: 9, minute: 00, second: 0)
            return try #require(Calendar.current.date(from: dateComponents))
        }()
        
        let endDate: Date = try {
            let dateComponents = DateComponents(year: 2024, month: 12, day: 1, hour: 10, minute: 45, second: 0)
            return try #require(Calendar.current.date(from: dateComponents))
        }()
        
        let observation = try createObservationFrom(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 42),
            start: startDate,
            end: endDate
        )
        
        guard case let .period(period) = observation.effective else {
            Issue.record("Expected period effective type")
            return
        }
        
        let startTimestamp = try #require(period.start?.value?.description)
        let endTimestamp = try #require(period.end?.value?.description)
        
        let currentTimeZone = TimeZone.current
        let totalMinutes = currentTimeZone.secondsFromGMT(for: startDate) / 60
        let hours = abs(totalMinutes / 60)
        let minutes = abs(totalMinutes % 60)
        let sign = totalMinutes >= 0 ? "+" : "-"
        let expectedOffsetString = String(format: "%@%02d:%02d", sign, hours, minutes)
        
        #expect(startTimestamp.starts(with: "2024-12-01T09:00:00"), "Start timestamp should begin with correct date and time")
        #expect(endTimestamp.starts(with: "2024-12-01T10:45:00"), "End timestamp should begin with correct date and time")
        #expect(try #require(period.start?.value).asNSDate() == startDate)
        #expect(try #require(period.end?.value).asNSDate() == endDate)
    }
    
    /// Tests that the current time zone is added if a time zone is not specified in metadata with the same start and end date  (results in a FHIR `DateTime`)
    @Test
    func defaultTimeZoneDateTime() throws {
        let startDate: Date = try {
            let dateComponents = DateComponents(year: 2024, month: 12, day: 1, hour: 9, minute: 00, second: 0)
            return try #require(Calendar.current.date(from: dateComponents))
        }()
        
        let endDate = startDate
        
        let observation = try createObservationFrom(
            type: HKQuantityType(.stepCount),
            quantity: HKQuantity(unit: .count(), doubleValue: 42),
            start: startDate,
            end: endDate
        )
        
        guard case let .dateTime(dateTime) = observation.effective else {
            Issue.record("Expected dateTime effective type")
            return
        }
        
        let timestamp = try #require(dateTime.value?.description)
        
        let currentTimeZone = TimeZone.current
        let totalMinutes = currentTimeZone.secondsFromGMT(for: startDate) / 60
        let hours = abs(totalMinutes / 60)
        let minutes = abs(totalMinutes % 60)
        let sign = totalMinutes >= 0 ? "+" : "-"
        let expectedOffsetString = String(format: "%@%02d:%02d", sign, hours, minutes)
        
        #expect(timestamp.starts(with: "2024-12-01T09:00:00"), "Timestamp should begin with correct date and time")
        #expect(try #require(dateTime.value).asNSDate() == startDate)
    }
    
    /// Tests creating a `Period` instance using different time zones for start and end date.
    @Test
    func multiTimeZonePeriod() throws {
        let timeZoneLA = try #require(TimeZone(identifier: "America/Los_Angeles"))
        let timeZoneDE = try #require(TimeZone(identifier: "Europe/Berlin"))
        
        // we're choosing this exact date bc at that point in time, LA was already in DST, while germany was not.
        let startDateLA = try #require(Calendar.current.date(from: .init(timeZone: timeZoneLA, year: 2025, month: 3, day: 14, hour: 7)))
        let startDateDE = try #require(Calendar.current.date(from: .init(timeZone: timeZoneDE, year: 2025, month: 3, day: 14, hour: 15)))
        let endDateLA = try #require(Calendar.current.date(from: .init(timeZone: timeZoneLA, year: 2025, month: 3, day: 14, hour: 7, minute: 30)))
        let endDateDE = try #require(Calendar.current.date(from: .init(timeZone: timeZoneDE, year: 2025, month: 3, day: 14, hour: 15, minute: 30)))
        
        #expect(try DateTime(date: startDateLA, timeZone: timeZoneLA).asNSDate() == DateTime(date: startDateDE, timeZone: timeZoneDE).asNSDate())
        
        #expect(try DateTime(date: endDateLA, timeZone: timeZoneLA).asNSDate() == DateTime(date: endDateDE, timeZone: timeZoneDE).asNSDate())
        
        let period1 = Period(
            end: FHIRPrimitive(try DateTime(date: startDateLA, timeZone: timeZoneLA)),
            start: FHIRPrimitive(try DateTime(date: endDateDE, timeZone: timeZoneDE))
        )
        let period2 = Period(
            end: FHIRPrimitive(try DateTime(date: startDateDE, timeZone: timeZoneDE)),
            start: FHIRPrimitive(try DateTime(date: endDateLA, timeZone: timeZoneLA))
        )
        
        #expect(try #require(period1.start?.value).asNSDate() == #require(period2.start?.value).asNSDate())
        #expect(try #require(period1.end?.value).asNSDate() == #require(period2.end?.value).asNSDate())
    }
}
