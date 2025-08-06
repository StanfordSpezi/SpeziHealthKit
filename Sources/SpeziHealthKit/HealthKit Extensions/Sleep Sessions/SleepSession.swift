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
/// ### Sleep Phase Durations
///
/// A Sleep Session might have overlapping samples, depending on how the source app that created the samples performed its sleep tracking.
/// Additionally, overlapping samples will exist if there were multiple apps that contributed sleep tracking data for the same night.
///
/// The ``SleepSession`` type, when working with time durations, differentiates between time *recorded* for a given ``SleepPhase``, and time *spent* in the ``SleepPhase``.
/// Starting with iOS 18, all `TimeInterval`-based APIs offered by ``SleepSession`` return *spent* time;
/// if your app, for whatever reason, needs to work with *recorded* time, it'll need to perform those computations itself.
///
/// The recorded time refers to the total amount of time for which data recordings exist, including potentially overlapping samples.
/// The *spent* time refers to the actual real-world time the tracked user spent in the ``SleepPhase``.
///
/// For example, a user might have slept for a total of 7 hours, with two apps contributing sleep tracking data for this night.
/// If the first app correctly recorded the entire 7 hours, while the second app only tracked 6.5 hours, the total *recorded* time would be 13.5 hours.
///
/// ## Topics
///
/// ### Instance Properties
/// - ``samples-swift.property``
/// - ``startDate``
/// - ``endDate``
///
/// ### Creating SleepSessions
/// - ``Swift/Collection/splitIntoSleepSessions(threshold:separateBySource:)``
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
    
    /// The total amount of time spent in each sleep phase.
    ///
    /// - Note: When running on iOS 18 or later, the values here will represent the actual time spent in the specific sleep phases, taking into account potential overlap between samples.
    ///     On earlier iOS versions, the values do not take overlaps into account, and the reported value might be too large.
    public let timeSpentInSleepPhase: [SleepPhase: TimeInterval]
    
    /// The total amount of time tracked as being asleep.
    ///
    /// - Note: When running on iOS 18 or later, the values here will represent the actual total time spent asleep, taking into account potential overlap between samples.
    ///     On earlier iOS versions, the values do not take overlaps into account, and the reported value might be too large.
    public let totalTimeSpentAsleep: TimeInterval
    
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
        func calcTotalTime(samplesPredicate: @escaping (HKCategorySample) -> Bool) -> TimeInterval {
            if #available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2, *) {
                return RangeSet<Date>(samples.lazy.filter(samplesPredicate).map { $0.timeRange })
                    .ranges
                    .reduce(into: 0) { $0 += $1.timeInterval }
            } else {
                return samples.reduce(into: 0) { $0 += $1.timeRange.timeInterval }
            }
        }
        timeSpentInSleepPhase = SleepPhase.allKnownValues.reduce(into: [:]) { mapping, phase in
            mapping[phase] = calcTotalTime { $0.sleepPhase == phase }
        }
        totalTimeSpentAsleep = calcTotalTime { $0.sleepPhase?.isAsleep == true }
    }
}


extension SleepSession {
    /// The total amount of time tracked as being awake.
    ///
    /// - Note: When running on iOS 18 or later, the values here will represent the actual time spent in the specific sleep phases, taking into account potential overlap between samples.
    ///     On earlier iOS versions, the values do not take overlaps into account, and the reported value might be too large.
    @inlinable public var totalTimeSpentAwake: TimeInterval {
        timeSpentInSleepPhase[.awake] ?? 0
    }
    
    /// Fetches all samples in the session that have the specified ``SleepPhase``
    @inlinable public func samples(for sleepPhase: SleepPhase) -> [HKCategorySample] {
        samples.filter { $0.sleepPhase == sleepPhase }
    }
    
    /// The total amount of tims spent in a sleep phase.
    ///
    /// - Note: When running on iOS 18 or later, the values here will represent the actual time spent in the specific sleep phases, taking into account potential overlap between samples.
    ///     On earlier iOS versions, the values do not take overlaps into account, and the reported value might be too large.
    @available(*, deprecated, renamed: "timeSpent(in:)")
    @inlinable public func timeTracked(for sleepPhase: SleepPhase) -> TimeInterval {
        timeSpent(in: sleepPhase)
    }
    
    /// The total amount of time spent in a sleep phase.
    ///
    /// - Note: When running on iOS 18 or later, the values here will represent the actual time spent in the specific sleep phases, taking into account potential overlap between samples.
    ///     On earlier iOS versions, the values do not take overlaps into account, and the reported value might be too large.
    @inlinable public func timeSpent(in sleepPhase: SleepPhase) -> TimeInterval {
        timeSpentInSleepPhase[sleepPhase] ?? 0
    }
}


extension SleepSession {
    /// The total amount of time tracked for each sleep phase.
    ///
    /// - Note: When running on iOS 18 or later, the values here will represent the actual time spent in the specific sleep phases, taking into account potential overlap between samples.
    ///     On earlier iOS versions, the values do not take overlaps into account, and the reported value might be too large.
    @available(*, deprecated, message: "Switch to either timeSpentBySleepPhase")
    public var timeTrackedBySleepPhase: [SleepPhase: TimeInterval] {
        timeSpentInSleepPhase
    }
    
    /// The total amount of time tracked as being awake.
    @available(*, deprecated, renamed: "totalTimeSpentAwake")
    @inlinable public var totalTimeAwake: TimeInterval {
        totalTimeSpentAwake
    }
    
    /// The total amount of time tracked as being asleep.
    ///
    /// - Note: When running on iOS 18 or later, the values here will represent the actual time spent in the specific sleep phases, taking into account potential overlap between samples.
    ///     On earlier iOS versions, the values do not take overlaps into account, and the reported value might be too large.
    @available(*, deprecated, renamed: "totalTimeSpentAsleep")
    @inlinable public var totalTimeAsleep: TimeInterval {
        totalTimeSpentAsleep
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
    
    /// Whether the value represents an asleep phase.
    @inlinable public var isAsleep: Bool {
        Self.allAsleepValues.contains(self)
    }
    
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


extension Range where Bound == Date {
    var timeInterval: TimeInterval {
        lowerBound.distance(to: upperBound)
    }
}
