# ``SpeziHealthKit``

<!--
#
# This source file is part of the Stanford Spezi open source project
#
# SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
#
# SPDX-License-Identifier: MIT
#       
-->

Simplified access to HealthKit samples ranging from single, anchored, and background queries.

## Overview

The Spezi HealthKit module simplifies access to HealthKit samples ranging from single, anchored, and background queries.

### Setup

You need to add the Spezi HealthKit Swift package to
 [your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) or
 [Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> Important: If your application is not yet configured to use Spezi, follow the
 [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) and set up the core Spezi infrastructure.

### Example

Before you configure the ``HealthKit`` module, make sure your `Standard` in your Spezi Application conforms to the ``HealthKitConstraint`` protocol to receive HealthKit data. The ``HealthKitConstraint/add(sample:)`` function is triggered once for every newly collected HealthKit sample, and the ``HealthKitConstraint/remove(sample:)`` function is triggered once for every deleted HealthKit sample.
```swift
actor ExampleStandard: Standard, HealthKitConstraint {
    // Add the newly collected HKSample to your application.
    func add(sample: HKSample) async {
        // ...
    }

    // Remove the deleted HKSample from your application.
    func remove(sample: HKDeletedObject) {
        // ...
    }
}
```


Then, you can configure the ``HealthKit`` module in the configuration section of your `SpeziAppDelegate`.
Provide ``HealthKitDataSourceDescription`` to define the data collection.
You can, e.g., use ``CollectSample`` to collect a wide variety of `HKSampleTypes`:
```swift
class ExampleAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: ExampleStandard()) {
            if HKHealthStore.isHealthDataAvailable() {
                HealthKit {
                    CollectSample(
                        HKQuantityType.electrocardiogramType(),
                        deliverySetting: .background(.manual)
                    )
                    CollectSample(
                        HKQuantityType(.stepCount),
                        deliverySetting: .background(.automatic)
                    )
                    CollectSample(
                        HKQuantityType(.pushCount),
                        deliverySetting: .anchorQuery(.manual)
                    )
                    CollectSample(
                        HKQuantityType(.activeEnergyBurned),
                        deliverySetting: .anchorQuery(.automatic)
                    )
                    CollectSample(
                        HKQuantityType(.restingHeartRate),
                        deliverySetting: .manual()
                    )
                }
            }
        }
    }
}
```

## Topics

### Module

- ``HealthKit``
- ``HealthKitConstraint``

### Data Sources

- ``HealthKitDataSourceDescription``
- ``HealthKitDataSourceDescriptionBuilder``
- ``HealthKitDataSource``

### Collecting Samples

- ``CollectSample``
- ``CollectSamples``
- ``HealthKitDeliverySetting``
- ``HealthKitDeliveryStartSetting``

