//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

import FHIRModelsExtensions
import HealthKit
import ModelsDSTU2
import ModelsR4
public import SpeziFHIR
public import SpeziHealthKit


extension FHIRResource {
    /// Creates a new ``FHIRResource`` instance using an `HKSample`.
    /// - Parameters:
    ///   - sample: The sample that should be transformed in a ``FHIRResource``.
    ///   - healthKit: Optional `HealthKit` module used to query additional context such as symptoms and voltage measurements for electrocardiograms and attachments for clinical records.
    ///   - loadHealthKitAttachments: Indicates if the `HKAttachmentStore` should be queried for any document references found in clinical records.
    /// - Returns: Created ``FHIRResource`` instance.
    public static func initialize( // swiftlint:disable:this function_body_length cyclomatic_complexity
        basedOn sample: HKSample,
        using healthKit: HealthKit? = nil,
        loadHealthKitAttachments: Bool = false
    ) async throws -> FHIRResource {
        switch sample {
        #if !os(watchOS)
        case let record as HKClinicalRecord:
            guard let fhirResource = record.fhirResource else {
                throw SpeziHealthKitFHIRError.invalidFHIRResource
            }
            let decoder = JSONDecoder()
            switch fhirResource.fhirVersion.fhirRelease {
            case .dstu2:
                var resource = try decoder.decode(ModelsDSTU2.ResourceProxy.self, from: fhirResource.data).get()
                if var domainResource = resource as? any ModelsDSTU2.DomainResource {
                    if domainResource.extension == nil {
                        domainResource.extension = []
                    }
                    domainResource.extension!.append( // swiftlint:disable:this force_unwrapping
                        ModelsDSTU2.Extension(
                            url: FHIRExtensionURL.hkSampleId.dstu2,
                            value: .id(record.uuid.uuidString.asFHIRStringPrimitive())
                        )
                    )
                    resource = domainResource
                }
                var fhirResource = FHIRResource(
                    versionedResource: .dstu2(resource),
                    displayName: record.displayName
                )
                if loadHealthKitAttachments, let healthKit {
                    try await fhirResource.loadAttachments(for: record, using: healthKit)
                }
                return fhirResource
            case .r4:
                var resource = try decoder.decode(ModelsR4.ResourceProxy.self, from: fhirResource.data).get()
                if var domainResource = resource as? any ModelsR4.DomainResource {
                    if domainResource.extension == nil {
                        domainResource.extension = []
                    }
                    domainResource.extension!.append( // swiftlint:disable:this force_unwrapping
                        ModelsR4.Extension(
                            url: .hkSampleId,
                            value: .id(record.uuid.uuidString.asFHIRStringPrimitive())
                        )
                    )
                    resource = domainResource
                }
                var fhirResource = FHIRResource(
                    versionedResource: .r4(resource),
                    displayName: record.displayName
                )
                if loadHealthKitAttachments, let healthKit {
                    try await fhirResource.loadAttachments(for: record, using: healthKit)
                }
                return fhirResource
            case .unknown:
                fallthrough // swiftlint:disable:this no_fallthrough_only
            default:
                throw SpeziHealthKitFHIRError.invalidFHIRResource
            }
            #endif
        case let electrocardiogram as HKElectrocardiogram:
            guard let healthKit = healthKit else {
                fallthrough
            }
            
            async let symptoms = try electrocardiogram.symptoms(from: healthKit)
            async let voltageMeasurements = try electrocardiogram.voltageMeasurements(from: healthKit.healthStore)
            
            let electrocardiogramResource = try await electrocardiogram.observation(
                symptoms: symptoms,
                voltageMeasurements: voltageMeasurements.map { ($0.timeOffset, $0.voltage) }
            )
            return FHIRResource(
                versionedResource: .r4(electrocardiogramResource),
                displayName: String(localized: "FHIR_RESOURCES_SUMMARY_ID_TITLE \(electrocardiogramResource.id?.value?.string ?? "-")")
            )
        default:
            let genericResource = try sample.resource().get()
            return FHIRResource(
                versionedResource: .r4(genericResource),
                displayName: String(localized: "FHIR_RESOURCES_SUMMARY_ID_TITLE \(genericResource.id?.value?.string ?? "-")")
            )
        }
    }
}

#endif
