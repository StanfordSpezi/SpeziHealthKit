//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


/// A non-ordered collection o funique type-erased ``SampleType``s
///
/// ``SampleTypesCollection`` conforms to Swift's `Collection` protocol, with an `Element` type of `any` ``AnySampleType``.
/// When working with a ``SampleTypesCollection``, you can obtain fully-typed ``SampleType`` instances using the following pattern:
/// ```swift
/// func processSampleTypes(_ sampleTypes: SampleTypesCollection) {
///     func imp<Sample>(_ sampleType: some AnySampleType<Sample>) {
///         let sampleType = SampleType(sampleType)
///         // do smth using the `sampleType` variable (which has type `SampleType<Sample>`)
///     }
///     for sampleType in sampleTypes {
///         imp(sampleType)
///     }
/// }
/// ```
public struct SampleTypesCollection: Hashable, Sendable, Codable {
    public typealias Storage = Set<WrappedSampleType>
    private var storage: Storage
    
    /// Creates a new, empty `SampleTypesCollection`.
    public init() {
        storage = []
    }
    
    /// Creates a new `SampleTypesCollection`, from the specified sample types
    public init(_ sampleTypes: some Collection<WrappedSampleType>) {
        storage = Set(sampleTypes)
    }
    
    /// Creates a new `SampleTypesCollection`, from the specified sample types
    public init(_ sampleTypes: some Collection<any AnySampleType>) {
        self.init(sampleTypes.lazy.map { WrappedSampleType($0) })
    }
    
    /// Creates a new `SampleTypesCollection`, from the specified sample types
    public init(_ sampleTypes: some Collection<some AnySampleType>) {
        self.init(sampleTypes.lazy.map { WrappedSampleType($0) })
    }
    
    /// Creates a new `SampleTypesCollection`, from the specified sample types
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
    /// Inserts a sample type into the collection.
    ///
    /// - returns: a boolean value indicating whether the sample type was inserted.
    @discardableResult
    public mutating func insert(_ sampleType: some AnySampleType) -> Bool {
        storage.insert(WrappedSampleType(sampleType)).inserted
    }
    
    /// Inserts a sample type into the collection.
    ///
    /// - returns: a boolean value indicating whether the sample type was inserted.
    @discardableResult
    public mutating func insert(_ sampleType: WrappedSampleType) -> Bool {
        storage.insert(sampleType).inserted
    }
    
    /// Inserts the sample types in the other collection into this collection.
    ///
    /// - Note: any sample types in `other` that are already contained in `self` will not be inserted.
    public mutating func insert(contentsOf other: some Collection<some AnySampleType>) {
        insert(contentsOf: other.lazy.map { $0 as any AnySampleType })
    }
    
    /// Inserts the sample types in the other collection into this collection.
    ///
    /// - Note: any sample types in `other` that are already contained in `self` will not be inserted.
    public mutating func insert(contentsOf other: some Collection<any AnySampleType>) {
        for sampleType in other {
            insert(sampleType)
        }
    }
    
    /// Removes the specified sample type from the collection, if it is a member.
    public mutating func remove(_ sampleType: some AnySampleType) {
        storage.remove(WrappedSampleType(sampleType))
    }
    
    /// Determines whether the specified sample type is a member of the collection.
    public func contains(_ sampleType: some AnySampleType) -> Bool {
        storage.contains(WrappedSampleType(sampleType))
    }
    
    /// Determines whether the specified sample type is a member of the collection.
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
    
    public func index(after idx: Storage.Index) -> Storage.Index {
        storage.index(after: idx)
    }
    
    public subscript(position: Storage.Index) -> any AnySampleType {
        storage[position].underlyingSampleType
    }
}


// MARK: ExpressibleByArrayLiteral

extension SampleTypesCollection: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: any AnySampleType...) {
        self.init()
        self.insert(contentsOf: elements)
    }
}
