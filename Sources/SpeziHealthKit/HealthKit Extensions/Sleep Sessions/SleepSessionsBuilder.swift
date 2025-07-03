//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import Algorithms
import Foundation
import HealthKit
import SpeziFoundation


/// An error that can occur when processing Sleep Analysis samples.
public enum SleepSessionConversionError: Error {
    /// The input data wasn't sleep analysis samples
    case invalidSampleType
}


extension Collection where Element == HKCategorySample {
    /// Splits the collection's individual samples into ``SleepSession``s.
    ///
    /// - parameter maxAllowedDistance: The maximum allowed distance between two samples for them to still be considered as bslonging to the same sleep session
    /// - throws: if the collection doens't exclusively consist of sleep analysis samples
    ///
    /// ## Topics
    /// - ``SleepSessionConversionError``
    public func splitIntoSleepSessions(
        threshold maxAllowedDistance: Duration = .minutes(60),
    ) throws(SleepSessionConversionError) -> [SleepSession] {
        guard allSatisfy({ $0.is(.sleepAnalysis) }) else {
            throw SleepSessionConversionError.invalidSampleType
        }
        return self
            // We need to process the samples separately by each source,
            // in order to avoid incorrect results when there's e.g. 2 apps
            // performing sleep tracking simultaneously. (E.g.: Apple Watch and AutoSleep.)
            .grouped(by: \.sourceRevision.source)
            .flatMap { SleepSessionsBuilder.run(maxAllowedDistance: maxAllowedDistance.timeInterval, samples: $0.value) }
    }
}


private struct SleepSessionsBuilder {
    // swiftlint:disable:next type_contents_order
    static func run(maxAllowedDistance: TimeInterval, samples: some Collection<HKCategorySample>) -> [SleepSession] {
        var builder = Self(maxAllowedDistance: maxAllowedDistance)
        for sample in samples {
            builder.process(sample)
        }
        return builder.sessions.map { SleepSession($0.samples)! } // swiftlint:disable:this force_unwrapping
    }
    
    
    private struct SimpleSleepSession {
        private(set) var samples = OrderedArray<HKCategorySample> {
            switch $0.startDate.compare($1.startDate) {
            case .orderedAscending:
                true
            case .orderedDescending:
                false
            case .orderedSame:
                $0.uuid < $1.uuid
            }
        }
        var timeRange: Range<Date> {
            firstSample.startDate..<lastSample.endDate
        }
        var firstSample: HKCategorySample {
            // SAFETY: it's guaranteed that `samples` will always contain at least one sample.
            samples[unsafe: 0]
        }
        var lastSample: HKCategorySample {
            // SAFETY: it's guaranteed that `samples` will always contain at least one sample.
            samples[unsafe: samples.endIndex - 1]
        }
        
        init(initialSample sample: HKCategorySample) {
            samples.insert(sample)
        }
        mutating func insert(sample: HKCategorySample) {
            samples.insert(sample)
        }
        mutating func formUnion(_ other: Self) {
            samples.insert(contentsOf: other.samples)
        }
    }
    
    
    /// The maximum amount of time we allow to exist between two samples, to still consider them as belonging to the same sleep session.
    private let maxAllowedDistance: TimeInterval
    
    private var sessions = OrderedArray<SimpleSleepSession> {
        $0.firstSample.startDate < $1.lastSample.startDate
    }
    
    private mutating func addSampleToSessionAndMergeWithNeighboursIfNecessary(
        _ sample: HKCategorySample,
        sessionIdx: OrderedArray<SimpleSleepSession>.Index
    ) {
        let newSessionTimeRange = sessions[sessionIdx].timeRange.union(with: sample.timeRange)
        let canMergeWithPrev = sessions[safe: sessionIdx - 1]?.timeRange.overlaps(newSessionTimeRange, threshold: maxAllowedDistance) ?? false
        let canMergeWithNext = sessions[safe: sessionIdx + 1]?.timeRange.overlaps(newSessionTimeRange, threshold: maxAllowedDistance) ?? false
        
        if !canMergeWithPrev && !canMergeWithNext {
            sessions[unsafe: sessionIdx].insert(sample: sample)
        } else {
            // we can merge w/ either the prev or the next
            sessions.withInvariantCheckingTemporarilyDisabled { sessions in
                sessions[unsafe: sessionIdx].insert(sample: sample)
                if canMergeWithNext {
                    sessions[unsafe: sessionIdx].formUnion(sessions[sessionIdx + 1])
                    sessions.remove(at: sessionIdx + 1)
                }
                if canMergeWithPrev {
                    sessions[unsafe: sessionIdx - 1].formUnion(sessions[sessionIdx])
                    sessions.remove(at: sessionIdx)
                }
            }
        }
    }
    
    private mutating func process(_ sample: HKCategorySample) {
        let binarySearchResult = sessions.binarySearchFirstIndex(where: { session in
            if session.timeRange.overlaps(sample.timeRange, threshold: maxAllowedDistance) {
                .orderedSame
            } else if sample.timeRange.upperBound < session.timeRange.lowerBound {
                .orderedAscending
            } else {
                .orderedDescending
            }
        })
        switch binarySearchResult {
        case .found(let sessionIdx):
            // we have found an existing session that overlaps with the sample's time range, or is close enough to still fall within the threshold
            // --> we add the sample to that session
            addSampleToSessionAndMergeWithNeighboursIfNecessary(sample, sessionIdx: sessionIdx)
        case .notFound(let idx):
            // we have not found a matching session
            // --> we create a new one, and insert it at the position where a matching session would be
            let session = SimpleSleepSession(initialSample: sample)
            sessions.unsafelyInsert(session, at: idx)
        }
    }
}


extension Range {
    func contains(_ element: Bound, threshold: Bound.Stride) -> Bool where Bound: Strideable {
        lowerBound.advanced(by: -threshold) <= element && element < upperBound.advanced(by: threshold)
    }
    
    /// Determines whether the range overlaps with the other range, or falls within `threshold` of it.
    func overlaps(_ other: Range<Bound>, threshold: Bound.Stride) -> Bool where Bound: Strideable {
        other.overlaps(lowerBound.advanced(by: -threshold)..<upperBound.advanced(by: threshold))
    }
    
    func union(with other: Range<Bound>) -> Range<Bound> {
        Swift.min(lowerBound, other.lowerBound)..<Swift.max(upperBound, other.upperBound)
    }
}
