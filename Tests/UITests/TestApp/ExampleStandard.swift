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

@Observable
private class ResponseList {
    var addedResponses = [HKSample]()
}

/// An example Standard used for the configuration.
actor ExampleStandard: Standard, EnvironmentAccessible {
    @MainActor private var responseList = ResponseList()
    @MainActor var addedResponses: [HKSample] {
        _read {
            yield responseList.addedResponses
        }
        _modify {
            yield &responseList.addedResponses
        }
    }
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
