//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import HealthKit
import Spezi


public struct HKSampleRemovalContext: Identifiable, Sendable {
    public let id: HKSample.ID
    public let sampleType: HKSampleType
    
    
    public init(id: HKSample.ID, sampleType: HKSampleType) {
        self.id = id
        self.sampleType = sampleType
    }
}
