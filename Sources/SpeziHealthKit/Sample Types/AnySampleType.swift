//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// Type-erased version of a ``SampleType``
///
/// ## Topics
/// ### Instance Properties
/// - ``hkSampleType``
/// - ``displayTitle``
/// - ``identifier``
/// ### Comparing type-erased sample types
/// - ``==(_:_:)-4zjyo``
/// - ``==(_:_:)-5dq7``
/// - ``==(_:_:)-80mw5``
public protocol AnySampleType: Hashable, Identifiable, Sendable where ID == String {
    /// The type of the sample type's underlying samples.
    ///
    /// E.g., for a sample type representing quantity samples, this would be `HKQuantitySample`.
    associatedtype Sample: _HKSampleWithSampleType
    
    /// The underlying `HKSampleType`
    var hkSampleType: Sample._SampleType { get }
    
    /// The recommended user-displayable name of this sample type.
    var displayTitle: String { get }
}


extension AnySampleType {
    /// The sample type's unique identifier, derived from its underlying `HKSampleType`
    @inlinable public var id: String {
        hkSampleType.identifier
    }
}


extension AnySampleType where Sample._SampleType: _HKSampleTypeWithIdentifierType {
    /// The sample type's strongly typed identifier.
    @inlinable public var identifier: Sample._SampleType._Identifier {
        .init(rawValue: hkSampleType.identifier)
    }
}


extension AnySampleType {
    /// Compare two sample types, based on their identifiers
    @inlinable public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Compare two sample types, based on their identifiers
    @inlinable public static func == (lhs: Self, rhs: SampleType<some Any>) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Hash the sample type, based on its identifier
    @inlinable public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Compare two type-erased sample type, based on their identifiers
@inlinable public func == (lhs: any AnySampleType, rhs: any AnySampleType) -> Bool { // swiftlint:disable:this static_operator
    lhs.id == rhs.id
}

/// Compare two type-erased sample type, based on their identifiers
@inlinable public func == (lhs: any AnySampleType, rhs: SampleType<some Any>) -> Bool { // swiftlint:disable:this static_operator
    lhs.id == rhs.id
}

/// Compare two type-erased sample type, based on their identifiers
@inlinable public func == (lhs: SampleType<some Any>, rhs: any AnySampleType) -> Bool { // swiftlint:disable:this static_operator
    lhs.id == rhs.id
}


extension AnySampleType {
    /// The sample types which should be used when requesting read/write authorization for this sample type with HealthKit.
    ///
    /// The reason this exists is that HealthKit doesn't allow such requests for some sample types, e.g. correlation types:
    /// instead of requesting read/write access to "blood pressure", apps need to request read/write access to each of the correlation's contained types,
    /// (eg:, in the case of blood pressure, systolic and diastolic blood pressure).
    var effectiveSampleTypesForAuthentication: [any AnySampleType] {
        if let self = self as? SampleType<HKCorrelation> {
            Array(self.associatedQuantityTypes)
        } else {
            [self]
        }
    }
}


func collectAllUnderyingEffectiveSampleTypes<each S>(
    _ seq: repeat each S
) -> Set<HKSampleType> where repeat (each S): Sequence, repeat (each S).Element: AnySampleType {
    var retval = Set<HKSampleType>()
    for seq in repeat each seq {
        retval.formUnion(seq.flatMap { $0.effectiveSampleTypesForAuthentication }.map { $0.hkSampleType })
    }
    return retval
}
