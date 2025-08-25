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
        let bundle = HealthKit.bundle
        let tables: [Bundle.LocalizationLookupTable] = [.custom("Localizable-HKTypes"), .default]
        if let title = bundle.localizedString(forKey: objectType.identifier, tables: tables) {
            // if we find a title for the current language, we return that
            return title
        } else {
            // ... otherwise we try to fetch an english translation as a fallback.
            return bundle.localizedString(forKey: objectType.identifier, tables: tables, localizations: [.init(identifier: "en")])
        }
    }
    
    static func localizedTitle(for objectType: HKObjectType, in language: Locale.Language) -> String? {
        HealthKit.bundle.localizedString(
            forKey: objectType.identifier,
            tables: [.custom("Localizable-HKTypes"), .default],
            localizations: [language]
        )
    }
}


extension Bundle {
    @_spi(Testing)
    public enum LocalizationLookupTable: Hashable, Sendable {
        /// The `Localizable.strings` table.
        case `default`
        /// A custom `{name}.strings` table.
        case custom(_ name: String)
        
        /// A String representation of the table, compatible with `Bundle`'s localization APIs.
        fileprivate var stringValue: String? {
            switch self {
            case .default: nil
            case .custom(let name): name
            }
        }
    }
    
    /// Looks up the localized version of a string in multiple tables, returning the first match.
    ///
    /// - parameter key: the localization key to look up a value for.
    /// - parameter tables: the tables in which the lookup should be performed.
    /// - returns: a localized version of the string, obtained from the first table that contained an entry for `key`.
    fileprivate func localizedString(forKey key: String, tables: [LocalizationLookupTable]) -> String? {
        let notFound = "NOT_FOUND"
        return (tables.isEmpty ? [.default] : tables).lazy
            .map { self.localizedString(forKey: key, value: notFound, table: $0.stringValue) }
            .first { $0 != notFound }
    }
    
    @_spi(Testing)
    public func localizedString( // swiftlint:disable:this missing_docs
        forKey key: String,
        tables: [LocalizationLookupTable],
        localizations: [Locale.Language]
    ) -> String? {
        if #available(macOS 15.4, iOS 18.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *) {
            let notFound = "NOT_FOUND"
            return localizations.lazy
                .compactMap { lang in
                    (tables.isEmpty ? [.default] : tables).lazy
                        .map { self.localizedString(forKey: key, value: notFound, table: $0.stringValue, localizations: [lang]) }
                        .first { $0 != notFound }
                }
                .first
        } else {
            return localizedStringForKeyFallback(key: key, tables: tables, localizations: localizations)
        }
    }
    
    // ideally this would be directly in the other function, but bc of the #available check we wouldn't be able to test it then.
    // NOTE: remove this when we increase our package deployment target to >= iOS 18.4!
    @_spi(Testing)
    public func localizedStringForKeyFallback( // swiftlint:disable:this missing_docs
        key: String,
        tables: [LocalizationLookupTable],
        localizations: [Locale.Language]
    ) -> String? {
        print(self.bundlePath)
        print(HealthKit.bundle.bundlePath)
        let tables = tables.isEmpty ? [.default] : tables
        for language in Bundle.preferredLocalizations(from: localizations.map(\.minimalIdentifier)) {
            guard let lproj = self.url(forResource: language.replacingOccurrences(of: "-", with: "_"), withExtension: "lproj"),
                  let bundle = Bundle(url: lproj) else {
                continue
            }
            if let title = bundle.localizedString(forKey: key, tables: tables) {
                return title
            }
        }
        if tables.contains(.default), let title = self.localizedString(forKey: key, tables: [.default]) {
            return title
        } else {
            return nil
        }
    }
}
