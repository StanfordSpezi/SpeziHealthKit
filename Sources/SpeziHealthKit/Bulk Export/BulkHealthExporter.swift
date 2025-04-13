//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import Spezi
import SpeziLocalStorage
import SwiftUI
import HealthKitOnFHIR


public final class BulkHealthExporter: Module, EnvironmentAccessible, @unchecked Sendable {
    @Dependency(HealthKit.self) private var healthKit
    @Dependency(LocalStorage.self) private var localStorage
    
    @MainActor private var activeSessions: [any ExportSessionProtocol] = []
    
    nonisolated public init() {}
}


extension BulkHealthExporter {
    public enum SessionError: Error {
        case conflictingSessionAlreadyExists
    }
    
    @MainActor
    public func startOrResumeSession<Format: BulkHealthExporter.ExportFormat>(
        _ id: String,
        for exportSampleTypes: Set<WrappedSampleType>,
        using format: Format
    ) async throws -> Session<Format> where Format.Output == Void {
        try await startOrResumeSession(id, for: exportSampleTypes, using: format, batchHandler: { _ in })
    }
    
    @MainActor
    public func startOrResumeSession<Format: BulkHealthExporter.ExportFormat>(
        _ id: String,
        for exportSampleTypes: Set<WrappedSampleType>,
        using format: Format,
        batchHandler: @Sendable @escaping (Format.Output) async throws -> Void
    ) async throws -> Session<Format> {
        if let session = activeSessions.first(where: { $0.sessionId == id }) {
            guard let session = session as? Session<Format> else {
                // we found an already-running session with the same id, but a different type
                throw SessionError.conflictingSessionAlreadyExists
            }
            return session
        } else {
            let session = try await Session<Format>(
                sessionId: id,
                healthKit: healthKit,
                exportFormat: format,
                sampleTypes: exportSampleTypes,
                localStorage: localStorage,
                batchHandler: batchHandler
            )
            session.start()
            activeSessions.append(session)
            return session
        }
    }
}



extension BulkHealthExporter {
    public protocol ExportFormat<Output>: Sendable {
        associatedtype Output
        func process<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) async throws -> Output
    }
    
    
    private struct ExportSessionDescriptor: Codable {
        struct ExportBatch: Codable {
            let sampleType: WrappedSampleType
            let timeRange: Range<Date>
        }
        
        let sessionId: String
        let exportEndDate: Date
        var pendingBatches: [ExportBatch]
        var completedSampleTypes: [WrappedSampleType]
        
        init(sessionId: String, exportStartDate: Date, exportEndDate: Date, sampleTypes: Set<WrappedSampleType>) {
            self.sessionId = sessionId
            self.exportEndDate = exportEndDate
            self.completedSampleTypes = []
            let cal = Calendar.current
            let yearRanges = sequence(first: cal.startOfYear(for: exportStartDate)) {
                $0 >= exportEndDate ? nil : cal.startOfNextYear(for: $0)
            }
            self.pendingBatches = sampleTypes.flatMap { sampleType -> [ExportBatch] in
                yearRanges.map { ExportBatch(sampleType: sampleType, timeRange: cal.rangeOfYear(for: $0)) }
            }
        }
    }
    
    
    private protocol ExportSessionProtocol {
        var sessionId: String { get }
    }
    
    
    @Observable
    public final class Session<Format: ExportFormat>: Sendable, ExportSessionProtocol {
        typealias BatchResultHandler = @Sendable (Format.Output) async throws -> Void
        
        let sessionId: String
        private unowned let healthKit: HealthKit
        private let format: Format
        private let localStorage: LocalStorage
        private let localStorageKey: LocalStorageKey<ExportSessionDescriptor>
        private let batchHandler: BatchResultHandler
        @MainActor private var descriptor: ExportSessionDescriptor
        @MainActor private var task: Task<Void, Never>?
        
        @MainActor
        fileprivate init(
            sessionId: String,
            healthKit: HealthKit,
            exportFormat: Format,
            sampleTypes: Set<WrappedSampleType>,
            localStorage: LocalStorage,
            batchHandler: @escaping BatchResultHandler
        ) async throws {
            self.sessionId = sessionId
            self.healthKit = healthKit
            self.format = exportFormat
            self.batchHandler = batchHandler
            self.localStorage = localStorage
            self.localStorageKey = LocalStorageKey("edu.stanford.spezi.HealthKit.BulkExport.\(sessionId)")
            if let descriptor = try localStorage.load(localStorageKey) {
                self.descriptor = descriptor
            } else {
                let cal = Calendar(identifier: .gregorian)
                let fallbackStartDate = cal.date(from: .init(year: 2014, month: 6, day: 2))! // swiftlint:disable:this force_unwrapping
                var startDate: Date?
                for sampleType in sampleTypes {
                    guard let date = try? await sampleType.oldestSampleDate(in: healthKit) else {
                        continue
                    }
                    if let _startDate = startDate {
                        startDate = min(_startDate, date)
                    } else {
                        startDate = date
                    }
                }
                self.descriptor = ExportSessionDescriptor(
                    sessionId: sessionId,
                    exportStartDate: startDate ?? fallbackStartDate,
                    exportEndDate: Date(),
                    sampleTypes: sampleTypes
                )
            }
        }
        
        @MainActor
        func start() {
            let healthKit = self.healthKit
            let format = self.format
            let batchHandler = self.batchHandler
            
            guard task == nil else {
                // is already running
                return
            }
            task = Task.detached {
                while let batch = await self.descriptor.pendingBatches.first {
                    guard !Task.isCancelled else {
                        return
                    }
                    let result: Format.Output
                    do {
                        result = try await batch.sampleType.queryAndProcess(timeRange: batch.timeRange, in: healthKit, using: format)
                    } catch {
                        fatalError() // ???
                    }
                    do {
                        try await batchHandler(result)
                        await MainActor.run {
                            _ = self.descriptor.pendingBatches.removeFirst()
                        }
                    } catch {
                        // TODO how to deal with this?
                        // if we remove it from pending, we'll just forget about it and not retry
                        // but if we keep it, we'll retry it forever (even if we move the batch eg to the back)
                        fatalError()
                    }
                }
            }
        }
    }
}

