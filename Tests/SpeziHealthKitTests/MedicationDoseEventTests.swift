//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

import Foundation
import HealthKit
@_spi(APISupport)
@testable import SpeziHealthKit
import Testing


@Suite
struct MedicationDoseEventTests {
    @Test
    func samplePredicate() {
        guard #available(iOS 26.0, watchOS 26.0, macOS 26.0, visionOS 26.0, *) else {
            return
        }
        let filter = HKQuery.predicateForMedicationDoseEvent(status: .taken)
        let predicate = HKMedicationDoseEvent._makeSamplePredicateInternal(
            type: HKObjectType.medicationDoseEventType(),
            filter: filter
        )
        #expect(predicate.sampleType == HKObjectType.medicationDoseEventType())
        #expect(predicate.nsPredicate == filter)
        let unfiltered = HKMedicationDoseEvent._makeSamplePredicateInternal(
            type: HKObjectType.medicationDoseEventType(),
            filter: nil
        )
        #expect(unfiltered.nsPredicate == nil)
    }
    
    @Test
    func sampleTypePredicate() {
        guard #available(iOS 26.0, watchOS 26.0, macOS 26.0, visionOS 26.0, *) else {
            return
        }
        let filter = HKQuery.predicateForMedicationDoseEvent(status: .skipped)
        let predicate = SampleType.medicationDoseEvent._makeSamplePredicate(filter: filter)
        #expect(predicate.sampleType == HKObjectType.medicationDoseEventType())
        #expect(predicate.nsPredicate == filter)
    }
    
    @Test
    func sampleTypeDefinition() {
        guard #available(iOS 26.0, watchOS 26.0, macOS 26.0, visionOS 26.0, *) else {
            return
        }
        let sampleType = SampleType.medicationDoseEvent
        #expect(sampleType.hkSampleType == HKObjectType.medicationDoseEventType())
        #expect(sampleType.id == "HKMedicationDoseEventTypeIdentifierMedicationDoseEvent")
        #expect(HKObjectType.allKnownObjectTypes.contains(HKObjectType.medicationDoseEventType()))
        #expect(SampleType<HKQuantitySample>.otherSampleTypes.contains { $0 == sampleType })
    }
    
    @Test
    func objectTypeMapping() throws {
        guard #available(iOS 26.0, watchOS 26.0, macOS 26.0, visionOS 26.0, *) else {
            return
        }
        let sampleType = try #require(HKObjectType.medicationDoseEventType().sampleType)
        #expect(sampleType == SampleType.medicationDoseEvent)
        #expect(HKObjectType.userAnnotatedMedicationType().sampleType == nil)
    }
    
    @Test
    func sampleTypeProxy() {
        guard #available(iOS 26.0, watchOS 26.0, macOS 26.0, visionOS 26.0, *) else {
            return
        }
        let proxy = SampleTypeProxy(SampleType.medicationDoseEvent)
        guard case .medicationDoseEvent(let underlying) = proxy else {
            Issue.record("Unexpected proxy case: \(proxy)")
            return
        }
        #expect(underlying == SampleType.medicationDoseEvent)
    }
    
    @Test
    func doseEventsAreExcludedFromRegularAuthorizationRequests() {
        guard #available(iOS 26.0, watchOS 26.0, macOS 26.0, visionOS 26.0, *) else {
            return
        }
        #expect(SampleType.medicationDoseEvent.effectiveSampleTypesForAuthentication.map { $0.id } == [SampleType.medicationDoseEvent.id])
        #expect(HKObjectType.medicationDoseEventType().effectiveObjectTypes == [HKObjectType.medicationDoseEventType()])
        #expect(HKObjectType.medicationDoseEventType().effectiveObjectTypesForAuthorization.isEmpty)
        let sampleTypes: [any AnySampleType] = [SampleType.medicationDoseEvent, SampleType.heartRate]
        #expect(HealthKit.DataAccessRequirements(read: sampleTypes).read == [HKQuantityType(.heartRate)])
        let allKnownRequirements = HealthKit.DataAccessRequirements(read: HKObjectType.allKnownObjectTypes)
        #expect(!allKnownRequirements.read.contains(HKObjectType.medicationDoseEventType()))
    }
    
    @Test
    @MainActor
    func didAskForAuthorizationIgnoresDoseEvents() async {
        guard #available(iOS 26.0, watchOS 26.0, macOS 26.0, visionOS 26.0, *) else {
            return
        }
        let healthKit = HealthKit()
        #expect(await healthKit.didAskForAuthorization(toRead: SampleType.medicationDoseEvent))
    }
    
    @Test
    @MainActor
    func medicationsAuthorizationNotifiesOnlyDoseEventObservers() async {
        guard #available(iOS 26.0, watchOS 26.0, macOS 26.0, visionOS 26.0, *) else {
            return
        }
        let healthKit = HealthKit()
        let doseEventRequirements = HealthKit.DataAccessRequirements(read: [SampleType.medicationDoseEvent])
        let heartRateRequirements = HealthKit.DataAccessRequirements(read: [SampleType.heartRate])
        #expect(doseEventRequirements.read.isEmpty)
        #expect(doseEventRequirements.implicitlyAuthorizedRead == [HKObjectType.medicationDoseEventType()])
        #expect(heartRateRequirements.implicitlyAuthorizedRead.isEmpty)
        let doseEventStream = healthKit.observeAuthenticationEvents(matching: doseEventRequirements)
        let heartRateStream = healthKit.observeAuthenticationEvents(matching: heartRateRequirements)
        healthKit.notifyMedicationsAuthorizationObservers()
        #expect(await nextElement(of: doseEventStream) == doseEventRequirements)
        #expect(await nextElement(of: heartRateStream) == nil)
    }
    
    private func nextElement<Element: Sendable>(of stream: AsyncStream<Element>) async -> Element? {
        await withTaskGroup(of: Element?.self) { group in
            group.addTask {
                var iterator = stream.makeAsyncIterator()
                return await iterator.next()
            }
            group.addTask {
                try? await Task.sleep(for: .milliseconds(500))
                return nil
            }
            let element = await group.next().flatMap { $0 }
            group.cancelAll()
            return element
        }
    }
}

#endif
