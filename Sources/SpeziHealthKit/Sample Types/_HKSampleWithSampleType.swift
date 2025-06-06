//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable type_name identifier_name

import HealthKit


/// Associates a `HKSample` subclass with its corresponding `HKSampleType` subclass.
public protocol _HKSampleWithSampleType: HKSample {
    associatedtype _SampleType: HKSampleType
    /// The `HKSample` subclass HealthKit will return when fetching samples of this type.
    /// - Note: This will always be equal to `Self`, but the Swift type system cannot express this constraint, which is why we need this associated type.
    ///     (When we extend e.g. `HKQuantitySample` to conform to this protocol, we cannot use `Self`, since from the compiler's point of view there might be subclasses).
    associatedtype _QueryResult: _HKSampleWithSampleType
    
    static func _makeSamplePredicateInternal(type sampleType: _SampleType, filter filterPredicate: NSPredicate?) -> HKSamplePredicate<_QueryResult>
}


extension _HKSampleWithSampleType {
    /// Checks whether the sample is of the specified ``SampleType``.
    @inlinable public func `is`(_ sampleType: SampleType<some Any>) -> Bool {
        self.sampleType == sampleType.hkSampleType
    }
}


extension HKQuantitySample: _HKSampleWithSampleType {
    public typealias _SampleType = HKQuantityType
    
    public static func _makeSamplePredicateInternal(
        type sampleType: HKQuantityType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKQuantitySample> {
        .quantitySample(type: sampleType, predicate: filterPredicate)
    }
}

extension HKCorrelation: _HKSampleWithSampleType {
    public typealias _SampleType = HKCorrelationType
    
    public static func _makeSamplePredicateInternal(
        type sampleType: HKCorrelationType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKCorrelation> {
        .correlation(type: sampleType, predicate: filterPredicate)
    }
}

extension HKCategorySample: _HKSampleWithSampleType {
    public typealias _SampleType = HKCategoryType
    
    public static func _makeSamplePredicateInternal(
        type sampleType: HKCategoryType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKCategorySample> {
        .categorySample(type: sampleType, predicate: filterPredicate)
    }
}

extension HKElectrocardiogram: _HKSampleWithSampleType {
    public typealias _SampleType = HKElectrocardiogramType
    
    public static func _makeSamplePredicateInternal(
        type sampleType: HKElectrocardiogramType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKElectrocardiogram> {
        .electrocardiogram(filterPredicate)
    }
}

extension HKAudiogramSample: _HKSampleWithSampleType {
    public typealias _SampleType = HKAudiogramSampleType
    
    public static func _makeSamplePredicateInternal(
        type sampleType: HKAudiogramSampleType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKAudiogramSample> {
        .audiogram(filterPredicate)
    }
}

extension HKWorkout: _HKSampleWithSampleType {
    public typealias _SampleType = HKWorkoutType
    
    public static func _makeSamplePredicateInternal(
        type sampleType: HKWorkoutType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKWorkout> {
        .workout(filterPredicate)
    }
}

@available(watchOS, unavailable)
extension HKClinicalRecord: _HKSampleWithSampleType {
    public typealias _SampleType = HKClinicalType
    
    public static func _makeSamplePredicateInternal(
        type sampleType: HKClinicalType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKClinicalRecord> {
        .clinicalRecord(type: sampleType, predicate: filterPredicate)
    }
}

extension HKVisionPrescription: _HKSampleWithSampleType {
    public typealias _SampleType = HKPrescriptionType
    
    public static func _makeSamplePredicateInternal(
        type sampleType: HKPrescriptionType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKVisionPrescription> {
        .visionPrescription(filterPredicate)
    }
}

@available(iOS 18.0, watchOS 11.0, macOS 15.0, visionOS 2.0, *)
extension HKStateOfMind: _HKSampleWithSampleType {
    public typealias _SampleType = HKStateOfMindType
    
    public static func _makeSamplePredicateInternal(
        type sampleType: HKStateOfMindType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKStateOfMind> {
        .stateOfMind(filterPredicate)
    }
}

extension HKHeartbeatSeriesSample: _HKSampleWithSampleType {
    public typealias _SampleType = HKSeriesType
    
    public static func _makeSamplePredicateInternal(
        type sampleType: HKSeriesType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKHeartbeatSeriesSample> {
        .heartbeatSeries(filterPredicate)
    }
}

extension HKWorkoutRoute: _HKSampleWithSampleType {
    public typealias _SampleType = HKSeriesType
    
    public static func _makeSamplePredicateInternal(
        type sampleType: HKSeriesType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKWorkoutRoute> {
        .workoutRoute(filterPredicate)
    }
}

@available(iOS 18.0, watchOS 11.0, macOS 15.0, visionOS 2.0, *)
extension HKGAD7Assessment: _HKSampleWithSampleType {
    public typealias _SampleType = HKScoredAssessmentType
    
    public static func _makeSamplePredicateInternal(
        type sampleType: HKScoredAssessmentType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKGAD7Assessment> {
        .gad7Assessment(filterPredicate)
    }
}

@available(iOS 18.0, watchOS 11.0, macOS 15.0, visionOS 2.0, *)
extension HKPHQ9Assessment: _HKSampleWithSampleType {
    public typealias _SampleType = HKScoredAssessmentType
    
    public static func _makeSamplePredicateInternal(
        type sampleType: HKScoredAssessmentType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKPHQ9Assessment> {
        .phq9Assessment(filterPredicate)
    }
}

// swiftlint:enable type_name
