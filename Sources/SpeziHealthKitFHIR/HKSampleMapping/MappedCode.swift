//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ModelsR4


/// A ``MappedCode`` instance is used to specify codings for FHIR observations mapped from HealthKit's `HKSample`s.
public struct MappedCode: Decodable, Sendable {
    /// Symbol in syntax defined by the system.
    public var code: String
    /// Representation defined by the system.
    public var display: String
    /// Identity of the terminology system.
    public var system: URL
    
    
    var coding: Coding {
        Coding(
            code: code.asFHIRStringPrimitive(),
            display: display.asFHIRStringPrimitive(),
            system: FHIRPrimitive(FHIRURI(system))
        )
    }

    
    /// A ``MappedCode`` instance is used to specify codings for FHIR observations mapped from HealthKit's `HKSample`s.
    /// - Parameters:
    ///   - code: Symbol in syntax defined by the system.
    ///   - display: Representation defined by the system.
    ///   - system: Identity of the terminology system.
    public init(
        code: String,
        display: String,
        system: URL
    ) {
        self.code = code
        self.display = display
        self.system = system
    }
}
