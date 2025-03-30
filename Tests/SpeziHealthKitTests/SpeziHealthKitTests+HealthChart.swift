//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SnapshotTesting
@testable import SpeziHealthKit
@testable import SpeziHealthKitUI
import SwiftUI
import Testing
import SpeziTesting


extension SpeziHealthKitTests {
#if os(iOS)
    @MainActor
    @Test("Simple HealthChart View Snapshot")
    func simpleHealthChartViewSnapshot() throws {
        var heartRateSamplesProvider = FakeSamplesProvider(
            sampleType: .heartRate,
            values: [97 as Double, 95, 91, 89, 89, 92, 117, 119, 118, 95, 85, 87].makeLoopingIterator(),
            dateProvider: try makeDateProvider(interval: (.hour, 2), starting: .init(year: 2024, month: 12, day: 17))
        )
        
        let results = MockQueryResults(sampleType: .heartRate, timeRange: .currentWeek, samples: try heartRateSamplesProvider.makeSamples(12 * 7))
        let healthChart = HealthChart {
            HealthChartEntry(results, drawingConfig: .init(mode: .line, color: .red))
        }
            .frame(width: 600, height: 500)
            .withLocale(.enUS, timeZone: .losAngeles)
        
        assertSnapshot(of: healthChart, as: .image)
        
//        bpmProvider.consume(6) // consume some elements to shift the cycle
        
        heartRateSamplesProvider.skipValues(5)
        heartRateSamplesProvider.skipDates(12 * 2)
        
        results.samples.append(contentsOf: try heartRateSamplesProvider.makeSamples(12 * 4))
        
        assertSnapshot(of: healthChart, as: .image)
    }
    
    
    @MainActor
    @Test("Multi Entry HealthChart View Snapshot")
    func multiEntryHealthChartViewSnapshot() throws {
        var heartRateSamplesProvider = FakeSamplesProvider(
            sampleType: .heartRate,
            values: [97 as Double, 95, 91, 89, 89, 92, 117, 119, 118, 95, 85, 87].makeLoopingIterator(),
            dateProvider: try makeDateProvider(interval: (.hour, 2), starting: .init(year: 2024, month: 12, day: 17))
        )
        var bloodOxygenSamplesProvider = FakeSamplesProvider(
            sampleType: .bloodOxygen,
            values: [100, 92, 96, 96, 96, 97, 99, 98, 99, 97, 99, 98, 95, 100, 97, 97, 96, 98, 99, 99, 98, 98, 98, 98, 99, 97, 99]
                .map { Double($0) / 100 }
                .makeLoopingIterator(),
            dateProvider: try makeDateProvider(interval: (.hour, 1), starting: .init(year: 2024, month: 12, day: 18))
        )
        
        let heartRateResults = MockQueryResults(
            sampleType: .heartRate,
            timeRange: .currentWeek,
            samples: try heartRateSamplesProvider.makeSamples(12 * 7)
        )
        let blooxOxygenResults = MockQueryResults(
            sampleType: .bloodOxygen,
            timeRange: .currentWeek,
            samples: try bloodOxygenSamplesProvider.makeSamples(24 * 7)
        )
        
        let healthChart = HealthChart {
            HealthChartEntry(heartRateResults, drawingConfig: .init(mode: .line, color: .red))
            HealthChartEntry(blooxOxygenResults, drawingConfig: .init(mode: .line, color: .blue))
        }
            .frame(width: 600, height: 500)
            .withLocale(.enUS, timeZone: .losAngeles)
        
        assertSnapshot(of: healthChart, as: .image)
        
////        bpmProvider.consume(6) // consume some elements to shift the cycle
//        
//        heartRateSamplesProvider.skipValues(5)
//        heartRateSamplesProvider.skipDates(12 * 2)
//        
//        results.samples.append(contentsOf: try heartRateSamplesProvider.makeSamples(12 * 4))
//        
//        assertSnapshot(of: healthChart, as: .image)
    }
    
    
    @MainActor
    @Test("Empty HealthChart No Entries Snapshot")
    func emptyHealthChartNoEntriesSnapshot() {
        let healthChart = HealthChart {
            // nothing in here
        }
            .frame(width: 600, height: 500)
            .withLocale(.enUS, timeZone: .losAngeles)
        
        assertSnapshot(of: healthChart, as: .image)
    }
    
    @MainActor
    @Test("Empty HealthChart Entries But No Data Snapshot")
    func emptyHealthChartEntriesButNoDataSnapshot() throws {
        let data = MockQueryResults(sampleType: .heartRate, timeRange: .currentWeek, samples: [])
        let healthChart = HealthChart {
            HealthChartEntry(data, drawingConfig: .init(mode: .bar, color: .red))
        }
            .frame(width: 600, height: 500)
            .withLocale(.enUS, timeZone: .losAngeles)
        
        assertSnapshot(of: healthChart, as: .image)
    }
    
    
    @MainActor
    @Test("Conditional HealthChart Content Snapshot")
    func conditionalHealthChartContentSnapshot() throws {
        var heartRateSamplesProvider = FakeSamplesProvider(
            sampleType: .heartRate,
            values: [97 as Double, 95, 91, 89, 89, 92, 117, 119, 118, 95, 85, 87].makeLoopingIterator(),
            dateProvider: try makeDateProvider(interval: (.hour, 2), starting: .init(year: 2024, month: 12, day: 17))
        )
        var bloodOxygenSamplesProvider = FakeSamplesProvider(
            sampleType: .bloodOxygen,
            values: [100, 92, 96, 96, 96, 97, 99, 98, 99, 97, 99, 98, 95, 100, 97, 97, 96, 98, 99, 99, 98, 98, 98, 98, 99, 97, 99]
                .map { Double($0) / 100 }
                .makeLoopingIterator(),
            dateProvider: try makeDateProvider(interval: (.hour, 1), starting: .init(year: 2024, month: 12, day: 18))
        )
        
        let heartRateResults = MockQueryResults(
            sampleType: .heartRate,
            timeRange: .currentWeek,
            samples: try heartRateSamplesProvider.makeSamples(12 * 7)
        )
        let blooxOxygenResults = MockQueryResults(
            sampleType: .bloodOxygen,
            timeRange: .currentWeek,
            samples: try bloodOxygenSamplesProvider.makeSamples(24 * 7)
        )
        
        func makeHealthChart(flag: Bool) -> some View {
            HealthChart {
                if flag {
                    HealthChartEntry(heartRateResults, drawingConfig: .init(mode: .line, color: .red))
                } else {
                    HealthChartEntry(blooxOxygenResults, drawingConfig: .init(mode: .line, color: .blue))
                }
            }
            .frame(width: 600, height: 500)
            .withLocale(.enUS, timeZone: .losAngeles)
        }
        
        let healthChart1 = makeHealthChart(flag: true)
        assertSnapshot(of: healthChart1, as: .image)
        
        let healthChart2 = makeHealthChart(flag: false)
        assertSnapshot(of: healthChart2, as: .image)
    }
#endif
}
