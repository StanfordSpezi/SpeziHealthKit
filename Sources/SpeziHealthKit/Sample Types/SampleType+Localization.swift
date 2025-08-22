//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


extension AnySampleType {
    /// Returns the sample type's localized display title, for the specified language, if available.
    public func localizedTitle(in language: Locale.Language) -> String? {
        Self.localizedTitle(for: hkSampleType, in: language)
    }
}

extension AnySampleType {
    static func localizedTitle(for objectType: HKObjectType) -> String? {
        let bundle = Bundle.module
        let tables = ["Localizable-HKTypes", "Localizable"]
        if let title = bundle.localizedString(forKey: objectType.identifier, tables: tables) {
            // if we find a title for the current language, we return that
            return title
        } else {
            // ... otherwise we try to fetch an english translation as a fallback.
            return bundle.localizedString(forKey: objectType.identifier, tables: tables, localizations: [.init(identifier: "en")])
        }
    }
    
    static func localizedTitle(for objectType: HKObjectType, in language: Locale.Language) -> String? {
        Bundle.module.localizedString(
            forKey: objectType.identifier,
            tables: ["Localizable-HKTypes", "Localizable"],
            localizations: [language]
        )
    }
}


extension Bundle {
    fileprivate func localizedString(forKey key: String, tables: [String?]) -> String? {
        let notFound = "NOT_FOUND"
        return tables.lazy
            .map { self.localizedString(forKey: key, value: notFound, table: $0) }
            .first { $0 != notFound }
    }
    
    fileprivate func localizedString(forKey key: String, tables: [String?], localizations: [Locale.Language]) -> String? {
        if #available(macOS 15.4, iOS 18.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *) {
            let notFound = "NOT_FOUND"
            return tables.lazy
                .map { self.localizedString(forKey: key, value: notFound, table: $0, localizations: localizations) }
                .first { $0 != notFound }
        } else {
            for language in Bundle.preferredLocalizations(from: localizations.map(\.minimalIdentifier)) {
                guard let lproj = self.url(forResource: language.replacingOccurrences(of: "-", with: "_"), withExtension: "lproj"),
                      let bundle = Bundle(url: lproj) else {
                    continue
                }
                if let title = bundle.localizedString(forKey: key, tables: tables) {
                    return title
                }
            }
            return nil
        }
    }
}
