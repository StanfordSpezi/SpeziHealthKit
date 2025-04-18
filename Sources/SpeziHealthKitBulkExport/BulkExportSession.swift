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
import SpeziHealthKit
import SpeziLocalStorage


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
public final class BulkExportSession<Processor: BatchProcessor>: Sendable, BulkExportSessionProtocol {
    typealias BatchResultHandler = @Sendable (Processor.Output) async -> Void
    public typealias Processor = Processor
    
    public let sessionId: BulkExportSessionIdentifier
    private unowned let bulkExporter: BulkHealthExporter
    private unowned let healthKit: HealthKit
    @ObservationIgnored private let batchProcessor: Processor
    @ObservationIgnored private let localStorage: LocalStorage
    @ObservationIgnored private let localStorageKey: LocalStorageKey<ExportSessionDescriptor>
    @ObservationIgnored private let batchResultHandler: BatchResultHandler
    @MainActor private var descriptor: ExportSessionDescriptor {
        didSet {
            try? localStorage.store(descriptor, for: localStorageKey)
        }
    }
    @ObservationIgnored @MainActor private var task: Task<Void, Never>?
    @MainActor public private(set) var state: BulkExportSessionState = .paused
    @MainActor public private(set) var progress: BulkExportSessionProgress?
    
    @MainActor public var pendingBatches: [ExportBatch] {
        descriptor.pendingBatches.filter { $0.result?.isFailure != true }
    }
    @MainActor public var completedBatches: [ExportBatch] {
        descriptor.completedBatches
    }
    @MainActor public var failedBatches: [ExportBatch] {
        descriptor.pendingBatches.filter { $0.result?.isFailure == true }
    }
    @MainActor public var numTotalBatches: Int {
        descriptor.pendingBatches.count + descriptor.completedBatches.count
    }
    
    @MainActor
    internal init(
        sessionId: BulkExportSessionIdentifier,
        bulkExporter: BulkHealthExporter,
        healthKit: HealthKit,
        sampleTypes: SampleTypesCollection,
        startDate: ExportSessionStartDate,
        endDate: Date,
        batchSize: ExportSessionBatchSize,
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
            // when restoring a previously-persisted session, we want to "reset" all failed batches, so that everything is processed again.
            // this is fine, because we only end up in here (in the ExportSession init) once per session per app lifecycle.
            // (once the session has been created, any further calls to BulkExporter.session() will return the previously-created Session.)
            for idx in self.descriptor.pendingBatches.indices {
                switch self.descriptor.pendingBatches[idx].result {
                case nil, .success:
                    break
                case .failure:
                    self.descriptor.pendingBatches[idx].result = nil
                }
            }
        } else {
            // if there's no persisted state for this session identifier, we create a new descriptor,
            // which will operate on all samples created up until right now.
            self.descriptor = await ExportSessionDescriptor(
                sessionId: sessionId,
                startDate: startDate,
                endDate: endDate,
                batchSize: batchSize,
                sampleTypes: sampleTypes,
                using: healthKit
            )
        }
    }
}


extension BulkExportSession {
    @MainActor
    public func start(retryFailedBatches: Bool = false) { // swiftlint:disable:this function_body_length missing_docs cyclomatic_complexity
        let logger = self.bulkExporter.logger
        let batchResultHandler = self.batchResultHandler
        guard task == nil || task?.isCancelled == true else {
            // is already running
            return
        }
        state = .running
        task = Task.detached { // swiftlint:disable:this closure_body_length
            if retryFailedBatches {
                await MainActor.run {
                    self.descriptor.unmarkAllFailedBatches()
                }
            }
            let numTotalBatches = await self.descriptor.pendingBatches.count + self.descriptor.completedBatches.count
            var numCompletedBatches = 0
            @MainActor func popBatch(withResult result: Result<Void, any Error>) {
                var batch = self.descriptor.pendingBatches.removeFirst()
                switch result {
                case .success:
                    batch.result = .success
                    self.descriptor.completedBatches.append(batch)
                case .failure(let error):
                    batch.result = .failure(errorDescription: error.localizedDescription)
                    self.descriptor.pendingBatches.append(batch)
                }
            }
            loop: while let batch = await self.descriptor.pendingBatches.first {
                guard !Task.isCancelled else {
                    await MainActor.run {
                        self.state = .paused
                    }
                    break loop
                }
                switch batch.result {
                case .success:
                    // should be unreachable, since we never put completed batches into `pendingBatches`
                    await popBatch(withResult: .success(()))
                    continue loop
                case .failure:
                    // the pending batch at the beginning of the queue is a failed one.
                    // we don't want to retry this one right now, so we'll instead move try to find another non-failed one.
                    if let idx = await self.descriptor.pendingBatches.firstIndex(where: { $0.result == nil }) {
                        // if there is at least one not-to-be-skipped batch, bring it to the front and continue the loop, to handle it next.
                        await MainActor.run {
                            self.descriptor.pendingBatches.swapAt(idx, self.descriptor.pendingBatches.startIndex)
                        }
                        continue loop
                    } else {
                        break loop
                    }
                case nil:
                    // the batch hasn't run yet. we simply continue with the code below
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
                        await popBatch(withResult: .failure(error))
                        continue loop
                    } catch {
                        // SAFETY: this is in fact unreachable: the `queryAndProcess` call above has a typed throw, but the compiler doesn't seem to understand this.
                        fatalError("unreachable")
                    }
                    await batchResultHandler(result)
                    await MainActor.run {
                        popBatch(withResult: .success(()))
                        numCompletedBatches += 1
                    }
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
        case .paused, .done:
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

extension BulkExportSession {
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
