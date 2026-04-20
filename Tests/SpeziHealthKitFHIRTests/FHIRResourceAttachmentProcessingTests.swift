//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

// swiftlint:disable all

// TODO!

import HealthKit
import ModelsDSTU2
import ModelsR4
@testable import SpeziFHIR
//@testable import SpeziFHIRHealthKit
import Testing


//enum FHIRTestVersion {
//    case r4 // swiftlint:disable:this identifier_name
//    case dstu2
//}
//
//@Suite
//struct FHIRResourceAttachmentProcessingTests { // swiftlint:disable:this type_body_length
//
//    // swiftlint:disable function_body_length
//    @Test(
//        "Document Reference: Should fill multiple empty attachments sequentially",
//        arguments: [FHIRTestVersion.r4, FHIRTestVersion.dstu2]
//    )
//    func testDocumentReferenceMultipleEmptyAttachments(_ version: FHIRTestVersion) throws {
//        switch version {
//        case .r4:
//            let docRef = try ModelsR4Mocks.createDocumentReference()
//
//            docRef.content = [
//                DocumentReferenceContent(
//                    attachment: Attachment(contentType: "application/pdf".asFHIRStringPrimitive())
//                ),
//                DocumentReferenceContent(
//                    attachment: Attachment(contentType: "text/plain".asFHIRStringPrimitive())
//                ),
//                DocumentReferenceContent(
//                    attachment: Attachment(contentType: "application/pdf".asFHIRStringPrimitive())
//                )
//            ]
//
//            let encodedAttachments = [
//                (identifier: "application/pdf", base64EncodedString: "pdf-content-1"),
//                (identifier: "application/pdf", base64EncodedString: "pdf-content-2")
//            ]
//
//            let resource = FHIRResource(
//                versionedResource: .r4(docRef),
//                displayName: "R4 Document Reference"
//            )
//
//            try resource.processAttachments(
//                for: docRef,
//                encodedAttachments: encodedAttachments
//            )
//
//            #expect(docRef.content.count == 3, "Should have the original 3 attachments")
//
//            let firstPdfAttachment = docRef.content[0].attachment
//            #expect(firstPdfAttachment.contentType?.value?.string == "application/pdf")
//            #expect(firstPdfAttachment.data?.value?.dataString == "pdf-content-1")
//
//            let wordAttachment = docRef.content[1].attachment
//            #expect(wordAttachment.contentType?.value?.string == "text/plain")
//            #expect(wordAttachment.data == nil)
//
//            let secondPdfAttachment = docRef.content[2].attachment
//            #expect(secondPdfAttachment.contentType?.value?.string == "application/pdf")
//            #expect(secondPdfAttachment.data?.value?.dataString == "pdf-content-2")
//
//        case .dstu2:
//            let emptyPdfAttachment1 = ModelsDSTU2.Attachment(
//                contentType: "application/pdf".asFHIRStringPrimitive()
//            )
//            let emptyWordAttachment = ModelsDSTU2.Attachment(
//                contentType: "text/plain".asFHIRStringPrimitive()
//            )
//            let emptyPdfAttachment2 = ModelsDSTU2.Attachment(
//                contentType: "application/pdf".asFHIRStringPrimitive()
//            )
//
//            let docRef = try ModelsDSTU2Mocks.createDocumentReference(attachments: [
//                emptyPdfAttachment1,
//                emptyWordAttachment,
//                emptyPdfAttachment2
//            ])
//
//            let encodedAttachments = [
//                (identifier: "application/pdf", base64EncodedString: "pdf-content-1"),
//                (identifier: "application/pdf", base64EncodedString: "pdf-content-2")
//            ]
//
//            let resource = FHIRResource(
//                versionedResource: .dstu2(docRef),
//                displayName: "DSTU2 Document Reference"
//            )
//
//            try resource.processAttachments(
//                for: docRef,
//                encodedAttachments: encodedAttachments
//            )
//
//            #expect(docRef.content.count == 3, "Should still have the original 3 attachments")
//
//            let firstPdfAttachment = docRef.content[0].attachment
//            #expect(firstPdfAttachment.contentType?.value?.string == "application/pdf")
//            #expect(firstPdfAttachment.data?.value?.dataString == "pdf-content-1")
//
//            let textAttachment = docRef.content[1].attachment
//            #expect(textAttachment.contentType?.value?.string == "text/plain")
//            #expect(textAttachment.data == nil)
//
//            let secondPdfAttachment = docRef.content[2].attachment
//            #expect(secondPdfAttachment.contentType?.value?.string == "application/pdf")
//            #expect(secondPdfAttachment.data?.value?.dataString == "pdf-content-2")
//        }
//    }
//
//    @Test(
//        "Diagnostic Report: Should fill multiple empty attachments sequentially",
//        arguments: [FHIRTestVersion.r4, FHIRTestVersion.dstu2]
//    )
//    func testDiagnosticReportMultipleEmptyAttachments(_ version: FHIRTestVersion) throws {
//        switch version {
//        case .r4:
//            let diagReport = try ModelsR4Mocks.createDiagnosticReport()
//
//            diagReport.presentedForm = [
//                Attachment(contentType: "application/pdf".asFHIRStringPrimitive()),
//                Attachment(contentType: "text/plain".asFHIRStringPrimitive()),
//                Attachment(contentType: "application/pdf".asFHIRStringPrimitive())
//            ]
//
//            let encodedAttachments = [
//                (identifier: "application/pdf", base64EncodedString: "pdf-content-1"),
//                (identifier: "application/pdf", base64EncodedString: "pdf-content-2")
//            ]
//
//            let resource = FHIRResource(
//                versionedResource: .r4(diagReport),
//                displayName: "R4 Diagnostic Report"
//            )
//
//            try resource.processAttachments(
//                for: diagReport,
//                encodedAttachments: encodedAttachments
//            )
//
//            #expect(diagReport.presentedForm?.count == 3, "Should have the original 3 attachments")
//
//            if let presentedForms = diagReport.presentedForm {
//                let firstPdfAttachment = presentedForms[0]
//                #expect(firstPdfAttachment.contentType?.value?.string == "application/pdf")
//                #expect(firstPdfAttachment.data?.value?.dataString == "pdf-content-1")
//
//                let textAttachment = presentedForms[1]
//                #expect(textAttachment.contentType?.value?.string == "text/plain")
//                #expect(textAttachment.data == nil)
//
//                let secondPdfAttachment = presentedForms[2]
//                #expect(secondPdfAttachment.contentType?.value?.string == "application/pdf")
//                #expect(secondPdfAttachment.data?.value?.dataString == "pdf-content-2")
//            }
//
//        case .dstu2:
//            let diagReport = try ModelsDSTU2Mocks.createDiagnosticReport()
//
//            diagReport.presentedForm = [
//                Attachment(contentType: "application/pdf".asFHIRStringPrimitive()),
//                Attachment(contentType: "text/plain".asFHIRStringPrimitive()),
//                Attachment(contentType: "application/pdf".asFHIRStringPrimitive())
//            ]
//
//            let encodedAttachments = [
//                (identifier: "application/pdf", base64EncodedString: "pdf-content-1"),
//                (identifier: "application/pdf", base64EncodedString: "pdf-content-2")
//            ]
//
//            let resource = FHIRResource(
//                versionedResource: .dstu2(diagReport),
//                displayName: "DSTU2 Diagnostic Report"
//            )
//
//            try resource.processAttachments(
//                for: diagReport,
//                encodedAttachments: encodedAttachments
//            )
//
//            #expect(diagReport.presentedForm?.count == 3, "Should have the original 3 attachments")
//
//            if let presentedForms = diagReport.presentedForm {
//                let firstPdfAttachment = presentedForms[0]
//                #expect(firstPdfAttachment.contentType?.value?.string == "application/pdf")
//                #expect(firstPdfAttachment.data?.value?.dataString == "pdf-content-1")
//
//                let textAttachment = presentedForms[1]
//                #expect(textAttachment.contentType?.value?.string == "text/plain")
//                #expect(textAttachment.data == nil)
//
//                let secondPdfAttachment = presentedForms[2]
//                #expect(secondPdfAttachment.contentType?.value?.string == "application/pdf")
//                #expect(secondPdfAttachment.data?.value?.dataString == "pdf-content-2")
//            }
//        }
//    }
//
//    @Test(
//        "Should create new attachment when all existing ones are filled",
//        arguments: [FHIRTestVersion.r4, FHIRTestVersion.dstu2]
//    )
//    func testCreateNewAttachmentWhenAllFilled(_ version: FHIRTestVersion) throws {
//        switch version {
//        case .r4:
//            let docRef = try ModelsR4Mocks.createDocumentReference()
//
//            let filledPdfAttachment = Attachment(
//                contentType: "application/pdf".asFHIRStringPrimitive(),
//                data: FHIRPrimitive(ModelsR4.Base64Binary("pdf-content-1"))
//            )
//
//            docRef.content = [
//                DocumentReferenceContent(attachment: filledPdfAttachment)
//            ]
//
//            let encodedAttachments = [
//                (identifier: "application/pdf", base64EncodedString: "pdf-content-2")
//            ]
//
//            let resource = FHIRResource(
//                versionedResource: .r4(docRef),
//                displayName: "R4 Document Reference"
//            )
//
//            try resource.processAttachments(
//                for: docRef,
//                encodedAttachments: encodedAttachments
//            )
//
//            #expect(docRef.content.count == 2, "Should have 2 attachments")
//
//            let originalPdfAttachment = docRef.content[0].attachment
//            #expect(originalPdfAttachment.contentType?.value?.string == "application/pdf")
//            #expect(originalPdfAttachment.data?.value?.dataString == "pdf-content-1")
//
//            let newPdfAttachment = docRef.content[1].attachment
//            #expect(newPdfAttachment.contentType?.value?.string == "application/pdf")
//            #expect(newPdfAttachment.data?.value?.dataString == "pdf-content-2")
//
//        case .dstu2:
//            let filledPdfAttachment = ModelsDSTU2.Attachment(
//                contentType: "application/pdf".asFHIRStringPrimitive(),
//                data: FHIRPrimitive(ModelsDSTU2.Base64Binary("pdf-content-1"))
//            )
//
//            let docRef = try ModelsDSTU2Mocks.createDocumentReference(attachments: [filledPdfAttachment])
//
//            let encodedAttachments = [
//                (identifier: "application/pdf", base64EncodedString: "pdf-content-2")
//            ]
//
//            let resource = FHIRResource(
//                versionedResource: .dstu2(docRef),
//                displayName: "DSTU2 Document Reference"
//            )
//
//            try resource.processAttachments(
//                for: docRef,
//                encodedAttachments: encodedAttachments
//            )
//
//            #expect(docRef.content.count == 2, "Should have 2 attachments")
//
//            let originalPdfAttachment = docRef.content[0].attachment
//            #expect(originalPdfAttachment.contentType?.value?.string == "application/pdf")
//            #expect(originalPdfAttachment.data?.value?.dataString == "pdf-content-1")
//
//            let newPdfAttachment = docRef.content[1].attachment
//            #expect(newPdfAttachment.contentType?.value?.string == "application/pdf")
//            #expect(newPdfAttachment.data?.value?.dataString == "pdf-content-2")
//        }
//    }
//
//    @Test(
//        "Diagnostic Report: Should create new presentedForm array when none exists",
//        arguments: [FHIRTestVersion.r4, FHIRTestVersion.dstu2]
//    )
//    func testDiagnosticReportCreateNewPresentedForm(_ version: FHIRTestVersion) throws {
//        switch version {
//        case .r4:
//            let diagReport = try ModelsR4Mocks.createDiagnosticReport()
//            diagReport.presentedForm = nil
//
//            let encodedAttachments = [
//                (identifier: "application/pdf", base64EncodedString: "pdf-content")
//            ]
//
//            let resource = FHIRResource(
//                versionedResource: .r4(diagReport),
//                displayName: "R4 Diagnostic Report"
//            )
//
//            try resource.processAttachments(
//                for: diagReport,
//                encodedAttachments: encodedAttachments
//            )
//
//            #expect(diagReport.presentedForm?.count == 1, "Should have 1 attachment")
//
//            if let presentedForms = diagReport.presentedForm {
//                let attachment = presentedForms[0]
//                #expect(attachment.contentType?.value?.string == "application/pdf")
//                #expect(attachment.data?.value?.dataString == "pdf-content")
//            }
//
//        case .dstu2:
//            let diagReport = try ModelsDSTU2Mocks.createDiagnosticReport()
//            diagReport.presentedForm = nil
//
//            let encodedAttachments = [
//                (identifier: "application/pdf", base64EncodedString: "pdf-content")
//            ]
//
//            let resource = FHIRResource(
//                versionedResource: .dstu2(diagReport),
//                displayName: "DSTU2 Diagnostic Report"
//            )
//
//            try resource.processAttachments(
//                for: diagReport,
//                encodedAttachments: encodedAttachments
//            )
//
//            #expect(diagReport.presentedForm?.count == 1, "Should have 1 attachment")
//
//            if let presentedForms = diagReport.presentedForm {
//                let attachment = presentedForms[0]
//                #expect(attachment.contentType?.value?.string == "application/pdf")
//                #expect(attachment.data?.value?.dataString == "pdf-content")
//            }
//        }
//    }
//
//    @Test(
//        "Diagnostic Report: Should append new attachment to existing presentedForm when no matching empty slots",
//        arguments: [FHIRTestVersion.r4, FHIRTestVersion.dstu2]
//    )
//    func testDiagnosticReportAppendNewAttachment(_ version: FHIRTestVersion) throws {
//        switch version {
//        case .r4:
//            let diagReport = try ModelsR4Mocks.createDiagnosticReport()
//
//            diagReport.presentedForm = [
//                Attachment(
//                    contentType: "text/plain".asFHIRStringPrimitive(),
//                    data: FHIRPrimitive(ModelsR4.Base64Binary("text-content"))
//                )
//            ]
//
//            let encodedAttachments = [
//                (identifier: "application/pdf", base64EncodedString: "pdf-content")
//            ]
//
//            let resource = FHIRResource(
//                versionedResource: .r4(diagReport),
//                displayName: "R4 Diagnostic Report"
//            )
//
//            try resource.processAttachments(
//                for: diagReport,
//                encodedAttachments: encodedAttachments
//            )
//
//            #expect(diagReport.presentedForm?.count == 2, "Should have 2 attachments")
//
//            if let presentedForms = diagReport.presentedForm {
//                let originalAttachment = presentedForms[0]
//                #expect(originalAttachment.contentType?.value?.string == "text/plain")
//                #expect(originalAttachment.data?.value?.dataString == "text-content")
//
//                let newAttachment = presentedForms[1]
//                #expect(newAttachment.contentType?.value?.string == "application/pdf")
//                #expect(newAttachment.data?.value?.dataString == "pdf-content")
//            }
//
//        case .dstu2:
//            let diagReport = try ModelsDSTU2Mocks.createDiagnosticReport()
//
//            diagReport.presentedForm = [
//                ModelsDSTU2.Attachment(
//                    contentType: "text/plain".asFHIRStringPrimitive(),
//                    data: FHIRPrimitive(ModelsDSTU2.Base64Binary("text-content"))
//                )
//            ]
//
//            let encodedAttachments = [
//                (identifier: "application/pdf", base64EncodedString: "pdf-content")
//            ]
//
//            let resource = FHIRResource(
//                versionedResource: .dstu2(diagReport),
//                displayName: "DSTU2 Diagnostic Report"
//            )
//
//            try resource.processAttachments(
//                for: diagReport,
//                encodedAttachments: encodedAttachments
//            )
//
//            #expect(diagReport.presentedForm?.count == 2, "Should have 2 attachments")
//
//            if let presentedForms = diagReport.presentedForm {
//                let originalAttachment = presentedForms[0]
//                #expect(originalAttachment.contentType?.value?.string == "text/plain")
//                #expect(originalAttachment.data?.value?.dataString == "text-content")
//
//                let newAttachment = presentedForms[1]
//                #expect(newAttachment.contentType?.value?.string == "application/pdf")
//                #expect(newAttachment.data?.value?.dataString == "pdf-content")
//            }
//        }
//    }
//}


#endif
