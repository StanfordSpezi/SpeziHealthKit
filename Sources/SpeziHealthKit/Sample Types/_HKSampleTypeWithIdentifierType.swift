//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable type_name

import HealthKit


public protocol _HKSampleTypeIdentifierType: Hashable {
    init(rawValue: String)
}

extension HKQuantityTypeIdentifier: _HKSampleTypeIdentifierType {}
extension HKCorrelationTypeIdentifier: _HKSampleTypeIdentifierType {}
extension HKCategoryTypeIdentifier: _HKSampleTypeIdentifierType {}


/// Associates a `HKSampleType` subclass with its corresponding identifier type.
public protocol _HKSampleTypeWithIdentifierType: HKSampleType {
    associatedtype _Identifier: _HKSampleTypeIdentifierType
}


extension HKQuantityType: _HKSampleTypeWithIdentifierType {
    public typealias _Identifier = HKQuantityTypeIdentifier
}

extension HKCorrelationType: _HKSampleTypeWithIdentifierType {
    public typealias _Identifier = HKCorrelationTypeIdentifier
}

extension HKCategoryType: _HKSampleTypeWithIdentifierType {
    public typealias _Identifier = HKCategoryTypeIdentifier
}

// swiftlint:enable type_name