extension WrappedSampleType {
    fileprivate func oldestSampleDate(in healthKit: HealthKit) async throws -> Date? {
        func imp<Sample>(_ sampleType: some AnySampleType<Sample>) async throws -> Date? {
            let sampleType = SampleType(sampleType)
            return try await healthKit.oldestSampleDate(for: sampleType)
        }
        return try await imp(self.underlyingSampleType)
    }
    
    fileprivate func queryAndProcess<Format: BulkHealthExporter.ExportFormat>(
        timeRange: Range<Date>,
        in healthKit: HealthKit,
        using exportFormat: borrowing Format
    ) async throws -> Format.Output {
        func imp<Sample>(_ sampleType: some AnySampleType<Sample>) async throws -> Format.Output {
            let sampleType = SampleType(sampleType)
            let samples = try await healthKit.query(sampleType, timeRange: .init(timeRange))
            return try await exportFormat.process(samples, of: sampleType)
        }
        return try await imp(self.underlyingSampleType)
    }
}


extension SampleType {
    init(_ typeErased: any AnySampleType<Sample>) {
        // SAFETY: SampleType is the only type conforming to `AnySampleType`.
        self = typeErased as! Self // swiftlint:disable:this force_cast
    }
}


public struct JSONFileExportFormat: BulkHealthExporter.ExportFormat {
    public typealias Output = URL
    
    private let compressUsingZlib: Bool
    
    fileprivate init(compressUsingZlib: Bool) {
        self.compressUsingZlib = compressUsingZlib
    }
    
    public func process<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) async throws -> URL {
        let resources = try samples.mapIntoResourceProxies()
        let encoded = try JSONEncoder().encode(resources)
        let url = URL(filePath: NSTemporaryDirectory() + UUID().uuidString + ".json")
        try encoded.write(to: url)
        if compressUsingZlib {
            // TODO compress!!!
        }
        return url
    }
}


extension BulkHealthExporter.ExportFormat where Self == JSONFileExportFormat {
    public static func jsonFile(compressUsingZlib: Bool) -> some BulkHealthExporter.ExportFormat<URL> {
        JSONFileExportFormat(compressUsingZlib: compressUsingZlib)
    }
}
