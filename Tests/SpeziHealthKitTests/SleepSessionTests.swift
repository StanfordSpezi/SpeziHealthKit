//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
@testable import SpeziHealthKit
import Testing


@Suite struct SleepSessionTests {
    private typealias SleepPhase = HKCategoryValueSleepAnalysis
    
    @Test
    func simpleSleepSessionConstruction0() throws {
        let startDate = try #require(Calendar.current.date(from: .init(year: 2025, month: 7, day: 17, hour: 22)))
        let inputSamples = makeSamples(startDate: startDate, for: [
            .sample(.asleepCore, duration: .hours(1)),
            .sample(.asleepDeep, duration: .hours(1)),
            .sample(.asleepCore, duration: .hours(1)),
            .sample(.asleepREM, duration: .hours(1)),
            .sample(.asleepDeep, duration: .hours(3)),
            .sample(.awake, duration: .minutes(5)),
            .sample(.asleepCore, duration: .minutes(55))
        ])
        let sleepSessions = try inputSamples.splitIntoSleepSessions()
        #expect(sleepSessions.count == 1)
        #expect(sleepSessions[0].samples == inputSamples)
        #expect(sleepSessions[0].timeRange == startDate..<startDate.addingTimeInterval(Duration.hours(8).timeInterval))
        #expect(sleepSessions[0].timeTracked(for: .asleepCore) == Duration.minutes(175).timeInterval)
    }
    
    // Tests overlapping samples
    @Test
    func simpleSleepSessionConstruction1() throws {
        let startDate = try #require(Calendar.current.date(from: .init(year: 2025, month: 7, day: 17, hour: 22)))
        let inputSamples = makeSamples(startDate: startDate, for: [
            .sample(.asleepCore, duration: .hours(1)),
            .sample(.asleepDeep, duration: .hours(1)),
            .sample(.asleepCore, duration: .hours(1)),
            .sample(.asleepREM, duration: .hours(1)),
            .emptyGap(.hours(-1)),
            .sample(.asleepDeep, duration: .hours(3)),
            .sample(.awake, duration: .minutes(5)),
            .sample(.asleepCore, duration: .minutes(55))
        ])
        let sleepSessions = try inputSamples.splitIntoSleepSessions()
        #expect(sleepSessions.count == 1)
        #expect(sleepSessions[0].samples == inputSamples)
        #expect(sleepSessions[0].timeRange == startDate..<startDate.addingTimeInterval(Duration.hours(8).timeInterval))
        #expect(sleepSessions[0].timeTracked(for: .asleepCore) == Duration.minutes(175).timeInterval)
    }
}


extension SleepSessionTests {
    private enum SampleDescriptor {
        case emptyGap(Duration)
        case sample(SleepPhase, duration: Duration)
    }
    
    private func makeSamples(startDate: Date, for descriptors: [SampleDescriptor]) -> [HKCategorySample] {
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
        return samples
    }
}
