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
    var dataAccessRequirements: HealthKit.DataAccessRequirements { get }
    
    /// Called when the component is addedd to the ``HealthKit-swift.class`` module.
    /// Components can use this function to register their respective custom functionalities with the module.
    @MainActor
    func configure(for healthKit: HealthKit, on standard: any HealthKitConstraint) async
}


extension HealthKit {
    /// Defines the object and sample types the ``HealthKit-swift.class`` module requires read and/or write access to.
    public struct DataAccessRequirements: Hashable, Sendable {
        /// The object types a component needs read access to.
        /// The ``HealthKit-swift.class`` module will include these object types in the
        /// request when the app calls ``HealthKit-swift.class/askForAuthorization()``
        public let read: Set<HKObjectType>
        /// The object types a component needs write access to.
        /// The ``HealthKit-swift.class`` module will include these object types in the
        /// request when the app calls ``HealthKit-swift.class/askForAuthorization()``
        public let write: Set<HKSampleType>
        
        /// Whether the data access requirements is empty
        public var isEmpty: Bool {
            read.isEmpty && write.isEmpty
        }
        
        /// Creates a new, empty instance.
        public init() {
            read = Set()
            write = Set()
        }
        
        /// Creates a new instance, with the specified read and write sample types.
        public init(read: some Sequence<HKObjectType> = [], write: some Sequence<HKSampleType> = []) {
            self.read = read.flatMapIntoSet { $0.effectiveSampleTypesForAuthentication }
            self.write = Set(write)
        }
        
        /// Creates a new instance, containing the union of the read and write requirements of `self` and `other`.
        public func merging(with other: Self) -> Self {
            Self(
                read: read.union(other.read),
                write: write.union(other.write)
            )
        }
        
        /// Merges another set of data access requirements into the current one.
        public mutating func merge(with other: Self) {
            self = self.merging(with: other)
        }
    }
}


extension HKObjectType {
    var effectiveSampleTypesForAuthentication: Set<HKObjectType> {
        if let sampleType = self.sampleType {
            sampleType.effectiveSampleTypesForAuthentication.mapIntoSet { $0.hkSampleType }
        } else {
            []
        }
    }
}
