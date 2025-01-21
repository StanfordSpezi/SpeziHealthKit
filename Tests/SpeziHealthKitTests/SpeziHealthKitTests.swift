//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
@testable import SpeziHealthKit
import XCTest
import XCTSpezi
import SnapshotTesting
import SwiftUI


private struct FakeSamplesProvider<Values: IteratorProtocol<Double>, Dates: IteratorProtocol<Date>> {
    private let sampleType: SampleType<HKQuantitySample>
    private var valueProvider: Values
    private var dateProvider: Dates
    
    init(sampleType: SampleType<HKQuantitySample>, values: Values, dateProvider: Dates) {
        self.sampleType = sampleType
        self.valueProvider = values
        self.dateProvider = dateProvider
    }
    
    
    mutating func skipValues(_ count: Int) {
        valueProvider.consume(count)
    }
    
    mutating func skipDates(_ count: Int) {
        dateProvider.consume(count)
    }
    
    mutating func makeSamples(_ count: Int) throws -> [HKQuantitySample] {
        try (0..<count).map { _ in
            HKQuantitySample(
                type: sampleType,
                quantity: .init(unit: sampleType.displayUnit, doubleValue: try XCTUnwrap(valueProvider.next())),
                date: try XCTUnwrap(dateProvider.next())
            )
        }
    }
}



final class SpeziHealthKitTests: XCTestCase {
    @MainActor
    func testSimpleHealthChartView() throws {
        var heartRateSamplesProvider = FakeSamplesProvider(
            sampleType: .heartRate,
            values: [97 as Double, 95, 91, 89, 89, 92, 117, 119, 118, 95, 85, 87].makeLoopingIterator(),
            dateProvider: try makeDateProvider(interval: (.hour, 2), starting: .init(year: 2024, month: 12, day: 17))
        )
        
        let results = MockQueryResults(sampleType: .heartRate, timeRange: .currentWeek, samples: try heartRateSamplesProvider.makeSamples(12 * 7))
        let healthChart = HealthChart {
            HealthChartEntry(results, drawingConfig: .init(mode: .line, color: .red))
        }.frame(width: 600, height: 500)
        assertSnapshot(of: healthChart, as: .image)
        
//        bpmProvider.consume(6) // consume some elements to shift the cycle
        
        heartRateSamplesProvider.skipValues(5)
        heartRateSamplesProvider.skipDates(12 * 2)
        
        results.samples.append(contentsOf: try heartRateSamplesProvider.makeSamples(12 * 4))
        
        assertSnapshot(of: healthChart, as: .image)
    }
    
    
    @MainActor
    func testMultiEntryHealthChartView() throws {
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
        }.frame(width: 600, height: 500)
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
    func testEmptyHealthChartNoEntries() {
        let healthChart = HealthChart {
            // nothing in here
        }.frame(width: 600, height: 500)
        assertSnapshot(of: healthChart, as: .image)
    }
    
    @MainActor
    func testEmptyHealthChartEntriesButNoData() {
        let data = MockQueryResults(sampleType: .heartRate, timeRange: .currentWeek, samples: [])
        let healthChart = HealthChart {
            HealthChartEntry(data, drawingConfig: .init(mode: .bar, color: .red))
        }.frame(width: 600, height: 500)
        assertSnapshot(of: healthChart, as: .image)
    }
    
    
    @MainActor
    func testConditionalHealthChartContent() throws {
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
            }.frame(width: 600, height: 500)
        }
        
        
        let healthChart1 = makeHealthChart(flag: true)
        assertSnapshot(of: healthChart1, as: .image)
        
        let healthChart2 = makeHealthChart(flag: false)
        assertSnapshot(of: healthChart2, as: .image)
    }
}


@Observable
private final class MockQueryResults: HealthKitQueryResults, @unchecked Sendable { // it really isn't sendable, but we also can't mark it as being MainActor-constrained, but since we only ever mutate it from the MainActor, we should (hopefully???) be safe here??
    typealias Sample = HKQuantitySample
    typealias Element = HKQuantitySample
    typealias Index = [Sample].Index
    
    let sampleType: SampleType<Sample>
    let timeRange: HealthKitQueryTimeRange
    var samples: [Sample]
    
    let queryError: (any Error)? = nil
    
    init(sampleType: SampleType<Sample>, timeRange: HealthKitQueryTimeRange, samples: [Sample]) {
        self.sampleType = sampleType
        self.samples = samples
        self.timeRange = timeRange
    }
    
    var startIndex: Index {
        samples.startIndex
    }
    
    var endIndex: Index {
        samples.endIndex
    }
    
    subscript(position: Index) -> HKQuantitySample {
        samples[position]
    }
}


// MARK: Utility things


private func makeDateProvider(
    interval: (component: Calendar.Component, multiple: Int),
    starting startDate: DateComponents
) throws -> some (Sequence<Date> & IteratorProtocol<Date>) {
    let cal = Calendar.current
    let startDate = try XCTUnwrap(cal.date(from: startDate))
    return sequence(first: startDate) {
        cal.date(byAdding: interval.component, value: interval.multiple, to: $0)
    }
}



extension HKQuantitySample {
    convenience init(type: SampleType<HKQuantitySample>, quantity: HKQuantity, date: Date) {
        self.init(type: type.hkSampleType, quantity: quantity, start: date, end: date)
    }
}


extension IteratorProtocol {
    mutating func consume(_ count: Int) {
        var numConsumed = 0
        while numConsumed < count, let _ = next() {
            numConsumed += 1
        }
    }
}




extension Collection {
    public func makeLoopingIterator() -> LoopingCollectionIterator<Self> {
        LoopingCollectionIterator(self)
    }
}


public struct LoopingCollectionIterator<Base: Collection>: IteratorProtocol {
    public typealias Element = Base.Element
    
    /// The collection we want to provide looping iteration over.
    private let base: Base
    /// The current iteration state, i.e. the index of the next element to be yielded from the iterator.
    private var idx: Base.Index
    
    fileprivate init(_ base: Base) {
        self.base = base
        self.idx = base.startIndex
    }
    
    public mutating func next() -> Element? {
        defer {
            base.formIndex(after: &idx)
            if idx >= base.endIndex {
                idx = base.startIndex
            }
        }
        return base[idx]
    }
    
    /// "Resets" the iterator to the beginning of the collection.
    /// The next call to ``LoopingIterator.next()`` will yield the collection's first element.
    public mutating func reset() {
        idx = base.startIndex
    }
}
