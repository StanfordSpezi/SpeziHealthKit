//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// Uniquely identifies a ``BulkExportSession``
public struct BulkExportSessionIdentifier: Hashable, Sendable, RawRepresentable, Codable {
    public let rawValue: String
    
    /// Creates a new Session Identifier
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
