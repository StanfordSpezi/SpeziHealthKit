//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import FHIRModelsExtensions
import Foundation
import HealthKit
import ModelsR4


extension FHIRExtensionUrls {
    // SAFETY: this is in fact safe, since the FHIRPrimitive's `extension` property is empty.
    // As a result, the actual instance doesn't contain any mutable state, and since this is a let,
    // it also never can be mutated to contain any.
    /// Url of a FHIR Extension containing, if applicable, encoded `HKDevice` of the `HKObject` from which a FHIR `Observation` was created.
    nonisolated(unsafe) public static let sourceDevice: FHIRPrimitive<ModelsR4.FHIRURI> = "https://bdh.stanford.edu/fhir/defs/sourceDevice".asFHIRURIPrimitive()!
    // swiftlint:disable:previous force_unwrapping
    
    // SAFETY: this is in fact safe, since the FHIRPrimitive's `extension` property is empty.
    // As a result, the actual instance doesn't contain any mutable state, and since this is a let,
    // it also never can be mutated to contain any.
    /// Url of a FHIR Extension containing, if applicable, encoded `HKSourceRevision` of the `HKObject` from which a FHIR `Observation` was created.
    nonisolated(unsafe) public static let sourceRevision: FHIRPrimitive<ModelsR4.FHIRURI> = "https://bdh.stanford.edu/fhir/defs/sourceRevision".asFHIRURIPrimitive()!
    // swiftlint:disable:previous force_unwrapping
}


extension FHIRExtensionBuilderProtocol where Self == FHIRExtensionBuilder<HKDevice> {
    /// A FHIR Extension Builder that writes a  `HKDevice` into a FHIR `Observation`.
    public static var sourceDevice: Self {
        .init { (device: HKDevice, observation) in
            let deviceInfo = Extension(url: FHIRExtensionUrls.sourceDevice)
            let appendDeviceInfoEntry = { (keyPath: KeyPath<HKDevice, String?>) in
                guard let name = keyPath._kvcKeyPathString else {
                    print("Unable to obtain name for keyPath '\(keyPath)'. Skipping.")
                    return
                }
                guard let value = device[keyPath: keyPath] else {
                    return
                }
                let url = FHIRExtensionUrls.sourceDevice.appending(component: name)
                deviceInfo.appendExtension(
                    Extension(url: url, value: .string(value.asFHIRStringPrimitive())),
                    replaceAllExistingWithSameUrl: true
                )
            }
            appendDeviceInfoEntry(\.name)
            appendDeviceInfoEntry(\.manufacturer)
            appendDeviceInfoEntry(\.model)
            appendDeviceInfoEntry(\.hardwareVersion)
            appendDeviceInfoEntry(\.firmwareVersion)
            appendDeviceInfoEntry(\.softwareVersion)
            appendDeviceInfoEntry(\.localIdentifier)
            appendDeviceInfoEntry(\.udiDeviceIdentifier)
            observation.appendExtension(deviceInfo, replaceAllExistingWithSameUrl: true)
        }
    }
}


extension FHIRExtensionBuilderProtocol where Self == FHIRExtensionBuilder<HKSourceRevision> {
    /// A FHIR Extension Builder that writes a `HKSourceRevision` into a FHIR `Observation`.
    public static var sourceRevision: Self {
        .init { (revision: HKSourceRevision, observation) throws in // swiftlint:disable:this closure_body_length
            let deviceInfo = Extension(url: FHIRExtensionUrls.sourceRevision)
            let fieldUrl = { (components: String...) in
                FHIRExtensionUrls.sourceRevision.appending(components: components)
            }
            let appendDeviceInfoEntry = { (keyPath: KeyPath<HKSourceRevision, String?>) in
                guard let name = keyPath._kvcKeyPathString else {
                    print("Unable to obtain name for keyPath '\(keyPath)'. Skipping.")
                    return
                }
                guard let value = revision[keyPath: keyPath] else {
                    return
                }
                let url = fieldUrl(name)
                deviceInfo.appendExtension(
                    Extension(url: url, value: .string(value.asFHIRStringPrimitive())),
                    replaceAllExistingWithSameUrl: true
                )
            }
            deviceInfo.appendExtension(
                Extension(
                    extension: [
                        Extension(
                            url: fieldUrl("source", "name"),
                            value: .string(revision.source.name.asFHIRStringPrimitive())
                        ),
                        Extension(
                            url: fieldUrl("source", "bundleIdentifier"),
                            value: .string(revision.source.bundleIdentifier.asFHIRStringPrimitive())
                        )
                    ],
                    url: fieldUrl("source")
                ),
                replaceAllExistingWithSameUrl: true
            )
            appendDeviceInfoEntry(\.version)
            appendDeviceInfoEntry(\.productType)
            appendDeviceInfoEntry(\.OSVersion)
            observation.appendExtension(deviceInfo, replaceAllExistingWithSameUrl: true)
        }
    }
}


extension FHIRExtensionBuilderProtocol where Self == FHIRExtensionBuilder<HKObject> {
    /// A FHIR Extension Builder that writes a HealthKit object's `HKSourceRevision` into a FHIR `Observation` created from the sample.
    public static var sourceRevision: Self {
        .init { object, observation in
            try observation.apply(.sourceRevision, input: object.sourceRevision)
        }
    }
    
    /// A FHIR Extension Builder that writes a HealthKit object's `HKDevice` into a FHIR `Observation` created from the sample.
    public static var sourceDevice: Self {
        .init { object, observation in
            if let device = object.device {
                try observation.apply(.sourceDevice, input: device)
            } else {
                observation.removeAllExtensions(withUrl: FHIRExtensionUrls.sourceDevice)
            }
        }
    }
}


extension HKSourceRevision {
    /// We define this as an optional String objc-compatible property, so that we can encode it into an Extension using the API we have above.
    @objc fileprivate var OSVersion: String? {
        let version = operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }
}
