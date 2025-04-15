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
import os
import Spezi
import SpeziFoundation
import SpeziLocalStorage


extension BulkHealthExporter {
    /// State of a ``Session``
    public enum ExportSessionState: Hashable, Sendable {
        /// The session hasn't yet been started.
        case scheduled
        /// The session is currently running.
        case running
        /// The session is currently paused.
        case paused
        /// The session has completed its work, and has nothing else left to do.
        case done
    }
    
    
    public struct ExportSessionProgress: Sendable {
        public fileprivate(set) var currentBatchIdx: Int
        public fileprivate(set) var numTotalBatches: Int
        public fileprivate(set) var currentBatchDescription: String
    }
    
    /// Protocol modeling a type-erased ``Session``
    public protocol ExportSessionProtocol {
        /// The session's unique identifier
        var sessionId: String { get }
        
        @MainActor var progress: ExportSessionProgress? { get }
        
        /// The current state of the export session.
        @MainActor var state: ExportSessionState { get }
        /// Starts the session, unless it is already running
        @MainActor func start()
        /// Pauses the session at the next possible point in time.
        ///
        /// This operation won't necessarily cause the session to get paused immediately.
        /// The session will complete its current block of work, and will only see the `pause()` call before starting the next work block.
        @MainActor func pause()
    }
}


