//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import HealthKitOnFHIR
import SpeziHealthKit
import SpeziViews
import SwiftUI


struct BulkExportView: View { // swiftlint:disable:this file_types_order
    @Environment(HealthKit.self)
    private var healthKit
    @Environment(BulkHealthExporter.self)
    private var bulkExporter
    
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        Form {
            Section {
                AsyncButton("Request full access", state: $viewState) {
                    try await healthKit.askForAuthorization(for: .init(
                        read: HKQuantityType.allKnownQuantities
                    ))
                }
                AsyncButton("Start Bulk Export", state: $viewState) {
                    try await bulkExporter.startOrResumeSession(
                        "testSession",
                        for: [.quantity(.restingHeartRate)],
                        using: .jsonFile(compressUsingZlib: false)
                    ) { url in
                        print("DID CREATE EXPORT: \(url)")
                    }
                }
            }
            Section {
                EmptyView()
            }
        }
    }
}


private struct JSONFileExportFormat: BulkHealthExporter.ExportFormat {
    typealias Output = URL
    
    private let compressUsingZlib: Bool
    
    fileprivate init(compressUsingZlib: Bool) {
        self.compressUsingZlib = compressUsingZlib
    }
    
    func process<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) async throws -> URL {
        let resources = try samples.mapIntoResourceProxies()
        let encoded = try JSONEncoder().encode(resources)
        let jsonUrl = URL(filePath: NSTemporaryDirectory() + UUID().uuidString + ".json")
        try encoded.write(to: jsonUrl)
        if compressUsingZlib {
            let fm = FileManager.default
            let zlibUrl = try fm.archiveFile(at: jsonUrl, using: .zlib)
            try fm.removeItem(at: jsonUrl)
            return zlibUrl
        } else {
            return jsonUrl
        }
    }
}


extension BulkHealthExporter.ExportFormat where Self == JSONFileExportFormat {
    fileprivate static func jsonFile(compressUsingZlib: Bool) -> some BulkHealthExporter.ExportFormat<URL> {
        JSONFileExportFormat(compressUsingZlib: compressUsingZlib)
    }
}
