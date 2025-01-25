//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit

// Idea: add list of known contained `SampleType`s to SampleType<HKCorrelation>?
extension SampleType {
    /// The sample type representing blood pressure correlation samples
    @inlinable public static var bloodPressure: SampleType<HKCorrelation> {
        .correlation(.bloodPressure, displayTitle: "Blood Pressure", displayUnit: .millimeterOfMercury())
    }
    
    /// Food correlation types combine any number of nutritional samples into a single food object.
    @inlinable public static var food: SampleType<HKCorrelation> {
        .correlation(.food, displayTitle: "Food", displayUnit: nil)
    }
}
