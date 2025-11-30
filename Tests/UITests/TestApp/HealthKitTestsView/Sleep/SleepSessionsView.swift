//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Charts
import SpeziHealthKit
import SpeziHealthKitUI
import SpeziViews
import SwiftUI


struct SleepSessionsView: View {
    @Environment(HealthKit.self)
    private var healthKit
    
    @SleepPhaseColors private var sleepPhaseColors
    
    @HealthKitQuery(.sleepAnalysis, timeRange: .init({ () -> Range<Date> in
        let cal = Calendar.current
        let start = cal.date(from: .init(year: 2025, month: 2, day: 19))! // swiftlint:disable:this force_unwrapping
        let end = start.addingTimeInterval(60 * 60 * 24 * 2) // add 2 days, so that we fetch the entirety of the 19th and 20th
        return start..<end
    }()))
    private var sleepAnalysisSamples
    
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        Form { // swiftlint:disable:this closure_body_length
            let devices = sleepAnalysisSamples.compactMapIntoSet(\.device)
                .sorted(using: KeyPathComparator(\.name))
            let sourceRevisions = sleepAnalysisSamples.mapIntoSet(\.sourceRevision)
                .sorted(using: KeyPathComparator(\.source.name))
            Section("Devices") {
                ForEach(devices, id: \.self) { device in
                    Text("\(device)")
                }
            }
            Section("SourceRevisions") {
                ForEach(sourceRevisions, id: \.self) { sourceRevision in
                    Text("\(sourceRevision)")
                }
            }
            if let sleepSession {
                Section {
                    LabeledContent("Tracked Time", value: sleepSession.timeRange, format: .timeDuration)
                    LabeledContent("Time Awake", value: Duration.seconds(sleepSession.totalTimeSpentAwake).formatted())
                    LabeledContent("Time Asleep", value: Duration.seconds(sleepSession.totalTimeSpentAsleep).formatted())
                    LabeledContent("#Samples", value: sleepSession.count, format: .number)
                    ForEach([SleepSession.SleepPhase.asleepCore, .asleepDeep, .asleepREM], id: \.self) { phase in
                        let duration = sleepSession.timeSpent(in: phase)
                        LabeledContent("Time: \(phase.displayTitle)", value: Duration.seconds(duration).formatted())
                    }
                }
                Section {
                    chart(for: sleepSession)
                        .frame(height: 250)
                }
            } else {
                HStack {
                    Spacer()
                    Text("No Sleep Data")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .navigationTitle("Sleep Sessions")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AsyncButton(state: $viewState) {
                    try await addSleepSession()
                } label: {
                    Image(systemName: "plus")
                        .accessibilityLabel("Add Samples")
                }
            }
        }
    }
    
    private var sleepSession: SleepSession? {
        (try? sleepAnalysisSamples.splitIntoSleepSessions())?.first
    }
    
    @ViewBuilder
    private func chart(for sleepSession: SleepSession) -> some View {
        Chart {
            let phases = [SleepSession.SleepPhase.inBed, .awake, .asleepREM, .asleepCore, .asleepDeep, .asleepUnspecified]
            ForEach(phases, id: \.self) { phase in
                ForEach(sleepSession.samples(for: phase)) { sample in
                    RuleMark(
                        xStart: .value("Start Date", sample.startDate),
                        xEnd: .value("End Date", sample.endDate),
                        y: .value("Sleep Phase", sample.sleepPhase!.displayTitle) // swiftlint:disable:this force_unwrapping
                    )
                    .foregroundStyle(sleepPhaseColors[phase])
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 1)) { value in
                if let date = value.as(Date.self) {
                    let hour = Calendar.current.component(.hour, from: date)
                    switch hour {
                    case 0, 12:
                        AxisValueLabel(format: .dateTime.hour())
                    default:
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)))
                    }
                    AxisGridLine()
                    AxisTick()
                }
            }
        }
    }
    
    
    private func addSleepSession() async throws { // swiftlint:disable:this function_body_length
        struct SampleDescriptor {
            let phase: SleepSession.SleepPhase
            let duration: TimeInterval
        }
        
        let sampleDescriptors = [
            SampleDescriptor(phase: .asleepCore, duration: 750.0),
            SampleDescriptor(phase: .asleepDeep, duration: 300.0),
            SampleDescriptor(phase: .asleepCore, duration: 390.0),
            SampleDescriptor(phase: .asleepDeep, duration: 330.0),
            SampleDescriptor(phase: .asleepCore, duration: 30.0),
            SampleDescriptor(phase: .awake, duration: 30.0),
            SampleDescriptor(phase: .asleepCore, duration: 660.0),
            SampleDescriptor(phase: .asleepDeep, duration: 1350.0),
            SampleDescriptor(phase: .asleepCore, duration: 330.0),
            SampleDescriptor(phase: .asleepREM, duration: 630.0),
            SampleDescriptor(phase: .asleepCore, duration: 1140.0),
            SampleDescriptor(phase: .asleepDeep, duration: 1350.0),
            SampleDescriptor(phase: .asleepCore, duration: 930.0),
            SampleDescriptor(phase: .asleepDeep, duration: 390.0),
            SampleDescriptor(phase: .asleepCore, duration: 540.0),
            SampleDescriptor(phase: .asleepREM, duration: 870.0),
            SampleDescriptor(phase: .awake, duration: 60.0),
            SampleDescriptor(phase: .asleepCore, duration: 450.0),
            SampleDescriptor(phase: .asleepREM, duration: 90.0),
            SampleDescriptor(phase: .asleepCore, duration: 3180.0),
            SampleDescriptor(phase: .awake, duration: 90.0),
            SampleDescriptor(phase: .asleepCore, duration: 660.0),
            SampleDescriptor(phase: .asleepREM, duration: 2580.0),
            SampleDescriptor(phase: .asleepCore, duration: 3930.0),
            SampleDescriptor(phase: .awake, duration: 60.0),
            SampleDescriptor(phase: .asleepCore, duration: 180.0),
            SampleDescriptor(phase: .asleepREM, duration: 1350.0),
            SampleDescriptor(phase: .awake, duration: 60.0),
            SampleDescriptor(phase: .asleepCore, duration: 3690.0),
            SampleDescriptor(phase: .awake, duration: 840.0),
            SampleDescriptor(phase: .asleepCore, duration: 90.0)
        ]
        
        func makeSamples(from sampleDescriptors: [SampleDescriptor], startingAt startDate: Date) -> [HKCategorySample] {
            var samples: [HKCategorySample] = []
            for descriptor in sampleDescriptors {
                let start = samples.last?.endDate ?? startDate
                samples.append(HKCategorySample(
                    type: SampleType.sleepAnalysis.hkSampleType,
                    value: descriptor.phase.rawValue,
                    start: start,
                    end: start.addingTimeInterval(descriptor.duration)
                ))
            }
            return samples
        }
        
        let samples = makeSamples(
            from: sampleDescriptors,
            // swiftlint:disable:next force_unwrapping
            startingAt: Calendar.current.date(from: .init(year: 2025, month: 02, day: 19, hour: 22, minute: 13))!
        )
        
        try await healthKit.healthStore.save(samples)
    }
}


extension SleepSession.SleepPhase {
    var displayTitle: String {
        switch self {
        case .inBed:
            "In Bed"
        case .asleepUnspecified:
            "Asleep"
        case .awake:
            "Awake"
        case .asleepCore:
            "Core Sleep"
        case .asleepDeep:
            "Deep Sleep"
        case .asleepREM:
            "REM Sleep"
        @unknown default:
            "unknown<\(rawValue)>"
        }
    }
}
