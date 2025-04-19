//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@testable import SpeziHealthKit
import Testing


@Suite
struct SampleTypesCollectionTests {
    @Test
    func uniqueness() {
        var sampleTypes = SampleTypesCollection()
        #expect(sampleTypes.isEmpty)
        #expect(sampleTypes.count == 0) // swiftlint:disable:this empty_count
        sampleTypes.insert(SampleType.heartRate)
        #expect(sampleTypes.count == 1)
    }
    
    
    @Test
    func initialization() {
        do {
            let samples1 = SampleTypesCollection([SampleType.heartRate, .stepCount, .dietaryIron] as [SampleType<HKQuantitySample>])
            let samples2 = SampleTypesCollection([SampleType.heartRate, SampleType.stepCount, SampleType.dietaryIron] as [any AnySampleType])
            #expect(samples1 == samples2)
        }
        do {
            let samples1 = SampleTypesCollection([SampleType.heartRate, SampleType.sleepAnalysis, SampleType.bloodPressure])
            let samples2 = SampleTypesCollection(quantity: [.heartRate], correlation: [.bloodPressure], category: [.sleepAnalysis])
            #expect(samples1 == samples2)
        }
    }
    
    
    @Test
    func properties() {
        do {
            let samples = SampleTypesCollection([SampleType.heartRate, SampleType.sleepAnalysis, SampleType.bloodPressure])
            #expect(samples.quantityTypes == [SampleType.heartRate])
            #expect(samples.categoryTypes == [SampleType.sleepAnalysis])
            #expect(samples.correlationTypes == [SampleType.bloodPressure])
            let expected: SampleTypesCollection = [
                SampleType.heartRate, SampleType.sleepAnalysis, SampleType.bloodPressureSystolic, SampleType.bloodPressureDiastolic
            ]
            #expect(SampleTypesCollection(samples.effectiveSampleTypesForAuthentication) == expected)
        }
    }
    
    
    @Test
    func operations() {
        var samples = SampleTypesCollection()
        #expect(samples.isEmpty)
        samples.insert(SampleType.heartRate)
        #expect(samples.count == 1 && samples.contains(SampleType.heartRate))
        #expect(samples.count == 1 && samples.contains(SampleTypeProxy(.heartRate)))
        
        do {
            // we can't simply directly call the mutating member function in the #expect :/
            let didInsert = samples.insert(SampleType.heartRate)
            #expect(!didInsert)
        }
        do {
            let didInsert = samples.insert(SampleTypeProxy(SampleType.heartRate))
            #expect(!didInsert)
        }
        samples.insert(contentsOf: [SampleTypeProxy(.heartRate), SampleTypeProxy(.activeEnergyBurned)])
        #expect(samples == SampleTypesCollection([SampleType.heartRate, .activeEnergyBurned]))
        samples.remove(SampleType.acne)
        #expect(samples == SampleTypesCollection([SampleType.heartRate, .activeEnergyBurned]))
        samples.remove(SampleType.heartRate)
        #expect(samples == SampleTypesCollection([SampleType.activeEnergyBurned]))
        samples.remove(SampleType.activeEnergyBurned)
        #expect(samples == SampleTypesCollection())
    }
}
