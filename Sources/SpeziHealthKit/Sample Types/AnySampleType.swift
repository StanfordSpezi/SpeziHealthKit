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
/// - Important: The ``AnySampleType`` protocol is public, but your application should not declare any new conformances to it; ``SampleType`` is the only type allowed to conform to ``AnySampleType``.
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
/// - ``~=(_:_:)``
public protocol AnySampleType<Sample>: Hashable, Identifiable, Sendable where ID == String {
    /// The type of the sample type's underlying samples.
    ///
    /// E.g., for a sample type representing quantity samples, this would be `HKQuantitySample`.
    associatedtype Sample: _HKSampleWithSampleType
    
    /// The underlying `HKSampleType`
    var hkSampleType: Sample._SampleType { get }
    
    /// The recommended user-displayable name of this sample type.
    var displayTitle: String { get }
    
    /// Creates a properly-typed `HKSamplePredicate` object, for the current sample type.
    func _makeSamplePredicateInternal(filter filterPredicate: NSPredicate?) -> HKSamplePredicate<Sample._QueryResult>
    // swiftlint:disable:previous identifier_name
}


extension AnySampleType {
    /// The sample type's unique identifier, derived from its underlying `HKSampleType`
    @inlinable public var id: String {
        hkSampleType.identifier
    }
    
    // swiftlint:disable:next identifier_name
    package func _makeSamplePredicate(filter filterPredicate: NSPredicate?) -> HKSamplePredicate<Sample> {
        let predicate = _makeSamplePredicateInternal(filter: filterPredicate)
        guard let predicate = predicate as? HKSamplePredicate<Sample> else {
            preconditionFailure("HKSamplePredicate has invalid type. Expected '\(HKSamplePredicate<Sample>.self)'; got '\(type(of: predicate))'")
        }
        return predicate
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

// swiftlint:disable static_operator

/// Compare two sample types, based on their identifiers
@inlinable public func == (lhs: any AnySampleType, rhs: any AnySampleType) -> Bool {
    lhs.id == rhs.id
}

/// Compare two sample types, based on their identifiers
@inlinable public func == (lhs: any AnySampleType, rhs: SampleType<some Any>) -> Bool {
    lhs.id == rhs.id
}

/// Compare two sample types, based on their identifiers
@inlinable public func == (lhs: SampleType<some Any>, rhs: any AnySampleType) -> Bool {
    lhs.id == rhs.id
}

/// Compare two sample types, based on their identifiers
@inlinable public func ~= (lhs: any AnySampleType, rhs: SampleType<some Any>) -> Bool {
    lhs.id == rhs.id
}

// swiftlint:enable static_operator


extension AnySampleType {
    /// The sample types which should be used when requesting read/write authorization for this sample type with HealthKit.
    ///
    /// The reason this exists is that HealthKit doesn't allow such requests for some sample types, e.g. correlation types:
    /// instead of requesting read/write access to "blood pressure", apps need to request read/write access to each of the correlation's contained types,
    /// (eg:, in the case of blood pressure, systolic and diastolic blood pressure).
    var effectiveSampleTypesForAuthentication: [any AnySampleType] {
        switch self {
        case let self as SampleType<HKCorrelation>:
            Array(self.associatedQuantityTypes)
        case let self as SampleType<HKHeartbeatSeriesSample>:
            [self, SampleType.heartRateVariabilitySDNN]
        case let self as SampleType<HKWorkoutRoute>:
            [self, SampleType.workout]
        default:
            [self]
        }
    }
}


extension HKObjectType {
    /// The corresponding ``SampleType``, if possible.
    public var sampleType: (any AnySampleType)? {
        switch self {
        case is HKQuantityType:
            SampleType<HKQuantitySample>(.init(rawValue: self.identifier))
        case is HKCorrelationType:
            SampleType<HKCorrelation>(.init(rawValue: self.identifier))
        case is HKCategoryType:
            SampleType<HKCategorySample>(.init(rawValue: self.identifier))
        case is HKWorkoutType:
            SampleType.workout
        case is HKElectrocardiogramType:
            SampleType.electrocardiogram
        case is HKAudiogramSampleType:
            SampleType.audiogram
        case HKSeriesType.heartbeat():
            SampleType.heartbeatSeries
        case HKSeriesType.workoutRoute():
            SampleType.workoutRoute
        case HKPrescriptionType.visionPrescriptionType():
            SampleType.visionPrescription
        case is HKCharacteristicType, is HKDocumentType, is HKActivitySummaryType:
            nil
        default:
            if #available(iOS 18.0, watchOS 11.0, macOS 15.0, visionOS 2.0, *) {
                switch self {
                case is HKStateOfMindType:
                    SampleType.stateOfMind
                case HKScoredAssessmentType(.GAD7):
                    SampleType.gad7
                case HKScoredAssessmentType(.PHQ9):
                    SampleType.phq9
                default:
                    nil
                }
            } else {
                nil
            }
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
