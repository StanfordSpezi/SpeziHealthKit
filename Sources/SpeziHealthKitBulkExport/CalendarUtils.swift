//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFoundation


extension Calendar {
    /// The subset of `Calendar.Component`s that can be used with date range iteration APIs.
    public enum ComponentForIteration: Hashable, Sendable, Codable {
        case year, month, week, day, hour
    }
    
    /// Returns a `Date` which represents the start of the
    func start(of component: ComponentForIteration, for date: Date) -> Date {
        switch component {
        case .year:
            startOfYear(for: date)
        case .month:
            startOfMonth(for: date)
        case .week:
            startOfWeek(for: date)
        case .day:
            startOfDay(for: date)
        case .hour:
            startOfHour(for: date)
        }
    }
}

extension Calendar.Component {
    init(_ other: Calendar.ComponentForIteration) {
        switch other {
        case .year:
            self = .year
        case .month:
            self = .month
        case .week:
            self = .weekOfYear
        case .day:
            self = .day
        case .hour:
            self = .hour
        }
    }
}


// MARK: Date Ranges

extension Calendar {
    func ranges(
        of component: ComponentForIteration,
        multiplier: Int = 1,
        startingAt start: Date,
        in limitRange: Range<Date>,
        clampToLimits: Bool
    ) -> some Sendable & Sequence<Range<Date>> {
        precondition(multiplier >= 1, "Invalid multiplier value")
        struct Iterator: IteratorProtocol, Sendable {
            typealias Element = Range<Date>
            let cal: Calendar
            let componentsToAdd: DateComponents
            let limitRange: Range<Date>
            let clampToLimits: Bool
            var nextLowerBound: Date?
            
            mutating func next() -> Range<Date>? {
                guard let lowerBound = nextLowerBound else {
                    return nil
                }
                guard let upperBound = cal.date(byAdding: componentsToAdd, to: lowerBound) else {
                    return nil
                }
                let range = lowerBound..<upperBound
                if upperBound >= limitRange.upperBound {
                    nextLowerBound = nil
                } else {
                    nextLowerBound = upperBound
                }
                return clampToLimits ? range.clamped(to: limitRange) : range
            }
        }
        let iterator = Iterator(
            cal: self,
            componentsToAdd: {
                var components = DateComponents()
                components.setValue(multiplier, for: .init(component))
                return components
            }(),
            limitRange: limitRange,
            clampToLimits: clampToLimits,
            nextLowerBound: self.start(of: component, for: start)
        )
        return IteratorSequence(iterator)
    }
}
