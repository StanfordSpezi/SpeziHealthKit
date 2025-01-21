# ``SampleType``

Safely work with HealthKit data types.

## Overview

The `SampleType` struct enables easy access to the various types of data supported by HealthKit, in a type-safe manner.

`SampleType` is generic over the sample type's respective `HKSample` subclass.
For example, the sample type representing heart rate samples (``SampleType/heartRate``) will fetch quantity samples, and is therefore a `SampleType<HKQuantitySample>`. 

- Note: `SampleType` already defines extensions for many HealthKit data types. It is strongly recommended you use these, whenever possible.


## Topics

### Accessing information about a SampleType
- ``SampleType/hkSampleType``
- ``SampleType/displayTitle``
- ``SampleType/displayUnit-1rnhb``
- ``SampleType/displayUnit-4gadf``
- ``SampleType/expectedValuesRange``

### Creating new SampleTypes
- ``SampleType/quantity(_:displayTitle:displayUnit:expectedValuesRange:)``
- ``SampleType/correlation(_:displayTitle:displayUnit:)``
- ``SampleType/category(_:displayTitle:)``

### Well-known quantity types
- ``SampleType/stepCount``
- ``SampleType/bloodOxygen``
- ``SampleType/heartRate``
- ``SampleType/restingHeartRate``
- ``SampleType/heartRateVariability``
- ``SampleType/pushCount``
- ``SampleType/activeEnergyBurned``
- ``SampleType/height``

### Well-known correlation types
- ``SampleType/bloodPressure``

### Well-known category types
- ``SampleType/sleepAnalysis``

### Other sample types
- ``SampleType/audiogram``
- ``SampleType/electrocardiogram``


### AnySampleType

The ``AnySampleType`` protocol allows ``SampleType``s to be used in a type-erased manner.

