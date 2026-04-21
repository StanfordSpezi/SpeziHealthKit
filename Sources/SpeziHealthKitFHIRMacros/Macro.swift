//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

/// Synthesizes a `var display: String?` property into an enum; the `display` String is derived from the enum case names.
///
/// ## Example:
/// ```swift
/// @SynthesizeDisplayProperty(HKDevicePlacementSide.self, .unknown, .left, .right, .central)
/// extension HKDevicePlacementSide {}
/// ```
///
/// - parameter type: The type the macro should operate on.
/// - parameter cases: The enum's cases.
/// - parameter additionalCases: Additional cases not listed in `cases`. This property exists to support cases whose availability is newer than the package's deployment target.
@attached(member, names: named(display))
public macro SynthesizeDisplayProperty<T>(
    _ type: T.Type,
    _ cases: T...,
    additionalCases: StaticString...
) = #externalMacro(module: "SpeziHealthKitFHIRMacrosImpl", type: "SynthesizeDisplayPropertyMacro")
