<!--

This source file is part of the Stanford Spezi open-source project.

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
  
-->

# Spezi HealthKit

[![Build and Test](https://github.com/StanfordSpezi/SpeziHealthKit/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/StanfordSpezi/SpeziHealthKit/actions/workflows/build-and-test.yml)
[![codecov](https://codecov.io/gh/StanfordSpezi/SpeziHealthKit/branch/main/graph/badge.svg?token=GSed8tVeou)](https://codecov.io/gh/StanfordSpezi/SpeziHealthKit)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7824636.svg)](https://doi.org/10.5281/zenodo.7824636)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordSpezi%2FSpeziHealthKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/StanfordSpezi/SpeziHealthKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordSpezi%2FSpeziHealthKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/StanfordSpezi/SpeziHealthKit)

Access Health data in your Spezi app.

## Overview

The Spezi HealthKit module enables apps to integrate with Apple's HealthKit system, fetch data, set up long-lived background data collection, and visualize Health-related data.

### Setup

You need to add the Spezi HealthKit Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> Important: If your application is not yet configured to use Spezi, follow the
  [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) and set up the core Spezi infrastructure.


### Example: health data collection

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
Provide ``HealthKitDataSourceDescription`` to define the data collection.
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


### Example: querying Health data in SwiftUI

You can use [`SpeziHealthKitUI`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkitui)'s [`HealthKitQuery`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkitui/healthkitquery) and [`HealthKitStatisticsQuery`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkitui/healthkitstatisticsquery) property wrappers to access the Health database in a View:
```swift
struct ExampleView: View {
    @HealthKitQuery(.heartRate, timeRange: .today)
    private var heartRateSamples

    var body: some View {
        ForEach(heartRateSamples) { sample in
            // ...
        }
    }
}
```

Additionally, you can use [`SpeziHealthKitUI`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkitui)'s [`HealthChart`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkitui/healthchart) to visualise query results:
```swift
struct ExampleView: View {
    @HealthKitQuery(.heartRate, timeRange: .today)
    private var heartRateSamples

    var body: some View {
        HealthChart {
            HealthChartEntry($heartRateSamples, drawingConfig: .init(mode: .line, color: .red))
        }
    }
}
```


For more information, please refer to the [API documentation](https://swiftpackageindex.com/StanfordSpezi/SpeziHealthKit/documentation).

## The Spezi Template Application

The [Spezi Template Application](https://github.com/StanfordSpezi/SpeziTemplateApplication) provides a great starting point and example using the `SpeziHealthKit` module.


## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.


## License

This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordSpezi/SpeziHealthKit/tree/main/LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
