//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import Foundation
import SwiftUI


extension Locale {
    static let enUS = Locale(identifier: "en_US")
}


extension TimeZone {
    static let losAngeles = TimeZone(identifier: "America/Los_Angeles")! // swiftlint:disable:this force_unwrapping
}


extension Calendar {
    func withLocale(_ locale: Locale, timeZone: TimeZone) -> Calendar {
        var cal = self
        cal.locale = locale
        cal.timeZone = timeZone
        return cal
    }
}


extension View {
    func withLocale(_ locale: Locale, timeZone: TimeZone) -> some View {
        var cal = Calendar.current
        cal.locale = locale
        cal.timeZone = timeZone
        return self
            .environment(\.locale, locale)
            .environment(\.timeZone, timeZone)
            .environment(\.calendar, cal)
    }
}
