//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


extension HealthKitSampleType where Sample == HKCorrelation {
    /// The sample type representing blood pressure correlation samples
    public static var bloodPressure: Self { .correlation(.bloodPressure, displayTitle: "Blood Pressure", displayUnit: .millimeterOfMercury()) }
}
