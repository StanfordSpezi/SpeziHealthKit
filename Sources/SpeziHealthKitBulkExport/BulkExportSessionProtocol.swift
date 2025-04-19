//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
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


/// An error which can occur when starting a ``BulkExportSession``.
public enum StartSessionError: Error {
    /// Attempted to `start()` a session which is already running.
    case alreadyRunning
    /// Attempted to `start()` a terminated session, which isn't allowed.
    case isTerminated
}


/// Protocol modeling a type-erased ``BulkExportSession``
public protocol BulkExportSessionProtocol<Processor>: AnyObject, Hashable, Sendable {
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
    /// The batch currently being processed, if the session is running.
    ///
    /// This can be used to obtain a user-displayable description of a running session's current work: `session.currentBatch?.userDisplayedDescription`.
    @MainActor var currentBatch: ExportBatch? { get }
    
    /// Starts the session.
    ///
    /// Attempting to start a session that is already running will result in a ``StartSessionError/alreadyRunning`` error.
    @MainActor func start(retryFailedBatches: Bool) throws(StartSessionError) -> AsyncStream<Processor.Output>
    
    /// Pauses the session at the next possible point in time.
    ///
    /// This operation won't necessarily cause the session to get paused immediately.
    /// The session will complete its current block of work, and will only see the `pause()` call before starting the next work block.
    @MainActor func pause()
    
    /// Irrevocably terminates the session and detaches it from the ``BulkHealthExporter``.
    @MainActor func _terminate() // swiftlint:disable:this identifier_name
}


extension BulkExportSessionProtocol {
    /// Whether the session is currently running.
    ///
    /// Note that this property being `false` does not mean that the session hasn't done anything
    @MainActor public var isRunning: Bool {
        switch state {
        case .running:
            true
        case .paused, .completed, .terminated:
            false
        }
    }
    
    /// The number of batches the session has already processed, i.e. the combined number of completed and failed batches.
    @MainActor public var numProcessedBatches: Int {
        completedBatches.count + failedBatches.count
    }
    
    /// Starts the session.
    ///
    /// Attempting to start a session that is already running will result in a ``StartSessionError/alreadyRunning`` error.
    @MainActor
    public func start(retryFailedBatches: Bool = false) throws(StartSessionError) where Processor.Output == Void {
        let _: AsyncStream = try start(retryFailedBatches: retryFailedBatches)
    }
}


extension BulkExportSessionProtocol {
    /// Compares two Bulk Export Sessions for equality.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    /// Hashes a Bulk Export Session
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
