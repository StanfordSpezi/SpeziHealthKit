//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// ## Quantity Sample Types
extension SampleType {
    /// The sample type representing step count quantity samples
    @inlinable public static var stepCount: SampleType<HKQuantitySample> {
        .quantity(.stepCount, displayTitle: "Step Count", displayUnit: .count())
    }
    
    /// The sample type representing blood oxygen saturation quantity samples
    @inlinable public static var bloodOxygen: SampleType<HKQuantitySample> {
        .quantity(.oxygenSaturation, displayTitle: "Blood Oxygen", displayUnit: .percent())
    }
    
    /// The sample type representing heart rate quantity samples
    @inlinable public static var heartRate: SampleType<HKQuantitySample> {
        .quantity(.heartRate, displayTitle: "Heart Rate", displayUnit: .count() / .minute(), expectedValuesRange: 60...150)
    }
    
    /// The sample type representing resting heart rate quantity samples
    @inlinable public static var restingHeartRate: SampleType<HKQuantitySample> {
        .quantity(.restingHeartRate, displayTitle: "Resting Heart Rate", displayUnit: .count() / .minute())
    }
    
    /// The sample type representing heart rate variability
    @inlinable public static var heartRateVariability: SampleType<HKQuantitySample> {
        .quantity(.heartRateVariabilitySDNN, displayTitle: "Heart Rate Variability", displayUnit: .secondUnit(with: .milli))
    }
    
    /// The wheelchair push count sample type
    @inlinable public static var pushCount: SampleType<HKQuantitySample> {
        .quantity(.pushCount, displayTitle: "Wheelchair Push Count", displayUnit: .count())
    }
    
    /// The active energy burned sample type
    @inlinable public static var activeEnergyBurned: SampleType<HKQuantitySample> {
        .quantity(.activeEnergyBurned, displayTitle: "Active Energy Burned", displayUnit: .largeCalorie())
    }
    
    /// The height sample type
    @inlinable public static var height: SampleType<HKQuantitySample> {
        .quantity(
            .height,
            displayTitle: "Height",
            displayUnit: { () -> HKUnit in
                switch Locale.current.measurementSystem {
                case .us:
                    HKUnit.foot()
                default:
                    HKUnit.meterUnit(with: .centi)
                }
            }()
        )
    }
}
