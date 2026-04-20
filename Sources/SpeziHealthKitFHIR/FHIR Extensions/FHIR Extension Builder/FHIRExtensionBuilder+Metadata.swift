//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_length

#if canImport(HealthKit)

public import FHIRModelsExtensions
import Foundation
public import HealthKit
import ModelsR4
import SpeziHealthKit


extension FHIRExtensionURL {
    /// Url of a FHIR Extension containing, if applicable, encoded metadata of the `HKObject` from which a FHIR `Observation` was created.
    public static let metadata = Self("https://bdh.stanford.edu/fhir/defs/metadata")
}


extension FHIRExtensionBuilderProtocol where Self == FHIRExtensionBuilder<HKObject> {
    /// A FHIR Extension Builder that writes encoded metadata of a HealthKit sample into a FHIR `Observation` created from the sample.
    public static var metadata: FHIRExtensionBuilder<HKObject> {
        .init { (object: HKObject, observation) in // swiftlint:disable:this closure_body_length
            guard let metadata = object.metadata, !metadata.isEmpty else {
                observation.removeAllExtensions(withUrl: .metadata)
                return
            }
            var metadataExtension = Extension(url: .metadata)
            for (key, value) in metadata {
                // The HKObject docs state that "Keys must be NSString and values must be either NSString, NSNumber, NSDate, or HKQuantity".
                // Additionally, there are some HKMetadataKey constants which say that they store a BOOL, so we support that as well.
                let extensionValue: Extension.ValueX
                switch value {
                case let value as String:
                    extensionValue = .string(value.asFHIRStringPrimitive())
                case let value as NSNumber:
                    if let type = Self.type(forMetadataKey: key), let value = type.init(rawValue: value.intValue) {
                        extensionValue = .coding(value.asCoding)
                    } else {
                        @_transparent
                        func typeEncoding(_ type: (some Any).Type) -> String {
                            String(cString: _getObjCTypeEncoding(type))
                        }
                        switch String(cString: value.objCType) {
                        case "c", typeEncoding(Bool.self), typeEncoding(ObjCBool.self):
                            extensionValue = .boolean(value.boolValue.asPrimitive())
                        default:
                            extensionValue = .decimal(FHIRPrimitive(FHIRDecimal(value.decimalValue)))
                        }
                    }
                case let value as Date:
                    extensionValue = .dateTime(FHIRPrimitive(try DateTime(date: value)))
                case let value as Bool:
                    extensionValue = .boolean(value.asPrimitive())
                case let value as HKQuantity:
                    switch key {
                    case HKMetadataKeyWeatherTemperature:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .weatherTemperature))
                    case HKMetadataKeyWeatherHumidity:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .weatherHumidity))
                    case HKMetadataKeySessionEstimate:
                        guard let sample = object as? HKQuantitySample,
                              let sampleType = SampleType(sample.quantityType),
                              let mapping = QuantityTypesFHIRMapping.default[sampleType] else {
                            continue // should be unreachable. skipping
                        }
                        extensionValue = .quantity(try value.buildQuantity(mapping: mapping))
                    case HKMetadataKeyHeartRateRecoveryActivityDuration:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .heartRateRecoveryActivityDuration))
                    case HKMetadataKeyHeartRateRecoveryMaxObservedRecoveryHeartRate:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .heartRateRecoveryMaxObservedRecoveryHeartRate))
                    case HKMetadataKeyAverageSpeed:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .averageSpeed))
                    case HKMetadataKeyMaximumSpeed:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .maximumSpeed))
                    case HKMetadataKeyAlpineSlopeGrade:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .alpineSlopeGrade))
                    case HKMetadataKeyElevationAscended:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .elevationAscended))
                    case HKMetadataKeyElevationDescended:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .elevationDescended))
                    case HKMetadataKeyFitnessMachineDuration:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .fitnessMachineDuration))
                    case HKMetadataKeyIndoorBikeDistance:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .indoorBikeDistance))
                    case HKMetadataKeyCrossTrainerDistance:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .crossTrainerDistance))
                    case HKMetadataKeyHeartRateEventThreshold:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .highHeartRateEventThreshold))
                    case HKMetadataKeyAverageMETs:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .averageMETs))
                    case HKMetadataKeyAudioExposureLevel:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .audioExposureLevel))
                    case HKMetadataKeyAudioExposureDuration:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .audioExposureDuration))
                    case HKMetadataKeyBarometricPressure:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .barometricPressure))
                    case HKMetadataKeyVO2MaxValue:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .vo2MaxValue))
                    case HKMetadataKeyLowCardioFitnessEventThreshold:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .lowCardioFitnessEventThreshold))
                    case HKMetadataKeyHeadphoneGain:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .headphoneGain))
                    case HKMetadataKeyMaximumLightIntensity:
                        extensionValue = .quantity(try value.buildQuantity(mapping: .maximumLightIntensity))
                    default:
                        print("Encountered unexpected HKQuantity metadata value for key '\(key)': \(value). Skipping.")
                        continue
                    }
                default:
                    print("Encountered unexpected HKSample metadata value of type \(Swift.type(of: value)), for key '\(key)': \(value). Skipping.")
                    continue
                }
                metadataExtension.append(
                    extension: Extension(url: .metadata.appending(component: key), value: extensionValue),
                    behaviour: .replace
                )
                observation.append(extension: metadataExtension, behaviour: .replace)
            }
        }
    }
    
    private static func type(forMetadataKey key: String) -> (any FHIRCodingConvertibleHKEnum.Type)? { // swiftlint:disable:this cyclomatic_complexity
        switch key {
        case HKMetadataKeyAppleECGAlgorithmVersion:
            HKAppleECGAlgorithmVersion.self
        case HKMetadataKeyBloodGlucoseMealTime:
            HKBloodGlucoseMealTime.self
        case HKMetadataKeyBodyTemperatureSensorLocation:
            HKBodyTemperatureSensorLocation.self
        case HKMetadataKeyCyclingFunctionalThresholdPowerTestType:
            HKCyclingFunctionalThresholdPowerTestType.self
        case HKMetadataKeyDevicePlacementSide:
            HKDevicePlacementSide.self
        case HKMetadataKeyHeartRateMotionContext:
            HKHeartRateMotionContext.self
        case HKMetadataKeyHeartRateRecoveryTestType:
            HKHeartRateRecoveryTestType.self
        case HKMetadataKeyHeartRateSensorLocation:
            HKHeartRateSensorLocation.self
        case HKMetadataKeyInsulinDeliveryReason:
            HKInsulinDeliveryReason.self
        case HKMetadataKeyPhysicalEffortEstimationType:
            HKPhysicalEffortEstimationType.self
        case HKMetadataKeySwimmingStrokeStyle:
            HKSwimmingStrokeStyle.self
        case HKMetadataKeyUserMotionContext:
            HKUserMotionContext.self
        case HKMetadataKeyVO2MaxTestType:
            HKVO2MaxTestType.self
        case HKMetadataKeyWaterSalinity:
            HKWaterSalinity.self
        case HKMetadataKeyWeatherCondition:
            HKWeatherCondition.self
        case HKMetadataKeySwimmingLocationType:
            HKWorkoutSwimmingLocationType.self
        default:
            nil
        }
    }
}


