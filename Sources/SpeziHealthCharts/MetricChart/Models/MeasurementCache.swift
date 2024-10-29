//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


actor MeasurementCache {
    enum CacheError: LocalizedError {
        case entryNotFound
        case entryExpired
        
        var errorDescription: String? {
            switch self {
            case .entryNotFound:
                String(localized: "No entries found for given key.")
            case .entryExpired:
                String(localized: "Entry found in cache has expired.")
            }
        }
    }
    
    struct CacheKey: Hashable {
        let type: MeasurementType
        let range: DateInterval
    }
    
    struct CacheValue {
        let measurements: [DataPoint]
        let timestamp: Date
    }
    
    private var cache: [CacheKey: CacheValue] = [:]
    
    private let maxEntries = 10
    private let ageLimit: TimeInterval = 24 * 60 * 60  // Time limit is one day.
    
    
    func store(_ measurements: [DataPoint], for type: MeasurementType, range dateRange: DateRange) {
        let key = CacheKey(type: type, range: dateRange.interval)
        self.cache[key] = CacheValue(measurements: measurements, timestamp: Date())
        
        if self.cache.count > self.maxEntries {
            self.cleanUpOldEntries()
        }
    }
    
    
    func fetch(for type: MeasurementType, range: DateInterval) throws -> [DataPoint] {
        let key = CacheKey(type: type, range: range)
        
        guard let entry = self.cache[key] else {
            // No entry matching the key is in the cache.
            throw CacheError.entryNotFound
        }
        
        guard Date().timeIntervalSince(entry.timestamp) > self.ageLimit else {
            // Entry has been cached for too long -- it has expired.
            cache.removeValue(forKey: key)
            throw CacheError.entryExpired
        }
        
        return entry.measurements
    }
    
    
    private func cleanUpOldEntries() {
        let now = Date()
        self.cache = self.cache.filter { _, value in
            now.timeIntervalSince(value.timestamp) <= self.ageLimit
        }
    }
}
