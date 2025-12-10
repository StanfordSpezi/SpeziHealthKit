# ``BulkHealthExporter``

<!--
This source file is part of the Stanford Spezi open-source project

SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
-->

Export large amounts of historical Health data

## Overview

The ``BulkHealthExporter`` enables and coordinates large-scale support of historical HealthKit data.

The Bulk Export API is built around the concept of Export Sessions (``BulkExportSession``), which implement and handle the Health data export processing. 
Sessions keep track of their pending and already-completed work, including across multiple app launches, ensuring that even for sample types with a very high number of samples a previously-started export can continue without issues if the app is terminated during the export.

Export Sessions are created using ``BulkHealthExporter/session(withId:for:startDate:endDate:batchSize:using:)``, and consist of the following components:
- A stable identifier, which is used to keep track of the session, persist its state, and restore it across app launches.
- A set of to-be-exported sample types.
- A ``BatchProcessor``, which allows the app to process the individual batches of fetched samples.

This structure allows the Bulk Export API to be used in a variety of ways, for different kinds of export operations. (See below for an example.)

In order to perform a Health data export, an app simply calls the ``BulkHealthExporter/session(withId:for:startDate:endDate:batchSize:using:)`` function once at some point after the app's launch; this will either:
- create and start a new session, if no matching session (based on the identifier) exists, or
- restore and continue an existing session (e.g., from a previous launch of the app).

It is safe to call this function multiple times and with the same input, even if a previously-created upload has already been completed.
The session will internally keep track of its creation date, and will only ever export samples up to that date.
This allows an app to e.g. use the `CollectSamples` API to continuously fetch and collect new Health samples, and use the ``BulkHealthExporter`` to do a one-time export operation of historical Health data.

The ``BulkHealthExporter/session(withId:for:startDate:endDate:batchSize:using:)`` function will, when a ``BulkExportSession`` is first created, also return an `AsyncStream` which can be used to access the individual results of the session's ``BatchProcessor``.

- Important: Ensure that your app has sufficient HealthKit access permissions before starting bulk export sessions. The session itself will *not* prompt the user for access; instead, it will fail to fetch and process any sample types for which no HealthKit permission is granted.

It is possible to ``BulkExportSession/pause()`` an export session, which can then be resumed using the ``BulkExportSession/start(retryFailedBatches:)`` function.


### Example 1: Bulk-Upload of Historical Health Data to Firebase

This example implements a custom ``BatchProcessor``, which uploads the exported HealthKit samples received from the ``BulkHealthExporter`` into Firebase. 
In this case, we implicitly define the Batch Processor's `Output` type as `Void`, since we're just interested in the uploading, and don't want to perform any additional on-device operations using the results of the individual batches. 

```swift
struct FirebaseUploader: BulkHealthExporter.BatchProcessor {
    func process<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) async throws {
        let batch = Firestore.firestore().batch()
        for sample in samples {
            let document = db.collection("healthData").document(sample.uuid.uuidString) 
            try batch.setData(from: sample.resource(), for: document)
        }
        try await batch.commit()
    }
}
```

We can then use the batch processor when creating a Bulk Export Session:
```swift
extension BulkExportSessionIdentifier {
    static let backgroundExport = Self("my-bulk-export-session")
}

// create the session (or obtain a previously-created session)
let session = try await bulkExporter.session(
    withId: .backgroundExport,
    for: [SampleType.activeEnergy, SampleType.heartRate, SampleType.stepCount],
    using: FirebaseUploader()
)

// start the session
try session.start()
```

This Bulk Export Session will, in the background, go through all historical Health data for the Active Energy, Heart Rate, and Step Count quantity types, fetch the data from HealthKit, and pass it to the Batch Processor, which will then upload it to Firebase.

In this example, since the `FirebaseUploader`'s `Output` type is `Void`, we simply can call ``BulkExportSession/start(retryFailedBatches:)`` and don't need to do anything beyond that.



### Example 2: Bulk-Export of FHIR-Encoded Historical Health Data to Disk

This example combines the [`HealthKitOnFHIR`](https://github.com/StanfordBDHG/HealthKitOnFHIR) library with the Bulk Exporter, to store each batch into a FHIR-encoded JSON file:
```swift
extension BulkExportSessionIdentifier {
    static let backgroundFHIRExport = Self("my-fhir-bulk-export-session")
}

struct FHIREncodedJSONExporter: BatchProcessor {
    func process<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) throws -> URL {
        let resources = try samples.mapIntoResourceProxies() // using HealthKitOnFHIR
        let encoded = try JSONEncoder().encode(resources)
        let url = URL.temporaryDirectory.appendingPathComponent(UUID().uuidString, conformingTo: .json)
        try encoded.write(to: url)
        return url
    }
}

// create the session
let session = try await bulkExporter.session(
    withId: .backgroundFHIRExport,
    for: [SampleType.activeEnergy, SampleType.heartRate, SampleType.stepCount],
    using: FHIREncodedJSONExporter()
)

// start the session
let results = try session.start()

// await the results
Task {
    for await url in results {
        // process the JSON file at `url` in some way
    }
}
```

Since the `FHIREncodedExporter` returns a `URL` (rather than `Void`, as with the `FirebaseUploader`), the ``BulkExportSession/start(retryFailedBatches:)`` function's return type will be an `AsyncStream<URL>` which gives us access to the individual batch processing results (in this case the urls of the exported JSON files).


### Performance Considerations

In order to optimize memory usage when fetching potentially large amounts of HealthKit samples, the ``BulkHealthExporter`` intentionally processes all sample types serially, and will perform multiple, batched fetches per sample type (e.g., by fetching data by year, rather than all at once).
This ensures that applications will stay under the iOS-enforced memory limit when processing bulk exports.

In some cases, the Bulk Exporter may decide to process a sample type at an even more granular level, e.g., batching by quarter rather than by year.

Even though all operations within an export session will run serially, multiple sessions will run in parallel; your app should ideally try to keep the total number of sessions as low as possible, in order to prevent excessive memory and CPU usage.


## Topics

### Creating a Bulk Exporter
- ``BulkHealthExporter/init()``

### Creating and Managing Export Sessions
- ``BulkHealthExporter/sessions``
- ``BulkHealthExporter/session(withId:for:startDate:endDate:batchSize:using:)``
- ``BulkHealthExporter/deleteSessionRestorationInfo(for:)``

### Export Session Types
- ``BulkExportSession``
- ``BatchProcessor``
- ``BulkExportSessionState``
- ``BulkHealthExporter/SessionError``
