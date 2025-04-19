//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziHealthKit


/// A Batch within a ``BulkExportSession``.
public struct ExportBatch: Codable, Sendable {
    private enum CodingKeys: CodingKey {
        case sampleType
        case timeRange
        case result
    }
    
    public enum Result: Hashable, Codable, Sendable {
        case success
        case failure(errorDescription: String) // can't be an `any Error` bc it needs to be Codable
        
        var isFailure: Bool {
            switch self {
            case .failure: true
            case .success: false
            }
        }
    }
    
    /// The batch's sample type.
    public let sampleType: any AnySampleType
    /// The batch's time range.
    public let timeRange: Range<Date>
    /// The batch's processing result.
    ///
    /// This value is `nil` for batches that haven't yet been processed, and ``Result-swift.enum/success`` or ``Result-swift.enum/failure(errorDescription:)`` for batches that have.
    public internal(set) var result: Result?
    
    init(sampleType: any AnySampleType, timeRange: Range<Date>) {
        self.sampleType = sampleType
        self.timeRange = timeRange
        self.result = nil
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sampleType = try container.decode(WrappedSampleType.self, forKey: .sampleType).underlyingSampleType
        self.timeRange = try container.decode(Range<Date>.self, forKey: .timeRange)
        self.result = try container.decode(Result?.self, forKey: .result)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(WrappedSampleType(sampleType), forKey: .sampleType)
        try container.encode(timeRange, forKey: .timeRange)
        try container.encode(result, forKey: .result)
    }
}


extension ExportBatch {
    private static let monthAndYearFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        return fmt
    }()
    
    /// A textual description of the batch, suitable for user-visible display.
    public var userDisplayedDescription: String {
        let cal = Calendar.current
        var desc = "\(sampleType.displayTitle) "
        if cal.isWholeYear(timeRange) {
            desc += "(\(cal.component(.year, from: timeRange.lowerBound)))"
        } else if cal.isWholeMonth(timeRange) {
            desc += "(\(Self.monthAndYearFormatter.string(from: timeRange.lowerBound)))"
        } else {
            let start = DateFormatter.localizedString(from: timeRange.lowerBound, dateStyle: .short, timeStyle: .none)
            let end = DateFormatter.localizedString(from: timeRange.upperBound.advanced(by: -1), dateStyle: .short, timeStyle: .none)
            desc += "(\(start) – \(end))"
        }
        return desc
    }
}


extension ExportBatch: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.sampleType == rhs.sampleType && lhs.timeRange == rhs.timeRange && lhs.result == rhs.result
    }
    
    public func hash(into hasher: inout Hasher) {
        sampleType.hash(into: &hasher)
        hasher.combine(timeRange)
        hasher.combine(result)
    }
}
