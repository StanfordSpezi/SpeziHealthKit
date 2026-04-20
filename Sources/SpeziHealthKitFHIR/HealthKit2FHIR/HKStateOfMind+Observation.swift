//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

import FHIRModelsExtensions
import HealthKit
import ModelsR4


@available(iOS 18.0, watchOS 11.0, macCatalyst 18.0, macOS 15.0, visionOS 2.0, *)
extension HKStateOfMind: FHIRObservationBuildable {
    func build(_ observation: inout Observation, mapping: SampleTypesFHIRMapping) throws {
        let mapping = mapping.stateOfMindTypeMapping
        observation.append(codings: mapping.codings)
        for category in mapping.categories {
            observation.append(category: CodeableConcept(coding: [category]))
        }
        observation.append(component: .init(
            code: CodeableConcept(coding: mapping.kind.codings),
            value: .string(self.kind.stringValue.asFHIRStringPrimitive())
        ))
        observation.append(component: .init(
            code: CodeableConcept(coding: mapping.valence.codings),
            value: .quantity(.init(value: try self.valence.asFHIRDecimalPrimitiveSafe()))
        ))
        observation.append(component: .init(
            code: CodeableConcept(coding: mapping.valenceClassification.codings),
            value: .string(self.valenceClassification.stringValue.asFHIRStringPrimitive())
        ))
        for label in self.labels {
            observation.append(component: .init(
                code: CodeableConcept(coding: mapping.label.codings),
                value: .string(label.stringValue.asFHIRStringPrimitive())
            ))
        }
        for association in self.associations {
            observation.append(component: .init(
                code: CodeableConcept(coding: mapping.association.codings),
                value: .string(association.stringValue.asFHIRStringPrimitive())
            ))
        }
    }
}


@available(iOS 18.0, watchOS 11.0, macCatalyst 18.0, macOS 15.0, visionOS 2.0, *)
extension HKStateOfMind.Kind {
    var stringValue: String {
        switch self {
        case .momentaryEmotion:
            "momentary emotion"
        case .dailyMood:
            "daily mood"
        @unknown default:
            "unknown"
        }
    }
}


@available(iOS 18.0, watchOS 11.0, macCatalyst 18.0, macOS 15.0, visionOS 2.0, *)
extension HKStateOfMind.ValenceClassification {
    var stringValue: String {
        switch self {
        case .veryUnpleasant:
            "very unpleasant"
        case .unpleasant:
            "unpleasant"
        case .slightlyUnpleasant:
            "slightly unpleasant"
        case .neutral:
            "neutral"
        case .slightlyPleasant:
            "slightly pleasant"
        case .pleasant:
            "pleasant"
        case .veryPleasant:
            "very pleasant"
        @unknown default:
            "unknown"
        }
    }
}


@available(iOS 18.0, watchOS 11.0, macCatalyst 18.0, macOS 15.0, visionOS 2.0, *)
extension HKStateOfMind.Label {
    var stringValue: String {
        switch self {
        case .amazed:
            "amazed"
        case .amused:
            "amused"
        case .angry:
            "angry"
        case .anxious:
            "anxious"
        case .ashamed:
            "ashamed"
        case .brave:
            "brave"
        case .calm:
            "calm"
        case .content:
            "content"
        case .disappointed:
            "disappointed"
        case .discouraged:
            "discouraged"
        case .disgusted:
            "disgusted"
        case .embarrassed:
            "embarrassed"
        case .excited:
            "excited"
        case .frustrated:
            "frustrated"
        case .grateful:
            "grateful"
        case .guilty:
            "guilty"
        case .happy:
            "happy"
        case .hopeless:
            "hopeless"
        case .irritated:
            "irritated"
        case .jealous:
            "jealous"
        case .joyful:
            "joyful"
        case .lonely:
            "lonely"
        case .passionate:
            "passionate"
        case .peaceful:
            "peaceful"
        case .proud:
            "proud"
        case .relieved:
            "relieved"
        case .sad:
            "sad"
        case .scared:
            "scared"
        case .stressed:
            "stressed"
        case .surprised:
            "surprised"
        case .worried:
            "worried"
        case .annoyed:
            "annoyed"
        case .confident:
            "confident"
        case .drained:
            "drained"
        case .hopeful:
            "hopeful"
        case .indifferent:
            "indifferent"
        case .overwhelmed:
            "overwhelmed"
        case .satisfied:
            "satisfied"
        @unknown default:
            "unknown"
        }
    }
}


@available(iOS 18.0, watchOS 11.0, macCatalyst 18.0, macOS 15.0, visionOS 2.0, *)
extension HKStateOfMind.Association {
    var stringValue: String {
        switch self {
        case .community:
            "community"
        case .currentEvents:
            "currentEvents"
        case .dating:
            "dating"
        case .education:
            "education"
        case .family:
            "family"
        case .fitness:
            "fitness"
        case .friends:
            "friends"
        case .health:
            "health"
        case .hobbies:
            "hobbies"
        case .identity:
            "identity"
        case .money:
            "money"
        case .partner:
            "partner"
        case .selfCare:
            "selfCare"
        case .spirituality:
            "spirituality"
        case .tasks:
            "tasks"
        case .travel:
            "travel"
        case .work:
            "work"
        case .weather:
            "weather"
        @unknown default:
            "unknown"
        }
    }
}

#endif
