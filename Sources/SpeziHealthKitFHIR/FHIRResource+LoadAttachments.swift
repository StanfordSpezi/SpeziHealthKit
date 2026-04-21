//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

import HealthKit
import ModelsDSTU2
import ModelsR4
import SpeziFHIR
import SpeziHealthKit


extension HKSample {
    /// An attachment that was loaded from the health store
    fileprivate struct LoadedAttachment: Sendable {
        let id: UUID
        let contentType: UTType
        let data: Data
    }
    
    fileprivate func loadAttachments(using healthKit: HealthKit) async throws -> [LoadedAttachment] {
        try await withThrowingTaskGroup/*(of: LoadedAttachment.self, returning: [LoadedAttachment].self)*/ { taskGroup in
            let store = HKAttachmentStore(healthStore: healthKit.healthStore)
            for attachment in try await store.attachments(for: self) {
                taskGroup.addTask {
                    let dataReader = store.dataReader(for: attachment)
                    return LoadedAttachment(
                        id: attachment.identifier,
                        contentType: attachment.contentType,
                        data: try await dataReader.data
                    )
                }
            }
            var results: [LoadedAttachment] = []
            while let result = try await taskGroup.next() {
                results.append(result)
            }
            return results
        }
    }
}


extension FHIRResource {
    /// Loads attachments for the FHIR resource from a HealthKit sample.
    /// - Parameters:
    ///   - healthKitSample: The HealthKit sample containing attachments.
    ///   - store: The health store to use. Defaults to a new `HKHealthStore` instance.
    mutating func loadAttachments(from sample: HKSample, using healthKit: HealthKit) async throws {
        guard category == .document || category == .diagnostic else {
            return
        }
        let attachments = try await sample.loadAttachments(using: healthKit)
        // We inject the data right in the resource if it has the same content type.
        // We assume that the content type is a MIME type, we would need to more checks around the content.format to be fully correct.
        // Otherwise we create a new content entry to inject this information in here.
        switch versionedResource {
        case .r4(var resource):
            try Self.process(attachments, into: &resource)
            self = .init(versionedResource: .r4(resource), displayName: self.displayName)
        case .dstu2(var resource):
            try Self.process(attachments, into: &resource)
            self = .init(versionedResource: .dstu2(resource), displayName: self.displayName)
        }
    }
    
    /// Adds attachments into the resource
    private static func process(_ attachments: [HKSample.LoadedAttachment], into resource: inout any ModelsR4.Resource) throws {
        switch resource {
        case var reference as ModelsR4.DocumentReference:
            for attachment in attachments {
                let b64Binary = FHIRPrimitive(ModelsR4.Base64Binary(attachment.data.base64EncodedString()))
                let attachmentContentType: ModelsR4.FHIRPrimitive = (attachment.contentType.preferredMIMEType ?? attachment.contentType.identifier).asFHIRStringPrimitive()
                if let matchingContentIdx = reference.content.firstIndex(where: {
                    $0.attachment.contentType == attachmentContentType && $0.attachment.data == nil
                }) {
                    reference.content[matchingContentIdx].attachment.data = b64Binary
                } else {
                    reference.content.append(DocumentReferenceContent(attachment: Attachment(contentType: attachmentContentType, data: b64Binary)))
                }
                resource = reference
            }
        case var report as ModelsR4.DiagnosticReport:
            for attachment in attachments {
                let b64Binary = FHIRPrimitive(ModelsR4.Base64Binary(attachment.data.base64EncodedString()))
                let attachmentContentType: ModelsR4.FHIRPrimitive = (attachment.contentType.preferredMIMEType ?? attachment.contentType.identifier).asFHIRStringPrimitive()
                if let matchingAttachmentIdx = (report.presentedForm ?? []).firstIndex(where: {
                    $0.contentType == attachmentContentType && $0.data == nil
                }) {
                    // SAFETY: if there is an index, we know that the array is not nil.
                    // swiftlint:disable:next force_unwrapping
                    report.presentedForm![matchingAttachmentIdx].data = b64Binary
                } else {
                    if report.presentedForm == nil {
                        report.presentedForm = []
                    }
                    // swiftlint:disable:next force_unwrapping
                    report.presentedForm!.append(Attachment(contentType: attachmentContentType, data: b64Binary))
                }
                resource = report
            }
        default:
            print("Unexpected FHIR type in the document parsing path: \(resource)")
        }
    }

    private static func process(_ attachments: [HKSample.LoadedAttachment], into resource: inout any ModelsDSTU2.Resource) throws {
        throw NSError(domain: "edu.stanford.SpeziFHIR", code: 0, userInfo: [
            NSLocalizedDescriptionKey: "DSTU2 resource attachment processing is currently unavailable"
        ])
        // TODO(DSTU2) // swiftlint:disable:this todo
//        switch resource {
//        case let reference as ModelsDSTU2.DocumentReference:
//            for attachment in encodedAttachments {
//                let data = FHIRPrimitive(ModelsDSTU2.Base64Binary(attachment.base64EncodedString))
//                if let matchingContent = reference.content.first(where: {
//                    $0.attachment.contentType?.value?.string == attachment.identifier && $0.attachment.data == nil
//                }) {
//                    matchingContent.attachment.data = data
//                } else {
//                    reference.content.append(
//                        DocumentReferenceContent(
//                            attachment: Attachment(contentType: FHIRPrimitive(stringLiteral: attachment.identifier), data: data)
//                        )
//                    )
//                }
//                resource = reference
//            }
//        case let report as ModelsDSTU2.DiagnosticReport:
//            for attachment in encodedAttachments {
//                let data = FHIRPrimitive(ModelsDSTU2.Base64Binary(attachment.base64EncodedString))
//                if let presentedForms = report.presentedForm {
//                    if let matchingAttachment = presentedForms.first(where: {
//                        $0.contentType?.value?.string == attachment.identifier && $0.data == nil
//                    }) {
//                        matchingAttachment.data = data
//                    } else {
//                        report.presentedForm?.append(
//                            Attachment(contentType: FHIRPrimitive(stringLiteral: attachment.identifier), data: data)
//                        )
//                    }
//                } else {
//                    report.presentedForm = [
//                        Attachment(contentType: FHIRPrimitive(stringLiteral: attachment.identifier), data: data)
//                    ]
//                }
//                resource = report
//            }
//        default:
//            print("Unexpected FHIR type in the document parsing path: \(resource.description)")
//        }
    }
}


extension HKAttachmentStore: @retroactive @unchecked Sendable {}

#endif
