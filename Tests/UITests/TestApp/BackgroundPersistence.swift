//
//  BackgroundPersistence.swift
//  TestApp
//
//  Created by Lukas Kollmer on 2025-01-23.
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
