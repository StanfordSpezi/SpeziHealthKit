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
        let sampleTypes: [any AnySampleType] = [
            SampleType.stepCount, SampleType.heartRate, SampleType.height, SampleType.walkingStepLength,
            SampleType.bloodOxygen, SampleType.bloodPressureSystolic, SampleType.appleMoveTime,
            SampleType.bloodPressure, SampleType.food, SampleType.sleepAnalysis,
            SampleType.workout, SampleType.electrocardiogram, SampleType.audiogram
        ]
        for sampleType in sampleTypes {
            let wrapped = try #require(SampleTypeProxy(sampleType))
            let encoded = try JSONEncoder().encode(wrapped)
            let decoded = try JSONDecoder().decode(SampleTypeProxy.self, from: encoded)
            #expect(decoded == wrapped)
        }
    }
}
