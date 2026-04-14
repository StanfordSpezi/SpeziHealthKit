//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


/// A ``MappedUnit`` instance is used to specify a unit mapping for FHIR observations mapped from HealthKit's `HKUnit`s.
public struct MappedUnit: Decodable, Sendable {
    private enum CodingKeys: String, CodingKey {
        case hkunit
        case unit
        case system
        case code
    }
    
    
    /// The specified `HKUnit` that should be mapped.
    public var hkunit: HKUnit
    /// Unit representation.
    public var unit: String
    /// Identity of the terminology system.
    public private(set) var system: URL?
    /// Representation defined by the system.
    public private(set) var code: String?
    
    
    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let hkunit = try HKUnit(from: values.decode(String.self, forKey: .hkunit))
        let unit = try values.decode(String.self, forKey: .unit)
        guard let system = try values.decodeIfPresent(URL.self, forKey: .system),
              let code = try values.decodeIfPresent(String.self, forKey: .code) else {
            self.init(
                hkunit: hkunit,
                unit: unit
            )
            return
        }
        
        self.init(
            hkunit: hkunit,
            unit: unit,
            system: system,
            code: code
        )
    }
    
    /// A ``MappedUnit`` instance is used to specify a unit mapping for FHIR observations mapped from HealthKit's `HKUnit`s.
    /// - Parameters:
    ///   - hkunit: The specified `HKUnit` that should be mapped.
    ///   - unit: Unit representation.
    public init(
        hkunit: HKUnit,
        unit: String
    ) {
        self.hkunit = hkunit
        self.unit = unit
    }
    
    /// A ``MappedUnit`` instance is used to specify a unit mapping for FHIR observations mapped from HealthKit's `HKUnit`s.
    /// - Parameters:
    ///   - hkunit: The specified `HKUnit` that should be mapped.
    ///   - unit: Unit representation.
    ///   - system: Identity of the terminology system.
    ///   - code: Representation defined by the system.
    public init(
        hkunit: HKUnit,
        unit: String,
        system: URL,
        code: String
    ) {
        self.hkunit = hkunit
        self.unit = unit
        self.system = system
        self.code = code
    }
    
    
    /// Update the system and code from the ``MappedUnit`` instance.
    /// - Parameters:
    ///   - system: Identity of the terminology system.
    ///   - code: Representation defined by the system.
    mutating func update(system: URL, code: String) {
        self.system = system
        self.code = code
    }
    
    /// Remove the system and code from the ``MappedUnit`` instance.
    mutating func removeSystemAndCode() {
        system = nil
        code = nil
    }
}
