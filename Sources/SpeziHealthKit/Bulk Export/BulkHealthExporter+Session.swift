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
import SpeziLocalStorage


extension BulkHealthExporter {
    /// State of a ``ExportSession``
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
    
    
    /// Information about the current progress of a ``ExportSession``.
    public struct ExportSessionProgress: Sendable {
        /// The index of the batch currently being uploaded.
        ///
        /// - Note: Since this value is intended for usage in user-visible contexts, it is 1-based, i.e., the first batch will have index `1`, the second `2`, and so on.
        public fileprivate(set) var currentBatchIdx: Int
        /// The expected total number of batches, across all sample types that will be processed as part of the current run of the session.
        public fileprivate(set) var numTotalBatches: Int
        /// A textual description of the current batch. This included information such as the batch's sample type and its time range, if applicable.
        public fileprivate(set) var currentBatchDescription: String
    }
    
    
    /// Protocol modeling a type-erased ``ExportSession``
    public protocol ExportSessionProtocol {
        /// The session's unique identifier
        var sessionId: String { get }
        /// The current progress of the session, if it is currently running.
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
    /// Component that receives fetched Health data for processing, as part of a ``BulkHealthExporter/ExportSession``.
    public protocol BatchProcessor<Output>: Sendable {
        /// The type of the processor's output. Should be `Void` if the processor simply consumes the samples.
        associatedtype Output: Sendable
        
        /// Invoked by a ``BulkHealthExporter/ExportSession``, to process a batch of Health samples.
        func process<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) async throws -> Output
    }
    
    
    /// The ``ExportSessionDescriptor`` serves as the `Codable` representation of a ``ExportSession``, and is used to restore a previously-created session's state across multiple app launches.
    ///
    /// It keeps track of the session's identity, and the stores the individual batches that need to be processed as part of the session.
    /// It also keeps track of the already-completed sample types, to prevent unnecessary duplicates when exporting.
    private struct ExportSessionDescriptor: Codable {
        struct ExportBatch: Codable {
            private enum CodingKeys: CodingKey { // swiftlint:disable:this nesting
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
}


extension BulkHealthExporter {
    /// A long-running backgrund exporting task that fetches and processes HealthKit data.
    ///
    /// ## Topics
    /// ### Session Lifecycle Management
    /// - ``start()``
    /// - ``pause()``
    /// ### Session State
    /// - ``isRunning``
    /// - ``state``
    /// - ``progress``
    @Observable
    public final class ExportSession<Processor: BatchProcessor>: Sendable, ExportSessionProtocol {
        typealias BatchResultHandler = @Sendable (Processor.Output) async -> Void
        
        public let sessionId: String
        private unowned let bulkExporter: BulkHealthExporter
        private unowned let healthKit: HealthKit
        @ObservationIgnored private let batchProcessor: Processor
        @ObservationIgnored private let localStorage: LocalStorage
        @ObservationIgnored private let localStorageKey: LocalStorageKey<ExportSessionDescriptor>
        @ObservationIgnored private let batchResultHandler: BatchResultHandler
        @ObservationIgnored @MainActor private var descriptor: ExportSessionDescriptor {
            didSet {
                try? localStorage.store(descriptor, for: localStorageKey)
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
            sampleTypes: SampleTypesCollection,
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
                // when restoring a previously-persisted session, we want to disable all requested skips, so that everything is processed again.
                // this is fine, because we only end up in here (in the ExportSession init) once per session per app lifecycle.
                // (once the session has been created, any further calls to BulkExporter.session() will return the previously-created Session.)
                for idx in self.descriptor.pendingBatches.indices {
                    self.descriptor.pendingBatches[idx].shouldSkipUntilNextLaunch = false
                }
            } else {
                // if there's no persisted state for this session identifier, we create a new descriptor,
                // which will operate on all samples created up until right now.
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


extension BulkHealthExporter.ExportSession {
    @MainActor
    public func start() { // swiftlint:disable:this function_body_length missing_docs
        let logger = self.bulkExporter.logger
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
                            currentBatchIdx: numCompletedBatches + 1, // +1 bc we want it to be user-displayable, ie starting at 1.
                            numTotalBatches: numTotalBatches,
                            currentBatchDescription: batch.userDisplayedDescription
                        )
                    }
                    result = try await self.queryAndProcess(sampleType: batch.sampleType, for: batch.timeRange)
                } catch let error as QueryAndProcessError {
                    logger.error(
                        "Failed to query and process batch \(String(describing: batch)): \(String(describing: error)). Will schedule for retry on next app launch."
                    )
                    await popBatchAndScheduleForRetry()
                    continue loop
                } catch {
                    // SAFETY: this is in fact unreachable: the `queryAndProcess` call above has a typed throw, but the compiler doesn't seem to understand this.
                    fatalError("unreachable")
                }
                await batchResultHandler(result)
                await MainActor.run {
                    _ = self.descriptor.pendingBatches.removeFirst()
                    numCompletedBatches += 1
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
    public func pause() { // swiftlint:disable:this missing_docs
        switch state {
        case .scheduled, .paused, .done:
            return
        case .running:
            break
        }
        task?.cancel()
    }
}


// NOTE: in Swift 6.0.3, we need to place this enum in the global scope, since nesting it in `BulkHealthExporter.ExportSession`
// (where it belongs) will cause the compiler to crash.
// Whatever the actual underlying issue here is, it seems to be fixed in Swift 6.1, so we'll hopefully be able to move this type soon.
private enum QueryAndProcessError: Error, Sendable {
    case query(any Error)
    case process(any Error)
}

extension BulkHealthExporter.ExportSession {
    private nonisolated func queryAndProcess<Sample: _HKSampleWithSampleType>(
        sampleType: some AnySampleType<Sample>,
        for timeRange: Range<Date>
    ) async throws(QueryAndProcessError) -> Processor.Output {
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

extension Calendar {
    func isWholeYear(_ range: Range<Date>) -> Bool {
        rangeOfYear(for: range.lowerBound) == range
    }
}


// MARK: Default Batch Processors

/// Batch Processor that simply passes through the unchanged samples.
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
