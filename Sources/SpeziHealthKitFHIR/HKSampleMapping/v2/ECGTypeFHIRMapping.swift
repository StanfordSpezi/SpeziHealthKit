//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import ModelsR4
private import SpeziHealthKit


/// Controls how a `HKElectrocardiogram` is mapped into a FHIR Observation.
///
/// ## Topics
///
/// ### Static Properties
/// - ``default``
///
/// ### Initializers
/// - ``init(codings:categories:classification:symptomsStatus:numberOfVoltageMeasurements:samplingFrequency:averageHeartRate:voltageMeasurements:voltagePrecision:)``
///
/// ### Instance Properties
/// - ``codings``
/// - ``categories``
/// - ``classification``
/// - ``symptomsStatus``
/// - ``numberOfVoltageMeasurements``
/// - ``samplingFrequency``
/// - ``averageHeartRate``
/// - ``voltageMeasurements``
/// - ``voltagePrecision``
public struct ECGTypeFHIRMapping: Hashable, Sendable {
    /// The FHIR codings defined as `Coding`s used for the `HKElectrocardiogram`.
    public var codings: [Coding]
    /// The FHIR categories defined as `Coding`s used for the `HKElectrocardiogram`.
    public var categories: [Coding]
    /// Defines the mapping of the `classification` category sample  of an `HKElectrocardiogram` to an FHIR  observation.
    public var classification: CategoryTypeFHIRMapping
    /// Defines the mapping of the `symptomsStatus` category sample  of an `HKElectrocardiogram` to an FHIR  observation.
    public var symptomsStatus: CategoryTypeFHIRMapping
    /// Defines the mapping of the `numberOfVoltageMeasurements` quantity property of an `HKElectrocardiogram` to an FHIR  observation.
    public var numberOfVoltageMeasurements: QuantityTypeFHIRMapping
    /// Defines the mapping of the `samplingFrequency` quantity property of an `HKElectrocardiogram` to an FHIR  observation.
    public var samplingFrequency: QuantityTypeFHIRMapping
    /// Defines the mapping of the `averageHeartRate` quantity property of an `HKElectrocardiogram` to an FHIR observation.
    public var averageHeartRate: QuantityTypeFHIRMapping
    /// Defines the mapping of the `voltageMeasurements` of an `HKElectrocardiogram` to an FHIR observation.
    public var voltageMeasurements: QuantityTypeFHIRMapping
    /// Defines the precision represented as the number of decimal values for the voltage measurement mapping of an `HKElectrocardiogram` to an FHIR observation.
    public var voltagePrecision: UInt
    
    public init(
        codings: [Coding],
        categories: [Coding],
        classification: CategoryTypeFHIRMapping,
        symptomsStatus: CategoryTypeFHIRMapping,
        numberOfVoltageMeasurements: QuantityTypeFHIRMapping,
        samplingFrequency: QuantityTypeFHIRMapping,
        averageHeartRate: QuantityTypeFHIRMapping,
        voltageMeasurements: QuantityTypeFHIRMapping,
        voltagePrecision: UInt
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


extension ECGTypeFHIRMapping {
    /// The default FHIR mapping for `HKElectrocardiogram` samples.
    public static let `default` = Self(
        codings: [
            Coding(
                code: "HKElectrocardiogram",
                display: "Electrocardiogram",
                system: "http://developer.apple.com/documentation/healthkit"
            ),
            Coding(
                code: "131328",
                display: "MDC_ECG_ELEC_POTL",
                system: "urn:oid:2.16.840.1.113883.6.24"
            )
        ],
        categories: [
            Coding(
                code: "procedure",
                display: "Procedure",
                system: "http://terminology.hl7.org/CodeSystem/observation-category"
            )
        ],
        classification: CategoryTypeFHIRMapping(codings: [
            Coding(
                code: "HKElectrocardiogram.Classification",
                display: "Electrocardiogram Classification",
                system: "http://developer.apple.com/documentation/healthkit"
            )
        ]),
        symptomsStatus: CategoryTypeFHIRMapping(codings: [
            Coding(
                code: "HKElectrocardiogram.SymptomsStatus",
                display: "Electrocardiogram Symptoms Status",
                system: "http://developer.apple.com/documentation/healthkit"
            )
        ]),
        numberOfVoltageMeasurements: QuantityTypeFHIRMapping(
            codings: [
                Coding(
                    code: "HKElectrocardiogram.NumberOfVoltageMeasurements",
                    display: "Electrocardiogram Number of Voltage Measurements",
                    system: "http://developer.apple.com/documentation/healthkit"
                )
            ],
            unit: QuantityTypeFHIRMapping.Unit(
                hkUnit: .count(),
                unit: "measurements",
                system: nil,
                code: nil
            )
        ),
        samplingFrequency: QuantityTypeFHIRMapping(
            codings: [
                Coding(
                    code: "HKElectrocardiogram.SamplingFrequency",
                    display: "Sampling Frequency",
                    system: "http://developer.apple.com/documentation/healthkit"
                )
            ],
            unit: QuantityTypeFHIRMapping.Unit(
                hkUnit: .hertz(),
                unit: "Hz",
                system: "http://unitsofmeasure.org",
                code: "hertz"
            )
        ),
        averageHeartRate: QuantityTypeFHIRMapping(
            codings: [
                Coding(
                    code: "8867-4",
                    display: "Heart rate",
                    system: "http://loinc.org"
                ),
                Coding(
                    code: "HKQuantityTypeIdentifierHeartRate",
                    display: "Heart Rate",
                    system: "http://developer.apple.com/documentation/healthkit"
                )
            ],
            unit: QuantityTypeFHIRMapping.Unit(
                hkUnit: .count() / .minute(),
                unit: "/min",
                system: "http://unitsofmeasure.org",
                code: "beats/minute"
            )
        ),
        voltageMeasurements: QuantityTypeFHIRMapping(
            codings: [
                Coding(
                    code: "131329",
                    display: "MDC_ECG_ELEC_POTL_I",
                    system: "urn:oid:2.16.840.1.113883.6.24"
                )
            ],
            unit: QuantityTypeFHIRMapping.Unit(
                hkUnit: .voltUnit(with: .micro),
                unit: "uV",
                system: "http://unitsofmeasure.org",
                code: "uV"
            )
        ),
        voltagePrecision: 3
    )
}
