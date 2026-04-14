# ``HealthKitOnFHIR``

<!--
                  
This source file is part of the HealthKitOnFHIR open source project

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

Extensions that convert supported HealthKit samples to FHIR resources.

## Overview

The HealthKitOnFHIR framework provides extensions that convert supported HealthKit samples to FHIR resources.

HealthKitOnFHIR supports:
- Extensions to convert data from Apple HealthKit to HL7® FHIR® R4.
- Customizable mappings between HealthKit data types and standardized codes (e.g., LOINC)

Please refer to the [HKObject Support Table](<doc:HKSampleSupportTables>) for a complete list of supported types.

## HealthKit Extensions

The HealthKitOnFHIR framework provides extensions that convert supported HealthKit samples to FHIR resources using [FHIRModels](https://github.com/apple/FHIRModels) encapsulated in a [ResourceProxy](https://github.com/apple/FHIRModels/blob/main/HowTo/Instantiation.md#1-use-resourceproxy).

```swift
let sample: HKSample = // ...
let resource = try sample.resource()
```

### Observations

`HKQuantitySample`, `HKCategorySample`, `HKCorrelationSample`, and `HKElectrocardiogram` will be converted into FHIR [Observation](https://hl7.org/fhir/R4/observation.html) resources encapsulated in a [ResourceProxy](https://github.com/apple/FHIRModels/blob/main/HowTo/Instantiation.md#1-use-resourceproxy).

```swift
let sample: HKQuantitySample = // ...
let observation = try sample.resource().get(if: Observation.self)
```

Codes and units can be customized by passing in a custom `HKSampleMapping` instance to the `resource(withMapping:)` method.

```swift
let sample: HKQuantitySample = // ...
let sampleMapping: HKSampleMapping = // ...
let observation = try sample.resource(withMapping: sampleMapping).get(if: Observation.self)
```

### Clinical Records

`HKClinicalRecord` will be converted to FHIR resources based on the type of its underlying data. Only records encoded in FHIR R4 are supported at this time.

```swift
let allergyRecord: HKClinicalRecord = // ...
let allergyIntolerance = try allergyRecord.resource().get(if: AllergyIntolerance.self)
```

## Example

In the following example, we will query the HealthKit store for step count data, convert the resulting samples to FHIR observations, and encode them into JSON.

```swift
import HealthKitOnFHIR

// Initialize an HKHealthStore instance and request permissions with it
// ...

let date = ISO8601DateFormatter().date(from: "1885-11-11T00:00:00-08:00") ?? .now
let sample = HKQuantitySample(
    type: HKQuantityType(.heartRate),
    quantity: HKQuantity(unit: HKUnit.count().unitDivided(by: .minute()), doubleValue: 42.0),
    start: date,
    end: date
)

// Convert the results to FHIR observations
let observation: Observation?
do {
    try observation = sample.resource().get(if: Observation.self)
} catch {
    // Handle any mapping errors here.
    // ...
}

// Encode FHIR observations as JSON
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]

guard let observation, 
      let data = try? encoder.encode(observation) else {
    // Handle any encoding errors here.
    // ...
}

// Print the resulting JSON
let json = String(decoding: data, as: UTF8.self)
print(json)
```

The following example generates the following FHIR observation:

```json
{
  "code" : {
    "coding" : [
      {
        "code" : "8867-4",
        "display" : "Heart rate",
        "system" : "http://loinc.org"
      }
    ]
  },
  "effectiveDateTime" : "1885-11-11T00:00:00-08:00",
  "identifier" : [
    {
      "id" : "8BA093D9-B99B-4A3C-8C9E-98C86F49F5D8"
    }
  ],
  "issued" : "2023-01-01T00:00:00-08:00",
  "resourceType" : "Observation",
  "status" : "final",
  "valueQuantity" : {
    "code": "/min",
    "unit": "beats/minute",
    "system": "http://unitsofmeasure.org",
    "value" : 42
  }
}
```

## Topics

### Mapping HealthKit Samples into FHIR Observations
- ``HealthKit/HKSample/resource(withMapping:issuedDate:extensions:)``
- ``HealthKit/HKSampleType/resourceType``
- ``HealthKit/HKElectrocardiogram/observation(symptoms:voltageMeasurements:withMapping:issuedDate:extensions:)``

### Supported HealthKit HKSample Types
- <doc:HKSampleSupportTables>
- <doc:SupportedHKQuantityTypes>
- <doc:SupportedHKClinicalTypes>
- <doc:SupportedHKCategoryTypes>
- <doc:SupportedHKCorrelationTypes>

### Working with FHIR Extensions
- ``FHIRExtensionBuilder``
- ``FHIRTypeWithExtensions``
