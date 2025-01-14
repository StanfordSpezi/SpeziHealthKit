//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


extension HealthKitSampleType where Sample == HKCategorySample {
    /// The sample type representing sleep analysis category samples
    public static var sleepAnalysis: Self { .category(.sleepAnalysis, displayTitle: "Sleep Analysis") }
}
