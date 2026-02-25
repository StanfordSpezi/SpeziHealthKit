//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if !canImport(HealthKit)

// swiftlint:disable missing_docs file_types_order

public import Foundation


// MARK: Object / Sample Classes

public class HKObject: NSObject, @unchecked Sendable {}

public class HKSample: HKObject, @unchecked Sendable {}

public class HKQuantitySample: HKSample, @unchecked Sendable {}
public class HKCategorySample: HKSample, @unchecked Sendable {}
public class HKCorrelation: HKSample, @unchecked Sendable {}
public class HKAudiogramSample: HKSample, @unchecked Sendable {}
public class HKElectrocardiogram: HKSample, @unchecked Sendable {}
public class HKWorkout: HKSample, @unchecked Sendable {}
public class HKWorkoutRoute: HKSample, @unchecked Sendable {}
public class HKVisionPrescription: HKSample, @unchecked Sendable {}
public class HKClinicalRecord: HKSample, @unchecked Sendable {}
public class HKStateOfMind: HKSample, @unchecked Sendable {}

public class HKSeriesSample: HKSample, @unchecked Sendable {}
public class HKHeartbeatSeriesSample: HKSeriesSample, @unchecked Sendable {}

public class HKScoredAssessment: HKSample, @unchecked Sendable {}
public class HKGAD7Assessment: HKScoredAssessment, @unchecked Sendable {}
public class HKPHQ9Assessment: HKScoredAssessment, @unchecked Sendable {}


// MARK: Sample Types


public class HKObjectType: NSObject, @unchecked Sendable {
    public let identifier: String
    
    fileprivate init(identifier: String) {
        self.identifier = identifier
    }
}


public class HKSampleType: HKObjectType, @unchecked Sendable {}


public class HKQuantityType: HKSampleType, @unchecked Sendable {
    public init(_ identifier: HKQuantityTypeIdentifier) {
        super.init(identifier: identifier.rawValue)
    }
}

public class HKCharacteristicType: HKSampleType, @unchecked Sendable {
    public init(_ identifier: HKCharacteristicTypeIdentifier) {
        super.init(identifier: identifier.rawValue)
    }
}

public class HKCorrelationType: HKSampleType, @unchecked Sendable {
    public init(_ identifier: HKCorrelationTypeIdentifier) {
        super.init(identifier: identifier.rawValue)
    }
}

public class HKCategoryType: HKSampleType, @unchecked Sendable {
    public init(_ identifier: HKCategoryTypeIdentifier) {
        super.init(identifier: identifier.rawValue)
    }
}

public class HKClinicalType: HKSampleType, @unchecked Sendable {
    public init(_ identifier: HKClinicalTypeIdentifier) {
        super.init(identifier: identifier.rawValue)
    }
}

public class HKScoredAssessmentType: HKSampleType, @unchecked Sendable {
    public init(_ identifier: HKScoredAssessmentTypeIdentifier) {
        super.init(identifier: identifier.rawValue)
    }
}


public class HKSeriesType: HKSampleType, @unchecked Sendable {
    fileprivate static let sharedWorkoutRouteType = HKSeriesType(identifier: HKWorkoutRouteTypeIdentifier)
    fileprivate static let sharedHeartbeatSeriesType = HKSeriesType(identifier: HKDataTypeIdentifierHeartbeatSeries)
}


public class HKWorkoutType: HKSampleType, @unchecked Sendable {
    fileprivate static let shared = HKWorkoutType(identifier: HKWorkoutTypeIdentifier)
}


public class HKPrescriptionType: HKSampleType, @unchecked Sendable {
    fileprivate static let visionPrescriptionType = HKPrescriptionType(identifier: HKVisionPrescriptionTypeIdentifier)
}


public class HKElectrocardiogramType: HKSampleType, @unchecked Sendable {
    fileprivate static let shared = HKElectrocardiogramType(identifier: HKElectrocardiogramTypeIdentifier)
}


public class HKAudiogramSampleType: HKSampleType, @unchecked Sendable {
    fileprivate static let shared = HKAudiogramSampleType(identifier: HKAudiogramSampleTypeIdentifier)
}


public class HKStateOfMindType: HKSampleType, @unchecked Sendable {
    fileprivate static let shared = HKStateOfMindType(identifier: HKDataTypeIdentifierStateOfMind)
}


public class HKDocumentType: HKSampleType, @unchecked Sendable {
    public init(_ identifier: HKDocumentTypeIdentifier) {
        super.init(identifier: identifier.rawValue)
    }
}


public class HKActivitySummaryType: HKSampleType, @unchecked Sendable {
    fileprivate static let shared = HKActivitySummaryType(identifier: HKActivitySummaryTypeIdentifier)
}

public class HKMedicationDoseEventType: HKSampleType, @unchecked Sendable {}
public class HKUserAnnotatedMedicationType: HKObjectType, @unchecked Sendable {}


extension HKObjectType {
    @available(*, deprecated, renamed: "HKQuantityType(_:)")
    public class func quantityType(forIdentifier identifier: HKQuantityTypeIdentifier) -> HKQuantityType? {
        HKQuantityType(identifier)
    }
    
    @available(*, deprecated, renamed: "HKCategoryType(_:)")
    public class func categoryType(forIdentifier identifier: HKCategoryTypeIdentifier) -> HKCategoryType? {
        HKCategoryType(identifier)
    }
    
    @available(*, deprecated, renamed: "HKCharacteristicType(_:)")
    public class func characteristicType(forIdentifier identifier: HKCharacteristicTypeIdentifier) -> HKCharacteristicType? {
        HKCharacteristicType(identifier)
    }
    
    @available(*, deprecated, renamed: "HKCorrelationType(_:)")
    public class func correlationType(forIdentifier identifier: HKCorrelationTypeIdentifier) -> HKCorrelationType? {
        HKCorrelationType(identifier)
    }
    
//    public class func documentType(forIdentifier identifier: HKDocumentTypeIdentifier) -> HKDocumentType?
    
    @available(*, unavailable, message: "Not yet implemented")
    public class func seriesType(forIdentifier identifier: String) -> HKSeriesType? {
        fatalError("Not yet implemented")
    }
    
    public class func workoutType() -> HKWorkoutType {
        HKWorkoutType.shared
    }
    
    @available(*, unavailable, message: "Not yet implemented")
    public class func activitySummaryType() -> HKActivitySummaryType {
        fatalError("Not yet implemented")
    }
    
    public class func audiogramSampleType() -> HKAudiogramSampleType {
        HKAudiogramSampleType.shared
    }
    
    public class func electrocardiogramType() -> HKElectrocardiogramType {
        HKElectrocardiogramType.shared
    }
    
    
    public class func visionPrescriptionType() -> HKPrescriptionType {
        HKPrescriptionType.visionPrescriptionType
    }
    
    public class func stateOfMindType() -> HKStateOfMindType {
        HKStateOfMindType.shared
    }
    
    @available(macOS 26.0, *)
    @available(*, unavailable, message: "Not yet implemented")
    public class func medicationDoseEventType() -> HKMedicationDoseEventType {
        fatalError("Not yet implemented")
    }
    
    @available(macOS 26.0, *)
    @available(*, unavailable, message: "Not yet implemented")
    public class func userAnnotatedMedicationType() -> HKUserAnnotatedMedicationType {
        fatalError("Not yet implemented")
    }
}


extension HKSeriesType {
    public static func workoutRoute() -> HKSeriesType {
        HKSeriesType.sharedWorkoutRouteType
    }
    
    public class func heartbeat() -> HKSeriesType {
        HKSeriesType.sharedHeartbeatSeriesType
    }
}

#endif
