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
    
    /// The result of obtaining a ``BulkExportSession`` through the ``BulkHealthExporter``.
    public enum ObtainSessionResult<Processor: BatchProcessor> {
        /// The ``BulkHealthExporter`` created a new session.
        ///
        /// This case encapsulates both the newly created session, as well as an `AsyncStream` for getting the individual batch processing results.
        case newSession(BulkExportSession<Processor>, AsyncStream<Processor.Output>)
        /// The ``BulkHealthExporter`` already had an existing matching session.
        case existingSession(BulkExportSession<Processor>)
    }
    
    /// Creates or restores a previously-created Health Bulk Export Session, as identified by `id`.
    ///
    /// See the ``BulkHealthExporter`` class documentation for more information.
    @MainActor
    public func session<Processor: BatchProcessor>(
        _ id: BulkExportSessionIdentifier,
        for exportSampleTypes: SampleTypesCollection,
        startDate: ExportSessionStartDate,
        endDate: Date = .now,
        batchSize: ExportSessionBatchSize = .automatic, // swiftlint:disable:this function_default_parameter_at_end
        using batchProcessor: Processor,
        startAutomatically: Bool = true
    ) async throws -> ObtainSessionResult<Processor> {
        if let session = sessions.first(where: { $0.sessionId == id }) {
            guard let session = session as? BulkExportSession<Processor> else {
                // we found an already-running session with the same id, but a different type
                throw SessionError.conflictingSessionAlreadyExists
            }
            return .existingSession(session)
        } else {
            let (stream, continuation) = AsyncStream.makeStream(of: Processor.Output.self, bufferingPolicy: .unbounded)
            let session = try await BulkExportSession<Processor>(
                sessionId: id,
                bulkExporter: self,
                healthKit: healthKit,
                sampleTypes: exportSampleTypes,
                startDate: startDate,
                endDate: endDate,
                batchSize: batchSize,
                localStorage: localStorage,
                batchProcessor: batchProcessor
            ) { output in
                continuation.yield(output)
            }
            sessions.append(session)
            if startAutomatically {
                session.start()
            }
            return .newSession(session, stream)
        }
    }
    
    /// Deletes the persisted state restoration info for a session created in during previous launch of the app, based on its identifier.
    ///
    /// - Note: This function can only be used to delete sessions that have not yet been restored during the current lifetime of the app.
    ///     Once a session identifier has been passed to ``session(_:for:startDate:endDate:batchSize:using:startAutomatically:)``, it cannot be passed to ``deleteSessionRestorationInfo(for:)`` anymore.
    @MainActor public func deleteSessionRestorationInfo(for id: BulkExportSessionIdentifier) throws {
        guard !sessions.contains(where: { $0.sessionId == id }) else {
            throw SessionError.unableToDeleteRegisteredSession
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
