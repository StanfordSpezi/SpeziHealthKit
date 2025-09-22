//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import Testing


@Suite
struct SampleTypeProxyTests {
    @Test
    func coding() throws {
        let sampleTypes = HKObjectType.allKnownObjectTypes.compactMap(\.sampleType)
        for sampleType in sampleTypes {
            guard let wrapped = SampleTypeProxy(_ifPossible: sampleType) else {
                continue
            }
            let encoded = try JSONEncoder().encode(wrapped)
            let decoded = try JSONDecoder().decode(SampleTypeProxy.self, from: encoded)
            #expect(decoded == wrapped)
        }
    }
}
