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
    let sessionId: BulkExportSessionIdentifier
    let exportEndDate: Date
    var pendingBatches: [ExportBatch]
    var completedBatches: [ExportBatch]
    
    init(sessionId: BulkExportSessionIdentifier, exportEndDate: Date, sampleTypes: SampleTypesCollection, using healthKit: HealthKit) async {
        self.sessionId = sessionId
        self.exportEndDate = exportEndDate
        self.completedBatches = []
        self.pendingBatches = []
        for sampleType in sampleTypes {
            await add(sampleType: sampleType, healthKit: healthKit)
        }
    }
    
    mutating func add<Sample>(sampleType: some AnySampleType<Sample>, healthKit: HealthKit) async {
        let sampleType = SampleType(sampleType)
        guard !(pendingBatches + completedBatches).contains(where: { $0.sampleType == sampleType }) else {
            // we have at least one scheduled or already-completed batch with this sample type
            // --> nothing to be done; we're already handling it.
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
    
    /// Resets the `result` of all failed batches to `nil`, so that they will be retried by the ``BulkExportSession``.
    mutating func unmarkAllFailedBatches() {
        assert(completedBatches.allSatisfy { $0.result == .success })
        assert(pendingBatches.allSatisfy { $0.result == nil || ($0.result?.isFailure == true) })
        for idx in pendingBatches.indices {
            var batch = pendingBatches[idx]
            if let result = batch.result, result.isFailure {
                batch.result = nil
            }
            pendingBatches[idx] = batch
        }
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
