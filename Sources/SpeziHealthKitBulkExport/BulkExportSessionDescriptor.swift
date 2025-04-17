//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import Foundation
import HealthKit
import Spezi
import SpeziFoundation
import SpeziHealthKit
import SpeziLocalStorage


/// The ``ExportSessionDescriptor`` serves as the `Codable` representation of a ``ExportSession``, and is used to restore a previously-created session's state across multiple app launches.
///
/// It keeps track of the session's identity, and the stores the individual batches that need to be processed as part of the session.
/// It also keeps track of the already-completed sample types, to prevent unnecessary duplicates when exporting.
struct ExportSessionDescriptor: Codable {
    struct ExportBatch: Codable {
        private enum CodingKeys: CodingKey {
            case sampleType
            case timeRange
            case shouldSkipUntilNextLaunch
        }
        
        let sampleType: any AnySampleType
        let timeRange: Range<Date>
        /// Whether this batch should be skipped for the remainder of the current lifetime of the session, i.e. until the next time the app is launched.
        var shouldSkipUntilNextLaunch: Bool
        
        var userDisplayedDescription: String {
            let cal = Calendar.current
            var desc = "\(sampleType.displayTitle)"
            if cal.isWholeYear(timeRange) {
                desc += " (\(cal.component(.year, from: timeRange.lowerBound)))"
            } else {
                let start = DateFormatter.localizedString(from: timeRange.lowerBound, dateStyle: .short, timeStyle: .none)
                let end = DateFormatter.localizedString(from: timeRange.upperBound.advanced(by: -1), dateStyle: .short, timeStyle: .none)
                desc += "(\(start) – \(end))"
            }
            return desc
        }
        
        init(sampleType: any AnySampleType, timeRange: Range<Date>) {
            self.sampleType = sampleType
            self.timeRange = timeRange
            self.shouldSkipUntilNextLaunch = false
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.sampleType = try container.decode(WrappedSampleType.self, forKey: .sampleType).underlyingSampleType
            self.timeRange = try container.decode(Range<Date>.self, forKey: .timeRange)
            self.shouldSkipUntilNextLaunch = try container.decode(Bool.self, forKey: .shouldSkipUntilNextLaunch)
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(WrappedSampleType(sampleType), forKey: .sampleType)
            try container.encode(timeRange, forKey: .timeRange)
            try container.encode(shouldSkipUntilNextLaunch, forKey: .shouldSkipUntilNextLaunch)
        }
    }
    
    let sessionId: String
    let exportEndDate: Date
    var pendingBatches: [ExportBatch]
    var completedSampleTypes: SampleTypesCollection
    var numCompletedExportBatches: Int
    
    init(sessionId: String, exportEndDate: Date, sampleTypes: SampleTypesCollection, using healthKit: HealthKit) async {
        self.sessionId = sessionId
        self.exportEndDate = exportEndDate
        self.completedSampleTypes = .init()
        self.pendingBatches = []
        self.numCompletedExportBatches = 0
        for sampleType in sampleTypes {
            await add(sampleType: sampleType, healthKit: healthKit)
        }
    }
    
    mutating func add<Sample>(sampleType: some AnySampleType<Sample>, healthKit: HealthKit) async {
        let sampleType = SampleType(sampleType)
        guard !(completedSampleTypes.contains(sampleType) || pendingBatches.contains { $0.sampleType == sampleType }) else {
            // we've either already marked the sample type as completed, or have it already scheduled
            // --> nothing to be done
            return
        }
        let cal = Calendar(identifier: .gregorian)
        let endDate = self.exportEndDate
        let startDate: Date = (try? await healthKit.oldestSampleDate(for: sampleType)) ?? {
            // if we can't determine the oldest sample date, we use the day HealthKit was introduced as our fallback
            // Note: it could be that there's no oldest sample date because there are no samples for the sample type,
            // but it could also be the case that the fetch itself simply failed.
            cal.date(from: .init(year: 2014, month: 6, day: 2))! // swiftlint:disable:this force_unwrapping
        }()
        let yearRanges = sequence(first: cal.rangeOfYear(for: startDate)) {
            $0.contains(endDate) || $0.lowerBound >= endDate ? nil : cal.rangeOfYear(for: cal.startOfNextYear(for: $0.lowerBound))
        }
        pendingBatches.append(contentsOf: yearRanges.map { year in
            ExportBatch(sampleType: sampleType, timeRange: year)
        })
    }
}


// MARK: Utils

extension Calendar {
    func isWholeYear(_ range: Range<Date>) -> Bool {
        rangeOfYear(for: range.lowerBound) == range
    }
}


// MARK: Default Batch Processors

/// Batch Processor that simply passes through the unchanged samples.
public struct IdentityBatchProcessor: BatchProcessor {
    public typealias Output = [HKSample]
    
    public func process<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) -> [HKSample] {
        samples
    }
}

extension BatchProcessor where Self == IdentityBatchProcessor {
    /// A Batch Processor that simply returns the unprocessed samples.
    public static var identity: some BatchProcessor<[HKSample]> {
        IdentityBatchProcessor()
    }
}
