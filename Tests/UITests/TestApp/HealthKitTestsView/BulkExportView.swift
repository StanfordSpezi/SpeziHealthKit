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
import SpeziViews
import SwiftUI


struct BulkExportView: View {
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
                    let session = try await bulkExporter.startOrResumeSession(
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
