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


@Observable
final class MockQueryResults: HealthKitQueryResults, @unchecked Sendable { // it really isn't sendable, but we also can't mark it as being MainActor-constrained, but since we only ever mutate it from the MainActor, we should (hopefully???) be safe here??
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


func makeDateProvider(
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

