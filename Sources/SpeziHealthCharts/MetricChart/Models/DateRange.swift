//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


public enum DateRange: Equatable {
    case day(start: Date)
    case week(start: Date)
    case month(start: Date)
    case sixMonths(start: Date)
    case year(start: Date)
    
    
    public var interval: DateInterval {
        DateInterval(start: .now, duration: 60*60*24)
    }
}
