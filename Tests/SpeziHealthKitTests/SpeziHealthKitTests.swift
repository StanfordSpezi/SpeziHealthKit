//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
@testable import SpeziHealthKit
import SpeziHealthKitUI
import Testing


@Suite("SpeziHealthKitTests")
struct SpeziHealthKitTests {
    @Test("Equal Time Ranges")
    func equalTimeRanges() {
        #expect(HealthKitQueryTimeRange.last(hours: 1) == .currentHour)
        #expect(HealthKitQueryTimeRange.last(days: 1) == .today)
        #expect(HealthKitQueryTimeRange.last(weeks: 1) == .currentWeek)
        #expect(HealthKitQueryTimeRange.last(months: 1) == .currentMonth)
        #expect(HealthKitQueryTimeRange.last(years: 1) == .currentYear)
    }

    @Test("Equal Well Known Identifiers")
    func equalWellKnownIdentifiers() {
        #expect(HKQuantityType.allKnownQuantities.count == HKQuantityTypeIdentifier.allKnownIdentifiers.count)
        #expect(HKCorrelationType.allKnownCorrelations.count == HKCorrelationTypeIdentifier.allKnownIdentifiers.count)
        #expect(HKCategoryType.allKnownCategories.count == HKCategoryTypeIdentifier.allKnownIdentifiers.count)
        #expect(HKObjectType.allKnownObjectTypes.count == 204)
    }


    @Test("Query anchors codable", arguments: [
        QueryAnchor(HKQueryAnchor(fromValue: 5734987678924)),
        QueryAnchor()
    ])
    func equalQueryAnchorCoding2(_ anchor: QueryAnchor) throws {
        let encoded = try JSONEncoder().encode(anchor)
        let decoded = try JSONDecoder().decode(QueryAnchor.self, from: encoded)
        #expect(anchor == decoded)
    }
    
    @Test
    func sourceFilter() throws {
        typealias Filter = HealthKit.SourceFilter
        
        let healthAppSource = try #require(HKSource.make(name: "Health", bundleId: "com.apple.health"))
        let appleWatchSource = try #require(HKSource.make(
            name: "Lukas' Apple Watch",
            bundleId: "com.apple.health.94C8E349-0D09-4184-BF6C-AF11692FA465"
        ))
        let autoSleepSource = try #require(HKSource.make(name: "AutoSleep", bundleId: "com.tantsissa.AutoSleep"))
        
        #expect(Filter.any.matches(healthAppSource))
        #expect(Filter.any.matches(appleWatchSource))
        #expect(Filter.any.matches(autoSleepSource))
        
        #expect(Filter.healthApp.matches(healthAppSource))
        #expect(!Filter.healthApp.matches(appleWatchSource))
        #expect(!Filter.healthApp.matches(autoSleepSource))
        
        let appleHealthSystemFilter = Filter.bundleId(beginsWith: "com.apple.health")
        #expect(appleHealthSystemFilter.matches(healthAppSource))
        #expect(appleHealthSystemFilter.matches(appleWatchSource))
        #expect(!appleHealthSystemFilter.matches(autoSleepSource))
    }
}


extension HKSource {
    static func make(name: String, bundleId: String) -> HKSource? {
        // +(id)_sourceWithBundleIdentifier:(id)arg1 name:(id)arg2 productType:(id)arg3 options:(unsigned long long)arg4
        let sel = Selector(("_sourceWithBundleIdentifier:name:productType:options:"))
        guard let method = class_getClassMethod(self, sel) else {
            return nil
        }
        let imp = unsafeBitCast(
            method_getImplementation(method),
            to: (@convention(c) (HKSource.Type, Selector, NSString, NSString, NSString, UInt64) -> HKSource).self
        )
        return imp(self, sel, bundleId as NSString, name as NSString, NSString(), 0)
    }
}
