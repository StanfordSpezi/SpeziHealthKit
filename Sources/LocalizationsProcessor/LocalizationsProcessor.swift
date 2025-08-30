//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import ArgumentParser
import Foundation
import SpeziHealthKit


private let allObjectTypes: [HKObjectType] = {
    var types: [HKObjectType] = SampleType<HKQuantitySample>.otherSampleTypes.map { $0.hkSampleType }
    for objectType in HKObjectType.allKnownObjectTypes {
        types.append(objectType)
    }
    return types.sorted { $0.identifier < $1.identifier }
}()


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
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            abstract: "Generate localized string catalogues for HealthKit data types",
            version: "0.1.0"
        )
    }
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
//        for ident in HKCharacteristicTypeIdentifier.allKnownIdentifiers {
//            let type = HKCharacteristicType(ident)
//            print(type.value(forKey: "hk_localizedName") as? String)
//        }
//        fatalError()
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
    private let mergedLoctables: [Locale: [String: [LocalizationEntry]]]
    
    init() throws { // swiftlint:disable:this function_body_length
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
