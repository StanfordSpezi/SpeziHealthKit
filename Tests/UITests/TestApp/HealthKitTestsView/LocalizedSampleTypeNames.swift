//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import SpeziHealthKit
import SwiftUI


struct LocalizedSampleTypeNames: View {
    var body: some View {
        Form {
            Section {
                ForEach([SampleType.food, .bloodPressure]) { sampleType in
                    Text(sampleType.displayTitle)
                }
            }
            let allSampleTypes = HKObjectType.allKnownObjectTypes
                .compactMap { $0.sampleType }
                .map(SampleTypeProxy.init)
                .sorted { $0.underlyingSampleType.displayTitle < $1.underlyingSampleType.displayTitle }
            List(allSampleTypes, id: \.self) { sampleType in
                Text(sampleType.underlyingSampleType.displayTitle)
            }
        }
    }
}
