//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


enum BackgroundDataCollectionLogEntry: Codable, Hashable, Identifiable {
    case added(id: UUID, type: String, date: ClosedRange<Date>, quantity: String?)
    case removed(id: UUID)
    
    var id: UUID {
        switch self {
        case .added(let id, _, _, _), .removed(let id):
            id
        }
    }
    
    init(_ sample: HKSample) {
        self = .added(
            id: sample.uuid,
            type: sample.sampleType.identifier,
            date: sample.startDate...sample.endDate,
            quantity: (sample as? HKQuantitySample)?.quantity.description
        )
    }
    
    init(_ object: HKDeletedObject) {
        self = .removed(id: object.uuid)
    }
}
