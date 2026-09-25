//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import SpeziHealthKitUI
import SpeziViews
import SwiftUI


@available(iOS 26.0, *)
struct MedicationsView: View {
    @Environment(HealthKit.self) private var healthKit
    
    @HealthKitQuery(.medicationDoseEvent, timeRange: .today) private var doseEvents
    
    @State private var medications: [HKUserAnnotatedMedication] = []
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        Form {
            Section {
                AsyncButton("Request Medications Access", state: $viewState) {
                    try await healthKit.askForMedicationsAuthorization()
                    await fetchMedications()
                }
            }
            Section("Medications") {
                if medications.isEmpty {
                    Text("No Medications")
                }
                ForEach(medications, id: \.medication.identifier) { medication in
                    Text(medication.nickname ?? medication.medication.displayText)
                }
            }
            Section("Today's Dose Events") {
                if doseEvents.isEmpty {
                    Text("No Dose Events")
                }
                ForEach(doseEvents) { doseEvent in
                    VStack(alignment: .leading) {
                        LabeledContent("Date", value: doseEvent.startDate, format: .dateTime)
                        LabeledContent("Status", value: doseEvent.logStatus.displayTitle)
                        if let doseQuantity = doseEvent.doseQuantity {
                            LabeledContent("Dose", value: doseQuantity, format: .number)
                        }
                    }
                }
            }
        }
        .navigationTitle("Medications")
        .viewStateAlert(state: $viewState)
        .task {
            await fetchMedications()
        }
    }
    
    private func fetchMedications() async {
        medications = (try? await HKUserAnnotatedMedicationQueryDescriptor().result(for: healthKit.healthStore)) ?? []
    }
}


@available(iOS 26.0, *)
extension HKMedicationDoseEvent.LogStatus {
    var displayTitle: String {
        switch self {
        case .notInteracted:
            "not interacted"
        case .notificationNotSent:
            "notification not sent"
        case .snoozed:
            "snoozed"
        case .taken:
            "taken"
        case .skipped:
            "skipped"
        case .notLogged:
            "not logged"
        @unknown default:
            "\(rawValue)"
        }
    }
}
