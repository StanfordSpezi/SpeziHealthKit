//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import HealthKit
import Spezi


#if compiler(<6)
extension HKSample: Swift.Identifiable {}
#else
extension HKSample: @retroactive Identifiable {}
#endif


extension HKSample {
    /// The `uuid` identifier.
    public var id: UUID {
        uuid
    }
}

extension HKHealthStore {
    @MainActor
    func anchoredSingleObjectQuery(
        for sampleType: HKSampleType,
        using anchor: HKQueryAnchor? = nil, // swiftlint:disable:this function_default_parameter_at_end
        withPredicate predicate: NSPredicate? = nil, // swiftlint:disable:this function_default_parameter_at_end
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
