//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi


/// A Constraint which all `Standard` instances must conform to when using the Spezi HealthKit module.
///
///
/// Make sure that your standard in your Spezi Application conforms to the ``HealthKitConstraint``
/// protocol to receive HealthKit data. The `add()` function is triggered once for every newly collected
/// HealthKit sample, and the `remove()` function is triggered once for every deleted HealthKit sample.
/// ```swift
/// actor ExampleStandard: Standard, HealthKitConstraint {
///    // Add the newly collected HKSample to your application.
///    func add(sample: HKSample) async {
///        ...
///    }
///    // Remove the deleted HKSample from your application.
///    func remove(sample: HKDeletedObject) {
///        ...
///    }
/// }
/// ```
///
public protocol HealthKitConstraint: Standard {
    /// Notifies the `Standard` about the addition of a HealthKit ``HKSample`` sample instance.
    /// - Parameter sample: The `HKSample` that should be added.
    func add(sample: HKSample) async
    
    /// Notifies the `Standard` about the removal of a HealthKit sample as defined by the `HKDeletedObject`.
    /// - Parameter sample: The `HKDeletedObject` is a sample that should be removed.
    func remove(sample: HKDeletedObject) async
}
