//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import Observation
import Spezi
import SpeziFoundation
import SpeziHealthKit
import SpeziLocalStorage


@Observable
public final class BulkHealthExporter: Module, EnvironmentAccessible, @unchecked Sendable {
    @ObservationIgnored @Application(\.logger) var logger
    @ObservationIgnored @Dependency(HealthKit.self) private var healthKit
    @ObservationIgnored @Dependency(LocalStorage.self) private var localStorage
    
    /// All export sessions currently known to the Bulk Exporter.
    @MainActor public private(set) var sessions: [any BulkExportSession] = []
    
    /// Create a new Bulk Health Exporter
    nonisolated public init() {}
    
    @MainActor
    func add(_ session: some BulkExportSession) throws {
        guard !sessions.contains(where: { $0.sessionId == session.sessionId }) else {
            throw SessionError.conflictingSessionAlreadyExists
        }
        sessions.append(session)
    }
    
    @MainActor
    func remove(_ session: some BulkExportSession) {
        guard session.state == .terminated else {
            preconditionFailure("Attempted to remove non-terminated session")
        }
        if let idx = sessions.firstIndex(where: { $0.sessionId == session.sessionId }) {
            sessions.remove(at: idx)
        }
    }
}


extension BulkHealthExporter {
    /// An error that can occur when creating or deleting a ``BulkExportSession``.
    public enum SessionError: Error {
        /// The ``BulkHealthExporter`` was unable to obtain a matching session,
        /// since there is already a registered session with the same identifier, but a different ``BatchProcessor``.
        case conflictingSessionAlreadyExists
    }
    
    /// Creates or restores a previously-created Health Bulk Export Session, as identified by `id`.
    ///
    /// See the ``BulkHealthExporter`` class documentation for more information.
    @MainActor
    public func session<Processor: BatchProcessor>(
        withId id: BulkExportSessionIdentifier,
        for exportSampleTypes: SampleTypesCollection,
        startDate: ExportSessionStartDate,
        endDate: Date = .now,
        batchSize: ExportSessionBatchSize = .automatic, // swiftlint:disable:this function_default_parameter_at_end
        using batchProcessor: Processor
    ) async throws -> some BulkExportSession<Processor> {
        if let session = sessions.first(where: { $0.sessionId == id }) {
            guard let session = session as? BulkExportSessionImpl<Processor> else {
                // we found an already-running session with the same id, but a different type
                throw SessionError.conflictingSessionAlreadyExists
            }
            return session
        } else {
            let session = try await BulkExportSessionImpl<Processor>(
                sessionId: id,
                bulkExporter: self,
                healthKit: healthKit,
                sampleTypes: exportSampleTypes,
                startDate: startDate,
                endDate: endDate,
                batchSize: batchSize,
                localStorage: localStorage,
                batchProcessor: batchProcessor
            )
            try add(session)
            return session
        }
    }
    
    /// Deletes the persisted state restoration info for a session created in during previous launch of the app, based on its identifier.
    ///
    /// Calling this function with an identifier matching an existing session will result in that session getting terminated.
    ///
    /// - Note: If the to-be-deleted session is currently running, this is an asyncronous operation.
    ///     The call will return once the termination request has been processed, which may take a little bit, e.g. if a ``BatchProcessor`` is performing a long-running operation.
    ///     Place the call inside a `Task` if you don't want to wait for this.
    @MainActor
    public func deleteSessionRestorationInfo(for id: BulkExportSessionIdentifier) async throws {
        if let session = sessions.first(where: { $0.sessionId == id }) {
            await session._terminate()
        }
        let fakeKey = LocalStorageKey<Never>(Self.localStorageKey(forSessionId: id))
        try localStorage.delete(fakeKey)
    }
}


extension BulkHealthExporter {
    static func localStorageKey(forSessionId id: BulkExportSessionIdentifier) -> String {
        "edu.stanford.spezi.HealthKit.BulkExport.\(id.rawValue)"
    }
}
