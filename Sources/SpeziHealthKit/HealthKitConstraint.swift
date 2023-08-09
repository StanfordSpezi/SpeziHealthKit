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
/// protocol to receive HealthKit data.
/// ```swift
/// actor ExampleStandard: Standard, HealthKitConstraint {
///    func add(sample: HKSample) async {
///        ...
///    }
///
///    func remove(sample: HKDeletedObject) {
///        ...
///    }
/// }
/// ```
///
public protocol HealthKitConstraint: Standard {
    /// Adds a new `HKSample` to the ``HealthKit`` module
    /// - Parameter sample: The `HKSample` that should be added.
    func add(sample: HKSample) async
    
    /// Notifies the ``Standard`` about the removal of a HealthKit sample as defined by the `HKDeletedObject`.
    /// - Parameter sample: The `HKDeletedObject` is a sample that should be removed.
    func remove(sample: HKDeletedObject) async
}
