//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


/// A collection of type-erased ``SampleType``s.
public struct SampleTypesCollection: Hashable, Sendable, Codable {
    public typealias Storage = Set<WrappedSampleType>
    private var storage: Storage
    
    public init() {
        storage = []
    }
    
    public init(_ sampleTypes: some Collection<WrappedSampleType>) {
        storage = Set(sampleTypes)
    }
    
    public init(_ sampleTypes: some Collection<any AnySampleType>) {
        self.init(sampleTypes.lazy.map { WrappedSampleType($0) })
    }
    
    public init(_ sampleTypes: some Collection<some AnySampleType>) {
        self.init(sampleTypes.lazy.map { WrappedSampleType($0) })
    }
    
    public init(
        quantity quantityTypes: some Collection<SampleType<HKQuantitySample>> = [],
        correlation correlationTypes: some Collection<SampleType<HKCorrelation>> = [],
        category categoryTypes: some Collection<SampleType<HKCategorySample>> = [],
        other otherTypes: some Collection<any AnySampleType> = []
    ) {
        self.init()
        self.insert(contentsOf: quantityTypes)
        self.insert(contentsOf: correlationTypes)
        self.insert(contentsOf: categoryTypes)
        self.insert(contentsOf: otherTypes)
    }
}


extension SampleTypesCollection {
    /// The contained quantity types
    public var quantityTypes: some Collection<SampleType<HKQuantitySample>> {
        storage.compactMap { $0.underlyingSampleType as? SampleType<_> }
    }
    
    /// The sample types which should be used when requesting read/write authorization for this sample type with HealthKit.
    ///
    /// The reason this exists is that HealthKit doesn't allow such requests for some sample types, e.g. correlation types:
    /// instead of requesting read/write access to "blood pressure", apps need to request read/write access to each of the correlation's contained types,
    /// (eg:, in the case of blood pressure, systolic and diastolic blood pressure).
    public var effectiveSampleTypesForAuthentication: [any AnySampleType] {
        storage.flatMap { $0.underlyingSampleType.effectiveSampleTypesForAuthentication }
    }
}


// MARK: Mutations

extension SampleTypesCollection {
    @discardableResult
    public mutating func insert(_ sampleType: some AnySampleType) -> Bool {
        storage.insert(WrappedSampleType(sampleType)).inserted
    }
    
    @discardableResult
    public mutating func insert(_ sampleType: WrappedSampleType) -> Bool {
        storage.insert(sampleType).inserted
    }
    
    public mutating func insert(contentsOf other: some Collection<some AnySampleType>) {
        insert(contentsOf: other.lazy.map { $0 as any AnySampleType })
    }
    
    public mutating func insert(contentsOf other: some Collection<any AnySampleType>) {
        for sampleType in other {
            insert(sampleType)
        }
    }
    
    public mutating func remove(_ sampleType: some AnySampleType) {
        storage.remove(WrappedSampleType(sampleType))
    }
    
    public func contains(_ sampleType: some AnySampleType) -> Bool {
        storage.contains(WrappedSampleType(sampleType))
    }
    
    public func contains(_ sampleType: WrappedSampleType) -> Bool {
        storage.contains(sampleType)
    }
}


// MARK: Collection

extension SampleTypesCollection: Collection {
    public typealias Index = Storage.Index
    public typealias Element = any AnySampleType
    
    public var startIndex: Storage.Index {
        storage.startIndex
    }
    
    public var endIndex: Storage.Index {
        storage.endIndex
    }
    
    public var isEmpty: Bool {
        storage.isEmpty
    }
    
    public var count: Int {
        storage.count
    }
    
    public subscript(position: Storage.Index) -> any AnySampleType {
        storage[position].underlyingSampleType
    }
    
    public func index(after idx: Storage.Index) -> Storage.Index {
        storage.index(after: idx)
    }
}


// MARK: ExpressibleByArrayLiteral

extension SampleTypesCollection: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: any AnySampleType...) {
        self.init()
        self.insert(contentsOf: elements)
    }
}
