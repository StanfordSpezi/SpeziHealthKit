//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


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
    
    subscript(sampleType: SampleType<some Any>) -> Value? {
        get {
            try? localStorage.load(storageKey(for: sampleType))
        }
        nonmutating set {
            try? localStorage.store(newValue, for: storageKey(for: sampleType))
        }
    }
}
