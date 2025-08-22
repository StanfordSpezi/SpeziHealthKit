//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ArgumentParser
import Foundation
import SpeziHealthKit


enum CommandError: Error {
    case unableToFindLoctable
    case unableToDecodeLoctable(URL)
    case other(String)
}

@main
struct LocalizationsProcessor: ParsableCommand {
    
    @Flag(name: .short, help: "Enable extended logging")
    var verbose = false
    
    @Flag(name: .short)
    var alt = false
    
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
    
    mutating func run() throws {
        if verbose {
            print("\(self)")
        }
        if alt {
            let localizations = try Localizations()
            if verbose {
                localizations.debugDump()
            }
            for locale in locales {
                try process(locale: locale, using: localizations)
            }
        } else {
            let bundle = Bundle(for: HKHealthStore.self)
            guard let bundleResourceUrl = bundle.resourceURL else {
                throw CommandError.other("Unable to find bundle resource url")
            }
            let loctableUrls = ((try? FileManager.default.contents(of: bundleResourceUrl.absoluteURL.resolvingSymlinksInPath())) ?? [])
                .filter { $0.pathExtension == "loctable" }
            /// lang: [key: [value]]
            let loctable: [String: [String: Set<String>]] = try loctableUrls.reduce(into: [:]) { mergedTable, url in
                let data = try Data(contentsOf: url)
                guard let table = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: [String: Any]] else {
                    throw CommandError.unableToDecodeLoctable(url)
                }
                for (key, value) in table where key != "LocProvenance" {
                    for (key2, value2) in value {
                        guard let value2 = value2 as? String else {
                            continue
                        }
                        mergedTable[key, default: [:]][key2, default: []].insert(value2)
                    }
                }
            }
            guard let referenceLoctable = loctable[Locale.current.language.minimalIdentifier] else {
                throw CommandError.other("unable to find reference loctable")
            }
            let displayNameKeysByObjectType: [HKObjectType: String] = HKObjectType.allKnownObjectTypes.reduce(into: [:]) { keys, type in
                guard !keys.keys.contains(type) else {
                    return
                }
                if let displayName = type.value(forKey: "hk_localizedName") as? String {
                    let keysWithMatchingValues = referenceLoctable.keys.filter { referenceLoctable[$0]?.contains(displayName) == true }
                    keys[type] = keysWithMatchingValues.min { $0.count < $1.count }
                } else {
                    print(
                        "Unable to determine display name key for \(type.identifier).",
                        Swift.type(of: type)
                    )
                }
            }
            for locale in locales {
                try process(locale: locale, using: loctable, displayNameKeys: displayNameKeysByObjectType)
            }
        }
    }
    
    
    mutating private func process(locale: Locale, using loctable: [String: [String: Set<String>]], displayNameKeys: [HKObjectType: String]) throws {
        guard let loctable = loctable[locale.identifier] else {
            throw CommandError.other("unable to find loctable for locale \(locale)")
        }
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
        for objectType in HKObjectType.allKnownObjectTypes {
            guard let key = displayNameKeys[objectType] else {
                print("[\(locale)] Skipping \(objectType) (no key)")
                continue
            }
            guard let displayTitles = loctable[key], !displayTitles.isEmpty else {
                print("[\(locale)] Skipping \(objectType) (no entry)")
                continue
            }
            if let title = displayTitles.first, displayTitles.count == 1 {
                stringsFile.append(#""\#(objectType.identifier)" = "\#(title)";\#n"#)
            } else {
                print("Found multiple potential titles for \(objectType.identifier). Skipping. Potential titles: \(displayTitles)")
            }
        }
        if let outputUrl {
            let dstStringsUrl = outputUrl
                .appending(component: "\(locale.identifier).lproj", directoryHint: .isDirectory)
                .appending(component: "Localizable.strings", directoryHint: .notDirectory)
            try FileManager.default.createDirectory(at: dstStringsUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
            print("Writing title mappings for \(locale.identifier) to \(dstStringsUrl.path)")
            try Data(stringsFile.utf8).write(to: dstStringsUrl)
        } else {
            print("\n\n\(locale.identifier).lproj:\n\(stringsFile)")
        }
    }
    
    mutating private func process(locale: Locale, using localizations: Localizations) throws {
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
        for objectType in HKObjectType.allKnownObjectTypes {
            if let title = localizations[objectType, locale: locale] {
                stringsFile.append(#""\#(objectType.identifier)" = "\#(title)";\#n"#)
            } else {
                print("\(locale.language.minimalIdentifier) Unable to determine display title for \(objectType.identifier)")
            }
        }
        if let outputUrl {
            let dstStringsUrl = outputUrl
                .appending(component: "\(locale.identifier).lproj", directoryHint: .isDirectory)
                .appending(component: "Localizable.strings", directoryHint: .notDirectory)
            try FileManager.default.createDirectory(at: dstStringsUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
            print("Writing title mappings for \(locale.identifier) to \(dstStringsUrl.path)")
            try Data(stringsFile.utf8).write(to: dstStringsUrl)
        } else {
            print("\n\n\(locale.identifier).lproj:\n\(stringsFile)")
        }
    }
}


struct Localizations {
    private let displayNameKeys: [HKObjectType: String]
    private let mergedLoctables: [Locale: [String: Set<String>]]
//    private let customTranslations: [HKObjectType: [Locale]]
    
    init() throws {
        let bundle = Bundle(for: HKHealthStore.self)
        guard let bundleResourceUrl = bundle.resourceURL else {
            throw CommandError.other("Unable to find bundle resource url")
        }
        let loctableUrls = ((try? FileManager.default.contents(of: bundleResourceUrl.absoluteURL.resolvingSymlinksInPath())) ?? [])
            .filter { $0.pathExtension == "loctable" }
        /// lang: [key: [value]]
        mergedLoctables = try loctableUrls.reduce(into: [:]) { mergedTable, url in
            let data = try Data(contentsOf: url)
            guard let table = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: [String: Any]] else {
                throw CommandError.unableToDecodeLoctable(url)
            }
            for (key, value) in table where key != "LocProvenance" {
                let locale = Locale(identifier: key)
                for (key2, value2) in value {
                    guard let value2 = value2 as? String else {
                        continue
                    }
                    mergedTable[locale, default: [:]][key2, default: []].insert(value2)
                }
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
            HKClinicalType(.coverageRecord): "INSURANCE_RECORDS"
        ]
        displayNameKeys = HKObjectType.allKnownObjectTypes.reduce(into: hardcodedNameKeys) { keys, type in
            guard !keys.keys.contains(type) else {
                return
            }
            if let displayName = type.value(forKey: "hk_localizedName") as? String {
                let keysWithMatchingValues = referenceLoctable.keys.filter { referenceLoctable[$0]?.contains(displayName) == true }
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
        if let title = potentialTitles.first, potentialTitles.count == 1 {
            return title
        } else if potentialTitles.count > 1 {
            print("Found multiple potential titles for \(type.identifier). Skipping. Potential titles: \(potentialTitles)")
            return nil
        } else {
            return nil
        }
    }
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
