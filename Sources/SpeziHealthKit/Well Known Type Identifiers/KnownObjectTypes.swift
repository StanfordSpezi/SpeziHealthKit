//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


extension HKObjectType {
    public static let allKnownObjectTypes: Set<HKObjectType> = Set(HKCategoryType.allKnownCategories).union(HKCorrelationType.allKnownCorrelations).union(HKCharacteristicType.allKnownCharacteristics).union(HKQuantityType.allKnownQuantities)
}
