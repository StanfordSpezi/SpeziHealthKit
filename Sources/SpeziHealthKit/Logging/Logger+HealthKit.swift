//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import OSLog

extension Logger {
    // swiftlint:disable force_unwrapping
    /// Using the bundle identifier to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    // swiftlint:enable force_unwrapping

    /// Logs the view cycles like a view that appeared.
    static let healthKit = Logger(subsystem: subsystem, category: "healthkit")
}
