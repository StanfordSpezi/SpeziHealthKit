//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import FHIRModelsExtensions
public import Foundation
public import HealthKit
public import ModelsR4
import SpeziHealthKit
import SpeziHealthKitFHIRMacros


extension HKElectrocardiogram {
    /// The `Symptoms` contain related `HKCategoryType` instances coded as `HKCategoryValueSeverity` enums related to an `HKElectrocardiogram`.
    public typealias Symptoms = [HKCategoryType: HKCategoryValueSeverity]
    /// The raw voltage measurements are defined as `HKQuantity` samples that are correlating to a specific measurement time.
    ///
    /// The voltage measurements must be sorted by time interval.
    public typealias VoltageMeasurements = [(time: TimeInterval, value: HKQuantity)]
    
    
    /// Creates an FHIR  observation incorporating additional `Symptoms` and`VoltageMeasurements` collected in HealthKit.
    /// If you do not need `HKElectrocardiogram` specific context added you can use the generic `observation` extension on `HKSample`.
    ///
    /// - Parameters:
    ///   - symptoms: The ``Symptoms`` that should be encoded in the FHIR observation.
    ///   - voltageMeasurements: The URL pointing to the raw voltage measurement data corrolated ot the FHIR observation.
    ///   - mapping: The ``HKSampleMapping`` used to populate the FHIR observation.
    ///   - issuedDate: `Instant` specifying when this version of the resource was made available. Defaults to `Date.now`.
    ///   - extensions: ``FHIRExtensionBuilder``s that should be applied to the resulting `Observation`.
    public func observation(
        symptoms: Symptoms,
        voltageMeasurements: VoltageMeasurements,
        withMapping mapping: SampleTypesFHIRMapping = .default,
        issuedDate: FHIRPrimitive<Instant>? = nil,
        extensions: [any FHIRExtensionBuilderProtocol] = []
    ) throws -> Observation {
        guard var observation = try resource(withMapping: mapping, issuedDate: issuedDate, extensions: extensions).get(if: Observation.self) else {
            throw SpeziHealthKitFHIRError.notSupported
        }
        if !symptoms.isEmpty {
            try appendSymptomsComponent(to: &observation, symptoms: symptoms, mappings: mapping)
        }
        if !voltageMeasurements.isEmpty {
            try appendVoltageMeasurementsComponent(to: &observation, voltageMeasurements: voltageMeasurements, mapping: mapping.ecgTypeMapping)
        }
        return observation
    }
}


extension HKElectrocardiogram: FHIRObservationBuildable {
    func build(_ observation: inout Observation, mapping: SampleTypesFHIRMapping) throws {
        let mapping = mapping.ecgTypeMapping
        observation.append(codings: mapping.codings)
        for category in mapping.categories {
            observation.append(
                category: CodeableConcept(coding: [category])
            )
        }
        try appendNumberOfVoltageMeasurementsComponent(to: &observation, mapping: mapping)
        try appendSamplingFrequencyComponent(to: &observation, mapping: mapping)
        appendClassificationComponent(to: &observation, mapping: mapping)
        try appendAverageHeartRateComponent(to: &observation, mapping: mapping)
        appendSymptomsStatusComponent(to: &observation, mapping: mapping)
    }
    
    
    private func appendNumberOfVoltageMeasurementsComponent(
        to observation: inout Observation,
        mapping: ECGTypeFHIRMapping
    ) throws {
        let component = ObservationComponent(
            code: CodeableConcept(coding: mapping.numberOfVoltageMeasurements.codings),
            value: .quantity(
                Quantity(
                    code: mapping.numberOfVoltageMeasurements.unit.code,
                    system: mapping.numberOfVoltageMeasurements.unit.system,
                    unit: mapping.numberOfVoltageMeasurements.unit.unit.asFHIRStringPrimitive(),
                    value: try Double(numberOfVoltageMeasurements).asFHIRDecimalPrimitiveSafe()
                )
            )
        )
        observation.append(component: component)
    }
    
    private func appendSamplingFrequencyComponent(
        to observation: inout Observation,
        mapping: ECGTypeFHIRMapping
    ) throws {
        guard let samplingFrequency else {
            return
        }
        let component = ObservationComponent(
            code: CodeableConcept(coding: mapping.samplingFrequency.codings),
            value: .quantity(
                Quantity(
                    code: mapping.samplingFrequency.unit.code,
                    system: mapping.samplingFrequency.unit.system,
                    unit: mapping.samplingFrequency.unit.unit.asFHIRStringPrimitive(),
                    value: try samplingFrequency.doubleValue(for: mapping.samplingFrequency.unit.hkUnit).asFHIRDecimalPrimitiveSafe()
                )
            )
        )
        observation.append(component: component)
    }
    
    private func appendClassificationComponent(
        to observation: inout Observation,
        mapping: ECGTypeFHIRMapping
    ) {
        let component = ObservationComponent(
            code: CodeableConcept(coding: mapping.classification.codings),
            value: .codeableConcept(CodeableConcept(coding: [classification.asCoding]))
        )
        observation.append(component: component)
    }
    
