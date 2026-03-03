//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import Foundation
#if canImport(HealthKit)
import HealthKit
#endif


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
        #if canImport(Darwin)
        if #available(macOS 15.4, iOS 18.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *) {
            let notFound = "NOT_FOUND"
            return localizations.lazy
                .compactMap { lang in
                    (tables.isEmpty ? [.default] : tables).lazy
                        .map { self.localizedString(forKey: key, value: notFound, table: $0.stringValue, localizations: [lang]) }
                        .first { $0 != notFound }
                }
                .first
        }
        #endif
        return localizedStringForKeyFallback(key: key, tables: tables, localizations: localizations)
    }
    
    // ideally this would be directly in the other function, but bc of the #available check we wouldn't be able to test it then.
    // NOTE: remove this when we increase our package deployment target to >= iOS 18.4!
    @_spi(Testing)
    public func localizedStringForKeyFallback( // swiftlint:disable:this missing_docs
        key: String,
        tables: [LocalizationLookupTable],
        localizations: [Locale.Language]
    ) -> String? {
        let tables = tables.isEmpty ? [.default] : tables
        for language in Bundle.preferredLocalizations(from: localizations.map(\.minimalIdentifier)) {
            let candidates = [
                // for some reason SPM packages compiled via xcodebuild keep the names of the lproj folders unchanged (eg "en_GB.lproj"),
                // but compiling with `swift build` lowercases them, so we need to check for both.
                self.url(forResource: language.replacingOccurrences(of: "-", with: "_"), withExtension: "lproj"),
                self.url(forResource: language.replacingOccurrences(of: "-", with: "_").lowercased(), withExtension: "lproj")
            ]
            guard let lproj = candidates.compactMap(\.self).first, let bundle = Bundle(url: lproj) else {
                continue
            }
            if let title = bundle.localizedString(forKey: key, tables: tables) {
                return title
            }
        }
        // To match the behaviour of apple's implementation
        return self.localizedString(forKey: key, tables: tables)
    }
}
