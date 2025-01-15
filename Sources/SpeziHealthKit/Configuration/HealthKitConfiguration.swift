//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi


/// A component in the configuration of the ``HealthKit-swift.class`` module.
///
/// Each configuration component defines the `HKObjectType`s it needs read and/or write access to,
/// and, as part of the ``HealthKit-swift.class`` module's initialization, is given the opportunity
/// to perform custom configuration actions.
public protocol HealthKitConfigurationComponent {
    /// The HealthKit data types this component needs read and/or write access to.
    var dataAccessRequirements: HealthKitDataAccessRequirements { get }
    
    /// Called when the component is addedd to the ``HealthKit-swift.class`` module.
    /// Components can use this function to register their respective custom functionalities with the module.
    @MainActor
    func configure(for healthKit: HealthKit, on standard: any HealthKitConstraint)
}



/// Defines the object and sample types the ``HealthKit-swift.class`` module requires read and/or write access to.
public struct HealthKitDataAccessRequirements {
    /// The object types a component needs read access to.
    /// The ``HealthKit-swift.class`` module will include these object types in the
    /// request when the app calls ``HealthKit-swift.class/askForAuthorization()``
    public let read: Set<HKObjectType>
    /// The object types a component needs write access to.
    /// The ``HealthKit-swift.class`` module will include these object types in the
    /// request when the app calls ``HealthKit-swift.class/askForAuthorization()``
    public let write: Set<HKSampleType>
    
    /// Creates a new instance, with the specified read and write sample types.
    public init(read: some Sequence<HKObjectType> = [], write: some Sequence<HKSampleType> = []) {
        self.read = Set(read)
        self.write = Set(write)
    }
    
    /// Creates a new instance, containing union of the read and write requirements of `self` and `other`.
    public func merging(with other: Self) -> Self {
        Self(
            read: read.union(other.read),
            write: write.union(other.write)
        )
    }
}
