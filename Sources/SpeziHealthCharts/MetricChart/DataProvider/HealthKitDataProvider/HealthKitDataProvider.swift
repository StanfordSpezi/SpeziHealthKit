//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


public final class HealthKitDataProvider: DataProvider {
    public func fetchData(for measurementType: HKQuantityType, in interval: ChartRange) async throws -> [HKQuantitySample] {
        []
    }
    
    
    public init() {}
}
