# ``BulkHealthExporter``

<!--
This source file is part of the Stanford Spezi open-source project

SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
-->

Export large amounts of historical Health data

## Overview

The ``BulkHealthExporter`` enables and coordinates large-scale support of historical HealthKit data, via a

The Bulk Exporter manages ``BulkHealthExporter/Session``s, which then handle the actual health data processing and exporting.
Each session


Your app creates a

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

This Bulk Export Session will now, in the background, go through all historical Health data for the Active Energy, Heart Rate, and Step Count quantity types, fetch the data from HealthKit, and pass it to the Batch Processor. 


### Persistence

The progress of a Bulk Export Session (i.e., the information which exports are still pending and which have already been successfully completed) is persisted to disk; this allows the bulk export to run across multiple app launches, without missing data.

Bulk Export Sessions are identified uniquely by their id.


### Performance Considerations

In order to optimize memory usage when fetching potentially large amounts of HealthKit samples, the ``BulkHealthExporter`` intentionally processes all sample types serially, and will perform multiple, batched fetches per sample type (e.g., by fetching data by year, rather than all at once).
This allows applications to ensure they stay under the iOS-imposed memory limit when processing bulk exports.

In some cases, the Bulk Exporter may decide to process a sample type at an even more granular level, e.g., batching by querter rather than by year.


## Topics

### Creating a Bulk Exporter
- ``BulkHealthExporter/init()``

### Export Sessions
- ``BulkHealthExporter/session(_:for:using:startAutomatically:batchResultHandler:)``
- ``BulkHealthExporter/session(_:for:using:startAutomatically:)``
- ``BulkHealthExporter/Session``
- ``BulkHealthExporter/ExportSessionProtocol``
