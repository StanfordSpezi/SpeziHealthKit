//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import FHIRModelsExtensions
import HealthKit
import ModelsR4


@available(iOS 18.0, watchOS 11.0, macCatalyst 18.0, macOS 15.0, visionOS 2.0, *)
extension HKStateOfMind: FHIRObservationBuildable {
    func build(_ observation: Observation, mapping: HKSampleMapping) throws {
        let mapping = mapping.stateOfMindMapping
        for code in mapping.codings {
            observation.appendCoding(code.coding)
        }
        for category in mapping.categories {
            observation.appendCategory(CodeableConcept(coding: [category.coding]))
        }
        observation.appendComponent(.init(
            code: CodeableConcept(coding: mapping.kind.codings.map(\.coding)),
            value: .string(self.kind.stringValue.asFHIRStringPrimitive())
        ))
        observation.appendComponent(.init(
            code: CodeableConcept(coding: mapping.valence.codings.map(\.coding)),
            value: .quantity(.init(value: try self.valence.asFHIRDecimalPrimitiveSafe()))
        ))
        observation.appendComponent(.init(
            code: CodeableConcept(coding: mapping.valenceClassification.codings.map(\.coding)),
            value: .string(self.valenceClassification.stringValue.asFHIRStringPrimitive())
        ))
        for label in self.labels {
            observation.appendComponent(.init(
                code: CodeableConcept(coding: mapping.label.codings.map(\.coding)),
                value: .string(label.stringValue.asFHIRStringPrimitive())
            ))
        }
        for association in self.associations {
            observation.appendComponent(.init(
                code: CodeableConcept(coding: mapping.association.codings.map(\.coding)),
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
