# ``BulkHealthExporter``

<!--
This source file is part of the Stanford Spezi open-source project

SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
-->

Export large amounts of historical Health data

## Overview

The ``BulkHealthExporter`` enables and coordinates large-scale support of historical HealthKit data, via a

Your app creates a

```swift
import FirebaseFirestore
import HealthKitOnFHIR
import SpeziHealthKit


struct FirebaseUploader: BulkHealthExporter.BatchProcessor {
    public func process<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) async throws {
        let db = Firestore.firestore()
        for sample in samples {
            let document = db.collection("healthData").document(sample.uuid.uuidString) 
            try await document.setData(from: sample.resource())
        }
    }
}
```

You can then use the batch processor when creating a session:
```swift
let session = try await bulkExporter.session(
    "my-bulk-export-session",
    for: [.quantity(.activeEnergy), .quantity(.heartRate), .quantity(.stepCount)],
    using: FirebaseUploader()
)
```

The Bulk Export Session will now


### Persistence

The progress of a Bulk Export Session (i.e., the information which exports are still pending and which have already been successfully completed) is persisted to disk; this allows the bulk export to run across multiple app launches, without missing data.

Bulk Export Sessions are identified uniquely by their id.

### Section header

<!--@START_MENU_TOKEN@-->Text<!--@END_MENU_TOKEN@-->
