//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziHealthKit
import SpeziHealthKitUI
import SpeziViews
import SwiftUI


struct ScoredAssessmentsView: View {
    private static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt
    }()
    @Environment(HealthKit.self) private var healthKit
    @Environment(\.calendar) private var cal
    
    @HealthKitQuery(.gad7, timeRange: .ever)
    private var gad7Assessments
    
    @HealthKitQuery(.phq9, timeRange: .ever)
    private var phq9Assessments
    
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        Form {
            Section("GAD-7") {
                if gad7Assessments.isEmpty {
                    Text("No GAD-7 Assessments")
                }
                ForEach(gad7Assessments) { (assessment: HKGAD7Assessment) in
                    VStack {
                        LabeledContent("Date", value: Self.dateFormatter.string(from: assessment.startDate))
                        LabeledContent("Risk", value: assessment.risk.rawValue, format: .number)
                        LabeledContent("Answers", value: assessment.answers.map { "\($0.rawValue)" }.joined(separator: ";"))
                    }
                }
            }
            Section("PHQ-9") {
                if phq9Assessments.isEmpty {
                    Text("No PHQ-9 Assessments")
                }
                ForEach(phq9Assessments) { assessment in
                    VStack {
                        LabeledContent("Date", value: Self.dateFormatter.string(from: assessment.startDate))
                        LabeledContent("Risk", value: assessment.risk.rawValue, format: .number)
                        LabeledContent("Answers", value: assessment.answers.map { "\($0.rawValue)" }.joined(separator: ";"))
                    }
                }
            }
        }
        .navigationTitle("Scored Assessments")
        .viewStateAlert(state: $viewState)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    AsyncButton("Add Sample: GAD-7", state: $viewState) {
                        try await addTestData(for: .GAD7)
                    }
                    AsyncButton("Add Sample: PHQ-9", state: $viewState) {
                        try await addTestData(for: .PHQ9)
                    }
                } label: {
                    Image(systemName: "plus")
                        .accessibilityLabel("Add")
                }
                .accessibilityIdentifier("Add")
            }
        }
    }
    
    private func addTestData(for scoredAssessment: HKScoredAssessmentTypeIdentifier) async throws {
        switch scoredAssessment {
        case .GAD7:
            let assessment = HKGAD7Assessment(
                // note that we intentionally give this one a different date, so that the test can keep them apart more easily
                date: cal.date(from: .init(year: 2025, month: 4, day: 25))!, // swiftlint:disable:this force_unwrapping
                answers: [
                    .moreThanHalfTheDays,
                    .nearlyEveryDay,
                    .notAtAll,
                    .severalDays,
                    .severalDays,
                    .notAtAll,
                    .moreThanHalfTheDays
                ]
            )
            try await healthKit.healthStore.save(assessment)
        case .PHQ9:
            let assessment = HKPHQ9Assessment(
                date: cal.date(from: .init(year: 2025, month: 4, day: 27))!, // swiftlint:disable:this force_unwrapping
                answers: [
                    .moreThanHalfTheDays,
                    .nearlyEveryDay,
                    .notAtAll,
                    .severalDays,
                    .severalDays,
                    .notAtAll,
                    .moreThanHalfTheDays,
                    .nearlyEveryDay,
                    .severalDays
                ]
            )
            try await healthKit.healthStore.save(assessment)
        default:
            return
        }
    }
}
