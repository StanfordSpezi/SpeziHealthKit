//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// Type-erased version of a ``SampleType``
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


extension AnySampleType {
    /// Compare two type-erased sample type, based on their identifiers
    @inlinable public static func == (lhs: any AnySampleType, rhs: any AnySampleType) -> Bool {
        lhs.id == rhs.id
    }
    
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
