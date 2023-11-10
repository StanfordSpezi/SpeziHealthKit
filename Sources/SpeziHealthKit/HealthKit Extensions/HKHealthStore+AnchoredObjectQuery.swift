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
    // We disable the SwiftLint as we order the parameters in a logical order and
    // therefore don't put the predicate at the end here.
    // swiftlint:disable function_default_parameter_at_end
    func anchoredSingleObjectQuery(
        for sampleType: HKSampleType,
        using anchor: HKQueryAnchor? = nil,
        withPredicate predicate: NSPredicate? = nil,
        standard: any HealthKitConstraint
    ) async throws -> HKQueryAnchor {
        try await self.requestAuthorization(toShare: [], read: [sampleType])

        let anchorDescriptor = anchorDescriptor(sampleType: sampleType, predicate: predicate, anchor: anchor)
        let result = try await anchorDescriptor.result(for: self)

        for deletedObject in result.deletedObjects {
            await standard.remove(sample: deletedObject)
        }

        for addedSample in result.addedSamples {
            await standard.add(sample: addedSample)
        }

        return (result.newAnchor)
    }
    // swiftlint:enable function_default_parameter_at_end
    
    
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
