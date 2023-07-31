//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi
import SpeziHealthKit


/// an example datatype for storing HealthSamples.
struct HKItem {
    var data: HKSample
    var id: String
}


/// an example Standard used for the configuration.
actor ExampleStandard: Standard, ObservableObjectProvider, ObservableObject {
    var addedResponses = [HKItem]()
}

extension ExampleStandard: HealthKitConstraint {
    func add(_ response: HKSample) async {
        addedResponses.append(.init(data: response, id: "\(UUID())"))
    }
    
    func remove(removalContext: SpeziHealthKit.HKSampleRemovalContext) {
        if let index = addedResponses.firstIndex(where: { $0.data.sampleType == removalContext.sampleType && $0.id == "\(removalContext.id)" }) {
            addedResponses.remove(at: index)
        }
    }
}
