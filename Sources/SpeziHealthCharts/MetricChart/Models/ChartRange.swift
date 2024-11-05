//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A `ChartRange` is the date domain of the x-axis of a `HealthChart`.
public struct ChartRange: Sendable, Equatable {
    var start: Date
    var end: Date
    var granularity: Calendar.Component
    
    
    var interval: DateInterval {
        DateInterval(start: start, end: end)
    }
    
    
    public init(start: Date, end: Date, granularity: Calendar.Component) {
        self.start = start
        self.end = end
        self.granularity = granularity
    }
    
    
    /// The last 24 hours relative to the current time, with a granularity of `.hour`.
    public static let day: ChartRange = {
        let now = Date()
        return ChartRange(start: now.addingTimeInterval(-60 * 60 * 24), end: now, granularity: .hour)
    }()
    
    /// The last 7 days relative to the current time, with a granularity of `.day`.
    public static let week: ChartRange = {
        let now = Date()
        return ChartRange(start: now.addingTimeInterval(-60 * 60 * 24 * 7), end: now, granularity: .day)
    }()
    
    /// The last 30 days relative to the current time, with a granularity of `.day`.
    public static let month: ChartRange = {
        let now = Date()
        return ChartRange(start: now.addingTimeInterval(-60 * 60 * 24 * 30), end: now, granularity: .day)
    }()
    
    /// The last 180 days (approximately six months) relative to the current time, with a granularity of `.weekOfYear`.
    public static let sixMonths: ChartRange = {
        let now = Date()
        return ChartRange(start: now.addingTimeInterval(-60 * 60 * 24 * 180), end: now, granularity: .weekOfYear)
    }()
    
    /// The last 365 days relative to the current time, with a granularity of `.month`.
    public static let year: ChartRange = {
        let now = Date()
        return ChartRange(start: now.addingTimeInterval(-60 * 60 * 24 * 365), end: now, granularity: .month)
    }()
}
