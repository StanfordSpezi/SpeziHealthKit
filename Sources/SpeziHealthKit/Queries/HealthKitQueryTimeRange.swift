//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import class HealthKit.HKQuery
import SpeziFoundation


/// The time range for which data should be fetched from the health store.
public struct HealthKitQueryTimeRange: Sendable {
    public let range: ClosedRange<Date>
    
    public var duration: TimeInterval {
        range.lowerBound.distance(to: range.upperBound)
    }
    
    public init(_ range: ClosedRange<Date>) {
        self.range = range
    }
    
    public init(_ range: Range<Date>) {
        self.init(range.lowerBound...range.upperBound.addingTimeInterval(-1))
    }
}


extension HealthKitQueryTimeRange {
    /// An `NSPredicate` that matches all samples which fall into the time range.
    ///
    /// - Note: A `nil` value means that no predicate is needed. This would be equivalent to a predicate that always returns `true`.
    public var predicate: NSPredicate? {
        if self == .ever {
            nil
        } else {
            HKQuery.predicateForSamples(
                withStart: range.lowerBound,
                end: range.upperBound,
                options: [.strictStartDate, .strictEndDate]
            )
        }
    }
    
    /// An `NSPredicate` which matches all samples that start after the time range's lower bound.
    ///
    /// - Note: This predicate will completely ignore the time range's end date.
    ///
    /// - Note: A `nil` value means that no predicate is needed. This would be equivalent to a predicate that always returns `true`.
    public var lowerBoundPredicate: NSPredicate? {
        if range.lowerBound == .distantPast {
            nil
        } else {
            HKQuery.predicateForSamples(
                withStart: range.lowerBound,
                end: nil,
                options: [.strictStartDate]
            )
        }
    }
}


extension HealthKitQueryTimeRange: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.range == rhs.range
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(range)
    }
}


extension HealthKitQueryTimeRange: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.duration < rhs.duration
    }
}


extension HealthKitQueryTimeRange {
    /// The time range containing the current hour.
    public static var currentHour: Self {
        .init(Calendar.current.rangeOfHour(for: .now))
    }
    /// The time range containing all of today.
    public static var today: Self {
        .init(Calendar.current.rangeOfDay(for: .now))
    }
    
    /// The time range encompassing the entire current week.
    public static var currentWeek: Self {
        .init(Calendar.current.rangeOfWeek(for: .now))
    }
    
    /// The time range encompassing the entire current month.
    public static var currentMonth: Self {
        .init(Calendar.current.rangeOfMonth(for: .now))
    }
    
    /// The time range encompassing the entire current year.
    public static var currentYear: Self {
        .init(Calendar.current.rangeOfYear(for: .now))
    }
    
    /// The time range encompassing all of time.
    public static var ever: Self {
        .init(Date.distantPast..<Date.distantFuture)
    }
    
    /// The time range encompassing the last `N` hours, starting at the end of the current hour.
    public static func last(hours: Int) -> Self {
        lastXImp(.hour, startOfComponentFn: Calendar.startOfHour, numUnits: hours)
    }
    
    /// The time range encompassing the last `N` days, starting at the end of the current day.
    /// - Note: the resulting effective time range of `lastNDays(1)` is equivalent to the one of `today`.
    public static func last(days: Int) -> Self {
        lastXImp(.day, startOfComponentFn: Calendar.startOfDay, numUnits: days)
    }
    
    /// The time range encompassing the last `N` weeks, starting at the end of the current week.
    public static func last(weeks: Int) -> Self {
        lastXImp(.weekOfYear, startOfComponentFn: Calendar.startOfWeek, numUnits: weeks)
    }
    
    /// The time range encompassing the last `N` months, starting at the end of the current month.
    public static func last(months: Int) -> Self {
        lastXImp(.month, startOfComponentFn: Calendar.startOfMonth, numUnits: months)
    }
    
    /// The time range encompassing the last `N` years, starting at the end of the current year.
    public static func last(years: Int) -> Self {
        lastXImp(.year, startOfComponentFn: Calendar.startOfYear, numUnits: years)
    }
    
    
    private static func lastXImp(
        _ component: Calendar.Component,
        startOfComponentFn: (Calendar) -> (Date) -> Date,
        numUnits: Int
    ) -> Self {
        guard numUnits >= 1 else {
            preconditionFailure("Invalid input: numUnits = \(numUnits); must be >= 1")
        }
        let cal = Calendar.current
        let startDate = tryUnwrap(
            cal.date(
                byAdding: component,
                value: -(numUnits - 1),
                to: startOfComponentFn(cal)(.now)
            ),
            "Unable to compute start date"
        )
        let endDate = tryUnwrap(
            cal.date(
                byAdding: component,
                value: 1,
                to: startOfComponentFn(cal)(.now)
            ),
            "Unable to compute end date"
        )
        return .init(startDate..<endDate)
    }
    
    
    private static func tryUnwrap<T>(_ value: T?, _ message: String) -> T {
        if let value {
            return value
        } else {
            preconditionFailure(message)
        }
    }
}
