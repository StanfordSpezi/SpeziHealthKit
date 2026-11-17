//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

import HealthKit
public import Spezi


/// The Constraint your app's `Standard` must conform to when using the Spezi HealthKit module.
///
/// Make sure that your standard in your Spezi Application conforms to the ``HealthKitConstraint``
/// protocol to receive HealthKit data.
/// 
/// The ``HealthKitConstraint/handleNewSamples(_:ofType:)`` function is triggered once for every batch of newly collected HealthKit samples, and ``HealthKitConstraint/handleDeletedObjects(_:ofType:)`` once for every batch of deleted HealthKit objects.
/// ```swift
/// actor ExampleStandard: Standard, HealthKitConstraint {
///     // Add the newly collected `HKSample`s to your application.
///     func handleNewSamples<Sample>(
///         _ addedSamples: some Collection<Sample> & Sendable,
///         ofType sampleType: SampleType<Sample>
///     ) async throws {
///         // ...
///     }
///
///     // Remove the deleted `HKObject`s from your application.
///     func handleDeletedObjects<Sample>(
///         _ deletedObjects: some Collection<HKDeletedObject> & Sendable,
///         ofType sampleType: SampleType<Sample>
///     ) async throws {
///         // ...
///     }
/// }
/// ```
///
/// ### Reporting Failures
///
/// SpeziHealthKit keeps track of which HealthKit changes it already delivered to your standard using a persisted query anchor.
/// The anchor is only advanced once both handlers have returned successfully for a batch.
///
/// If your standard is unable to store a batch (e.g., because of a network or disk error), throw an error from the handler.
/// The batch is then treated as not stored, the anchor is not advanced, and the same changes will be delivered again later:
/// - for foreground collection, the collection is restarted from the last persisted anchor after a backoff delay;
/// - for background collection, the changes are delivered again with the next background update or app launch.
///
/// Since a batch may be delivered more than once (e.g., if a handler stored some of the samples before throwing, if one of the two handlers
/// succeeded and the other one threw, or if the app was terminated before the anchor was persisted),
/// your handlers should be idempotent, e.g., by using the samples' `uuid` to deduplicate.
///
/// Implementations that do not throw remain valid; in that case every delivered batch is considered to be successfully handled.
///
public protocol HealthKitConstraint: Standard {
    /// Notifies the `Standard` about the addition of a batch of HealthKit `HKSample` samples.
    /// - parameter addedSamples: The `HKSample`s that were added to the HealthKit database.
    /// - parameter sampleType: The ``SampleType`` of the new samples
    /// - throws: Throw an error if the samples could not be stored. The query anchor will not be advanced, and the samples will be delivered again later.
    func handleNewSamples<Sample>(
        _ addedSamples: some Collection<Sample> & Sendable,
        ofType sampleType: SampleType<Sample>
    ) async throws
    
    /// Notifies the `Standard` about the removal of a batch of HealthKit objects.
    /// - parameter deletedObjects: The `HKDeletedObject`s that were removed from the HealthKit database
    /// - parameter sampleType: The ``SampleType`` of the deleted objects
    /// - throws: Throw an error if the deletions could not be applied. The query anchor will not be advanced, and the deleted objects will be delivered again later.
    func handleDeletedObjects<Sample>(
        _ deletedObjects: some Collection<HKDeletedObject> & Sendable,
        ofType sampleType: SampleType<Sample>
    ) async throws
}

#endif