    private func appendAverageHeartRateComponent(
        to observation: inout Observation,
        mapping: ECGTypeFHIRMapping
    ) throws {
        guard let averageHeartRate else {
            return
        }
        let component = ObservationComponent(
            code: CodeableConcept(coding: mapping.averageHeartRate.codings),
            value: .quantity(
                Quantity(
                    code: mapping.averageHeartRate.unit.code,
                    system: mapping.averageHeartRate.unit.system,
                    unit: mapping.averageHeartRate.unit.unit.asFHIRStringPrimitive(),
                    value: try averageHeartRate.doubleValue(for: mapping.averageHeartRate.unit.hkUnit).asFHIRDecimalPrimitiveSafe()
                )
            )
        )
        observation.append(component: component)
    }
    
    private func appendSymptomsStatusComponent(
        to observation: inout Observation,
        mapping: ECGTypeFHIRMapping
    ) {
        let component = ObservationComponent(
            code: CodeableConcept(coding: mapping.symptomsStatus.codings),
            value: .codeableConcept(CodeableConcept(coding: [symptomsStatus.asCoding]))
        )
        observation.append(component: component)
    }
    
    
    private func appendSymptomsComponent(
        to observation: inout Observation,
        symptoms: Symptoms,
        mappings: SampleTypesFHIRMapping
    ) throws {
        for symptom in symptoms {
            guard let sampleType = SampleType(symptom.key),
                  let mapping = mappings.categoryTypesMapping[sampleType] else {
                throw SpeziHealthKitFHIRError.notSupported
            }
            let component = ObservationComponent(
                code: CodeableConcept(coding: mapping.codings),
                value: .codeableConcept(CodeableConcept(coding: [symptom.value.asCoding]))
            )
            observation.append(component: component)
        }
    }
    
    
    private func appendVoltageMeasurementsComponent(
        to observation: inout Observation,
        voltageMeasurements: VoltageMeasurements,
        mapping ecgTypeMapping: ECGTypeFHIRMapping
    ) throws {
        let voltageMapping = ecgTypeMapping.voltageMeasurements
        let voltageMeasurements = voltageMeasurements.sorted(by: { $0.time < $1.time })
        
        // Number of milliseconds between samples
        let period: Double = if let samplingFrequency {
            (1.0 / samplingFrequency.doubleValue(for: .hertz())) * 1000
        } else {
            ((voltageMeasurements.last?.time ?? 0.0) * 1000) / Double(voltageMeasurements.count)
        }
        
        // Batch the measurements in 10 Second Intervals
        var lastIndex = 0
        var lastRemainder = 10.0
        var voltageMeasurementBatches: [[(time: TimeInterval, value: HKQuantity)]] = []
        for voltageMeasurement in voltageMeasurements.enumerated() {
            let remainder = voltageMeasurement.element.time.truncatingRemainder(dividingBy: 10.0)
            if lastRemainder > remainder && lastIndex < voltageMeasurement.offset {
                voltageMeasurementBatches.append(Array(voltageMeasurements[lastIndex..<voltageMeasurement.offset]))
                lastIndex = voltageMeasurement.offset
            }
            lastRemainder = remainder
        }
        // Append the last elements that are left over (ideally exactly 10 seconds of data).
        voltageMeasurementBatches.append(Array(voltageMeasurements[lastIndex..<voltageMeasurements.count]))
        
        // Check that we did not loose any data in the batching process.
        assert(voltageMeasurements.count == voltageMeasurementBatches.reduce(0, { $0 + $1.count }))
        
        let voltagePrecision = ecgTypeMapping.voltagePrecision
        for voltageMeasurementBatch in voltageMeasurementBatches {
            // Create a space separated string of all the measurement values as defined by the mapping unit
            let data = voltageMeasurementBatch
                .map { String(format: "%.\(voltagePrecision)f", $0.value.doubleValue(for: voltageMapping.unit.hkUnit)) }
                .joined(separator: " ")
            let component = ObservationComponent(
                code: CodeableConcept(coding: voltageMapping.codings),
                value: .sampledData(
                    SampledData(
                        data: data.asFHIRStringPrimitive(),
                        dimensions: 1,
                        origin: Quantity(
                            code: voltageMapping.unit.code,
                            system: voltageMapping.unit.system,
                            unit: voltageMapping.unit.unit.asFHIRStringPrimitive(),
                            value: 0.asFHIRDecimalPrimitive()
                        ),
                        period: try period.asFHIRDecimalPrimitiveSafe()
                    )
                )
            )
            observation.append(component: component)
        }
    }
}


// MARK: HKElectrocardiogram-related enums

@SynthesizeDisplayProperty(
    HKElectrocardiogram.Classification.self,
    .notSet, .sinusRhythm, .atrialFibrillation, .inconclusiveLowHeartRate,
    .inconclusiveHighHeartRate, .inconclusivePoorReading, .inconclusiveOther, .unrecognized
)
extension HKElectrocardiogram.Classification: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKElectrocardiogram.SymptomsStatus.self,
    .notSet, .none, .present
)
extension HKElectrocardiogram.SymptomsStatus: FHIRCodingConvertibleHKEnum {}
