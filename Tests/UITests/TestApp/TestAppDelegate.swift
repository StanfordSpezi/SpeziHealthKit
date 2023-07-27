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
import XCTSpezi

struct HKItem {
    var data: HKSample
    var id: String
}

/// an example Standard used for the configuration
actor ExampleStandard: Standard, ObservableObjectProvider, ObservableObject {
//    var observableObjectProviders: [any ObservableObjectProvider]
    
    var addedResponses = [HKItem]()
}

extension ExampleStandard: HealthKitConstraint {
    
    func add(_ response: HKSample) async {
//        addedResponses.append(response)
        addedResponses.append(.init(data: response, id: "\(UUID())"))
    }
    
    func remove(removalContext: SpeziHealthKit.HKSampleRemovalContext) {
        if let index = addedResponses.firstIndex(where: { $0.data.sampleType == removalContext.sampleType && $0.id == "\(removalContext.id)" }) {
            addedResponses.remove(at: index)
        }
        
    }
    
    // store by appening to added elements, and removed elements for data changes old code
    
}

class TestAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: ExampleStandard()) {
            HealthKit {
                CollectSample(
                    HKQuantityType.electrocardiogramType(),
                    deliverySetting: .background(.manual)
                )
                CollectSample(
                    HKQuantityType(.stepCount),
                    deliverySetting: .background(.afterAuthorizationAndApplicationWillLaunch)
                )
                CollectSample(
                    HKQuantityType(.pushCount),
                    deliverySetting: .anchorQuery(.manual)
                )
                CollectSample(
                    HKQuantityType(.activeEnergyBurned),
                    deliverySetting: .anchorQuery(.afterAuthorizationAndApplicationWillLaunch)
                )
                CollectSample(
                    HKQuantityType(.restingHeartRate),
                    deliverySetting: .manual()
                )
            }
        }
    }
}
