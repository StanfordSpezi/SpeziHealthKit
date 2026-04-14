//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import ModelsDSTU2
import ModelsR4
import SpeziFHIR
import SpeziHealthKit


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
        case let record as HKClinicalRecord:
            guard let fhirResource = record.fhirResource else {
                throw HealthKitOnFHIRError.invalidFHIRResource
            }
            let decoder = JSONDecoder()
            switch fhirResource.fhirVersion.fhirRelease {
            case .dstu2:
                let resourceProxy = try decoder.decode(ModelsDSTU2.ResourceProxy.self, from: fhirResource.data)
                if let domainResource = resourceProxy.get(if: ModelsDSTU2.DomainResource.self) {
                    if domainResource.extension == nil {
                        domainResource.extension = []
                    }
                    domainResource.extension!.append( // swiftlint:disable:this force_unwrapping
                        ModelsDSTU2.Extension(
                            url: Self.fhirExtensionUrlHKSampleId.asFHIRURIPrimitive(),
                            value: .id(record.uuid.uuidString.asFHIRStringPrimitive())
                        )
                    )
                }
                var resource = FHIRResource(
                    versionedResource: .dstu2(resourceProxy.get()),
                    displayName: record.displayName
                )
                if loadHealthKitAttachments, let healthKit {
                    try await resource.loadAttachments(for: record, using: healthKit)
                }
                return resource
            case .r4:
                let resourceProxy = try decoder.decode(ModelsR4.ResourceProxy.self, from: fhirResource.data)
                if let domainResource = resourceProxy.get(if: ModelsR4.DomainResource.self) {
                    if domainResource.extension == nil {
                        domainResource.extension = []
                    }
                    domainResource.extension!.append( // swiftlint:disable:this force_unwrapping
                        ModelsR4.Extension(
                            url: Self.fhirExtensionUrlHKSampleId.asFHIRURIPrimitive(),
                            value: .id(record.uuid.uuidString.asFHIRStringPrimitive())
                        )
                    )
                }
                var resource = FHIRResource(
                    versionedResource: .r4(resourceProxy.get()),
                    displayName: record.displayName
                )
                if loadHealthKitAttachments, let healthKit {
                    try await resource.loadAttachments(for: record, using: healthKit)
                }
                return resource
            case .unknown:
                fallthrough // swiftlint:disable:this no_fallthrough_only
            default:
                throw HealthKitOnFHIRError.invalidFHIRResource
            }
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
