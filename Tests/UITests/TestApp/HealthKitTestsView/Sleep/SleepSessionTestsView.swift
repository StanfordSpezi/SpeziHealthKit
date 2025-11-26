//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import SwiftUI


struct SleepSessionTestsView: View {
    private typealias SleepPhase = HKCategoryValueSleepAnalysis
    
    @Environment(\.calendar) private var cal
    @Environment(HealthKit.self) private var healthKit
    
    @State private var result: Result<(), any Error>?
    
    var body: some View {
        Group {
            switch result {
            case nil:
                ProgressView("Running tests…")
            case .success:
                Text("Success")
            case .failure(let error):
                if let error = error as? TestError {
                    Text(verbatim: "Failure in \(error.sourceLocation.function) @ L\(error.sourceLocation.line):\n\(error.message)")
                } else {
                    Text(verbatim: "Failure:\n\(error)")
                }
            }
        }
        .padding()
        .task {
            #if targetEnvironment(simulator)
            result = await .init {
                try await test1()
                try await test2()
            }
            #else
            result = .failure(NSError(domain: "edu.stanford.SpeziHealthKit", code: 123, userInfo: [
                NSLocalizedDescriptionKey: """
                    Ignoring Sleep Session Tests bc not running in Simulator.
                    The tests will delete **all** Sleep Data stored in the Health app, and therefore should only be run in the simulator.
                    """
            ]))
            #endif
        }
    }
    
    private func resetSleepData() async throws {
        try await healthKit.healthStore.deleteObjects(
            of: SampleType.sleepAnalysis.hkSampleType,
            predicate: HKQuery.predicateForObjects(from: .default())
        )
    }
    
    private func test1() async throws {
        try await resetSleepData()
        let startDate = try unwrap(cal.date(from: .init(year: 2025, month: 7, day: 17, hour: 22)))
        let samples = try await addSamples(startDate: startDate, for: [
            .sample(.asleepCore, duration: .hours(1)),
            .sample(.asleepDeep, duration: .hours(1)),
            .sample(.asleepCore, duration: .hours(1)),
            .sample(.asleepREM, duration: .hours(1)),
            .sample(.asleepDeep, duration: .hours(3)),
            .sample(.awake, duration: .minutes(5)),
            .sample(.asleepCore, duration: .minutes(55))
        ])
        let sleepSessions = try samples.splitIntoSleepSessions()
        try expectEqual(sleepSessions.count, 1)
        let session = try unwrap(sleepSessions.first)
        try expectEqual(session.samples, samples)
        try expectEqual(session.timeRange, startDate..<startDate.addingTimeInterval(Duration.hours(8).timeInterval))
        try expectEqual(session.timeSpent(in: .asleepCore), Duration.minutes(175).timeInterval)
        try expectEqual(session.totalTimeSpentAsleep, (Duration.hours(7) + .minutes(55)).timeInterval)
        try expectEqual(session.reduce(into: 0) { $0 += $1.timeRange.timeInterval }, Duration.hours(8).timeInterval)
    }
    
    
    // Tests overlapping samples
    private func test2() async throws {
        try await resetSleepData()
        let startDate = try unwrap(cal.date(from: .init(year: 2025, month: 7, day: 17, hour: 22)))
        let inputSamples = try await addSamples(startDate: startDate, for: [
            .sample(.asleepCore, duration: .hours(1)),
            .sample(.asleepDeep, duration: .hours(1)),
            .sample(.asleepCore, duration: .hours(1)),
            .sample(.asleepREM, duration: .hours(1)),
            .emptyGap(.minutes(-30)),
            .sample(.asleepDeep, duration: .hours(3)),
            .sample(.awake, duration: .minutes(5)),
            .sample(.asleepCore, duration: .minutes(55))
        ])
        let sleepSessions = try inputSamples.splitIntoSleepSessions()
        try expectEqual(sleepSessions.count, 1)
        let session = try unwrap(sleepSessions.first)
        try expectEqual(session.samples, inputSamples)
        try expectEqual(session.timeRange, startDate..<startDate.addingTimeInterval(Duration.hours(7.5).timeInterval))
        try expectEqual(session.timeSpent(in: .asleepCore), Duration.minutes(175).timeInterval)
        try expectEqual(session.totalTimeSpentAsleep, (Duration.hours(7) + .minutes(25)).timeInterval)
        try expectEqual(session.reduce(into: 0) { $0 += $1.timeRange.timeInterval }, Duration.hours(8).timeInterval)
    }
}


extension SleepSessionTestsView {
    private enum SampleDescriptor {
        case emptyGap(Duration)
        case sample(SleepPhase, duration: Duration)
    }
    
    /// Adds the specified samples to the health store, and then fetches **all** sleep samples from the health store.
    private func addSamples(startDate: Date, for descriptors: [SampleDescriptor]) async throws -> [HKCategorySample] {
        var samples: [HKCategorySample] = []
        var currentTime = startDate
        for descriptor in descriptors {
            switch descriptor {
            case .emptyGap(let duration):
                currentTime += duration.timeInterval
            case let .sample(sleepPhase, duration):
                let startDate = currentTime
                currentTime += duration.timeInterval
                samples.append(HKCategorySample(
                    type: .init(.sleepAnalysis),
                    value: sleepPhase.rawValue,
                    start: startDate,
                    end: currentTime,
                    metadata: [:]
                ))
            }
        }
        try await healthKit.healthStore.save(samples)
        return try await healthKit.query(.sleepAnalysis, timeRange: .ever)
    }
}


extension Result {
    init(catching body: sending () async throws(Failure) -> Success) async {
        do {
            self = .success(try await body())
        } catch {
            self = .failure(error)
        }
    }
}


extension Range where Bound == Date {
    var timeInterval: TimeInterval {
        lowerBound.distance(to: upperBound)
    }
}
