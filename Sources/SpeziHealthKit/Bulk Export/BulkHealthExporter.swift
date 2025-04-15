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
import os
import Spezi
import SpeziFoundation
import SpeziLocalStorage


@Observable
public final class BulkHealthExporter: Module, EnvironmentAccessible, @unchecked Sendable {
    @ObservationIgnored @Application(\.logger) var logger
    @ObservationIgnored @Dependency(HealthKit.self) private var healthKit
    @ObservationIgnored @Dependency(LocalStorage.self) private var localStorage
    
    /// All export sessions currently known to the Bulk Exporter.
    @MainActor public private(set) var sessions: [any ExportSessionProtocol] = []
    
    nonisolated public init() {}
}


extension BulkHealthExporter {
    public enum SessionError: Error {
        case conflictingSessionAlreadyExists
    }
    
    /// Creates or restores a previously-created Health Bulk Export Session, as identified by `id`.
    @MainActor
    public func session<Processor: BatchProcessor>(
        _ id: String,
        for exportSampleTypes: Set<WrappedSampleType>,
        using batchProcessor: Processor,
        startAutomatically: Bool = true
    ) async throws -> Session<Processor> where Processor.Output == Void {
        try await session(
            id,
            for: exportSampleTypes,
            using: batchProcessor,
            startAutomatically: startAutomatically,
            batchResultHandler: { _ in true }
        )
    }
    
    /// Creates or restores a previously-created Health Bulk Export Session, as identified by `id`.
    @MainActor
    public func session<Processor: BatchProcessor>(
        _ id: String,
        for exportSampleTypes: Set<WrappedSampleType>,
        using batchProcessor: Processor,
        startAutomatically: Bool = true,
        batchResultHandler: @Sendable @escaping (Processor.Output) async -> Bool
    ) async throws -> Session<Processor> {
        try? deleteSession(id)
        if let session = sessions.first(where: { $0.sessionId == id }) {
            guard let session = session as? Session<Processor> else {
                // we found an already-running session with the same id, but a different type
                throw SessionError.conflictingSessionAlreadyExists
            }
            return session
        } else {
            let session = try await Session<Processor>(
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
    
    @MainActor func deleteSession(_ id: String) throws {
        let fakeKey = LocalStorageKey<Never>(Self.localStorageKey(forSessionId: id))
        try localStorage.delete(fakeKey)
    }
}


extension BulkHealthExporter {
    static func localStorageKey(forSessionId id: String) -> String {
        "edu.stanford.spezi.HealthKit.BulkExport.\(id)"
    }
}
