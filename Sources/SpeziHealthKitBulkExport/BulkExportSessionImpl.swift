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
import SpeziFoundation
import SpeziHealthKit
import SpeziLocalStorage


/// A long-running backgrund exporting task that fetches and processes HealthKit data.
@Observable
final class BulkExportSessionImpl<Processor: BatchProcessor>: Sendable, BulkExportSession {
    typealias Processor = Processor
    
    private enum StateChangeRequest {
        case paused, terminated
    }
    
    let sessionId: BulkExportSessionIdentifier
    private unowned let bulkExporter: BulkHealthExporter
    private unowned let healthKit: HealthKit
    @ObservationIgnored private let batchProcessor: Processor
    @ObservationIgnored @MainActor private var pendingStateChangeRequest: StateChangeRequest?
    @ObservationIgnored private let persistDescriptor: SessionDescriptorPersisting
    
    @MainActor private var descriptor: ExportSessionDescriptor {
        didSet {
            if state != .terminated {
                persistDescriptor(descriptor)
            }
        }
    }
    
    /// The `Task` on which the session's exporting is executed.
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
    @MainActor private(set) var currentBatches = Set<ExportBatch>()
    
    @MainActor var progress: BulkExportSessionProgress? {
        guard state == .running else {
            return nil
        }
        return BulkExportSessionProgress(
            numCompletedBatches: completedBatches.count,
            numFailedBatches: failedBatches.count,
            numTotalBatches: numTotalBatches,
            activeBatches: currentBatches
        )
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
        batchProcessor: Processor
    ) async throws {
        self.sessionId = sessionId
        self.bulkExporter = bulkExporter
        self.healthKit = healthKit
        self.batchProcessor = batchProcessor
        let storageKey = LocalStorageKey<ExportSessionDescriptor>(BulkHealthExporter.localStorageKey(forSessionId: sessionId))
        self.persistDescriptor = .init(localStorage: localStorage, storageKey: storageKey)
        if let descriptor = try localStorage.load(storageKey) {
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
            var descriptor = ExportSessionDescriptor(
                sessionId: sessionId,
                startDate: startDate,
                endDate: endDate,
            )
            for sampleType in sampleTypes {
                await descriptor.add(sampleType: sampleType, batchSize: batchSize, healthKit: healthKit)
            }
            self.descriptor = descriptor
        }
    }
}


