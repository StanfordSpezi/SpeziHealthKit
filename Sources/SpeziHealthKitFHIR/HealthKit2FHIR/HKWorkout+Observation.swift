//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import ModelsR4


extension HKWorkout: FHIRObservationBuildable {
    /// Generates an observation that captures the type of physical activity performed for a single instance of physical activity, based on https://build.fhir.org/ig/HL7/physical-activity/StructureDefinition-pa-observation-activity-measure.html
    /// Note:  An `HKWorkout` object can also act as a container for other `HKSample` objects, which will need to be converted to observations individually.
    func build(_ observation: inout Observation, mapping: SampleTypesFHIRMapping) throws {
        let mapping = mapping.workoutTypeMapping
        observation.append(codings: mapping.codings)
        for category in mapping.categories {
            observation.append(category: CodeableConcept(coding: [category]))
        }
        let valueCodeableConcept = CodeableConcept(
            coding: [
                Coding(
                    code: try self.workoutActivityType.fhirWorkoutTypeValue.asFHIRStringPrimitive(),
                    system: "http://developer.apple.com/documentation/healthkit".asFHIRURIPrimitive()
                )
            ]
        )
        observation.value = .codeableConcept(valueCodeableConcept)
    }
}


extension HKWorkoutActivityType {
    var fhirWorkoutTypeValue: String {
        get throws {
            switch self {
            case .americanFootball:
                return "americanFootball"
            case .archery:
                return "archery"
            case .australianFootball:
                return "australianFootball"
            case .badminton:
                return "badminton"
            case .barre:
                return "barre"
            case .baseball:
                return "baseball"
            case .basketball:
                return "basketball"
            case .bowling:
                return "bowling"
            case .boxing:
                return "boxing"
            case .cardioDance:
                return "cardioDance"
            case .climbing:
                return "climbing"
            case .cooldown:
                return "coolDown"
            case .coreTraining:
                return "coreTraining"
            case .cricket:
                return "cricket"
            case .crossCountrySkiing:
                return "crossCountrySkiing"
            case .crossTraining:
                return "crossTraining"
            case .curling:
                return "curling"
            case .cycling:
                return "cycling"
            case .dance:
                return "dance"
            case .danceInspiredTraining:
                return "danceInspiredTraining"
            case .discSports:
                return "discSports"
            case .downhillSkiing:
                return "downhillSkiing"
            case .elliptical:
                return "elliptical"
            case .equestrianSports:
                return "equestrianSports"
            case .fencing:
                return "fencing"
            case .fishing:
                return "fishing"
            case .fitnessGaming:
                return "fitnessGaming"
            case .flexibility:
                return "flexibility"
            case .functionalStrengthTraining:
                return "functionalStrengthTraining"
            case .golf:
                return "golf"
            case .gymnastics:
                return "gymnastics"
            case .handCycling:
                return "handCycling"
            case .handball:
                return "handball"
            case .highIntensityIntervalTraining:
                return "highIntensityIntervalTraining"
            case .hiking:
                return "hiking"
            case .hockey:
                return "hockey"
            case .hunting:
                return "hunting"
            case .jumpRope:
                return "jumpRope"
            case .kickboxing:
                return "kickboxing"
            case .lacrosse:
                return "lacrosse"
            case .martialArts:
                return "martialArts"
            case .mindAndBody:
                return "mindAndBody"
            case .mixedCardio:
                return "mixedCardio"
            case .mixedMetabolicCardioTraining:
                return "mixedMetabolicCardioTraining"
            case .other:
                return "other"
            case .paddleSports:
                return "paddleSports"
            case .pickleball:
                return "pickleball"
            case .pilates:
                return "pilates"
            case .play:
                return "play"
            case .preparationAndRecovery:
                return "preparationAndRecovery"
            case .racquetball:
                return "racquetball"
            case .rowing:
                return "rowing"
            case .rugby:
                return "rugby"
            case .running:
                return "running"
            case .sailing:
                return "sailing"
            case .skatingSports:
                return "skatingSports"
            case .snowboarding:
                return "snowboarding"
            case .snowSports:
                return "snowSports"
            case .soccer:
                return "soccer"
            case .socialDance:
                return "socialDance"
            case .softball:
                return "softball"
            case .squash:
                return "squash"
            case .stairClimbing:
                return "stairClimbing"
            case .stairs:
                return "stairs"
            case .stepTraining:
                return "stepTraining"
            case .surfingSports:
                return "surfingSports"
            case .swimBikeRun:
                return "swimBikeRun"
            case .swimming:
                return "swimming"
            case .tableTennis:
                return "tableTennis"
            case .taiChi:
                return "taiChi"
            case .tennis:
                return "tennis"
            case .trackAndField:
                return "trackAndField"
            case .traditionalStrengthTraining:
                return "traditionalStrengthTraining"
            case .transition:
                return "transition"
            case .underwaterDiving:
                return "underwaterDiving"
            case .volleyball:
                return "volleyball"
            case .walking:
                return "walking"
            case .waterFitness:
                return "waterFitness"
            case .waterPolo:
                return "waterPolo"
            case .waterSports:
                return "waterSports"
            case .wheelchairRunPace:
                return "wheelchairRunPace"
            case .wheelchairWalkPace:
                return "wheelchairWalkPace"
            case .wrestling:
                return "wrestling"
            case .yoga:
                return "yoga"
            @unknown default:
                throw SpeziHealthKitFHIRError.invalidValue
            }
        }
    }
}
