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
///
/// You can turn a ``SampleTypeProxy`` back into a proper fully-typed ``SampleType`` by means of the ``underlyingSampleType`` property and ``SampleType/init(_:)-6kzr1``:
///
/// ```swift
/// func doSomething(_ sampleType: SampleTypeProxy) -> Result {
///     func imp<Sample>(_ sampleType: some AnySampleType<Sample>) -> Result {
///         let sampleType = SampleType(sampleType)
///         // actual implementation, using the `sampleType` variable, which now has type `SampleType<Sample>`
///     }
///     return imp(sampleType.underlyingSampleType)
/// }
/// ```
public enum SampleTypeProxy: Identifiable, Sendable {
    /// An Error that can occur when attempting to create a ``SampleTypeProxy`` from another `SampleType`.
    public enum InitError: Swift.Error {
        /// `SampleTypeProxy` is not currently able to represent this `AnySampleType`.
        case unableToRepresent(any AnySampleType)
    }
    
    case quantity(SampleType<HKQuantitySample>)
    case correlation(SampleType<HKCorrelation>)
    case category(SampleType<HKCategorySample>)
    #if !os(watchOS)
    case clinical(SampleType<HKClinicalRecord>)
    #endif
    case electrocardiogram(SampleType<HKElectrocardiogram>)
    case audiogram(SampleType<HKAudiogramSample>)
    case workout(SampleType<HKWorkout>)
    /// - Note: The associated value here is of type `SampleType<HKStateOfMind>`, but this cannot expressed this way because the `HKStateOfMind` type is only available starting with iOS 18.
    ///     The type will be changed in an upcoming release, and should always be treated as `SampleType<HKStateOfMind>`.
    case stateOfMind(any AnySampleType)
    
    /// The type-erased underlying ``AnySampleType``.
    ///
    /// You can use this property to obtain a proper fully-typed ``SampleType`` from a ``SampleTypeProxy``, via ``SampleType/init(_:)-6kzr1``:
    /// ```swift
    /// func doSomething(_ sampleType: SampleTypeProxy) -> Result {
    ///     func imp<Sample>(_ sampleType: some AnySampleType<Sample>) -> Result {
    ///         let sampleType = SampleType(sampleType)
    ///         // actual implementation, using the `sampleType` variable, which now has type `SampleType<Sample>`
    ///     }
    ///     return imp(sampleType.underlyingSampleType)
    /// }
    /// ```
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
        case .stateOfMind(let sampleType):
            sampleType
        }
    }
    
    @inlinable
    public var id: String {
        underlyingSampleType.id
    }
}


extension SampleTypeProxy: Equatable, Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.quantity(lhs), .quantity(rhs)):
            lhs == rhs
        case let (.correlation(lhs), .correlation(rhs)):
            lhs == rhs
        case let (.category(lhs), .category(rhs)):
            lhs == rhs
        case let (.clinical(lhs), .clinical(rhs)):
            lhs == rhs
        case let (.electrocardiogram(lhs), .electrocardiogram(rhs)):
            lhs == rhs
        case let (.audiogram(lhs), .audiogram(rhs)):
            lhs == rhs
        case let (.workout(lhs), .workout(rhs)):
            lhs == rhs
        case let (.stateOfMind(lhs), .stateOfMind(rhs)):
            lhs == rhs
        default: false
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .quantity(let sampleType):
            hasher.combine(sampleType)
        case .correlation(let sampleType):
            hasher.combine(sampleType)
        case .category(let sampleType):
            hasher.combine(sampleType)
        case .clinical(let sampleType):
            hasher.combine(sampleType)
        case .electrocardiogram(let sampleType):
            hasher.combine(sampleType)
        case .audiogram(let sampleType):
            hasher.combine(sampleType)
        case .workout(let sampleType):
            hasher.combine(sampleType)
        case .stateOfMind(let sampleType):
            hasher.combine(sampleType)
        }
    }
}


extension SampleTypeProxy: Codable {
    /// An error that can occur when decoding a ``SampleTypeProxy``.
    public enum SampleTypeDecodingError: Error {
        case unknownSampleTypeClassname(String)
        case unknownSampleTypeIdentifier(String)
    }
    
    public init(from decoder: any Decoder) throws { // swiftlint:disable:this cyclomatic_complexity
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
        case .some(let cls):
            if #available(iOS 18.0, watchOS 11.0, macOS 15.0, visionOS 2.0, *), cls is HKStateOfMindType.Type {
                self = .stateOfMind(SampleType.stateOfMind)
            } else {
                throw SampleTypeDecodingError.unknownSampleTypeClassname(sampleTypeClassname)
            }
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        let classname = NSStringFromClass(type(of: underlyingSampleType.hkSampleType))
        try container.encode("\(classname);\(underlyingSampleType.hkSampleType.identifier)")
    }
}


/// Compare two sample types, based on their identifiers
@inlinable // swiftlint:disable:next static_operator
public func ~= (pattern: SampleType<some Any>, value: SampleTypeProxy) -> Bool {
    pattern.id == value.id
}
