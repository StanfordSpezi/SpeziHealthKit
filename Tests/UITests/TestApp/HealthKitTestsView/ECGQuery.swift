//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziHealthKit
import SpeziHealthKitUI
import SwiftUI


struct ECGQuery: View {
    @Environment(HealthKit.self) private var healthKit
    
    @HealthKitQuery(.electrocardiogram, timeRange: .ever) private var ecgs
    
    var body: some View {
        Form {
            ForEach(ecgs) { ecg in
                ECGSection(ecg: ecg)
            }
        }
        .navigationTitle("ECGs")
    }
}


extension ECGQuery {
    private struct ECGSection: View {
        @Environment(HealthKit.self) private var healthKit
        let ecg: HKElectrocardiogram
        @State private var numVoltages = 0
        @State private var symptoms: HKElectrocardiogram.Symptoms?
        
        var body: some View {
            Section {
                LabeledContent("Date", value: ecg.startDate, format: .iso8601)
                LabeledContent("Duration", value: ecg.timeRange, format: Date.ComponentsFormatStyle(style: .abbreviated))
                LabeledContent("#Voltages", value: numVoltages, format: .number)
                HStack {
                    Text("Symptoms")
                    Spacer()
                    if let symptoms {
                        VStack(alignment: .trailing) {
                            ForEach(Array(symptoms), id: \.key) { symptom, severity in
                                Text(verbatim: "\(symptom.sampleType?.displayTitle ?? symptom.identifier): \(severity.displayTitle)")
                            }
                        }
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                    } else {
                        Text("n/a")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .task {
                numVoltages = (try? await ecg.voltageMeasurements(from: healthKit.healthStore))?.count ?? 0
                symptoms = try? await ecg.symptoms(from: healthKit)
            }
        }
    }
}


extension HKCategoryValueSeverity {
    var displayTitle: String {
        switch self {
        case .unspecified:
            "unspecified"
        case .notPresent:
            "not present"
        case .mild:
            "mild"
        case .moderate:
            "moderate"
        case .severe:
            "severe"
        @unknown default:
            "\(rawValue)"
        }
    }
}
