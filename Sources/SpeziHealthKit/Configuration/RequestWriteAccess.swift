//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// A ``HealthKit-class`` configuration component that requests write acess to HealthKit sample types.
///
/// - Important: Apps can only request HealthKit write access if the `Info.plist` file contains an entry for the `NSHealthUpdateUsageDescription` key.
public struct RequestWriteAccess: HealthKitConfigurationComponent {
    public let dataAccessRequirements: HealthKit.DataAccessRequirements
    
    /// Creates a HealthKit configuration component that requests write access to the specified `HKObjectType`s.
    public init(_ objectTypes: some Sequence<HKSampleType>) {
        dataAccessRequirements = .init(write: Set(objectTypes))
    }
    
    /// Creates a HealthKit configuration component that requests write access to the specified type identifiers.
    /// - parameter quantity: Any quantity sample types you wish to request write access for
    /// - parameter category: Any category sample types you wish to request write access for
    /// - parameter correlation: Any correlation sample types you wish to request write access for. Note: rather than requesting access for the correlation type itself (which is not allowed), this will request access for the set of the specific correlation types' underlying sample types. For example, a write access request to the ``SampleType/bloodPressure`` correlation type, will get translated into write access requests to ``SampleType/bloodPressureSystolic`` and ``SampleType/bloodPressureDiastolic``.
    /// - parameter other: Any other sample types you wish to request write access to. Use this parameter for "special" sample types which don't fall into any of the other categories, e.g. ``SampleType/workout`` or ``SampleType/electrocardiogram``.
    public init(
        quantity: Set<SampleType<HKQuantitySample>> = [],
        category: Set<SampleType<HKCategorySample>> = [],
        correlation: Set<SampleType<HKCorrelation>> = [],
        other: [any AnySampleType] = []
    ) {
        let types = collectAllUnderyingEffectiveSampleTypes(quantity, category, correlation)
            .union(other.map { $0.hkSampleType })
        self.init(types)
    }
    
    public func configure(for healthKit: HealthKit, on standard: any HealthKitConstraint) {
        // This type only provides object types to the HealthKit module;
        // and consequently doesn't need to do anything in here.
    }
}
