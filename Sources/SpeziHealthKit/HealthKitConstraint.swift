//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi


/// The Constraint your app's `Standard` must conform to when using the Spezi HealthKit module.
///
/// Make sure that your standard in your Spezi Application conforms to the ``HealthKitConstraint``
/// protocol to receive HealthKit data.
/// The ``HealthKitConstraint/handleNewSamples(_:ofType:)`` function is triggered once for every batch of newly collected HealthKit samples, and ``HealthKitConstraint/handleDeletedObjects(_:ofType:)`` once for every batch of deleted HealthKit objects.
/// ```swift
/// actor ExampleStandard: Standard, HealthKitConstraint {
///     // Add the newly collected `HKSample`s to your application.
///     func handleNewSamples<Sample>(
///         _ addedSamples: some Collection<Sample>,
///         ofType sampleType: SampleType<Sample>
///     ) async {
///         // ...
///     }
///
///     // Remove the deleted `HKObject`s from your application.
///     func handleDeletedObjects<Sample>(
///         _ deletedObjects: some Collection<HKDeletedObject>,
///         ofType sampleType: SampleType<Sample>
///     ) async {
///         // ...
///     }
/// }
/// ```
///
public protocol HealthKitConstraint: Standard {
    /// Notifies the `Standard` about the addition of a batch of HealthKit `HKSample` samples.
    /// - Parameter addedSamples: The `HKSample`s that were added to the HealthKit database.
    func handleNewSamples<Sample>(
        _ addedSamples: some Collection<Sample>,
        ofType sampleType: SampleType<Sample>
    ) async
    
    /// Notifies the `Standard` about the removal of a batch of HealthKit objects.
    /// - Parameter deletedObjects: The `HKDeletedObject`s that were removed from the HealthKit database
    func handleDeletedObjects<Sample>(
        _ deletedObjects: some Collection<HKDeletedObject>,
        ofType sampleType: SampleType<Sample>
    ) async
}
