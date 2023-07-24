//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

//@preconcurrency import HealthKit
//import Spezi
//import SpeziHealthKit
//import XCTSpezi
//
//
//actor TestAppHealthKitAdapter: SingleValueAdapter {
//    typealias InputElement = HKSample
//    typealias InputRemovalContext = HKSampleRemovalContext
//    typealias OutputElement = TestAppStandard.BaseType
//    typealias OutputRemovalContext = TestAppStandard.RemovalContext
//
//
//    func transform(element: InputElement) throws -> OutputElement {
//        TestAppStandard.BaseType(id: element.sampleType.identifier)
//    }
//
//    func transform(removalContext: InputRemovalContext) throws -> OutputRemovalContext {
//        OutputRemovalContext(id: removalContext.id.uuidString)
//    }
//}
