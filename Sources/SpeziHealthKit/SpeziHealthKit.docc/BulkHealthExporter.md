# ``BulkHealthExporter``

<!--
This source file is part of the Stanford Spezi open-source project

SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
-->

Export large amounts of historical Health data

## Overview

The ``BulkHealthExporter`` enables and coordinates large-scale support of historical HealthKit data.

The Bulk Export API is built around the concept of a Export Sessions (``BulkHealthExporter/ExportSession``), which implement and handle the actual Health data export processing. 
Sessions keep track of their pending and already-completed work, even across multiple app launches, ensuring that even for sample types with a very high number of samples a previously-started export can continue without issues if the app is terminated during the export.

Export Sessions are created using ``BulkHealthExporter/session(_:for:using:startAutomatically:batchResultHandler:)``, and consist of the following components:
- A stable identifier, which will be used to keep track of the session, persist its state, and restore it across app launches.
- A set of to-be-exported sample types.
- A ``BulkHealthExporter/BatchProcessor``, which allows the app process the individual batches of fetched samples.
- An optional "batch result handler" closure, which will be called by the Session to inform the app about the results of the individual batch processing operations.
This structure allows the Bulk Export API to be used in a variety of ways, for different kinds of export operations. (See below for an example.)

An app wishing to perform a Health data export should simply call the ``BulkHealthExporter/session(_:for:using:startAutomatically:batchResultHandler:)`` function once at some point after the app's launch; this will either:
- create and start a new session, if no matching session (based on the identifier) exists, or
- restore and continue an existing session (e.g., from a previous launch of the app).

It is safe to call this function multiple times and with the same input, even if a previously-created upload has already been completed.
The session will internally keep track of its creation date, and will only ever export samples up to that date.
This allows an app to e.g. use the ``CollectSample`` API to continuously fetch and collect new Health samples, and use the ``BulkHealthExporter`` to do a one-time export operation of historical Health data.

- Important: Ensure that your app has sufficient HealthKit access permissions before starting bulk export sessions. The session itself will *not* prompt the user for access; instead, it will fail to fetch and process any sample types for which no HealthKit permission is granted.

It is possible to ``BulkHealthExporter/ExportSession/pause()`` an export session, which can then be resumed using the ``BulkHealthExporter/ExportSession/start()`` function.


### Example: Bulk-Upload of Historical Health Data to Firebase

Firstly, you define a custom ``BulkHealthExporter/BatchProcessor``, which will receive collections of HealthKit samples from the ``BulkHealthExporter``, and upload them to Firebase.
In this case, we implicitly define the Batch Processor's `Output` type as `Void`, since we're just interested in the uploading, and don't want to immediately use the samples for anything else on-device. 

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

You can then use the batch processor when creating a Bulk Export Session:
```swift
let session = try await bulkExporter.session(
    "my-bulk-export-session",
    for: [.quantity(.activeEnergy), .quantity(.heartRate), .quantity(.stepCount)],
    using: FirebaseUploader()
)
```

This Bulk Export Session will, in the background, go through all historical Health data for the Active Energy, Heart Rate, and Step Count quantity types, fetch the data from HealthKit, and pass it to the Batch Processor, which will then upload it to Firebase.


### Performance Considerations

In order to optimize memory usage when fetching potentially large amounts of HealthKit samples, the ``BulkHealthExporter`` intentionally processes all sample types serially, and will perform multiple, batched fetches per sample type (e.g., by fetching data by year, rather than all at once).
This allows applications to ensure they stay under the iOS-imposed memory limit when processing bulk exports.

In some cases, the Bulk Exporter may decide to process a sample type at an even more granular level, e.g., batching by querter rather than by year.

Even though all operations within a session will run serially, multiple sessions will run in parallel; your app should ideally try to keep the total number of sessions as low as possible, in order to prevent excessive memory and CPU usage.


## Topics

### Creating a Bulk Exporter
- ``BulkHealthExporter/init()``

### Creating and Managing Export Sessions
- ``BulkHealthExporter/sessions``
- ``BulkHealthExporter/session(_:for:using:startAutomatically:batchResultHandler:)``
- ``BulkHealthExporter/session(_:for:using:startAutomatically:)``
- ``BulkHealthExporter/deleteSessionRestorationInfo(for:)``

### Export Session Types
- ``BulkHealthExporter/ExportSession``
- ``BulkHealthExporter/BatchProcessor``
- ``BulkHealthExporter/ExportSessionState``
- ``BulkHealthExporter/ExportSessionProtocol``
- ``BulkHealthExporter/SessionError``
