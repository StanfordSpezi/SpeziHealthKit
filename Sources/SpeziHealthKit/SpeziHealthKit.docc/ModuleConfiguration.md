# HealthKit Module Configuration

Configure Spezi's HealthKit module to work with your app

## Configuration Components

Your app uses ``HealthKitConfigurationComponent``s to configure the ``HealthKit-swift.class`` module for use in your app.
Each configuration component defines which HealthKit data types it needs access to, and is given the opportunity to register additional
Configuration components are processed in the order in which they are defined.

There are several built-in configuration components you can use in your app:
- ``CollectSample``: Set up background delivery of HealthKit samples to your app's `Standard`
- ``RequestReadAccess``: Define which HealthKit sample types your app requires read-access to
- ``RequestWriteAccess``: Define which HealthKit sample types your app requires write-access to

In addition to these, you can use the ``HealthKitConfigurationComponent`` protocol to define your own components and integrate then with the `HealthKit` module.


### Example: Collect step count samples, and request read access to some additional sample types
```swift
HealthKit {
    CollectSample(
        .stepCount,
        delivery: .background(.automatic)
    )
    RequestReadAccess(quantity: [.heartRate, .oxygenSaturation])
}
```


## Health Data Access Authorization

iOS apps require user consent in order to access Health data stored on the device.
The `HealthKit` module manages this for Spezi applications: the module builds up the set of Health data access requirements of all configuration components, and keep track of the app's current Health data access requirements. 

Your app should, at some point during its launch call ``HealthKit-swift.class/askForAuthorization()``.
This will ask the user to grant the app access to all HealthKit data types requested by the configuration components.
You can choose the timing of this call in a way that best suits your app: for example, you might want to integrate the Health permission request into a dedicated onboarding step.


## Topics
- ``HealthKitConfigurationComponent``
- ``RequestReadAccess``
- ``RequestWriteAccess``
