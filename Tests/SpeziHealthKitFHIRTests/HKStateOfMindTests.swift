//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
@testable import SpeziHealthKitFHIR
import ModelsR4
import Testing


@Suite
struct HKStateOfMindTests {
    @Test
    @available(iOS 18.0, watchOS 11.0, macCatalyst 18.0, macOS 15.0, visionOS 2.0, *)
    func stateOfMind1() throws {
        let cal = Calendar.current
        let yesterday = try #require(cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: .now)))
        let sample = HKStateOfMind(
            date: yesterday,
            kind: .dailyMood,
            valence: 0.27,
            labels: [.indifferent],
            associations: [.work]
        )
        let observation = try #require(sample.resource().get(if: Observation.self))
        #expect(observation.effective == .dateTime(try FHIRPrimitive<DateTime>(.init(date: yesterday))))
        #expect(observation.category?.first?.coding?.first?.code == "survey")
        #expect(observation.status == .final)
        let components = try #require(observation.component)
        #expect(components.count == 5)
        components.expectContainsComponent(withCode: "HKStateOfMindKind", value: .string("daily mood"))
        components.expectContainsComponent(withCode: "HKStateOfMindValence", value: .quantity(.init(value: 0.27)))
        components.expectContainsComponent(withCode: "HKStateOfMindValenceClassification", value: .string("slightly pleasant"))
        components.expectContainsComponent(withCode: "HKStateOfMindLabel", value: .string("indifferent"))
        components.expectContainsComponent(withCode: "HKStateOfMindAssociation", value: .string("work"))
    }
    
    
    @Test
    @available(iOS 18.0, watchOS 11.0, macCatalyst 18.0, macOS 15.0, visionOS 2.0, *)
    func stateOfMind2() throws {
        let cal = Calendar.current
        let yesterday = try #require(cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: .now)))
        let sample = HKStateOfMind(
            date: yesterday,
            kind: .momentaryEmotion,
            valence: -0.52,
            labels: [.brave, .confident, .lonely],
            associations: [.dating, .community, .friends]
        )
        let observation = try #require(sample.resource().get(if: Observation.self))
        #expect(observation.effective == .dateTime(try FHIRPrimitive<DateTime>(.init(date: yesterday))))
        #expect(observation.category?.first?.coding?.first?.code == "survey")
        #expect(observation.status == .final)
        let components = try #require(observation.component)
        #expect(components.count == 9)
        components.expectContainsComponent(withCode: "HKStateOfMindKind", value: .string("momentary emotion"))
        components.expectContainsComponent(withCode: "HKStateOfMindValence", value: .quantity(.init(value: -0.52)))
        components.expectContainsComponent(withCode: "HKStateOfMindValenceClassification", value: .string("unpleasant"))
        components.expectContainsComponent(withCode: "HKStateOfMindLabel", value: .string("brave"))
        components.expectContainsComponent(withCode: "HKStateOfMindLabel", value: .string("confident"))
        components.expectContainsComponent(withCode: "HKStateOfMindLabel", value: .string("lonely"))
        components.expectContainsComponent(withCode: "HKStateOfMindAssociation", value: .string("dating"))
        components.expectContainsComponent(withCode: "HKStateOfMindAssociation", value: .string("community"))
        components.expectContainsComponent(withCode: "HKStateOfMindAssociation", value: .string("friends"))
    }
}


extension Array where Element == ObservationComponent {
    func expectContainsComponent(withCode code: String, value: ObservationComponent.ValueX?) {
        let candidates = self.filter { $0.code.coding?.contains { $0.code?.value?.string == code } == true }
        guard !candidates.isEmpty else {
            Issue.record("Unable to find a component for code '\(code)'.")
            return
        }
        if candidates.count == 1 {
            #expect(candidates[0].value == value, "Mismatching component values for code '\(code)'")
        } else {
            #expect(candidates.contains { $0.value == value }, "No component with matching value.")
        }
    }
}
