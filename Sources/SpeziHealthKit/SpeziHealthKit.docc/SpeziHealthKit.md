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

> Important: If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) to set up the core Spezi infrastructure. 

### Health Data Collection

You can configure the ``HealthKit-class`` module to collect HealthKit samples in the configuration section of your `SpeziAppDelegate`.

There are several built-in configurations you can use:

- ``CollectSample`` sets up data collection of HealthKit samples and delivers them to the functions defined in your app's `Standard` (as described above).
- ``RequestReadAccess`` defines which HealthKit sample types your app requires read access to, but does not set up data collection.
- ``RequestWriteAccess`` defines which HealthKit sample types your app requires write access to.

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

By default, ``CollectSample`` starts collecting and delivering samples automatically when the app launches and after the user has given consent. The `continueInBackground` property defines whether the sample collection should continue in the background when the app is no longer running, and is set to `false` by default. In the example above, active energy burned and heart rate will be collected and delivered automatically. Heart rate will also be collected and delivered in the background.

You can also set data collection to be started manually by changing the `start` property to `.manual` as shown in the step count, push count, and electrocardiogram configurations above. In this case, automatic data collection will be set up but not begin until the first time that the ``HealthKit-class/triggerDataSourceCollection()`` function is called. In the example above, step count, push count, and electrocardiogram are set up in this manner.

Once you've configured the ``HealthKit-class`` module, the next step is to update the `Standard` in your Spezi Application in order to conform to the ``HealthKitConstraint`` protocol to receive HealthKit data.

> Tip: The `Standard` is a Spezi module in your app that orchestrates data flow by meeting requirements defined by modules. The ``HealthKit-class`` module requires the Standard to have two functions that will handle data you collect, which are described below.

The ``HealthKitConstraint/handleNewSamples(_:ofType:)`` function is called once for every batch of newly collected HealthKit samples, and the ``HealthKitConstraint/handleDeletedObjects(_:ofType:)`` function is called once for every batch of deleted HealthKit objects.

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


### Querying and Displaying Health Data

You can use [``SpeziHealthKitUI``](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkitui)'s ``HealthKitQuery`` and ``HealthKitStatisticsQuery`` property wrappers to access the Health database in a View:
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

Additionally, you can use [``SpeziHealthKitUI``](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkitui)'s ``HealthChart`` to visualise query results:
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


### Bulk Export of Historical Health Data

The [``BulkHealthExporter``](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkitbulkexport/bulkhealthexporter) enables export of historical HealthKit data through sessions that can process large amounts of data while maintaining memory efficiency and supporting resumption across app launches.

First, configure the `BulkHealthExporter` in your `SpeziAppDelegate`:

```swift
import SpeziHealthKitBulkExport

class ExampleAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: ExampleStandard()) {
            HealthKit {
                // ... your existing HealthKit configuration
            }
            BulkHealthExporter()
        }
    }
}
```

Start the bulk export from your `Standard` after app launch:

```swift
actor ExampleStandard: Standard, HealthKitConstraint {
    @Dependency(BulkHealthExporter.self) private var bulkExporter
    
    func configure() {
        Task {
            await performBulkExportIfNeeded()
        }
    }
    
    private func performBulkExportIfNeeded() async {
        // Define the sample types to export
        let sampleTypes = SampleTypesCollection(
            quantity: [.heartRate, .stepCount, .activeEnergyBurned]
        )
        
        // Create or restore an export session
        let session = try await bulkExporter.session(
            withId: BulkExportSessionIdentifier("historicalDataExport"),
            for: sampleTypes,
            startDate: .oldestSample,
            endDate: .now,
            using: .identity  // Built-in processor which returns raw HealthKit samples
        )
        
        // Start the export and handle results
        let results = try await session.start()
        
        Task {
            for await samples in results {
                // Process the raw HealthKit samples as needed
                print("Exported \(samples.count) samples")
                // samples is [HKSample] - save to file, upload to server, etc.
            }
        }
    }
    
    // ... your existing HealthKitConstraint methods
}
```

For more advanced processing, you can create a custom [``BatchProcessor``](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkitbulkexport/batchprocessor):

```swift
struct CustomProcessor: BatchProcessor {
    func process<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) async throws -> Int {
        // Custom processing logic (upload to server, transform data, etc.)
        return samples.count
    }
}

// Use with: using: CustomProcessor()
```

> Tip: See ``SampleType`` for a complete list of supported sample types.

> Important: In order to be able to read Health data, your app's `Info.plist` file must include the `NSHealthShareUsageDescription` key.

## Topics

### Module
- ``HealthKit-swift.class``
- <doc:ModuleConfiguration>

### Health Data Collection
- ``CollectSample``
- ``HealthDataCollector``
- ``HealthDataCollectorDeliverySetting``

### HealthKit Sample Types
- ``SampleType``
- ``AnySampleType``
- ``SampleTypesCollection``

### Characteristics
- ``HealthKitCharacteristic``
- ``HealthKitCharacteristicProtocol``

### Working with Sleep Analysis Data
- ``SleepSession``
- ``Swift/Collection/splitIntoSleepSessions(threshold:separateBySource:)``

### Working with ECG Data
- ``HealthKit/HKElectrocardiogram/symptoms(from:)``
- ``HealthKit/HKElectrocardiogram/voltageMeasurements(from:)``
- ``HealthKit/HKElectrocardiogram/Symptoms``
- ``HealthKit/HKElectrocardiogram/Measurement``
- ``HealthKit/HKElectrocardiogram/correlatedSymptomTypes``

### HealthKit Utilities
- ``HealthKit/HKUnit/*(_:_:)``
- ``HealthKit/HKUnit//(_:_:)``
- ``HealthKit/HKBloodType/allKnownValues``
- ``HealthKit/HKBloodType/displayTitle``
