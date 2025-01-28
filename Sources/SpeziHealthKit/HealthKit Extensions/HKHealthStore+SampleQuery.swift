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
}
