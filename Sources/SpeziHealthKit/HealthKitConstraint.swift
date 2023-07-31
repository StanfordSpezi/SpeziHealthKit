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
public protocol HealthKitConstraint: Standard {
    /// Adds a new `HKSample` to the ``HealthKit`` module
    /// - Parameter response: The `HKSample` that should be added.
    func add(_ response: HKSample) async
    
    /// Removes a `HKSampleRemovalContext` from the ``HealthKit`` module
    /// - Parameter response: The `HKSampleRemovalContext` that contains information on the item that should be removed.
    func remove(removalContext: HKSampleRemovalContext)
}
