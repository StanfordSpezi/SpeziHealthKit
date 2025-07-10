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

> [!IMPORTANT]  
> If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) to set up the core Spezi infrastructure.


### Health Data Collection

You can configure the [`SpeziHealthKit`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkit/healthkit-swift.class) module to collect HealthKit samples in the configuration section of your `SpeziAppDelegate`.

There are several built-in configurations you can use:

- [`CollectSample`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkit/collectsample) sets up data collection of HealthKit samples and delivers them to the functions defined in your app's `Standard` (as described above).
- [`RequestReadAccess`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkit/requestreadaccess) defines which HealthKit sample types your app requires read access to, but does not set up data collection.
- [`RequestWriteAccess`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkit/requestwriteaccess) defines which HealthKit sample types your app requires write access to.

The example below sets up automated data collection for active energy burned, step count, push count, heart rate, and electrocardiograms. It also requests read access to the blood oxygen, which will prompt the user for authorization, but not handle automated collection of the data, which will need to be queried elsewhere in your code (see *Querying Health Data* below).


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

By default, [`CollectSample`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkit/collectsample) starts collecting and delivering samples automatically when the app launches and after the user has given consent. The `continueInBackground` property defines whether the sample collection should continue in the background when the app is no longer running, and is set to `false` by default. In the example above, active energy burned and heart rate will be collected and delivered automatically. Heart rate will also be collected and delivered in the background.

You can also set data collection to be started manually by changing the `start` property to `.manual` as shown in the step count, push count, and electrocardiogram configurations above. In this case, automatic data collection will be set up but not begin until the first time that the [`triggerDataSourceCollection()`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/1.1.3/documentation/spezihealthkit/healthkit-swift.class/triggerdatasourcecollection()) function is called. In the example above, step count, push count, and electrocardiogram are set up in this manner.

> [!TIP]
> See [`SampleType`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkit/sampletype) for a complete list of supported HealthKit sample types.

Once you've configured the [`SpeziHealthKit`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkit/healthkit-swift.class)  module, the next step is to update the `Standard` in your Spezi Application in order to conform to the [`HealthKitConstraint`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkit/healthkitconstraint) protocol to receive HealthKit data.

> [!TIP]
> The [`Standard`](https://swiftpackageindex.com/stanfordspezi/spezi/main/documentation/spezi/standard) is a Spezi module in your app that orchestrates data flow by meeting requirements defined by modules. The [`SpeziHealthKit`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkit/healthkit-swift.class) module requires the Standard to have two functions that will handle data you collect, which are described below.

The [`HealthKitConstraint/handleNewSamples(_:ofType:)`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkit/healthkitconstraint/handleNewSamples(_:ofType:)) function is called once for every batch of newly collected HealthKit samples, and the [`HealthKitConstraint/handleDeletedObjects(_:ofType:)`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkit/healthkitconstraint/handleDeletedObjects(_:ofType:)) function is called once for every batch of deleted HealthKit objects.

Below is an example of the two functions implemented in a `Standard`. In the function body, you can add any logic you wish to handle the HealthKit samples that are collected or deleted.

You may wish to refer to the [example](https://github.com/StanfordSpezi/SpeziTemplateApplication/blob/main/TemplateApplication/TemplateApplicationStandard.swift) in the [SpeziTemplateApplication](https://github.com/StanfordSpezi/SpeziTemplateApplication) which serializes HealthKit samples into FHIR and inserts them into a database.

```swift
actor ExampleStandard: Standard, HealthKitConstraint {
    // Add the newly collected HealthKit samples to your application.
    func handleNewSamples<Sample>(
        _ addedSamples: some Collection<Sample>,
        ofType sampleType: SampleType<Sample>
    ) async {
        // ...
    }

    // Remove the deleted HealthKit objects from your application.
    func handleDeletedObjects<Sample>(
        _ deletedObjects: some Collection<HKDeletedObject>,
        ofType sampleType: SampleType<Sample>
    ) async {
        // ...
    }
}
```


### Querying Health Data in SwiftUI

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

The [Spezi Template Application](https://github.com/StanfordSpezi/SpeziTemplateApplication) provides a great starting point and example using the [`SpeziHealthKit`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkit) module.


## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.


## License

This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordSpezi/SpeziHealthKit/tree/main/LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