extension BulkHealthExporter {
    public protocol BatchProcessor<Output>: Sendable {
        associatedtype Output
        func process<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) async throws -> Output
    }
    
    
    private struct ExportSessionDescriptor: Codable {
        struct ExportBatch: Codable {
            let sampleType: WrappedSampleType
            let timeRange: Range<Date>
            /// Whether this batch should be skipped for the remainder of the current lifetime of the session, i.e. until the next time the app is launched.
            var shouldSkipUntilNextLaunch: Bool
            
            var userDisplayedDescription: String {
                let cal = Calendar.current
                var desc = "\(sampleType.underlyingSampleType.displayTitle)"
                if cal.isWholeYear(timeRange) {
                    desc += " (\(cal.component(.year, from: timeRange.lowerBound)))"
                } else {
                    let start = DateFormatter.localizedString(from: timeRange.lowerBound, dateStyle: .short, timeStyle: .none)
                    let end = DateFormatter.localizedString(from: timeRange.upperBound, dateStyle: .short, timeStyle: .none)
                    desc += "(\(start) – \(end))"
                }
                return desc
            }
            
            init(sampleType: WrappedSampleType, timeRange: Range<Date>) {
                self.sampleType = sampleType
                self.timeRange = timeRange
                self.shouldSkipUntilNextLaunch = false
            }
        }
        
        let sessionId: String
        let exportEndDate: Date
        var pendingBatches: [ExportBatch]
        var completedSampleTypes: [WrappedSampleType]
        var numCompletedExportBatches: Int
        
        init(sessionId: String, exportEndDate: Date, sampleTypes: Set<WrappedSampleType>, using healthKit: HealthKit) async {
            self.sessionId = sessionId
            self.exportEndDate = exportEndDate
            self.completedSampleTypes = []
            self.pendingBatches = []
            self.numCompletedExportBatches = 0
            for sampleType in sampleTypes {
                await add(sampleType: sampleType, healthKit: healthKit)
            }
        }
        
        mutating func add(sampleType: WrappedSampleType, healthKit: HealthKit) async {
            guard !(completedSampleTypes.contains(sampleType) || pendingBatches.contains { $0.sampleType == sampleType }) else {
                // we've either already marked the sample type as completed, or have it already scheduled
                // --> nothing to be done
                return
            }
            let cal = Calendar(identifier: .gregorian)
            let endDate = self.exportEndDate
            let startDate: Date = (try? await sampleType.oldestSampleDate(in: healthKit)) ?? {
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
    
    
    @Observable
    public final class Session<Processor: BatchProcessor>: Sendable, ExportSessionProtocol {
        typealias BatchResultHandler = @Sendable (Processor.Output) async -> Bool
        
        public let sessionId: String
        private unowned let bulkExporter: BulkHealthExporter
        private unowned let healthKit: HealthKit
        @ObservationIgnored private let batchProcessor: Processor
        @ObservationIgnored private let localStorage: LocalStorage
        @ObservationIgnored private let localStorageKey: LocalStorageKey<ExportSessionDescriptor>
        @ObservationIgnored private let batchResultHandler: BatchResultHandler
        @ObservationIgnored @MainActor private var descriptor: ExportSessionDescriptor {
            didSet {
//                try? localStorage.store(descriptor, for: localStorageKey)
            }
        }
        @ObservationIgnored @MainActor private var task: Task<Void, Never>?
        @MainActor public private(set) var state: BulkHealthExporter.ExportSessionState = .scheduled
        @MainActor public private(set) var progress: ExportSessionProgress?
        
        @MainActor
        internal init(
            sessionId: String,
            bulkExporter: BulkHealthExporter,
            healthKit: HealthKit,
            sampleTypes: Set<WrappedSampleType>,
            localStorage: LocalStorage,
            batchProcessor: Processor,
            batchResultHandler: @escaping BatchResultHandler
        ) async throws {
            self.sessionId = sessionId
            self.bulkExporter = bulkExporter
            self.healthKit = healthKit
            self.batchProcessor = batchProcessor
            self.batchResultHandler = batchResultHandler
            self.localStorage = localStorage
            self.localStorageKey = LocalStorageKey(BulkHealthExporter.localStorageKey(forSessionId: sessionId))
            if let descriptor = try localStorage.load(localStorageKey) {
                self.descriptor = descriptor
                for idx in self.descriptor.pendingBatches.indices {
                    self.descriptor.pendingBatches[idx].shouldSkipUntilNextLaunch = false
                }
            } else {
                self.descriptor = await ExportSessionDescriptor(
                    sessionId: sessionId,
                    exportEndDate: Date(),
                    sampleTypes: sampleTypes,
                    using: healthKit
                )
            }
        }
    }
}

extension BulkHealthExporter.Session {
    @MainActor
    public func start() { // swiftlint:disable:this function_body_length
        let logger = self.bulkExporter.logger
        let healthKit = self.healthKit
        let batchProcessor = self.batchProcessor
        let batchResultHandler = self.batchResultHandler
        guard task == nil || task?.isCancelled == true else {
            // is already running
            return
        }
        state = .running
        task = Task.detached { // swiftlint:disable:this closure_body_length
            var numTotalBatches = await self.descriptor.pendingBatches.count(where: { !$0.shouldSkipUntilNextLaunch })
            var numCompletedBatches = 0
            let popBatchAndScheduleForRetry = { @MainActor in
                var batch = self.descriptor.pendingBatches.removeFirst()
                batch.shouldSkipUntilNextLaunch = true
                numTotalBatches -= 1
                self.descriptor.pendingBatches.append(batch)
            }
            loop: while let batch = await self.descriptor.pendingBatches.first {
                guard !Task.isCancelled else {
                    await MainActor.run {
                        self.state = .paused
                    }
                    break loop
                }
                guard !batch.shouldSkipUntilNextLaunch else {
                    if let idx = await self.descriptor.pendingBatches.firstIndex(where: { !$0.shouldSkipUntilNextLaunch }) {
                        // if there is at least one not-to-be-skipped batch, bring it to the front and continue the loop, to handle it next.
                        await MainActor.run {
                            self.descriptor.pendingBatches.swapAt(idx, self.descriptor.pendingBatches.startIndex)
                        }
                        continue loop
                    } else {
                        break loop
                    }
                }
                let result: Processor.Output
                do {
                    await MainActor.run {
                        self.progress = .init(
                            currentBatchIdx: numCompletedBatches + 1,
                            numTotalBatches: numTotalBatches,
                            currentBatchDescription: batch.userDisplayedDescription
                        )
                    }
                    result = try await batch.sampleType.queryAndProcess(timeRange: batch.timeRange, in: healthKit, using: batchProcessor)
                } catch let error as WrappedSampleType.QueryAndProcessError {
                    logger.error("Failed to query and process batch \(String(describing: batch)): \(String(describing: error))")
                    await popBatchAndScheduleForRetry()
                    continue loop
                } catch {
                    fatalError("unreachable")
                }
                if await batchResultHandler(result) {
                    await MainActor.run {
                        _ = self.descriptor.pendingBatches.removeFirst()
                        numCompletedBatches += 1
                    }
                } else {
                    // failed
                    await popBatchAndScheduleForRetry()
                }
            }
            await MainActor.run {
                self.task = nil
                if self.state != .paused {
                    self.state = .done
                }
            }
        }
    }
    
    @MainActor
    public func pause() {
        switch state {
        case .scheduled, .paused, .done:
            return
        case .running:
            break
        }
        task?.cancel()
    }
}


extension BulkHealthExporter.ExportSessionProtocol {
    /// Whether the session is currently running.
    ///
    /// Note that this property being `false` does not mean that the session hasn't done anything
    @MainActor public var isRunning: Bool {
        switch state {
        case .running:
            true
        case .scheduled, .paused, .done:
            false
        }
    }
}


// MARK: Utils

extension WrappedSampleType {
    fileprivate enum QueryAndProcessError: Error {
        case query(any Error)
        case process(any Error)
    }
    
    fileprivate func oldestSampleDate(in healthKit: HealthKit) async throws -> Date? {
        func imp<Sample>(_ sampleType: some AnySampleType<Sample>) async throws -> Date? {
            let sampleType = SampleType(sampleType)
            return try await healthKit.oldestSampleDate(for: sampleType)
        }
        return try await imp(self.underlyingSampleType)
    }
    
    fileprivate func queryAndProcess<Processor: BulkHealthExporter.BatchProcessor>(
        timeRange: Range<Date>,
        in healthKit: HealthKit,
        using batchProcessor: borrowing Processor
    ) async throws(QueryAndProcessError) -> Processor.Output {
        func imp<Sample>(_ sampleType: some AnySampleType<Sample>) async throws(QueryAndProcessError) -> Processor.Output {
            let sampleType = SampleType(sampleType)
            let samples: [Sample]
            do {
                samples = try await healthKit.query(sampleType, timeRange: .init(timeRange))
            } catch {
                throw .query(error)
            }
            do {
                return try await batchProcessor.process(samples, of: sampleType)
            } catch {
                throw .process(error)
            }
        }
        return try await imp(self.underlyingSampleType)
    }
}


// MARK: Batch Processors

public struct IdentityBatchProcessor: BulkHealthExporter.BatchProcessor {
    public typealias Output = [HKSample]
    
    public func process<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) -> [HKSample] {
        samples
    }
}

extension BulkHealthExporter.BatchProcessor where Self == IdentityBatchProcessor {
    /// A Batch Processor that simply returns the unprocessed samples.
    public static var identity: some BulkHealthExporter.BatchProcessor<[HKSample]> {
        IdentityBatchProcessor()
    }
}


// MARK: Utils

extension Calendar {
    func isWholeYear(_ range: Range<Date>) -> Bool {
        rangeOfYear(for: range.lowerBound) == range
    }
}
