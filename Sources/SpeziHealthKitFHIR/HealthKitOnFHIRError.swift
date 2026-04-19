//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// Error thrown by the SpeziHealthKitFHIR module if transforming a specific `HKSample` type to an FHIR resource was not possible.
public enum SpeziHealthKitFHIRError: Error {
    /// Indicates that a specific `HKSample` type is currently not supported by SpeziHealthKitFHIIR.
    case notSupported
    /// Indicates that a specific value is not valid
    case invalidValue
    /// Indicates that the given FHIR resource encoded in an `HKClinicalRecord` uses an unsupported version
    case unsupportedFHIRVersion
    /// Indicates that the fhirResource property of an `HKClinicalRecord` is nil
    case invalidFHIRResource
}