extension BulkExportSessionImpl {
    @MainActor
    func start(retryFailedBatches: Bool, concurrencyLevel: BulkExportConcurrencyLevel) throws(StartSessionError) -> AsyncStream<Processor.Output> {
        switch state {
        case .running:
            throw .alreadyRunning
        case .completed, .paused:
            break
        case .terminated:
            throw .isTerminated
        }
        guard task == nil || task?.isCancelled == true else {
            // is already running
            throw .alreadyRunning
        }
        state = .running
        let (batchResults, batchResultsContinuation) = AsyncStream.makeStream(of: Processor.Output.self)
        if retryFailedBatches {
            self.descriptor.unmarkAllFailedBatches()
        }
        task = Task.detached {
            await self._run(
                concurrencyLevel: concurrencyLevel,
                batchResultsContinuation: batchResultsContinuation
            )
        }
        return batchResults
    }
    
    
    @MainActor
    func pause() async {
        guard let task else {
            return
        }
        switch state {
        case .paused, .completed, .terminated:
            return
        case .running:
            pendingStateChangeRequest = .paused
            task.cancel()
            _ = await task.result
        }
    }
    
    
    @MainActor
    func _terminate() async { // swiftlint:disable:this identifier_name
        defer {
            bulkExporter.remove(self)
        }
        guard let task else {
            state = .terminated
            return
        }
        switch state {
        case .terminated, .completed:
            return
        case .paused:
            state = .terminated
        case .running:
            pendingStateChangeRequest = .terminated
            task.cancel()
            _ = await task.result
        }
    }
    
    
    @concurrent
    private func _run( // swiftlint:disable:this function_body_length cyclomatic_complexity
        concurrencyLevel: BulkExportConcurrencyLevel,
        batchResultsContinuation: AsyncStream<Processor.Output>.Continuation
    ) async {
        let logger = self.bulkExporter.logger
        let popBatch = { @MainActor @Sendable (batch: ExportBatch, result: Result<Void, any Error>) in
            var batch = batch
            if let batchIdx = self.descriptor.pendingBatches.firstIndex(of: batch) {
                self.descriptor.pendingBatches.remove(at: batchIdx)
            } else {
                preconditionFailure("Unable to find to-be-removed batch")
            }
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
        
        /// processes a single batch
        ///
        /// - invariant: the batch must not have been processed already. (i.e., `batch.result == nil` must be true.)
        let handleBatch = { @Sendable (batch: ExportBatch) in
            switch batch.result {
            case .success, .failure:
                // unreachable (taken care of by caller)
                return
            case nil: // the batch hasn't run yet
                await MainActor.run {
                    _ = self.currentBatches.insert(batch)
                }
                defer {
                    Task { @MainActor in
                        self.currentBatches.remove(batch)
                    }
                }
                let result: Processor.Output
                do {
                    result = try await self.queryAndProcess(sampleType: batch.sampleType, for: batch.timeRange)
                } catch let error as QueryAndProcessError {
                    if !(error.underlyingError is CancellationError && Task.isCancelled) {
                        logger.error(
                            "Failed to query and process batch \(String(describing: batch)): \(String(describing: error)). Will schedule for retry on next app launch."
                        )
                    }
                    await popBatch(batch, .failure(error.underlyingError))
                    return
                } catch {
                    // SAFETY: this is in fact unreachable: the `queryAndProcess` call above has a typed throw, but the compiler doesn't seem to understand this.
                    fatalError("unreachable")
                }
                batchResultsContinuation.yield(result)
                await popBatch(batch, .success(()))
            }
        }
        
        let isDone = { @MainActor @Sendable in
            self.task = nil
            if !(self.state == .paused || self.state == .terminated) {
                // if we end up in here (ie, outside of the while loop), and we haven't manually paused or terminated the session,
                // it reached its end normally and we simply want to complete it.
                self.state = .completed
            }
            batchResultsContinuation.finish()
        }
        
        await withTaskCancellationHandler {
            await withManagedTaskQueue(limit: concurrencyLevel.effectiveLimit) { taskQueue in
                let batches = await self.descriptor.pendingBatches
                for batch in batches where batch.result == nil {
                    taskQueue.addTask {
                        guard !Task.isCancelled else {
                            return
                        }
                        await handleBatch(batch)
                    }
                }
            }
            await isDone()
        } onCancel: {
            Task {
                await MainActor.run {
                    switch self.pendingStateChangeRequest {
                    case nil:
                        break
                    case .paused:
                        self.state = .paused
                    case .terminated:
                        self.state = .terminated
                    }
                    self.pendingStateChangeRequest = nil
                    isDone()
                }
            }
        }
    }
}


// MARK: Helpers

private final class SessionDescriptorPersisting: Sendable {
    @globalActor
    private actor PersistSessionStateActor {
        static let shared = PersistSessionStateActor()
    }
    
    private let localStorage: LocalStorage
    private let storageKey: LocalStorageKey<ExportSessionDescriptor>
    private let persistTaskLock = RWLock()
    nonisolated(unsafe) private var persistTask: Task<Void, any Error>?
    
    init(localStorage: LocalStorage, storageKey: LocalStorageKey<ExportSessionDescriptor>) {
        self.localStorage = localStorage
        self.storageKey = storageKey
    }
    
    func callAsFunction(_ descriptor: ExportSessionDescriptor) {
        Task { @concurrent in
            await persistDescriptor(descriptor)
        }
    }
    
    @concurrent
    private func persistDescriptor(_ descriptor: ExportSessionDescriptor) async {
        persistTaskLock.withWriteLock {
            persistTask?.cancel()
            persistTask = Task { @PersistSessionStateActor in
                guard !Task.isCancelled else {
                    return
                }
                try? localStorage.store(descriptor, for: storageKey)
            }
        }
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
    nonisolated private func queryAndProcess<Sample: _HKSampleWithSampleType>(
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


extension BulkExportConcurrencyLevel {
    fileprivate var effectiveLimit: Int {
        switch self {
        case .disabled:
            1
        case .limit(let limit):
            limit
        case .unlimited:
            .max
        }
    }
}
