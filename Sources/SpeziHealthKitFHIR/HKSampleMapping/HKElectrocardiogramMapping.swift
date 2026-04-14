//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// An ``HKElectrocardiogramMapping`` allows developers to customize the mapping of an`HKElectrocardiogram` to an FHIR  observation.
public struct HKElectrocardiogramMapping: Decodable, Sendable {
    /// A default instance of an ``HKElectrocardiogramMapping`` instance allowing developers to customize the ``HKElectrocardiogramMapping``.
    ///
    /// The default values are loaded from the `HKSampleMapping.json` resource in the ``HealthKitOnFHIR`` Swift Package.
    public static let `default` = HKSampleMapping.default.electrocardiogramMapping
    
    
    /// The FHIR codings defined as ``MappedCode``s used for the `HKElectrocardiogram`.
    public var codings: [MappedCode]
    /// The FHIR categories defined as ``MappedCode``s used for the `HKElectrocardiogram`.
    public var categories: [MappedCode]
    /// Defines the mapping of the `classification` category sample  of an `HKElectrocardiogram` to an FHIR  observation.
    public var classification: HKCategorySampleMapping
    /// Defines the mapping of the `symptomsStatus` category sample  of an `HKElectrocardiogram` to an FHIR  observation.
    public var symptomsStatus: HKCategorySampleMapping
    /// Defines the mapping of the `numberOfVoltageMeasurements` quantity property of an `HKElectrocardiogram` to an FHIR  observation.
    public var numberOfVoltageMeasurements: HKQuantitySampleMapping
    /// Defines the mapping of the `samplingFrequency` quantity property of an `HKElectrocardiogram` to an FHIR  observation.
    public var samplingFrequency: HKQuantitySampleMapping
    /// Defines the mapping of the `averageHeartRate` quantity property of an `HKElectrocardiogram` to an FHIR observation.
    public var averageHeartRate: HKQuantitySampleMapping
    /// Defines the mapping of the `voltageMeasurements` of an `HKElectrocardiogram` to an FHIR observation.
    public var voltageMeasurements: HKQuantitySampleMapping
    /// Defines the precision represented as the number of decimal values for the voltage measurement mapping of an `HKElectrocardiogram` to an FHIR observation.
    public var voltagePrecision: UInt
    
    
    /// An ``HKCorrelationMapping`` allows developers to customize the mapping of an`HKElectrocardiogram` to an FHIR  observation.
    /// - Parameters:
    ///   - codings: The FHIR codings defined as ``MappedCode``s used for the specified `HKElectrocardiogram`
    ///   - categories: The FHIR categories defined as ``MappedCode``s used for the specified `HKElectrocardiogram`
    ///   - classification: Defines the mapping of the `classification` category sample  of an `HKElectrocardiogram` to an FHIR  observation.
    ///   - symptomsStatus: Defines the mapping of the `symptomsStatus` category sample  of an `HKElectrocardiogram` to an FHIR  observation.
    ///   - numberOfVoltageMeasurements: Defines the mapping of the `numberOfVoltageMeasurements` quantity property of an `HKElectrocardiogram` to an FHIR  observation.
    ///   - samplingFrequency: Defines the mapping of the `samplingFrequency` quantity property of an `HKElectrocardiogram` to an FHIR  observation.
    ///   - averageHeartRate: Defines the mapping of the `averageHeartRate` quantity property of an `HKElectrocardiogram` to an FHIR  observation.
    ///   - voltageMeasurements: Defines the mapping of the `voltageMeasurements` of an `HKElectrocardiogram` to an FHIR  observation.
    ///   - voltagePrecision: Defines the precision represented as the number of decimal values for the voltage measurement mapping of an `HKElectrocardiogram` to an FHIR observation.
    public init(
        codings: [MappedCode] = Self.default.codings,
        categories: [MappedCode] = Self.default.categories,
        classification: HKCategorySampleMapping = Self.default.classification,
        symptomsStatus: HKCategorySampleMapping = Self.default.symptomsStatus,
        numberOfVoltageMeasurements: HKQuantitySampleMapping = Self.default.numberOfVoltageMeasurements,
        samplingFrequency: HKQuantitySampleMapping = Self.default.samplingFrequency,
        averageHeartRate: HKQuantitySampleMapping = Self.default.averageHeartRate,
        voltageMeasurements: HKQuantitySampleMapping = Self.default.voltageMeasurements,
        voltagePrecision: UInt = Self.default.voltagePrecision
    ) {
        self.codings = codings
        self.categories = categories
        self.classification = classification
        self.symptomsStatus = symptomsStatus
        self.numberOfVoltageMeasurements = numberOfVoltageMeasurements
        self.samplingFrequency = samplingFrequency
        self.averageHeartRate = averageHeartRate
        self.voltageMeasurements = voltageMeasurements
        self.voltagePrecision = voltagePrecision
    }
}
