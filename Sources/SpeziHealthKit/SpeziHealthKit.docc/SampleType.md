# ``SampleType``

<!--
This source file is part of the Stanford Spezi open-source project

SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
-->

Work with HealthKit data types.

## Overview

The `SampleType` struct enables easy access to the various types of data supported by HealthKit, in a type-safe manner.

`SampleType` is generic over the sample type's respective `HKSample` subclass.
For example, the sample type representing heart rate samples (``SampleType/heartRate``) will fetch quantity samples, and is therefore a `SampleType<HKQuantitySample>`. 

> Note: `SampleType` already defines extensions for many HealthKit data types. It is strongly recommended you use these, whenever possible.


## Topics

### Accessing information about a SampleType
- ``SampleType/hkSampleType``
- ``SampleType/displayTitle``
- ``SampleType/displayUnit-1rnhb``
- ``SampleType/expectedValuesRange``

### Well-known quantity types
- <doc:SampleType+QuantityTypes>

### Well-known correlation types
- ``SampleType/bloodPressure``
- ``SampleType/food``

### Well-known category types
- <doc:SampleType+CategoryTypes>

### Well-known clinical record types
- <doc:SampleType+ClinicalRecords>

### Other sample types
- ``SampleType/audiogram``
- ``SampleType/electrocardiogram``
- ``SampleType/workout``

### Creating new SampleType
- ``SampleType/quantity(_:displayTitle:displayUnit:expectedValuesRange:)``
- ``SampleType/correlation(_:displayTitle:associatedQuantityTypes:)``
- ``SampleType/category(_:displayTitle:)``
- ``SampleType/clinical(_:displayTitle:)``

### Comparing Sample Types
- ``SampleType/==(_:_:)-8xhr4``
- ``SampleType/==(_:_:)-4gmmo``


### AnySampleType

The ``AnySampleType`` protocol allows ``SampleType``s to be used in a type-erased manner.

