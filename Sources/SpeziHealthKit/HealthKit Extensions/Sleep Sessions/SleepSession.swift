//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Algorithms
import Foundation
import HealthKit
import SpeziFoundation


/// A `SleepSession` represents a continuous series of individual ``SampleType/sleepAnalysis`` `HKCategorySample`s.
///
/// ## Topics
/// ### Initializers
/// - ``init(_:)``
/// ### Properties
/// - ``samples-swift.property``
/// - ``startDate``
/// - ``endDate``
public struct SleepSession: Hashable, Sendable {
    public typealias Samples = [HKCategorySample]
    public typealias SleepPhase = HKCategoryValueSleepAnalysis
    
    /// The individual `HKCategorySample`s belonging to this sleep session.
    ///
    /// It is guaranteed that there is at least one sample in the session.
    public let samples: Samples
    
    /// The session's overall start date
    public var startDate: Date {
        // SAFETY: `samples` is a non-empty array
        samples.first!.startDate // swiftlint:disable:this force_unwrapping
    }
    /// The session's overall end date
    public var endDate: Date {
        // SAFETY: `samples` is a non-empty array
        samples.last!.endDate // swiftlint:disable:this force_unwrapping
    }
    
    /// The total time range of the tracked samples.
    public var timeRange: Range<Date> {
        startDate..<endDate
    }
    
    /// The total amount of time tracked for each sleep phase.
    ///
    /// - Note: Sleep Analysis samples with the same ``SleepPhase`` value typically don't overlap with each other within a single Sleep Session.
    ///     If a session does contain overlapping samples with the same phase, the value here would be the
    public let timeTrackedBySleepPhase: [SleepPhase: TimeInterval]
    
    /// Creates a new `SleepSession`, from a collection of `HKCategorySample`s representing sleep analysis samples.
    ///
    /// If `samples` is empty or contains non-sleep-analysis samples, the initializer will fail and return `nil`.
    /// - parameter samples: A collection of sleep analysis samples belonging to a single sleep session.
    /// - Note: Prefer using ``Swift/Collection/splitIntoSleepSessions(threshold:)`` over this init,
    ///     if you have a collection of sleep samples that might not all belong to a single sleep session.
    init?(_ samples: some Collection<HKCategorySample>) {
        guard !samples.isEmpty && samples.allSatisfy({ $0.is(.sleepAnalysis) }) else {
            return nil
        }
        self.samples = Array(samples)
        assert(samples.allSatisfy { $0.startDate <= $0.endDate })
        assert(samples.adjacentPairs().allSatisfy { $0.startDate <= $1.startDate })
        timeTrackedBySleepPhase = samples.reduce(into: [:]) { results, sample in
            if let sleepPhase = sample.sleepPhase {
                results[sleepPhase, default: 0] += sample.endDate.timeIntervalSince(sample.startDate)
            }
        }
    }
}


extension SleepSession {
    /// The total amount of time tracked as being awake.
    public var totalTimeAwake: TimeInterval {
        timeTrackedBySleepPhase[.awake] ?? 0
    }
    
    /// The total amount of time tracked as being asleep.
    public var totalTimeAsleep: TimeInterval {
        timeTrackedBySleepPhase.lazy
            .compactMap { SleepPhase.allAsleepValues.contains($0) ? $1 : nil }
            .reduce(0, +)
    }
    
    /// Fetches all samples in the session that have the specified ``SleepPhase``
    public func samples(for sleepPhase: SleepPhase) -> [HKCategorySample] {
        samples.filter { $0.sleepPhase == sleepPhase }
    }
    
    /// The total amount of time tracked for a sleep phase.
    ///
    /// - Note: Sleep Analysis samples with the same ``SleepPhase`` value typically don't overlap with each other within a single Sleep Session.
    ///     If a session does contain overlapping samples with the same phase, the value returned here would be the total tracked time, without the overlap taken into account.
    public func timeTracked(for sleepPhase: SleepPhase) -> TimeInterval {
        samples(for: sleepPhase).reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
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


extension SleepSession: CustomStringConvertible {
    public var description: String {
        var desc = "SleepSession("
        desc.append("timeRange: \(timeRange)")
        desc.append("; \(samples.count) sample\(samples.count > 1 ? "s" : "")")
        for sleepPhase in SleepSession.SleepPhase.allKnownValues.sorted(using: KeyPathComparator(\.rawValue)) {
            let numSamples = samples(for: sleepPhase).count
            if numSamples > 0 {
                desc.append("; \(numSamples) \(sleepPhase.displayTitle)")
            }
        }
        desc.append(")")
        return desc
    }
}


extension HKCategorySample {
    /// The sample's sleep phase, if applicable.
    public var sleepPhase: HKCategoryValueSleepAnalysis? {
        guard self.is(.sleepAnalysis) else {
            return nil
        }
        return .init(rawValue: value)
    }
}


extension SleepSession.SleepPhase {
    /// All currently-known sleep phases
    public static let allKnownValues: Set<Self> = [
        .inBed,
        .asleepUnspecified,
        .awake,
        .asleepCore,
        .asleepDeep,
        .asleepREM
    ]
    
    fileprivate var displayTitle: String {
        switch self {
        case .inBed:
            "in bed"
        case .asleepUnspecified:
            "asleep (unspecified)"
        case .awake:
            "awake"
        case .asleepCore:
            "core"
        case .asleepDeep:
            "deep"
        case .asleepREM:
            "rem"
        @unknown default:
            "other (\(rawValue))"
        }
    }
}
