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

Access Health data in your Spezi app.

## Overview

The Spezi HealthKit module enables apps to integrate with Apple's HealthKit system, fetch data, set up long-lived background data collection, and visualize Health-related data.

### Setup

You need to add the Spezi HealthKit Swift package to
 [your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) or
 [Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> Important: If your application is not yet configured to use Spezi, follow the
 [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) and set up the core Spezi infrastructure. 

### Example

Before you configure the ``HealthKit-class`` module, make sure your `Standard` in your Spezi Application conforms to the ``HealthKitConstraint`` protocol to receive HealthKit data. The ``HealthKitConstraint/add(sample:)`` function is triggered once for every newly collected HealthKit sample, and the ``HealthKitConstraint/remove(sample:)`` function is triggered once for every deleted HealthKit sample.
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


Then, you can configure the ``HealthKit-class`` module in the configuration section of your `SpeziAppDelegate`.
You can, e.g., use ``CollectSample`` to collect a wide variety of `HKSampleTypes`:
```swift
class ExampleAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: ExampleStandard()) {
            HealthKit {
                CollectSample(.activeEnergyBurned)
                CollectSample(.stepCount, start: .manual)
                CollectSample(.pushCount, start: .manual)
                CollectSample(.heartRate, continueInBackground: true)
                CollectSample(.electrocardiogram, start: .manual)
                RequestReadAccess(quantity: [.bloodOxygen])
            }
        }
    }
}
```

> Important: In order to be able to read Health data, your app's `Info.plist` file must include the `NSHealthShareUsageDescription` key.

## Topics

### Module
- <doc:ModuleConfiguration>

### Health Data Collection
- ``CollectSample``
- ``HealthDataCollector``
- ``HealthDataCollectorDeliverySetting``

### HealthKit Sample Types
- ``SampleType``
- ``AnySampleType``

### HealthKit Utilities
- ``HealthKit/HKUnit/*(_:_:)``
- ``HealthKit/HKUnit//(_:_:)``
