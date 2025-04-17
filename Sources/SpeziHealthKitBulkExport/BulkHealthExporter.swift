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
    @MainActor public private(set) var sessions: [any BulkExportSessionProtocol] = []
    
    /// Create a new Bulk Health Exporter
    nonisolated public init() {}
}


extension BulkHealthExporter {
    /// An error that can occur when creating or deleting a ``BulkExportSession``.
    public enum SessionError: Error {
        /// The ``BulkHealthExporter`` was unable to obtain a matching session,
        /// since there is already a registered session with the same identifier, but a different ``BatchProcessor``.
        case conflictingSessionAlreadyExists
        /// The ``BulkHealthExporter`` was unable to delete the session, since there is already a matching registered session.
        case unableToDeleteRegisteredSession
    }
    
    /// Creates or restores a previously-created Health Bulk Export Session, as identified by `id`.
    ///
    /// See the ``BulkHealthExporter`` class documentation for more information.
    @MainActor
    public func session<Processor: BatchProcessor>(
        _ id: String,
        for exportSampleTypes: SampleTypesCollection,
        using batchProcessor: Processor,
        startAutomatically: Bool = true
    ) async throws -> BulkExportSession<Processor> where Processor.Output == Void {
        try await session(
            id,
            for: exportSampleTypes,
            using: batchProcessor,
            startAutomatically: startAutomatically,
            batchResultHandler: { _ in }
        )
    }
    
    /// Creates or restores a previously-created Health Bulk Export Session, as identified by `id`.
    ///
    /// See the ``BulkHealthExporter`` class documentation for more information.
    @MainActor
    public func session<Processor: BatchProcessor>(
        _ id: String,
        for exportSampleTypes: SampleTypesCollection,
        using batchProcessor: Processor,
        startAutomatically: Bool = true,
        batchResultHandler: @Sendable @escaping (Processor.Output) async -> Void
    ) async throws -> BulkExportSession<Processor> {
        if let session = sessions.first(where: { $0.sessionId == id }) {
            guard let session = session as? BulkExportSession<Processor> else {
                // we found an already-running session with the same id, but a different type
                throw SessionError.conflictingSessionAlreadyExists
            }
            return session
        } else {
            let session = try await BulkExportSession<Processor>(
                sessionId: id,
                bulkExporter: self,
                healthKit: healthKit,
                sampleTypes: exportSampleTypes,
                localStorage: localStorage,
                batchProcessor: batchProcessor,
                batchResultHandler: batchResultHandler
            )
            sessions.append(session)
            if startAutomatically {
                session.start()
            }
            return session
        }
    }
    
    /// Deletes the persisted state restoration info for a session created in during previous launch of the app, based on its identifier.
    ///
    /// - Note: This function can only be used to delete sessions that have not yet been restored during the current lifetime of the app.
    ///     Once a session identifier has been passed to ``session(_:for:using:startAutomatically:batchResultHandler:)``, it cannot be passed to ``deleteSessionRestorationInfo(for:)`` anymore.
    @MainActor public func deleteSessionRestorationInfo(for id: String) throws {
        guard !sessions.contains(where: { $0.sessionId == id }) else {
            throw SessionError.unableToDeleteRegisteredSession
        }
        let fakeKey = LocalStorageKey<Never>(Self.localStorageKey(forSessionId: id))
        try localStorage.delete(fakeKey)
    }
}


extension BulkHealthExporter {
    static func localStorageKey(forSessionId id: String) -> String {
        "edu.stanford.spezi.HealthKit.BulkExport.\(id)"
    }
}
