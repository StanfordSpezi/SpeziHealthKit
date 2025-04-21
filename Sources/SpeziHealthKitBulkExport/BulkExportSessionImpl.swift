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
@Observable
final class BulkExportSessionImpl<Processor: BatchProcessor>: Sendable, BulkExportSession {
    typealias Processor = Processor
    
    private enum PendingStateChangeRequest {
        case pause(_ completionHandner: () -> Void)
        case terminate(_ completionHandner: () -> Void)
    }
    
    let sessionId: BulkExportSessionIdentifier
    private unowned let bulkExporter: BulkHealthExporter
    private unowned let healthKit: HealthKit
    @ObservationIgnored private let batchProcessor: Processor
    @ObservationIgnored private let localStorage: LocalStorage
    @ObservationIgnored private let localStorageKey: LocalStorageKey<ExportSessionDescriptor>
    @ObservationIgnored @MainActor private var pendingStateChangeRequest: PendingStateChangeRequest?
    
    @MainActor private var descriptor: ExportSessionDescriptor {
        didSet {
            if state != .terminated {
                try? localStorage.store(descriptor, for: localStorageKey)
            }
            updateProgress()
        }
    }
    @ObservationIgnored @MainActor private var task: Task<Void, Never>?
    @MainActor private(set) var state: BulkExportSessionState = .paused {
        willSet {
            if state == .terminated && newValue != .terminated {
                preconditionFailure("Attempted to move already-terminated session back into non-terminated state")
            }
        }
    }
    
    @MainActor var pendingBatches: [ExportBatch] {
        descriptor.pendingBatches.filter { $0.result?.isFailure != true }
    }
    @MainActor var completedBatches: [ExportBatch] {
        descriptor.completedBatches
    }
    @MainActor var failedBatches: [ExportBatch] {
        descriptor.pendingBatches.filter { $0.result?.isFailure == true }
    }
    @MainActor var numTotalBatches: Int {
        descriptor.pendingBatches.count + descriptor.completedBatches.count
    }
    @MainActor var currentBatch: ExportBatch? {
        state == .running ? pendingBatches.first : nil
    }
    
    @MainActor private(set) var progress: Progress?
    
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
        batchProcessor: Processor
    ) async throws {
        self.sessionId = sessionId
        self.bulkExporter = bulkExporter
        self.healthKit = healthKit
        self.batchProcessor = batchProcessor
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


extension BulkExportSessionImpl {
    @MainActor
    private func updateProgress() {
        guard let progress else {
            return
        }
        progress.totalUnitCount = Int64(numTotalBatches)
        progress.completedUnitCount = Int64(completedBatches.count)
        progress.localizedDescription = String(
            localized: "Completed \(completedBatches.count) of \(numTotalBatches) (\(failedBatches.count) failed)"
        )
    }
    
    @MainActor
    func start(retryFailedBatches: Bool = false) throws(StartSessionError) -> AsyncStream<Processor.Output> {
        // swiftlint:disable:previous function_body_length cyclomatic_complexity
        switch state {
        case .running:
            throw .alreadyRunning
        case .completed, .paused:
            break
        case .terminated:
            throw .isTerminated
        }
        let logger = self.bulkExporter.logger
        guard task == nil || task?.isCancelled == true else {
            // is already running
            throw .alreadyRunning
        }
        state = .running
        let (stream, continuation) = AsyncStream.makeStream(of: Processor.Output.self)
        if progress == nil {
            progress = .discreteProgress(totalUnitCount: Int64(numTotalBatches))
            updateProgress()
        }
        task = Task.detached { // swiftlint:disable:this closure_body_length
            if retryFailedBatches {
                await MainActor.run {
                    self.descriptor.unmarkAllFailedBatches()
                }
            }
            @MainActor func popBatch(withResult result: Result<Void, any Error>) {
                var batch = self.descriptor.pendingBatches.removeFirst()
                switch result {
                case .success:
                    batch.result = .success
                    self.descriptor.completedBatches.append(batch)
                case .failure(let error):
                    if error is CancellationError {
                        // If this is a CancellationError, the batch didn't actually fail, but simply got cancelled.
                        batch.result = nil
                        self.descriptor.pendingBatches.insert(batch, at: 0)
                    } else {
                        batch.result = .failure(errorDescription: error.localizedDescription)
                        self.descriptor.pendingBatches.append(batch)
                    }
                }
            }
            loop: while let batch = await self.descriptor.pendingBatches.first {
                guard !Task.isCancelled else {
                    await MainActor.run {
                        switch self.pendingStateChangeRequest {
                        case nil:
                            break
                        case .pause((let completionHandler)):
                            self.state = .paused
                            completionHandler()
                        case .terminate(let completionHandler):
                            self.state = .terminated
                            completionHandler()
                        }
                        self.pendingStateChangeRequest = nil
                    }
                    // intentionally not a return (here and everywhere else in the Task),
                    // bc we still want to end up in he block at the bottom, after the task
                    // (the block can't be a defer, since it's async).
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
                            self.progress?.localizedAdditionalDescription = batch.userDisplayedDescription
                        }
                        result = try await self.queryAndProcess(sampleType: batch.sampleType, for: batch.timeRange)
                    } catch let error as QueryAndProcessError {
                        if !(error.underlyingError is CancellationError && Task.isCancelled) {
                            logger.error(
                                "Failed to query and process batch \(String(describing: batch)): \(String(describing: error)). Will schedule for retry on next app launch."
                            )
                        }
                        await popBatch(withResult: .failure(error.underlyingError))
                        continue loop
                    } catch {
                        // SAFETY: this is in fact unreachable: the `queryAndProcess` call above has a typed throw, but the compiler doesn't seem to understand this.
                        fatalError("unreachable")
                    }
                    continuation.yield(result)
                    await popBatch(withResult: .success(()))
                }
            }
            await MainActor.run {
                self.task = nil
                self.progress?.localizedAdditionalDescription = nil
                if !(self.state == .paused || self.state == .terminated) {
                    // if we end up in here (ie, outside of the while loop), and we haven't manually paused or terminated the session,
                    // it reached its end normally and we simply want to complete it.
                    self.state = .completed
                }
                continuation.finish()
            }
        }
        return stream
    }
    
    
    @MainActor
    func pause() async {
        switch (state, pendingStateChangeRequest) {
        case (.paused, _), (.completed, _), (.terminated, _):
            return
        case (.running, nil):
            // the session is running, and there is no pending request to change its state
            // --> pause it
            await withCheckedContinuation { continuation in
                pendingStateChangeRequest = .pause {
                    continuation.resume()
                }
                task?.cancel()
            }
        case (.running, .pause):
            // we already have a pending pause request
            // --> nothing to be done
            return
        case (.running, .terminate):
            // we have a pending termination request, which takes precedence over the pause request
            // --> nothing to be done
            return
        }
    }
    
    
    @MainActor
    func _terminate() async { // swiftlint:disable:this identifier_name
        await withCheckedContinuation { continuation in
            pendingStateChangeRequest = .terminate {
                continuation.resume()
            }
            state = .terminated
            task?.cancel()
        }
        bulkExporter.remove(self)
    }
}


private enum QueryAndProcessError: Error, Sendable {
    case query(any Error)
    case process(any Error)
    
    var underlyingError: any Error {
        switch self {
        case .query(let error), .process(let error):
            error
        }
    }
}

extension BulkExportSessionImpl {
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
