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


protocol HealthKitAttachmentsProvider {
    func getEncodedAttachments(
        for sample: HKSample
    ) async throws -> [(identifier: String, base64EncodedString: String)]
}


struct DefaultHealthKitAttachmentsProvider: HealthKitAttachmentsProvider {
    private let healthKit: HealthKit
    
    init(healthKit: HealthKit) {
        self.healthKit = healthKit
    }

    func getEncodedAttachments(
        for sample: HKSample
    ) async throws -> [(identifier: String, base64EncodedString: String)] {
        try await withThrowingTaskGroup(of: (String, String).self, returning: [(String, String)].self) { taskGroup in
            let attachmentStore = HKAttachmentStore(healthStore: healthKit.healthStore)
            let attachments = try await attachmentStore.attachments(for: sample)
            for attachment in attachments {
                taskGroup.addTask {
                    let mimeType = attachment.contentType.preferredMIMEType ?? attachment.contentType.identifier
                    let dataReader = attachmentStore.dataReader(for: attachment)
                    return (mimeType, try await dataReader.data.base64EncodedString())
                }
            }
            var base64Attachments: [(String, String)] = []
            while let base64Attachment = try await taskGroup.next() {
                base64Attachments.append(base64Attachment)
            }
            return base64Attachments
        }
    }
}

extension FHIRResource {
    /// Loads attachments for the FHIR resource from a HealthKit sample.
    /// - Parameters:
    ///   - healthKitSample: The HealthKit sample containing attachments.
    ///   - store: The health store to use. Defaults to a new `HKHealthStore` instance.
    ///   - attachmentsProvider: Optional custom provider for attachments. If nil, a default provider will be created.
    mutating func loadAttachments(
        for healthKitSample: HKSample,
        using healthKit: HealthKit,
        attachmentsProvider: (any HealthKitAttachmentsProvider)? = nil
    ) async throws {
        guard category == .document || category == .diagnostic else {
            return
        }
        let provider = attachmentsProvider ?? DefaultHealthKitAttachmentsProvider(healthKit: healthKit)
        let encodedAttachments = try await provider.getEncodedAttachments(for: healthKitSample)
        // We inject the data right in the resource if it has the same content type.
        // We assume that the content type is a MIME type, we would need to more checks around the content.format to be fully correct.
        // Otherwise we create a new content entry to inject this information in here.
        switch versionedResource {
        case .r4(var resource):
            try processAttachments(for: &resource, encodedAttachments: encodedAttachments)
            self = .init(versionedResource: .r4(resource), displayName: self.displayName)
        case .dstu2(var resource):
            try processAttachments(for: &resource, encodedAttachments: encodedAttachments)
            self = .init(versionedResource: .dstu2(resource), displayName: self.displayName)
        }
    }

    func processAttachments(
        for resource: inout any ModelsR4.Resource,
        encodedAttachments: [(identifier: String, base64EncodedString: String)]
    ) throws {
        switch resource {
        case var reference as ModelsR4.DocumentReference:
            for attachment in encodedAttachments {
                let data = FHIRPrimitive(ModelsR4.Base64Binary(attachment.base64EncodedString))
                if let matchingContentIdx = reference.content.firstIndex(where: {
                    $0.attachment.contentType?.value?.string == attachment.identifier && $0.attachment.data == nil
                }) {
                    reference.content[matchingContentIdx].attachment.data = data
                } else {
                    reference.content.append(
                        DocumentReferenceContent(
                            attachment: Attachment(contentType: FHIRPrimitive(stringLiteral: attachment.identifier), data: data)
                        )
                    )
                }
                resource = reference
            }
        case var report as ModelsR4.DiagnosticReport:
            for attachment in encodedAttachments {
                let data = FHIRPrimitive(ModelsR4.Base64Binary(attachment.base64EncodedString))
                if let matchingAttachmentIdx = (report.presentedForm ?? []).firstIndex(where: {
                    $0.contentType?.value?.string == attachment.identifier && $0.data == nil
                }) {
                    // SAFETY: if there is an index, we know that the array is not nil.
                    // swiftlint:disable:next force_unwrapping
                    report.presentedForm![matchingAttachmentIdx].data = data
                } else {
                    if report.presentedForm == nil {
                        report.presentedForm = []
                    }
                    report.presentedForm!.append( // swiftlint:disable:this force_unwrapping
                        Attachment(contentType: FHIRPrimitive(stringLiteral: attachment.identifier), data: data)
                    )
                }
                resource = report
            }
        default:
            print("Unexpected FHIR type in the document parsing path: \(resource)")
        }
    }

    func processAttachments(
        for resource: inout any ModelsDSTU2.Resource,
        encodedAttachments: [(identifier: String, base64EncodedString: String)]
    ) throws {
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
