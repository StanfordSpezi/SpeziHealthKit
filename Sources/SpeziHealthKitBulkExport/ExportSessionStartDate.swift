//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziHealthKit

/// The earliest date for which the session should collect and export historical Health data.
public enum ExportSessionStartDate: Hashable, Codable, Sendable {
    /// The session should, for every sample type, go back all the way to the oldest sample, and start collecting from there.
    ///
    /// This option will result in a ``BulkExportSession`` exporting all samples up until the point in time the session was first started.
    case oldestSample
    
    /// The session should, relative to the time it was first created, collect a certain range of past data.
    ///
    /// This option will identify the first non-nil and non-zero component, starting at `year`,
    /// and result in a start date that is `exportEndDate - <value of component> * <component>`.
    ///
    /// Valid components that will be checked for are `year`, `month`, `weekOfYear`, and `day`.
    ///
    /// If there is no component with a non-nil and non-zero value, the behaviour will be equivalent to `ExportSessionStartDate.oldestSample`.
    ///
    /// For example:
    /// - `ExportSessionStartDate.last(DateComponents(year: 2))` will collect the last 2 years of historical data;
    /// - `ExportSessionStartDate.last(DateComponents(month: 18))` will collect the last 18 months of historical data;
    /// - `ExportSessionStartDate.last(DateComponents(year: 2, month: 1))` will collect the last 25 months of historical data.
    case last(DateComponents)
    
    /// The session should use a specific `Date` as its start date.
    case custom(Date)
}


extension ExportSessionStartDate {
    /// The session should, relative to the time it was first created, collect the last `numMonths` of historical Health data.
    public static func last(numMonths: Int) -> Self {
        .last(DateComponents(month: numMonths))
    }
}


extension ExportSessionStartDate {
    func startDate(for sampleType: SampleType<some Any>, in healthKit: HealthKit, relativeTo endDate: Date) async -> Date? {
        switch self {
        case .oldestSample:
            return try? await healthKit.oldestSampleDate(for: sampleType)
        case .last(let dateComponents):
            let componentsToCheck: [Calendar.Component] = [.year, .month, .weekOfYear, .day]
            guard componentsToCheck.contains(where: { dateComponents.value(for: $0) ?? 0 != 0 }) else {
                return try? await healthKit.oldestSampleDate(for: sampleType)
            }
            return Calendar.current.date(byAdding: dateComponents.negated(), to: endDate)
        case .custom(let date):
            return date
        }
    }
}


// MARK: Utils

extension SignedNumeric {
    func negated() -> Self {
        var copy = self
        copy.negate()
        return copy
    }
}

extension DateComponents {
    func negated() -> DateComponents {
        DateComponents(
            calendar: calendar,
            timeZone: timeZone,
            era: era?.negated(),
            year: year?.negated(),
            month: month?.negated(),
            day: day?.negated(),
            hour: hour?.negated(),
            minute: minute?.negated(),
            second: second?.negated(),
            nanosecond: nanosecond?.negated(),
            weekday: weekday?.negated(),
            weekdayOrdinal: weekdayOrdinal?.negated(),
            quarter: quarter?.negated(),
            weekOfMonth: weekOfMonth?.negated(),
            weekOfYear: weekOfYear?.negated(),
            yearForWeekOfYear: yearForWeekOfYear?.negated()
        )
    }
}
