//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


/// An enum for working with ``SampleType``s in non-generic contexts.
///
/// This utility type is useful for APIs which operate on heterogeneous collections of ``SampleType``s,
/// and in contexts where generics aren't easily available, e.g. when using ``SampleType``s as `Codable` properties.
public enum WrappedSampleType: Hashable, Identifiable, Sendable {
    case quantity(SampleType<HKQuantitySample>)
    case correlation(SampleType<HKCorrelation>)
    case category(SampleType<HKCategorySample>)
    #if !os(watchOS)
    case clinical(SampleType<HKClinicalRecord>)
    #endif
    case electrocardiogram(SampleType<HKElectrocardiogram>)
    case audiogram(SampleType<HKAudiogramSample>)
    case workout(SampleType<HKWorkout>)
    
    /// The type-erased underlying ``AnySampleType``.
    public var underlyingSampleType: any AnySampleType {
        switch self {
        case .quantity(let sampleType):
            sampleType
        case .correlation(let sampleType):
            sampleType
        case .category(let sampleType):
            sampleType
        #if !os(watchOS)
        case .clinical(let sampleType):
            sampleType
        #endif
        case .electrocardiogram(let sampleType):
            sampleType
        case .audiogram(let sampleType):
            sampleType
        case .workout(let sampleType):
            sampleType
        }
    }
    
    public var id: String {
        underlyingSampleType.id
    }
    
    /// Attempts to wrap a sample type.
    public init?(_ sampleType: any AnySampleType) {
        if let sampleType = sampleType as? SampleType<HKQuantitySample> {
            self = .quantity(sampleType)
        } else if let sampleType = sampleType as? SampleType<HKCorrelation> {
            self = .correlation(sampleType)
        } else if let sampleType = sampleType as? SampleType<HKCategorySample> {
            self = .category(sampleType)
        } else if let sampleType = sampleType as? SampleType<HKElectrocardiogram> {
            self = .electrocardiogram(sampleType)
        } else if let sampleType = sampleType as? SampleType<HKAudiogramSample> {
            self = .audiogram(sampleType)
        } else if let sampleType = sampleType as? SampleType<HKWorkout> {
            self = .workout(sampleType)
        } else {
            #if !os(watchOS)
            if let sampleType = sampleType as? SampleType<HKClinicalRecord> {
                self = .clinical(sampleType)
            }
            #endif
            return nil
        }
    }
}


extension WrappedSampleType: Codable {
    /// An error that can occur when decoding a ``WrappedSampleType``.
    public enum SampleTypeDecodingError: Error {
        case unknownSampleTypeClassname(String)
        case unknownSampleTypeIdentifier(String)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        let components = rawValue.components(separatedBy: ";")
        guard components.count == 2 else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid encoded value"))
        }
        let sampleTypeClassname = components[0]
        let sampleTypeIdentifier = components[1]
        func tryInit<T>(
            _ sampleTypeInit: @Sendable (T._SampleType._Identifier) -> SampleType<T>?
        ) throws -> SampleType<T> where T._SampleType: _HKSampleTypeWithIdentifierType {
            let identifier = T._SampleType._Identifier(rawValue: sampleTypeIdentifier)
            if let sampleType = sampleTypeInit(identifier) {
                return sampleType
            } else {
                throw SampleTypeDecodingError.unknownSampleTypeIdentifier(sampleTypeIdentifier)
            }
        }
        switch NSClassFromString(sampleTypeClassname) {
        case nil:
            throw SampleTypeDecodingError.unknownSampleTypeClassname(sampleTypeClassname)
        case is HKQuantityType.Type:
            self = .quantity(try tryInit(SampleType<HKQuantitySample>.init(_:)))
        case is HKCorrelationType.Type:
            self = .correlation(try tryInit(SampleType<HKCorrelation>.init(_:)))
        case is HKCategoryType.Type:
            self = .category(try tryInit(SampleType<HKCategorySample>.init(_:)))
        #if !os(watchOS)
        case is HKClinicalType.Type:
            self = .clinical(try tryInit(SampleType<HKClinicalRecord>.init(_:)))
        #endif
        case is HKElectrocardiogramType.Type:
            self = .electrocardiogram(.electrocardiogram)
        case is HKAudiogramSampleType.Type:
            self = .audiogram(.audiogram)
        case is HKWorkoutType.Type:
            self = .workout(.workout)
        default:
            throw SampleTypeDecodingError.unknownSampleTypeClassname(sampleTypeClassname)
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        let classname = NSStringFromClass(type(of: underlyingSampleType.hkSampleType))
        try container.encode("\(classname);\(underlyingSampleType.hkSampleType.identifier)")
    }
}
