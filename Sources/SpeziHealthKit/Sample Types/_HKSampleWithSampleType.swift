//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable type_name

import HealthKit


/// Associates a `HKSampleType` subclass with a `HKSample` subclass.
public protocol _HKSampleWithSampleType: HKSample {
    associatedtype _SampleType: HKSampleType
}


extension HKQuantitySample: _HKSampleWithSampleType {
    public typealias _SampleType = HKQuantityType
}

extension HKCorrelation: _HKSampleWithSampleType {
    public typealias _SampleType = HKCorrelationType
}

extension HKCategorySample: _HKSampleWithSampleType {
    public typealias _SampleType = HKCategoryType
}

extension HKElectrocardiogram: _HKSampleWithSampleType {
    public typealias _SampleType = HKElectrocardiogramType
}

extension HKAudiogramSample: _HKSampleWithSampleType {
    public typealias _SampleType = HKAudiogramSampleType
}

// swiftlint:enable type_name
