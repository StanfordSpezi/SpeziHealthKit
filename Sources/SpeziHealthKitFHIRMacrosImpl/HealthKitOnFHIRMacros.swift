//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros


@main
struct HealthKitOnFHIRMacros: CompilerPlugin {
    var providingMacros: [any Macro.Type] = [
        SynthesizeDisplayPropertyMacro.self
    ]
}
