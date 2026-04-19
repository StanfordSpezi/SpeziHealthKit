//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import ModelsR4
import SpeziHealthKitFHIRMacros


/// Models a value type used by a `HKCategoryType`.
protocol FHIRCodingConvertible {
    static var system: FHIRPrimitive<FHIRURI> { get }
    
    var code: String { get }
    var display: String? { get }
    
    init?(rawValue: Int)
}

extension FHIRCodingConvertible {
    var asCoding: Coding {
        Coding(
            code: code.asFHIRStringPrimitive(),
            display: display?.asFHIRStringPrimitive(),
            system: Self.system
        )
    }
}


extension FHIRCodingConvertible where Self: RawRepresentable, RawValue == Int {
    var code: String {
        String(rawValue)
    }
}


protocol FHIRCodingConvertibleHKEnum: FHIRCodingConvertible {}

extension FHIRCodingConvertibleHKEnum {
    static var system: FHIRPrimitive<FHIRURI> {
        let typename = String(describing: Self.self).lowercased()
        return "https://developer.apple.com/documentation/healthkit/\(typename)".asFHIRURIPrimitive()! // swiftlint:disable:this force_unwrapping
    }
}


// MARK: Extensions

@available(iOS 18.0, macOS 15.0, watchOS 11.0, visionOS 2.0, *)
@SynthesizeDisplayProperty(
    HKCategoryValueVaginalBleeding.self,
    .unspecified, .light, .medium, .heavy, .none
)
extension HKCategoryValueVaginalBleeding: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCategoryValueCervicalMucusQuality.self,
    .dry, .sticky, .creamy, .watery, .eggWhite
)
extension HKCategoryValueCervicalMucusQuality: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCategoryValueMenstrualFlow.self,
    .unspecified, .light, .medium, .heavy, .none
)
extension HKCategoryValueMenstrualFlow: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCategoryValueOvulationTestResult.self,
    .negative, .luteinizingHormoneSurge, .indeterminate, .estrogenSurge
)
extension HKCategoryValueOvulationTestResult: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCategoryValueContraceptive.self,
    .unspecified, .implant, .injection, .intrauterineDevice, .intravaginalRing, .oral, .patch
)
extension HKCategoryValueContraceptive: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCategoryValueSleepAnalysis.self,
    .inBed, .asleepUnspecified, .awake, .asleepCore, .asleepDeep, .asleepREM
)
extension HKCategoryValueSleepAnalysis: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCategoryValueAppetiteChanges.self,
    .unspecified, .noChange, .decreased, .increased
)
extension HKCategoryValueAppetiteChanges: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCategoryValueEnvironmentalAudioExposureEvent.self,
    .momentaryLimit
)
extension HKCategoryValueEnvironmentalAudioExposureEvent: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCategoryValueHeadphoneAudioExposureEvent.self,
    .sevenDayLimit
)
extension HKCategoryValueHeadphoneAudioExposureEvent: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCategoryValueLowCardioFitnessEvent.self,
    .lowFitness
)
extension HKCategoryValueLowCardioFitnessEvent: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKAppleWalkingSteadinessClassification.self,
    .ok, .low, .veryLow
)
extension HKAppleWalkingSteadinessClassification: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCategoryValueAppleWalkingSteadinessEvent.self,
    .initialLow, .initialVeryLow, .repeatLow, .repeatVeryLow
)
extension HKCategoryValueAppleWalkingSteadinessEvent: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCategoryValuePregnancyTestResult.self,
    .negative, .positive, .indeterminate
)
extension HKCategoryValuePregnancyTestResult: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCategoryValueProgesteroneTestResult.self,
    .negative, .positive, .indeterminate
)
extension HKCategoryValueProgesteroneTestResult: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCategoryValueAppleStandHour.self,
    .stood, .idle
)
extension HKCategoryValueAppleStandHour: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCategoryValueSeverity.self,
    .unspecified, .notPresent, .mild, .moderate, .severe
)
extension HKCategoryValueSeverity: FHIRCodingConvertibleHKEnum {}

@SynthesizeDisplayProperty(
    HKCategoryValuePresence.self,
    .present, .notPresent
)
extension HKCategoryValuePresence: FHIRCodingConvertibleHKEnum {}
