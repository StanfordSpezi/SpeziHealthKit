//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// A ``HealthKit-class`` configuration component that requests read acess to HealthKit sample types.
///
/// - Important: Apps can only request HealthKit read access if the `Info.plist` file contains an entry for the `NSHealthShareUsageDescription` key.
public struct RequestReadAccess: HealthKitConfigurationComponent {
    public let dataAccessRequirements: HealthKit.DataAccessRequirements
    
    /// Creates a HealthKit configuration component that requests read access to the specified `HKObjectType`s.
    public init(_ objectTypes: some Sequence<HKObjectType>) {
        dataAccessRequirements = .init(read: Set(objectTypes))
    }
    
    /// Creates a HealthKit configuration component that requests read access to the specified sample types.
    /// - parameter quantity: Any quantity sample types you wish to request read access for
    /// - parameter category: Any category sample types you wish to request read access for
    /// - parameter correlation: Any correlation sample types you wish to request read access for. Note: rather than requesting access for the correlation type itself (which is not allowed), this will request access for the set of the specific correlation types' underlying sample types. For example, a read access request to the ``SampleType/bloodPressure`` correlation type, will get translated into read access requests to ``SampleType/bloodPressureSystolic`` and ``SampleType/bloodPressureDiastolic``.
    /// - parameter characteristic: Any characteristic sample types you wish to request read access for
    /// - parameter other: Any other sample types you wish to request read access to. Use this parameter for "special" sample types which don't fall into any of the other categories, e.g. ``SampleType/workout`` or ``SampleType/electrocardiogram``.
    public init(
        quantity: Set<SampleType<HKQuantitySample>> = [],
        category: Set<SampleType<HKCategorySample>> = [],
        correlation: Set<SampleType<HKCorrelation>> = [],
        characteristic: [any HealthKitCharacteristicProtocol] = [],
        record: Set<SampleType<HKClinicalRecord>> = [],
        other: [any AnySampleType] = []
    ) {
        let types = (collectAllUnderyingEffectiveSampleTypes(quantity, category, correlation) as Set<HKObjectType>)
            .union(characteristic.map(\.hkType))
            .union(record.map(\.hkSampleType))
            .union(other.map { $0.hkSampleType })
        self.init(types)
    }
    
    public func configure(for healthKit: HealthKit, on standard: any HealthKitConstraint) {
        // This type only provides object types to the HealthKit module;
        // and consequently doesn't need to do anything in here.
    }
}
