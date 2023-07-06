//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi
import SpeziHealthKit
import XCTSpezi

actor MockAdapterActor: Adapter {
    typealias InputElement = HKSample
    typealias InputRemovalContext = HKSampleRemovalContext
    typealias OutputElement = TestAppStandard.BaseType
    typealias OutputRemovalContext = TestAppStandard.RemovalContext
    
    
    func transform(
        _ asyncSequence: some TypedAsyncSequence<DataChange<InputElement, InputRemovalContext>>
    ) async -> any TypedAsyncSequence<DataChange<OutputElement, OutputRemovalContext>> {
        asyncSequence.map { element in
            element.map(
                element: { OutputElement(id: String(describing: $0.id)) },
                removalContext: { OutputRemovalContext(id: $0.id.uuidString) }
            )
        }
    }
}
