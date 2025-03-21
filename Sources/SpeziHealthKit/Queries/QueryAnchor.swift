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
///
/// The `QueryAnchor` type wraps around HealthKit's `HKQueryAnchor` type, adding support for `Codable`-based serialization,
/// allowing you to persist your query's last-seen database state across multiple app launches:
///
/// ```swift
/// func loadAnchor() throws -> QueryAnchor? {
///     guard let data = try? Data(contentsOf: anchorUrl) else {
///         return nil
///     }
///     return try? JSONDecoder().decode(QueryAnchor.self, from: data)
/// }
///
/// func storeAnchor(_ anchor: QueryAnchor) throws {
///     let data = try JSONEncoder().encode(anchor)
///     try data.write(to: anchorUrl)
/// }
///
/// // fetches all heart rate samples since the last call
/// func fetchNewSamples() async throws -> [HKQuantitySample] {
///     // Fetch the last-used anchor,
///     // or create an empty new one for the initial launch
///     var anchor = try loadAnchor() ?? QueryAnchor()
///     let samples = try await healthKit.query(
///         .heartRate,
///         timeRange: .today,
///         anchor: &anchor
///     )
///     try storeAnchor(anchor)
///     return samples
/// }
/// ```
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
