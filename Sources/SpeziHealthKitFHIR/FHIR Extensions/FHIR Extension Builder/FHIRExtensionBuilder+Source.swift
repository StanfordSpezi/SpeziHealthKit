//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

public import FHIRModelsExtensions
import Foundation
public import HealthKit
import ModelsR4


extension FHIRExtensionURL {
    /// Url of a FHIR Extension containing, if applicable, encoded `HKDevice` of the `HKObject` from which a FHIR `Observation` was created.
    public static let sourceDevice = Self("https://bdh.stanford.edu/fhir/defs/sourceDevice")
    
    /// Url of a FHIR Extension containing, if applicable, encoded `HKSourceRevision` of the `HKObject` from which a FHIR `Observation` was created.
    public static let sourceRevision = Self("https://bdh.stanford.edu/fhir/defs/sourceRevision")
}


extension FHIRExtensionBuilderProtocol where Self == FHIRExtensionBuilder<HKDevice> {
    /// A FHIR Extension Builder that writes a  `HKDevice` into a FHIR `Observation`.
    public static var sourceDevice: Self {
        .init { (device: HKDevice, observation) in
            var deviceInfo = Extension(url: .sourceDevice)
            let appendDeviceInfoEntry = { (keyPath: KeyPath<HKDevice, String?>) in
                guard let name = keyPath._kvcKeyPathString else {
                    print("Unable to obtain name for keyPath '\(keyPath)'. Skipping.")
                    return
                }
                guard let value = device[keyPath: keyPath] else {
                    return
                }
                deviceInfo.append(
                    extension: Extension(
                        url: .sourceDevice.appending(component: name),
                        value: .string(value.asFHIRStringPrimitive())
                    ),
                    behaviour: .replace
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
            observation.append(extension: deviceInfo, behaviour: .replace)
        }
    }
}


extension FHIRExtensionBuilderProtocol where Self == FHIRExtensionBuilder<HKSourceRevision> {
    /// A FHIR Extension Builder that writes a `HKSourceRevision` into a FHIR `Observation`.
    public static var sourceRevision: Self {
        .init { (revision: HKSourceRevision, observation) throws in // swiftlint:disable:this closure_body_length
            var deviceInfo = Extension(url: .sourceRevision)
            let fieldUrl = { (components: String...) in
                FHIRExtensionURL.sourceRevision.appending(components: components)
            }
            let appendDeviceInfoEntry = { (keyPath: KeyPath<HKSourceRevision, String?>) in
                guard let name = keyPath._kvcKeyPathString else {
                    print("Unable to obtain name for keyPath '\(keyPath)'. Skipping.")
                    return
                }
                guard let value = revision[keyPath: keyPath] else {
                    return
                }
                deviceInfo.append(
                    extension: Extension(url: fieldUrl(name), value: .string(value.asFHIRStringPrimitive())),
                    behaviour: .replace
                )
            }
            deviceInfo.append(
                extension: Extension(
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
                behaviour: .replace
            )
            appendDeviceInfoEntry(\.version)
            appendDeviceInfoEntry(\.productType)
            appendDeviceInfoEntry(\.OSVersion)
            observation.append(extension: deviceInfo, behaviour: .replace)
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
                observation.removeAllExtensions(withUrl: .sourceDevice)
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

#endif
