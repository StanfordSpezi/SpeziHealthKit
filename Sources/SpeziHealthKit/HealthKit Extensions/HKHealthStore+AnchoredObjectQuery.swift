//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi


extension HKSample: Identifiable {
    public var id: UUID {
        uuid
    }
}

extension HKHealthStore {
    func anchoredSingleObjectQuery(
        for sampleType: HKSampleType,
        using anchor: HKQueryAnchor? = nil,
        withPredicate predicate: NSPredicate? = nil,
        standard: any HealthKitConstraint
    ) async throws -> (HKQueryAnchor) {
        try await self.requestAuthorization(toShare: [], read: [sampleType])

        let anchorDescriptor = anchorDescriptor(sampleType: sampleType, predicate: predicate, anchor: anchor)
        let result = try await anchorDescriptor.result(for: self)

        for deletedObject in result.deletedObjects {
            await standard.remove(removalContext: HKSampleRemovalContext(id: deletedObject.uuid, sampleType: sampleType))
        }

        for addedSample in result.addedSamples {
            await standard.add(addedSample)
        }

        return (result.newAnchor)
    }
    
    
    func anchorDescriptor(
        sampleType: HKSampleType,
        predicate: NSPredicate?,
        anchor: HKQueryAnchor?
    ) -> HKAnchoredObjectQueryDescriptor<HKSample> {
        HKAnchoredObjectQueryDescriptor(
            predicates: [
                .sample(type: sampleType, predicate: predicate)
            ],
            anchor: anchor
        )
    }
}
