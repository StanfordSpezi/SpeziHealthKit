//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


extension SampleTypeProxy {
    /// Wraps an ``AnySampleType``.
    public init?(_ifPossible sampleType: any AnySampleType) {
        switch sampleType {
        case let sampleType as SampleType<HKQuantitySample>:
            self = .quantity(sampleType)
        case let sampleType as SampleType<HKCorrelation>:
            self = .correlation(sampleType)
        case let sampleType as SampleType<HKCategorySample>:
            self = .category(sampleType)
        #if !os(watchOS)
        case let sampleType as SampleType<HKClinicalRecord>:
            self = .clinical(sampleType)
        #endif
        case let sampleType as SampleType<HKElectrocardiogram>:
            self = .electrocardiogram(sampleType)
        case let sampleType as SampleType<HKAudiogramSample>:
            self = .audiogram(sampleType)
        case let sampleType as SampleType<HKWorkout>:
            self = .workout(sampleType)
        default:
            if #available(iOS 18.0, watchOS 11.0, macOS 15.0, visionOS 2.0, *), let sampleType = sampleType as? SampleType<HKStateOfMind> {
                self = .stateOfMind(sampleType)
            } else {
                return nil
            }
        }
    }
}


extension SampleTypeProxy {
    /// Wraps an ``AnySampleType``.
    @_disfavoredOverload
    public init(_ sampleType: SampleType<some Any>) {
        self.init(sampleType)
    }
    
    /// Wraps an ``AnySampleType``.
    public init(_ sampleType: any AnySampleType) {
        if let proxy = Self(_ifPossible: sampleType) {
            self = proxy
        } else {
            fatalError("Unsupported SampleType input: \(type(of: sampleType)) (\(sampleType))")
        }
    }
}
