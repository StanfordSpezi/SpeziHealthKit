//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import HealthKit
import Spezi
import SpeziHealthKit


/// An example Standard used for the configuration.
actor ExampleStandard: Standard, ObservableObject, ObservableObjectProvider {
    @Published @MainActor var addedResponses = [HKSample]()
}


extension ExampleStandard: HealthKitConstraint {
    func add(sample: HKSample) async {
        _Concurrency.Task { @MainActor in
            addedResponses.append(sample)
        }
    }
    
    func remove(sample: HKDeletedObject) async {
        _Concurrency.Task { @MainActor in
            if let index = addedResponses.firstIndex(where: { $0.uuid == sample.uuid }) {
                addedResponses.remove(at: index)
            }
        }
    }
}
