//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import Foundation


/// How an ``BulkExportSession`` should size its batches within each sample type.
public enum ExportSessionBatchSize: Hashable, Codable, Sendable {
    /// The export session should, based on the sample type being exported, auto-select a suitable batch size.
    ///
    /// This is the recommended option, since it allows for the greatest possible efficiency w.r.t. resource usage and performance.
    case automatic
    /// The export session should, for every sample type, create one batch for every range of the specified calendar component,  within the total time range for which data is being exported.
    ///
    /// - parameter component: The calendar component on which the batch size should be based
    /// - parameter multiplier: How many instances of the component the batch should span.
    ///     For example, `.calendarComponent(.week, multiplier: 2)` would result in each batch covering two weeks.
    case calendarComponent(_ component: Calendar.ComponentForIteration, multiplier: Int = 1)
    
    /// The export session should, for every sample type, create one batch for every year of data being exported.
    public static var byYear: Self {
        .calendarComponent(.year)
    }
    /// The export session should, for every sample type, create one batch for every month of data being exported.
    public static var byMonth: Self {
        .calendarComponent(.month)
    }
}
