//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit

class HKHealthStoreSpy: HKHealthStore {
    var configuredTypesToRead: Set<HKSampleType> = []

    override func statusForAuthorizationRequest(toShare typesToShare: Set<HKSampleType>, read typesToRead: Set<HKObjectType>) async throws -> HKAuthorizationRequestStatus {
        if typesToRead.isSubset(of: self.configuredTypesToRead) {
            return .unnecessary
        } else {
            return .shouldRequest
        }
    }
}
