//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


extension HealthKitSampleType where Sample == HKQuantitySample {
    /// The sample type representing step count quantity samples
    public static var stepCount: Self { .quantity(.stepCount, displayTitle: "Step Count", displayUnit: .count()) }
    
    /// The sample type representing blood oxygen saturation quantity samples
    public static var bloodOxygen: Self { .quantity(.oxygenSaturation, displayTitle: "Blood Oxygen", displayUnit: .percent()) }
    
    /// The sample type representing heart rate quantity samples
    public static var heartRate: Self { .quantity(
        .heartRate,
        displayTitle: "Heart Rate",
        displayUnit: .count() / .minute()
//        expectedValuesRange: 60...150
    ) }
    
    /// The sample type representing resting heart rate quantity samples
    public static var restingHeartRate: Self { .quantity(
        .restingHeartRate,
        displayTitle: "Resting Heart Rate",
        displayUnit: .count() / .minute()
    ) }
    
    /// The sample type representing heart rate variability
    public static var heartRateVariability: Self { .quantity(
        .heartRateVariabilitySDNN,
        displayTitle: "Heart Rate Variability",
        displayUnit: .secondUnit(with: .milli)
    ) }
    
    /// The wheelchair push count sample type
    public static var pushCount: Self { .quantity(
        .pushCount,
        displayTitle: "Wheelchair Push Count",
        displayUnit: .count()
    ) }
    
    public static var activeEnergyBurned: Self { .quantity(
        .activeEnergyBurned,
        displayTitle: "Active Energy Burned",
        displayUnit: .largeCalorie()
    ) }
    
    public static var height: Self { .quantity(
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
    ) }
}
