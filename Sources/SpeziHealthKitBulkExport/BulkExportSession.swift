//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
public import Observation
import SpeziHealthKit


/// State of a ``BulkExportSession``
public enum BulkExportSessionState: Hashable, Sendable {
    /// The session is currently paused.
    ///
    /// This is also the initial state for newly created but not yet started sessions.
    case paused
    /// The session is currently running.
    case running
    /// The session has completed its work, and has nothing else left to do.
    ///
    /// - Note: A ``completed`` session can be restarted and transition back into the ``running`` state, if additional sample types are added to it.
    case completed
    /// The session is irrevocably terminated, has been detached from the ``BulkHealthExporter``, and can not be restarted.
    ///
    /// A session enters this state if the ``BulkHealthExporter/deleteSessionRestorationInfo(for:)`` is called for an already-created session.
    case terminated
}


public struct BulkExportSessionProgress: Hashable, Sendable {
    /// The amount of work that has already been successfully completed, as a value from `0` to `1`.
    public let completion: Double
    /// The number of batches that have been successfully completed.
    public let numCompletedBatches: Int
    /// The number of batches that failed.
    public let numFailedBatches: Int
    /// The total number of batches expected for the session.
    public let numTotalBatches: Int
    /// The export batches that are currently being processed.
    public let activeBatches: Set<ExportBatch>
    
    init(
        numCompletedBatches: Int,
        numFailedBatches: Int,
        numTotalBatches: Int,
        activeBatches: Set<ExportBatch>
    ) {
        self.completion = min(1, Double(numCompletedBatches) / Double(numTotalBatches))
        self.numCompletedBatches = numCompletedBatches
        self.numFailedBatches = numFailedBatches
        self.numTotalBatches = numTotalBatches
        self.activeBatches = activeBatches
    }
}


/// How much concurrency a ``BulkExportSession`` should employ when running.
///
/// Allowing concurrency for a session greatly improves performance, since the session will be able to fetch and process multiple batches at the same time.
public enum BulkExportConcurrencyLevel: Hashable, Sendable {
    /// The session should not process multiple batches at the same time
    case disabled
    /// The session should process at most `limit` batches at the same time.
    case limit(Int)
    /// The session should parallelise to the maximum possible extent.
    case unlimited
    
    /// The session should intelligently select a concurrency level.
    public static var automatic: Self {
        .unlimited
    }
}


/// An error which can occur when starting a ``BulkExportSession``.
public enum StartSessionError: Error {
    /// Attempted to `start()` a session which is already running.
    case alreadyRunning
    /// Attempted to `start()` a terminated session, which isn't allowed.
    case isTerminated
}


/// Protocol modeling a type-erased ``BulkExportSession``
///
/// ## Topics
/// ### Instance Properties
/// - ``sessionId``
/// - ``state``
/// - ``pendingBatches``
/// - ``completedBatches``
/// - ``failedBatches``
/// - ``numTotalBatches``
/// - ``numProcessedBatches``
/// - ``currentBatch``
/// - ``progress``
/// ### Instance Methods
/// - ``start(retryFailedBatches:)-23rws``
/// - ``start(retryFailedBatches:)-9dmk0``
/// - ``pause()``
/// ### Other
/// - ``SpeziHealthKitBulkExport/==(_:_:)``
public protocol BulkExportSession<Processor>: AnyObject, Hashable, Sendable, Observable {
    /// The session's ``BatchProcessor``
    associatedtype Processor: BatchProcessor
    
    /// The session's unique identifier
    var sessionId: BulkExportSessionIdentifier { get }
    /// The current state of the export session.
    @MainActor var state: BulkExportSessionState { get }
    
    /// The session's pending batches.
    ///
    /// If the session is running, this will include the batch currently being processed.
    @MainActor var pendingBatches: [ExportBatch] { get }
    /// The session's completed batches.
    @MainActor var completedBatches: [ExportBatch] { get }
    /// The session's failed batches.
    @MainActor var failedBatches: [ExportBatch] { get }
    /// The total number of batches in the session.
    @MainActor var numTotalBatches: Int { get }
    
//    /// The batches currently being processed, if the session is running.
//    ///
//    /// This can be used to obtain a user-displayable description of a running session's current work; see also ``ExportBatch/userDisplayedDescription``.
//    @MainActor var currentBatches: Set<ExportBatch> { get }
    
    /// The session's current progress.
    ///
    /// `nil` if the session is terminated or hasn't yet been started.
    @MainActor var progress: BulkExportSessionProgress? { get }
    
    /// Starts the session.
    ///
    /// Attempting to start a session that is already running will result in a ``StartSessionError/alreadyRunning`` error.
    ///
    /// - returns: an `AsyncStream` that can be used to access the individual batch results resulting from processing the export session.
    @MainActor func start(
        retryFailedBatches: Bool,
        concurrencyLevel: BulkExportConcurrencyLevel
    ) throws(StartSessionError) -> AsyncStream<Processor.Output>
    
    /// Pauses the session at the next possible point in time.
    ///
    /// This operation won't necessarily cause the session to get paused immediately.
    /// The session will complete its current block of work, and will only see the `pause()` call before starting the next work block.
    ///
    /// - Note: This is an asyncronous operation. The call will return once the pause request has been processed,
    ///     which may take a little bit, e.g. if a ``BatchProcessor`` is performing a long-running operation.
    ///     Place the call inside a `Task` if you don't want to wait for this.
    @MainActor func pause() async
    
    /// Irrevocably terminates the session and detaches it from the ``BulkHealthExporter``.
    ///
    /// - Note: This is an asyncronous operation. The call will return once the termination request has been processed,
    ///     which may take a little bit, e.g. if a ``BatchProcessor`` is performing a long-running operation.
    ///     Place the call inside a `Task` if you don't want to wait for this.
    @MainActor func _terminate() async // swiftlint:disable:this identifier_name
}


extension BulkExportSession {
    /// The number of batches the session has already processed, i.e. the combined number of completed and failed batches.
    @MainActor public var numProcessedBatches: Int {
        completedBatches.count + failedBatches.count
    }
    
    /// Starts the session.
    ///
    /// Attempting to start a session that is already running will result in a ``StartSessionError/alreadyRunning`` error.
    @_disfavoredOverload
    @MainActor
    public func start(
        retryFailedBatches: Bool = false,
        concurrencyLevel: BulkExportConcurrencyLevel = .automatic
    ) throws(StartSessionError) -> AsyncStream<Processor.Output> {
        try start(retryFailedBatches: retryFailedBatches, concurrencyLevel: concurrencyLevel)
    }
    
    /// Starts the session.
    ///
    /// Attempting to start a session that is already running will result in a ``StartSessionError/alreadyRunning`` error.
    @MainActor
    public func start(
        retryFailedBatches: Bool = false,
        concurrencyLevel: BulkExportConcurrencyLevel = .automatic
    ) throws(StartSessionError) where Processor.Output == Void {
        let _: AsyncStream = try start(retryFailedBatches: retryFailedBatches, concurrencyLevel: concurrencyLevel)
    }
}


extension BulkExportSession {
    /// Compares two Bulk Export Sessions for equality.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    /// Hashes a Bulk Export Session
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

/// Compares two Bulk Export Sessions for equality.
public func == (lhs: any BulkExportSession, rhs: any BulkExportSession) -> Bool { // swiftlint:disable:this static_operator
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}
