//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


/// Used by anchor queries to keep track of the last-seen state of the HealthKit database.
public struct QueryAnchor: Hashable, Codable, Sendable {
    let hkAnchor: HKQueryAnchor?
    
    /// Creates a new, empty `QueryAnchor`.
    ///
    /// Use this initializer to create a "fresh" anchor, which when used in a query will match against all samples in the database.
    public init() {
        self.hkAnchor = nil
    }
    
    /// Creates a `QueryAnchor` from a HealthKit `HKQueryAnchor`.
    public init(_ hkAnchor: HKQueryAnchor) {
        self.hkAnchor = hkAnchor
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = QueryAnchor()
        } else {
            let data = try container.decode(Data.self)
            guard let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data) else {
                throw DecodingError.valueNotFound(HKQueryAnchor.self, .init(codingPath: [], debugDescription: ""))
            }
            self = QueryAnchor(anchor)
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        if let hkAnchor {
            let data = try NSKeyedArchiver.archivedData(withRootObject: hkAnchor, requiringSecureCoding: true)
            try container.encode(data)
        } else {
            try container.encodeNil()
        }
    }
}
