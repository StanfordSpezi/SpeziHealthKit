//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(SpeziLocalStorage)
import Foundation
import SpeziFoundation
import SpeziLocalStorage


// Essentially just a thread-safe dictionary that keeps track of our `LocalStorageKey`s used by the `SampleTypeScopedLocalStorage`.
// The reason this exists is bc the LocalStorage API is intended to be used with long-lived LocalStorageKey objects, which doesn't easily
// work with the multi-key scoping approach we're using here.
// Were we not to use something like this for caching and re-using the keys, we'd need to create temporary `LocalStorageKey`s for
// every load/store operation, which would of course work but would also defeat the whole purpose of having the `LocalStorageKey`s
// be long-lived objects which are also used for e.g. locking / properly handling concurrent reads or writes.
private enum LocalStorageKeysHandling {
    private struct DictKey: Hashable {
        let valueType: String
        let sampleType: String
        
        init(valueType: (some Any).Type, sampleType: SampleType<some Any>) {
            // this is fine bc we're not using it as a stable identifier
            // (the `valueType` key must only be valid&unique for the lifetime of the app)
            self.valueType = String(reflecting: valueType)
            self.sampleType = sampleType.id
        }
    }
    
    private static let lock = NSLock()
    nonisolated(unsafe) private static var localStorageKeys: [DictKey: Any] = [:]
    
    static func localStorageKey<Value>(
        forValueType valueType: Value.Type,
        sampleType: SampleType<some Any>,
        defaultValue makeKey: @autoclosure () -> LocalStorageKey<Value>
    ) -> LocalStorageKey<Value> {
        lock.withLock {
            let dictKey = DictKey(valueType: valueType, sampleType: sampleType)
            if let key = localStorageKeys[dictKey] {
                if let key = key as? LocalStorageKey<Value> {
                    return key
                } else {
                    preconditionFailure("LocalStorageKey unexpectedly has incorrect type: expected '\(LocalStorageKey<Value>.self)'; got '\(type(of: key))'")
                }
            } else {
                let key = makeKey()
                localStorageKeys[dictKey] = key
                return key
            }
        }
    }
}


/// Thrown internally by ``SampleTypeScopedLocalStorage/compareAndStore(_:for:ifCurrentValue:)`` to abort the write if the check fails.
private struct CompareAndStoreMismatch: Error {}


struct SampleTypeScopedLocalStorage<Value: SendableMetatype> {
    private let localStorage: LocalStorage
    private let makeStorageKey: @Sendable (any AnySampleType) -> LocalStorageKey<Value>
    
    private init(
        localStorage: LocalStorage,
        makeStorageKey: @escaping @Sendable (any AnySampleType) -> LocalStorageKey<Value>
    ) {
        self.localStorage = localStorage
        self.makeStorageKey = makeStorageKey
    }
    
    init(
        localStorage: LocalStorage,
        storageKeyPrefix: String,
        storageSetting: LocalStorageSetting
    ) where Value: Codable {
        self.init(localStorage: localStorage) { sampleType in
            LocalStorageKey<Value>("\(storageKeyPrefix).\(sampleType.id)", setting: storageSetting)
        }
    }
    
    private func storageKey(for sampleType: SampleType<some Any>) -> LocalStorageKey<Value> {
        LocalStorageKeysHandling.localStorageKey(forValueType: Value.self, sampleType: sampleType, defaultValue: makeStorageKey(sampleType))
    }
    
    /// Loads the value stored for `sampleType`.
    ///
    /// - returns: `nil` if no value is stored.
    /// - throws: if a value exists but could not be read or decoded.
    func load(for sampleType: SampleType<some Any>) throws -> Value? {
        try localStorage.load(storageKey(for: sampleType))
    }
    
    /// Stores `value` for `sampleType`, or removes the stored value if `value` is `nil`.
    func store(_ value: Value?, for sampleType: SampleType<some Any>) throws {
        try localStorage.store(value, for: storageKey(for: sampleType))
    }
    
    /// Atomically stores `newValue` for `sampleType`, but only if the currently stored value satisfies `isExpected`.
    ///
    /// The check and the write happen while holding the storage key's write lock, i.e., no other ``load(for:)``, ``store(_:for:)``,
    /// or `compareAndStore` call for the same `sampleType` (and value type) can interleave with it.
    ///
    /// - parameter newValue: The value to store, or `nil` to remove the stored value.
    /// - parameter isExpected: Called with the currently stored value (or `nil`, if no value is stored).
    /// - returns: `true` if `newValue` was stored; `false` if the stored value didn't satisfy `isExpected`, in which case nothing was written.
    /// - throws: if the stored value could not be read, or `newValue` could not be written.
    func compareAndStore(
        _ newValue: Value?,
        for sampleType: SampleType<some Any>,
        ifCurrentValue isExpected: (Value?) -> Bool
    ) throws -> Bool {
        do {
            // `LocalStorage.modify` holds the key's write lock for the whole read-check-write sequence.
            // We abort it by throwing, so that nothing gets written if the check fails.
            try localStorage.modify(storageKey(for: sampleType)) { value in
                guard isExpected(value) else {
                    throw CompareAndStoreMismatch()
                }
                value = newValue
            }
            return true
        } catch is CompareAndStoreMismatch {
            return false
        }
    }
    
    /// Error-swallowing convenience accessor.
    ///
    /// - Important: Do not use this for values where a failed read or write needs to be detected (e.g., query anchors);
    ///     use ``load(for:)`` and ``store(_:for:)`` instead.
    subscript(sampleType: SampleType<some Any>) -> Value? {
        get {
            try? load(for: sampleType)
        }
        nonmutating set {
            try? store(newValue, for: sampleType)
        }
    }
}
#endif
