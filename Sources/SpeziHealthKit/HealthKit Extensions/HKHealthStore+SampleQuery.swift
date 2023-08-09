//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi


extension HKHealthStore {
    func sampleQuery(
        for sampleType: HKSampleType,
        withPredicate predicate: NSPredicate? = nil
    ) async throws -> [HKSample] {
        try await self.requestAuthorization(toShare: [], read: [sampleType])
        
        // Create the descriptor.
        let sampleQueryDescriptor = HKSampleQueryDescriptor(
            predicates: [
                .sample(type: sampleType, predicate: predicate)
            ],
            sortDescriptors: [
                SortDescriptor(\.endDate, order: .reverse)
            ]
        )
        
        return try await sampleQueryDescriptor.result(for: self)
    }
    
    // We disable the SwiftLint as we order the parameters in a logical order and
    // therefore don't put the predicate at the end here.
    // swiftlint:disable function_default_parameter_at_end
    func sampleQueryStream(
        for sampleType: HKSampleType,
        withPredicate predicate: NSPredicate? = nil,
        standard: any HealthKitConstraint
    ) {
        _Concurrency.Task {
            for sample in try await sampleQuery(for: sampleType, withPredicate: predicate) {
                await standard.add(sample: sample)
            }
        }
    }
    // swiftlint:enable function_default_parameter_at_end
}
