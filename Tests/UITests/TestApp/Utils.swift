//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension Sequence {
    /// async-compatible version of `Sequence.allSatisfy(_:)`
    @_disfavoredOverload
    func allSatisfy(_ predicate: @Sendable (Element) async -> Bool) async -> Bool {
        for element in self {
            if await !predicate(element) { // swiftlint:disable:this for_where
                return false
            }
        }
        return true
    }
}