extension QuantityTypeFHIRMapping {
    fileprivate static let weatherTemperature = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyWeatherTemperature",
                display: "Weather Temperature",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .degreeCelsius(),
            unit: "C",
            system: .unitsOfMeasureSystem,
            code: "Cel"
        )
    )
    
    fileprivate static let weatherHumidity = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyWeatherHumidity",
                display: "Weather Humidity",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .percent(),
            unit: "%",
            system: .unitsOfMeasureSystem,
            code: "%"
        )
    )
    
    fileprivate static let heartRateRecoveryActivityDuration = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyHeartRateRecoveryActivityDuration",
                display: "Heart Rate Recovery Activity Duration",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .second(),
            unit: "s",
            system: .unitsOfMeasureSystem,
            code: "s"
        )
    )
    
    fileprivate static let heartRateRecoveryMaxObservedRecoveryHeartRate = Self( // swiftlint:disable:this identifier_name
        codings: [
            Coding(
                code: "HKMetadataKeyHeartRateRecoveryMaxObservedRecoveryHeartRate",
                display: "Heart Rate Recovery Max Observed Recovery Heart Rate",
                system: .healthKitSystem
            ),
            Coding(
                code: "8867-4",
                display: "Heart rate",
                system: .loincSystem
            ),
            Coding(
                code: "364075005",
                display: "Heart rate",
                system: .snomedCT
            )
        ],
        unit: Unit(
            hkUnit: .count().unitDivided(by: .minute()),
            unit: "beats/minute",
            system: .unitsOfMeasureSystem,
            code: "/min"
        )
    )
    
    fileprivate static let averageSpeed = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyAverageSpeed",
                display: "Average Speed",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .meter().unitDivided(by: .second()),
            unit: "m/sec",
            system: .unitsOfMeasureSystem,
            code: "m/s"
        )
    )
    
    fileprivate static let maximumSpeed = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyMaximumSpeed",
                display: "Maximum Speed",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .meter().unitDivided(by: .second()),
            unit: "m/sec",
            system: .unitsOfMeasureSystem,
            code: "m/s"
        )
    )
    
    fileprivate static let alpineSlopeGrade = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyAlpineSlopeGrade",
                display: "Alpine Slope Grade",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .percent(),
            unit: "%",
            system: .unitsOfMeasureSystem,
            code: "%"
        )
    )
    
    fileprivate static let elevationAscended = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyElevationAscended",
                display: "Elevation Ascended",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .meter(),
            unit: "m",
            system: .unitsOfMeasureSystem,
            code: "m"
        )
    )
    
    fileprivate static let elevationDescended = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyElevationDescended",
                display: "Elevation Descended",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .meter(),
            unit: "m",
            system: .unitsOfMeasureSystem,
            code: "m"
        )
    )
    
    fileprivate static let fitnessMachineDuration = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyFitnessMachineDuration",
                display: "Fitness Machine Duration",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .second(),
            unit: "s",
            system: .unitsOfMeasureSystem,
            code: "s"
        )
    )
    
    fileprivate static let indoorBikeDistance = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyIndoorBikeDistance",
                display: "Indoor Bike Distance",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .meter(),
            unit: "m",
            system: .unitsOfMeasureSystem,
            code: "m"
        )
    )
    
    fileprivate static let crossTrainerDistance = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyCrossTrainerDistance",
                display: "Cross Trainer Distance",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .meter(),
            unit: "m",
            system: .unitsOfMeasureSystem,
            code: "m"
        )
    )
    
    fileprivate static let highHeartRateEventThreshold = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyHeartRateEventThreshold",
                display: "Heart Rate Event Threshold",
                system: .healthKitSystem
            ),
            Coding(
                code: "8867-4",
                display: "Heart rate",
                system: .loincSystem
            ),
            Coding(
                code: "364075005",
                display: "Heart rate",
                system: .snomedCT
            )
        ],
        unit: Unit(
            hkUnit: .count().unitDivided(by: .minute()),
            unit: "beats/min",
            system: .unitsOfMeasureSystem,
            code: "/min"
        )
    )
    
    fileprivate static let averageMETs = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyAverageMETs",
                display: "Average METs",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .largeCalorie().unitDivided(by: .gramUnit(with: .kilo).unitMultiplied(by: .hour())),
            unit: "kcal/(kg*hr)",
            system: .unitsOfMeasureSystem,
            code: "kcal/(kg*hr)"
        )
    )
    
    fileprivate static let audioExposureLevel = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyAudioExposureLevel",
                display: "Audio Exposure Level",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .init(from: "dBASPL"),
            unit: "dB(SPL)",
            system: .unitsOfMeasureSystem,
            code: "dB(SPL)"
        )
    )
    
    fileprivate static let audioExposureDuration = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyAudioExposureDuration",
                display: "Audio Exposure Duration",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .second(),
            unit: "s",
            system: .unitsOfMeasureSystem,
            code: "s"
        )
    )
    
    fileprivate static let barometricPressure = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyBarometricPressure",
                display: "Barometric Pressure",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .millimeterOfMercury(),
            unit: "mmHg",
            system: .unitsOfMeasureSystem,
            code: "mm[Hg]"
        )
    )
    
    fileprivate static let vo2MaxValue = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyVO2MaxValue",
                display: "VO2Max Value",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .init(from: "mL/kg*min"),
            unit: "mL/kg/min",
            system: .unitsOfMeasureSystem,
            code: "mL/kg/min"
        )
    )
    
    fileprivate static let lowCardioFitnessEventThreshold = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyLowCardioFitnessEventThreshold",
                display: "Low Cardio Fitness Event Threshold",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .init(from: "mL/kg*min"),
            unit: "mL/kg/min",
            system: .unitsOfMeasureSystem,
            code: "mL/kg/min"
        )
    )
    
    fileprivate static let headphoneGain = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyHeadphoneGain",
                display: "Headphone Gain",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .decibelAWeightedSoundPressureLevel(),
            unit: "dB(SPL)",
            system: .unitsOfMeasureSystem,
            code: "dB(SPL)"
        )
    )
    
    fileprivate static let maximumLightIntensity = Self(
        codings: [
            Coding(
                code: "HKMetadataKeyMaximumLightIntensity",
                display: "Maximum Light Intensity",
                system: .healthKitSystem
            )
        ],
        unit: Unit(
            hkUnit: .lux(),
            unit: "lux",
            system: .unitsOfMeasureSystem,
            code: "lux"
        )
    )
}

#endif
