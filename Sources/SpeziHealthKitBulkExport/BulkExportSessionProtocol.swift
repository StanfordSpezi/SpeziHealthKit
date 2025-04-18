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
    /// The session hasn't yet been started.
    case scheduled
    /// The session is currently running.
    case running
    /// The session is currently paused.
    case paused
    /// The session has completed its work, and has nothing else left to do.
    case done
}


/// Information about the current progress of a ``BulkExportSession``.
public struct BulkExportSessionProgress: Sendable {
    /// The index of the batch currently being uploaded.
    ///
    /// - Note: Since this value is intended for usage in user-visible contexts, it is 1-based, i.e., the first batch will have index `1`, the second `2`, and so on.
    public fileprivate(set) var currentBatchIdx: Int
    /// The expected total number of batches, across all sample types that will be processed as part of the current run of the session.
    public fileprivate(set) var numTotalBatches: Int
    /// A textual description of the current batch. This included information such as the batch's sample type and its time range, if applicable.
    public fileprivate(set) var currentBatchDescription: String
}


/// Protocol modeling a type-erased ``BulkExportSession``
public protocol BulkExportSessionProtocol<Processor> {
    /// The session's ``BatchProcessor``
    associatedtype Processor: BatchProcessor
    
    /// The session's unique identifier
    var sessionId: BulkExportSessionIdentifier { get }
    /// The current progress of the session, if it is currently running.
    @MainActor var progress: BulkExportSessionProgress? { get }
    /// The current state of the export session.
    @MainActor var state: BulkExportSessionState { get }
    /// Starts the session, unless it is already running
    @MainActor func start()
    /// Pauses the session at the next possible point in time.
    ///
    /// This operation won't necessarily cause the session to get paused immediately.
    /// The session will complete its current block of work, and will only see the `pause()` call before starting the next work block.
    @MainActor func pause()
}


extension BulkExportSessionProtocol {
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
