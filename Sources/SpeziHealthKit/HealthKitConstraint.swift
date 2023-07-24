//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
//import ModelsR4
import HealthKit

public protocol HealthKitConstraint: Standard {
    func add(_ response: HKSample) async
    func remove(removalContext: HKSampleRemovalContext)
}
