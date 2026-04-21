//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

import HealthKit
import SpeziHealthKitFHIRMacros


@SynthesizeDisplayProperty(
    HKAppleECGAlgorithmVersion.self,
    .version1, .version2
)
extension HKAppleECGAlgorithmVersion: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKBloodGlucoseMealTime.self,
    .preprandial, .postprandial
)
extension HKBloodGlucoseMealTime: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKBodyTemperatureSensorLocation.self,
    .other, .armpit, .body, .ear, .finger, .gastroIntestinal,
    .mouth, .rectum, .toe, .earDrum, .temporalArtery, .forehead
)
extension HKBodyTemperatureSensorLocation: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCyclingFunctionalThresholdPowerTestType.self,
    .maxExercise60Minute, .maxExercise20Minute, .rampTest, .predictionExercise)
extension HKCyclingFunctionalThresholdPowerTestType: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKDevicePlacementSide.self,
    .unknown, .left, .right, .central
)
extension HKDevicePlacementSide: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKHeartRateMotionContext.self,
    .notSet, .sedentary, .active
)
extension HKHeartRateMotionContext: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKHeartRateRecoveryTestType.self,
    .maxExercise, .predictionSubMaxExercise, .predictionNonExercise
)
extension HKHeartRateRecoveryTestType: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKHeartRateSensorLocation.self,
    .other, .chest, .wrist, .finger, .hand, .earLobe, .foot
)
extension HKHeartRateSensorLocation: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKInsulinDeliveryReason.self,
    .basal, .bolus
)
extension HKInsulinDeliveryReason: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKPhysicalEffortEstimationType.self,
    .activityLookup, .deviceSensed
)
extension HKPhysicalEffortEstimationType: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKSwimmingStrokeStyle.self,
    .unknown, .mixed, .freestyle, .backstroke, .breaststroke, .butterfly, .kickboard
)
extension HKSwimmingStrokeStyle: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKUserMotionContext.self,
    .notSet, .stationary, .active
)
extension HKUserMotionContext: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKVO2MaxTestType.self,
    .maxExercise, .predictionSubMaxExercise, .predictionNonExercise,
    additionalCases: "predictionStepTest"
)
extension HKVO2MaxTestType: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKWaterSalinity.self,
    .freshWater, .saltWater
)
extension HKWaterSalinity: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKWeatherCondition.self,
    .none, .clear, .fair, .partlyCloudy, .mostlyCloudy, .cloudy, .foggy, .haze,
    .windy, .blustery, .smoky, .dust, .snow, .hail, .sleet, .freezingDrizzle,
    .freezingRain, .mixedRainAndHail, .mixedRainAndSnow, .mixedRainAndSleet, .mixedSnowAndSleet,
    .drizzle, .scatteredShowers, .showers, .thunderstorms, .tropicalStorm, .hurricane, .tornado
)
extension HKWeatherCondition: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKWorkoutSwimmingLocationType.self,
    .unknown, .pool, .openWater
)
extension HKWorkoutSwimmingLocationType: FHIRCodingConvertibleHKEnum {}

#endif
