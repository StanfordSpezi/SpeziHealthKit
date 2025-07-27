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
    let startDate: ExportSessionStartDate
    let endDate: Date
    var pendingBatches: [ExportBatch]
    var completedBatches: [ExportBatch]
    
    init(
        sessionId: BulkExportSessionIdentifier,
        startDate: ExportSessionStartDate,
        endDate: Date
    ) {
        self.sessionId = sessionId
        self.startDate = startDate
        self.endDate = endDate
        self.pendingBatches = []
        self.completedBatches = []
    }
    
    mutating func add<Sample>(sampleType: some AnySampleType<Sample>, batchSize: ExportSessionBatchSize, healthKit: HealthKit) async {
        await add(sampleType: SampleType(sampleType), batchSize: batchSize, healthKit: healthKit)
    }
    
    mutating func add<Sample>(sampleType: SampleType<Sample>, batchSize: ExportSessionBatchSize, healthKit: HealthKit) async {
        let sampleType = SampleType(sampleType)
        guard !(pendingBatches + completedBatches).contains(where: { $0.sampleType == sampleType }) else {
            // we have at least one scheduled or already-completed batch with this sample type
            // --> nothing to be done; we're already handling it.
            return
        }
        let cal = Calendar.current
        let startDate: Date = await startDate.startDate(for: sampleType, in: healthKit, relativeTo: self.endDate) ?? {
            // if we can't determine the oldest sample date, we use the day HealthKit was introduced as our fallback
            // Note: it could be that there's no oldest sample date because there are no samples for the sample type,
            // but it could also be the case that the fetch itself simply failed.
            cal.date(from: .init(year: 2014, month: 6, day: 2))! // swiftlint:disable:this force_unwrapping
        }()
        let batchTimeRanges: [Range<Date>]
        switch Self.resolveBatchSize(batchSize, for: sampleType) {
        case .automatic:
            // guaranteed to be unreachable by resolveBatchSize()
            fatalError("unreachable")
        case let .calendarComponent(component, multiplier):
            batchTimeRanges = Array(cal.ranges(
                of: component,
                multiplier: multiplier,
                startingAt: startDate,
                in: startDate..<endDate,
                clampToLimits: true
            ))
        }
        pendingBatches.append(contentsOf: batchTimeRanges.map { timeRange in
            ExportBatch(sampleType: sampleType, timeRange: timeRange)
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


extension ExportSessionDescriptor {
    /// Determines a resolved batch size, based on an input batch size and a sample type.
    ///
    /// Guaranteed to not return ``ExportSessionBatchSize/automatic``.
    private static func resolveBatchSize(_ batchSize: ExportSessionBatchSize, for sampleType: SampleType<some Any>) -> ExportSessionBatchSize {
        switch batchSize {
        case .automatic:
            switch sampleType {
            case SampleType.activeEnergyBurned, SampleType.basalEnergyBurned, SampleType.heartRate,
                SampleType.distanceWalkingRunning, SampleType.physicalEffort, SampleType.stepCount:
                .byMonth
            default:
                .calendarComponent(.month, multiplier: 6)
            }
        case .calendarComponent:
            batchSize
        }
    }
}


// MARK: Utils

extension Calendar {
    func isWholeYear(_ range: Range<Date>) -> Bool {
        rangeOfYear(for: range.lowerBound) == range
    }
    
    func isWholeMonth(_ range: Range<Date>) -> Bool {
        rangeOfMonth(for: range.lowerBound) == range
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
