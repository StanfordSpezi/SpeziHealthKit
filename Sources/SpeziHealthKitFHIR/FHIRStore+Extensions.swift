//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import HealthKit
@_spi(Internal)
public import SpeziFHIR
public import SpeziHealthKit


extension FHIRStore {
    /// Add a HealthKit sample to the FHIR store.
    /// - Parameters:
    ///   - sample: The sample that should be added.
    ///   - loadHealthKitAttachments: Indicates if the `HKAttachmentStore` should be queried for any document references found in clinical records.
    public func add(
        _ sample: HKSample,
        using healthKit: HealthKit,
        loadHealthKitAttachments: Bool = false
    ) async throws {
        let resource = try await FHIRResource.initialize(
            basedOn: sample,
            using: healthKit,
            loadHealthKitAttachments: loadHealthKitAttachments
        )
        await insert(resource)
    }
    
    /// Remove a HealthKit sample delete object from the FHIR store.
    /// - Parameter sample: The sample delete object that should be removed.
    @MainActor
    public func remove(_ deletedObject: HKDeletedObject) {
        removeResource(withHealthKitUUID: deletedObject.uuid.uuidString)
    }
}
