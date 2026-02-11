//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable type_name identifier_name

#if canImport(HealthKit)
import HealthKit
#endif


/// Associates a `HKSample` subclass with its corresponding `HKSampleType` subclass.
public protocol _HKSampleWithSampleType: HKSample {
    associatedtype _SampleType: HKSampleType
    
    #if canImport(HealthKit)
    /// The `HKSample` subclass HealthKit will return when fetching samples of this type.
    /// - Note: This will always be equal to `Self`, but the Swift type system cannot express this constraint, which is why we need this associated type.
    ///     (When we extend e.g. `HKQuantitySample` to conform to this protocol, we cannot use `Self`, since from the compiler's point of view there might be subclasses).
    associatedtype _QueryResult: _HKSampleWithSampleType
    
    static func _makeSamplePredicateInternal(type sampleType: _SampleType, filter filterPredicate: NSPredicate?) -> HKSamplePredicate<_QueryResult>
    #endif
}


#if canImport(HealthKit)
extension _HKSampleWithSampleType {
    /// Checks whether the sample is of the specified ``SampleType``.
    @inlinable public func `is`(_ sampleType: SampleType<some Any>) -> Bool {
        self.sampleType == sampleType.hkSampleType
    }
}
#endif


extension HKQuantitySample: _HKSampleWithSampleType {
    public typealias _SampleType = HKQuantityType
    
    #if canImport(HealthKit)
    public static func _makeSamplePredicateInternal(
        type sampleType: HKQuantityType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKQuantitySample> {
        .quantitySample(type: sampleType, predicate: filterPredicate)
    }
    #endif
}

extension HKCorrelation: _HKSampleWithSampleType {
    public typealias _SampleType = HKCorrelationType
    
    #if canImport(HealthKit)
    public static func _makeSamplePredicateInternal(
        type sampleType: HKCorrelationType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKCorrelation> {
        .correlation(type: sampleType, predicate: filterPredicate)
    }
    #endif
}

extension HKCategorySample: _HKSampleWithSampleType {
    public typealias _SampleType = HKCategoryType
    
    #if canImport(HealthKit)
    public static func _makeSamplePredicateInternal(
        type sampleType: HKCategoryType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKCategorySample> {
        .categorySample(type: sampleType, predicate: filterPredicate)
    }
    #endif
}

extension HKElectrocardiogram: _HKSampleWithSampleType {
    public typealias _SampleType = HKElectrocardiogramType
    
    #if canImport(HealthKit)
    public static func _makeSamplePredicateInternal(
        type sampleType: HKElectrocardiogramType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKElectrocardiogram> {
        .electrocardiogram(filterPredicate)
    }
    #endif
}

extension HKAudiogramSample: _HKSampleWithSampleType {
    public typealias _SampleType = HKAudiogramSampleType
    
    #if canImport(HealthKit)
    public static func _makeSamplePredicateInternal(
        type sampleType: HKAudiogramSampleType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKAudiogramSample> {
        .audiogram(filterPredicate)
    }
    #endif
}

extension HKWorkout: _HKSampleWithSampleType {
    public typealias _SampleType = HKWorkoutType
    
    #if canImport(HealthKit)
    public static func _makeSamplePredicateInternal(
        type sampleType: HKWorkoutType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKWorkout> {
        .workout(filterPredicate)
    }
    #endif
}

@available(watchOS, unavailable)
extension HKClinicalRecord: _HKSampleWithSampleType {
    public typealias _SampleType = HKClinicalType
    
    #if canImport(HealthKit)
    public static func _makeSamplePredicateInternal(
        type sampleType: HKClinicalType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKClinicalRecord> {
        .clinicalRecord(type: sampleType, predicate: filterPredicate)
    }
    #endif
}

extension HKVisionPrescription: _HKSampleWithSampleType {
    public typealias _SampleType = HKPrescriptionType
    
    #if canImport(HealthKit)
    public static func _makeSamplePredicateInternal(
        type sampleType: HKPrescriptionType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKVisionPrescription> {
        .visionPrescription(filterPredicate)
    }
    #endif
}

@available(iOS 18.0, watchOS 11.0, macOS 15.0, visionOS 2.0, *)
extension HKStateOfMind: _HKSampleWithSampleType {
    public typealias _SampleType = HKStateOfMindType
    
    #if canImport(HealthKit)
    public static func _makeSamplePredicateInternal(
        type sampleType: HKStateOfMindType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKStateOfMind> {
        .stateOfMind(filterPredicate)
    }
    #endif
}

extension HKHeartbeatSeriesSample: _HKSampleWithSampleType {
    public typealias _SampleType = HKSeriesType
    
    #if canImport(HealthKit)
    public static func _makeSamplePredicateInternal(
        type sampleType: HKSeriesType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKHeartbeatSeriesSample> {
        .heartbeatSeries(filterPredicate)
    }
    #endif
}

extension HKWorkoutRoute: _HKSampleWithSampleType {
    public typealias _SampleType = HKSeriesType
    
    #if canImport(HealthKit)
    public static func _makeSamplePredicateInternal(
        type sampleType: HKSeriesType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKWorkoutRoute> {
        .workoutRoute(filterPredicate)
    }
    #endif
}

@available(iOS 18.0, watchOS 11.0, macOS 15.0, visionOS 2.0, *)
extension HKGAD7Assessment: _HKSampleWithSampleType {
    public typealias _SampleType = HKScoredAssessmentType
    
    #if canImport(HealthKit)
    public static func _makeSamplePredicateInternal(
        type sampleType: HKScoredAssessmentType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKGAD7Assessment> {
        .gad7Assessment(filterPredicate)
    }
    #endif
}

@available(iOS 18.0, watchOS 11.0, macOS 15.0, visionOS 2.0, *)
extension HKPHQ9Assessment: _HKSampleWithSampleType {
    public typealias _SampleType = HKScoredAssessmentType
    
    #if canImport(HealthKit)
    public static func _makeSamplePredicateInternal(
        type sampleType: HKScoredAssessmentType,
        filter filterPredicate: NSPredicate?
    ) -> HKSamplePredicate<HKPHQ9Assessment> {
        .phq9Assessment(filterPredicate)
    }
    #endif
}
