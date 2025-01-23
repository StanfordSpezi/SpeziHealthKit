//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import HealthKit
import SpeziHealthKit
import XCTest


// NOTE: this type isn't really Sendable, but we also can't mark it as being MainActor-constrained,
// but since we only use it in the HealthChartTests, all of which are MainActor-constrained,
// we should be safe here.
@Observable
final class MockQueryResults: HealthKitQueryResults, @unchecked Sendable { // swiftlint:disable:this file_types_order
    typealias Sample = HKQuantitySample
    typealias Element = HKQuantitySample
    typealias Index = [Sample].Index
    
    let sampleType: SampleType<Sample>
    let timeRange: HealthKitQueryTimeRange
    var samples: [Sample]
    
    let queryError: (any Error)? = nil
    
    var startIndex: Index { samples.startIndex }
    var endIndex: Index { samples.endIndex }
    
    init(sampleType: SampleType<Sample>, timeRange: HealthKitQueryTimeRange, samples: [Sample]) {
        self.sampleType = sampleType
        self.samples = samples
        self.timeRange = timeRange
    }
    
    subscript(position: Index) -> HKQuantitySample {
        samples[position]
    }
}


struct FakeSamplesProvider<Values: IteratorProtocol<Double>, Dates: IteratorProtocol<Date>> {
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


// MARK: Utility things

func makeDateProvider(
    interval: (component: Calendar.Component, multiple: Int),
    starting startDate: DateComponents
) throws -> some (Sequence<Date> & IteratorProtocol<Date>) {
    let cal = Calendar.current.withLocale(.enUS, timeZone: .losAngeles)
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
        while numConsumed < count, _ = next() {
            numConsumed += 1
        }
    }
}
