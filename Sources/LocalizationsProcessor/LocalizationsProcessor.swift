//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

// swiftlint:disable file_types_order

import ArgumentParser
import Foundation
import SpeziHealthKit


private let allObjectTypes = HKObjectType.allKnownObjectTypes.sorted { $0.identifier < $1.identifier }


enum CommandError: Error {
    case unableToFindLoctable
    case unableToDecodeLoctable(URL)
    case other(String)
}


struct LocalizationEntry: Hashable {
    let key: String
    let value: String
    let table: String
}


@main
struct LocalizationsProcessor: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Generate localized string catalogues for HealthKit data types",
        version: "0.1.0"
    )
    
    @Flag(name: .short, help: "Enable extended logging")
    var verbose = false
    
    @Option(
        name: .customShort("o"),
        help: """
            Output directory path. Should point to 'Sources/SpeziHealthKit/Resources/'.
            May be omitted to perform a dry run, in which case the resulting translation mappings will be printed to stdout, but not written to disk.
            """
    )
    var outputUrl: URL?
    
    @Argument(help: "Locale identifiers for which translations should be processed.")
    var locales: [Locale]
    
    
    func run() throws {
        if verbose {
            print("\(self)")
        }
        let localizations = try Localizations()
        if verbose {
            localizations.debugDump()
        }
        for locale in locales {
            try process(locale: locale, using: localizations)
        }
    }
    
    
    private func process(locale: Locale, using localizations: Localizations) throws {
        let year = Calendar.current.component(.year, from: .now)
        var stringsFile = """
            //
            // This source file is part of the Stanford Spezi open-source project
            //
            // SPDX-FileCopyrightText: \(year) Stanford University and the project authors (see CONTRIBUTORS.md)
            //
            // SPDX-License-Identifier: MIT
            //
            
            // THIS FILE IS AUTO-GENERATED! DO NOT EDIT!!!
            
            
            """
        if case let duplicates = allObjectTypes.grouped(by: \.self).filter({ $1.count > 1 }), !duplicates.isEmpty {
            preconditionFailure(
                "Duplicate object types in input:\n\(duplicates.keys.map(\.identifier).sorted().map { "- \($0)" }.joined(separator: "\n"))"
            )
        }
        precondition(allObjectTypes.count == allObjectTypes.mapIntoSet(\.self).count, "1")
        precondition(allObjectTypes.count == allObjectTypes.mapIntoSet(\.identifier).count, "2")
        for objectType in allObjectTypes {
            if let title = localizations[objectType, locale: locale] {
                stringsFile.append(#""\#(objectType.identifier)" = "\#(title)";\#n"#)
            } else {
                print("\(locale.language.minimalIdentifier) Unable to determine display title for \(objectType.identifier)")
            }
        }
        if let outputUrl {
            let dstStringsUrl = outputUrl
                .appending(component: "\(locale.identifier).lproj", directoryHint: .isDirectory)
                .appending(component: "Localizable-HKTypes.strings", directoryHint: .notDirectory)
            try FileManager.default.createDirectory(at: dstStringsUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
            print("Writing title mappings for \(locale.identifier) to \(dstStringsUrl.path)")
            try Data(stringsFile.utf8).write(to: dstStringsUrl)
        } else {
            print("\n\n\(locale.identifier).lproj:\n\(stringsFile)")
        }
    }
}


private struct Localizations {
    private let displayNameKeys: [HKObjectType: String]
    private var mergedLoctables: [Locale: [String: [LocalizationEntry]]]
    
    init() throws { // swiftlint:disable:this function_body_length
        let bundle = Bundle(for: HKHealthStore.self)
        guard let bundleResourceUrl = bundle.resourceURL else {
            throw CommandError.other("Unable to find bundle resource url")
        }
        let loctableUrls = ((try? FileManager.default.contents(of: bundleResourceUrl.absoluteURL.resolvingSymlinksInPath())) ?? [])
            .filter { $0.pathExtension == "loctable" }
        print(loctableUrls)
        /// lang: [key: [value]]
        mergedLoctables = try loctableUrls.reduce(into: [:]) { mergedTable, url in
            let data = try Data(contentsOf: url)
            guard let table = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: [String: Any]] else {
                throw CommandError.unableToDecodeLoctable(url)
            }
            for (locale, value) in table where locale != "LocProvenance" {
                let locale = Locale(identifier: locale)
                for (key2, value2) in value {
                    guard let value2 = value2 as? String else {
                        continue
                    }
                    mergedTable[locale, default: [:]][key2, default: []].append(.init(
                        key: key2,
                        value: value2,
                        table: url.deletingPathExtension().lastPathComponent
                    ))
                }
            }
        }
        for (key, entries) in Self.hardcodedMappings {
            for (locale, value) in entries {
                let locale = Locale(identifier: locale)
                guard mergedLoctables.keys.contains(locale) else {
                    continue
                }
                let entry = LocalizationEntry(key: key, value: value, table: "")
                mergedLoctables[locale, default: [:]][key, default: []].append(.init(
                    key: key,
                    value: value,
                    table: ""
                ))
            }
        }
        guard let referenceLoctable = mergedLoctables[.init(identifier: Locale.current.language.minimalIdentifier)] else {
            throw CommandError.other("unable to find reference loctable")
        }
        let hardcodedNameKeys: [HKObjectType: String] = [
            HKClinicalType(.allergyRecord): "ALLERGY_RECORDS",
            HKClinicalType(.clinicalNoteRecord): "CLINICAL_NOTES_RECORDS",
            HKClinicalType(.conditionRecord): "CONDITION_RECORDS",
            HKClinicalType(.immunizationRecord): "IMMUNIZATION_RECORDS",
            HKClinicalType(.labResultRecord): "LAB_RESULT_RECORDS",
            HKClinicalType(.medicationRecord): "MEDICATION_RECORDS",
            HKClinicalType(.procedureRecord): "PROCEDURE_RECORDS",
            HKClinicalType(.vitalSignRecord): "VITAL_SIGN_RECORDS",
            HKClinicalType(.coverageRecord): "INSURANCE_RECORDS",
            // for some reason `HKCorrelationType(.food)` has a -hk_localizedName, but .food does not...
            HKCorrelationType(.food): "HKCorrelationTypeIdentifierFood"
        ]
        displayNameKeys = allObjectTypes.reduce(into: hardcodedNameKeys) { keys, type in
            guard !keys.keys.contains(type) else {
                return
            }
            if let displayName = type.value(forKey: "hk_localizedName") as? String {
                let keysWithMatchingValues = referenceLoctable.keys.filter {
                    referenceLoctable[$0]?.contains(where: { $0.value == displayName }) == true
                }
                keys[type] = keysWithMatchingValues.min { $0.count < $1.count }
            } else {
                print(
                    "Unable to determine display name key for \(type.identifier).",
                    Swift.type(of: type)
                )
            }
        }
    }
    
    func debugDump() {
        print("LOCALIZATIONS")
        for (type, key) in displayNameKeys {
            print("\(type.identifier) -> \(key)")
        }
        for (lang, entries) in mergedLoctables {
            for (key, value) in entries {
                print("[\(lang)] \(key) = \(value)")
            }
        }
    }
    
    subscript(type: HKObjectType, locale locale: Locale) -> String? {
        guard let key = displayNameKeys[type] else {
            print("no display name key for \(type)")
            return nil
        }
        guard let potentialTitles = mergedLoctables[locale]?[key] else {
            print("no entry for \(key)")
            return nil
        }
        if potentialTitles.count > 1 {
            print("Found multiple potential titles for \(type.identifier). Will use first.")
            for entry in potentialTitles {
                print("- [\(entry.table)] \(entry.key) = \(entry.value)")
            }
        }
        return potentialTitles.first?.value
    }
}


extension Localizations {
    /// mapping of localization keys to lang-value dictionaries
    private static let hardcodedMappings: [String: [String: String]] = [
        "HKCorrelationTypeIdentifierFood": [
            "en": "Nutrition",
            "en_GB": "Nutrition",
            "fr": "Nutrition",
            "de": "Ernährung",
            "es": "Nutrición",
            "es_US": "Nutrición"
        ]
    ]
}


extension Locale.Language {
    static let english = Locale.Language(identifier: "en")
    static let englishUK = Locale.Language(identifier: "en_GB")
    static let german = Locale.Language(identifier: "de")
    static let french = Locale.Language(identifier: "fr")
    static let spanish = Locale.Language(identifier: "es")
    static let spanishUS = Locale.Language(identifier: "es_US")
}


extension Locale: @retroactive _SendableMetatype {}
extension Locale: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        guard Locale.availableIdentifiers.contains(argument) else {
            return nil
        }
        self.init(identifier: argument)
    }
}


extension URL: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self = URL(filePath: argument, relativeTo: .currentDirectory()).absoluteURL
    }
}

#endif
