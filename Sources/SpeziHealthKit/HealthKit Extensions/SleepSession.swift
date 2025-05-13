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


/// A `SleepSession` represents a continuous series of individual ``SampleType/sleepAnalysis`` `HKCategorySample`s.
public struct SleepSession: Hashable, Sendable {
    public typealias Samples = [HKCategorySample]
    public typealias SleepPhase = HKCategoryValueSleepAnalysis
    
    /// The individual `HKCategorySample`s belonging to this sleep session.
    ///
    /// It is guaranteed that there is at least one sample in the session.
    public let samples: Samples
    
    /// The session's overall start date
    public var startDate: Date {
        samples.first!.startDate // swiftlint:disable:this force_unwrapping
    }
    /// The session's overall end date
    public var endDate: Date {
        samples.last!.endDate // swiftlint:disable:this force_unwrapping
    }
    
    /// The session's total amount of tracked time, including both asleep and awake periods.
    public let totalTimeTracked: TimeInterval
    /// The total amount of time tracked for each sleep phase.
    public let trackedTimeBySleepPhase: [SleepPhase: TimeInterval]
    
    init?(_ samples: some Collection<HKCategorySample>) {
        guard !samples.isEmpty && samples.allSatisfy({ $0.is(.sleepAnalysis) }) else {
            return nil
        }
        self.samples = Array(samples)
        assert(samples.allSatisfy { $0.startDate <= $0.endDate })
        assert(samples.adjacentPairs().allSatisfy { $0.startDate <= $1.startDate })
        trackedTimeBySleepPhase = samples.reduce(into: [:]) { results, sample in
            if let sleepPhase = sample.sleepPhase {
                results[sleepPhase, default: 0] += sample.endDate.timeIntervalSince(sample.startDate)
            }
        }
        totalTimeTracked = trackedTimeBySleepPhase.values.reduce(0, +)
    }
}


extension SleepSession: RandomAccessCollection {
    public var startIndex: Samples.Index {
        samples.startIndex
    }
    public var endIndex: Samples.Index {
        samples.endIndex
    }
    public subscript(position: Int) -> Samples.Element {
        samples[position]
    }
}


/// An error that can occur when processing Sleep Analysis samples.
public enum SleepSessionConversionError: Error {
    /// The input data wasn't sleep analysis samples
    case invalidSampleType
}

extension Collection where Element == HKCategorySample {
    /// Splits the collection's individual samples into ``SleepSession``s.
    ///
    /// - throws: if the collection doens't contain sleep analysis samples
    ///
    /// ## Topics
    /// - ``SleepSessionConversionError``
    public func splitIntoSleepSessions(threshold: TimeInterval = 60 * 15) throws -> [SleepSession] {
        guard allSatisfy({ $0.is(.sleepAnalysis) }) else {
            throw SleepSessionConversionError.invalidSampleType
        }
        return SleepSessionsBuilder.run(threshold: threshold, samples: self)
    }
}


private struct SleepSessionsBuilder {
    // swiftlint:disable:next type_contents_order
    static func run(threshold: TimeInterval, samples: some Collection<HKCategorySample>) -> [SleepSession] {
        var builder = Self(threshold: threshold)
        for sample in samples {
            builder.process(sample)
        }
        assert(builder.sessions.adjacentPairs().allSatisfy { $1.timeRange.lowerBound.timeIntervalSince($0.timeRange.upperBound) > threshold })
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
        var timeRange: ClosedRange<Date> {
            firstSample.startDate...lastSample.endDate
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
    private let threshold: TimeInterval
    
    private var sessions = OrderedArray<SimpleSleepSession> {
        $0.firstSample.startDate < $1.lastSample.startDate
    }
    
    private mutating func addSampleToSessionAndMergeWithNeighboursIfNecessary(
        _ sample: HKCategorySample,
        sessionIdx: OrderedArray<SimpleSleepSession>.Index
    ) {
        let newSessionTimeRange = sessions[sessionIdx].timeRange.union(with: sample.timeRange)
        let canMergeWithPrev = sessions[safe: sessionIdx - 1]?.timeRange.overlaps(newSessionTimeRange, threshold: threshold) ?? false
        let canMergeWithNext = sessions[safe: sessionIdx + 1]?.timeRange.overlaps(newSessionTimeRange, threshold: threshold) ?? false
        
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
            if session.timeRange.overlaps(sample.timeRange, threshold: threshold) {
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


extension ClosedRange {
    func contains(_ element: Bound, threshold: Bound.Stride) -> Bool where Bound: Strideable {
        lowerBound.advanced(by: -threshold) <= element && element <= upperBound.advanced(by: threshold)
    }
    
    /// Determines whether the range overlaps with the other range, or falls within `threshold` of it.
    func overlaps(_ other: ClosedRange<Bound>, threshold: Bound.Stride) -> Bool where Bound: Strideable {
        other.overlaps(lowerBound.advanced(by: -threshold)...upperBound.advanced(by: threshold))
    }
    
    func union(with other: ClosedRange<Bound>) -> ClosedRange<Bound> {
        Swift.min(lowerBound, other.lowerBound)...Swift.max(upperBound, other.upperBound)
    }
}


extension HKCategorySample {
    /// The sample's sleep phase, if applicable.
    public var sleepPhase: HKCategoryValueSleepAnalysis? {
        guard categoryType == SampleType.sleepAnalysis.hkSampleType else {
            return nil
        }
        return .init(rawValue: value)
    }
}


extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}


extension Array {
    subscript(unsafe position: Int) -> Element {
        @_transparent
        get {
            withUnsafeBufferPointer { $0[position] }
        }
    }
}
