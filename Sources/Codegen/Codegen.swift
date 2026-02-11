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


@main
struct Codegen: ParsableCommand {
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
            Output directory path. Should point to 'Sources/SpeziHealthKit/Sample Types/Linux/HKTypeIdentifiers+Linux.swift'.
            May be omitted to perform a dry run, in which case the resulting translation mappings will be printed to stdout, but not written to disk.
            """
    )
    var outputUrl: URL?
    
    
    func run() throws {
        guard #available(macOS 15, *) else {
            print("Must be run on macOS 15+")
            Foundation.exit(EXIT_FAILURE)
        }
        let file = makeIdentifierDefsFile()
        if let outputUrl {
            try Data(file.utf8).write(to: outputUrl)
        } else {
            print(file)
        }
    }
    
    
    @available(macOS 15, *)
    private func makeIdentifierDefsFile() -> String {
        let staticPropertiesByStructName = _SampleTypeIdentifierDefinition.definitions
            .reduce(into: [:] as [String: [_SampleTypeIdentifierDefinition.IdentifierConstDef]]) { partialResult, element in
                switch element {
                case ._globalVariable:
                    return
                case let ._staticProperty(parentStruct, definition):
                    partialResult[parentStruct, default: []].append(definition)
                }
            }
        
        var file = IdentifierDefinitionsFile()
        for (structName, defs) in staticPropertiesByStructName {
            file.defineStruct(name: structName, staticProperties: defs)
        }
        // IDEA instead of having this in here, handle it via the gyb file!
        if staticPropertiesByStructName["HKDocumentTypeIdentifier"] == nil {
            file.defineStruct(name: "HKDocumentTypeIdentifier", staticProperties: [
                .init(
                    identifierName: "CDA",
                    rawValue: HKDocumentTypeIdentifier.CDA.rawValue,
                    docComment: "The CDA Document type identifier, used when requesting permission to read or share CDA documents."
                )
            ])
        }
        
        for definition in _SampleTypeIdentifierDefinition.definitions {
            switch definition {
            case ._staticProperty:
                break
            case ._globalVariable(let definition):
                file.defineGlobalVariable(definition)
            }
        }
        file.defineGlobalVariable(.init(
            identifierName: "HKActivitySummaryTypeIdentifier",
            rawValue: HKObjectType.activitySummaryType().identifier,
            docComment: ""
        ))
        return file.finalize()
    }
}


private struct IdentifierDefinitionsFile: ~Copyable {
    typealias VariableDef = _SampleTypeIdentifierDefinition.IdentifierConstDef
    
    private var contents = """
        //
        // This source file is part of the Stanford Spezi open-source project
        //
        // SPDX-FileCopyrightText: \(Calendar.current.component(.year, from: .now)) Stanford University and the project authors (see CONTRIBUTORS.md)
        //
        // SPDX-License-Identifier: MIT
        //
        
        // THIS FILE IS AUTO-GENERATED! DO NOT EDIT!!!
        // swiftlint:disable all
        
        #if !canImport(HealthKit)
        
        """
    
    private var currentIndent: Int {
        guard let lineBreakIdx = contents.lastIndex(where: \.isNewline) else {
            return 0
        }
        if contents.index(after: lineBreakIdx) == contents.endIndex {
            guard let lineStartIdx = contents[..<lineBreakIdx].lastIndex(where: \.isNewline) else {
                fatalError("hmmm")
            }
            let line = contents[contents.index(after: lineStartIdx)..<lineBreakIdx]
            return line.prefix { $0 == " " }.count
        } else {
            return contents.distance(from: lineBreakIdx, to: contents.endIndex)
        }
    }
    
    consuming func finalize() -> String {
        contents += "\n\n#endif // !canImport(HealthKit)\n"
        return contents
    }
    
    mutating func defineStruct(name: String, staticProperties: [VariableDef]) {
        contents += "\n"
        contents += """
            public struct \(name): Hashable, RawRepresentable, Sendable {
                public let rawValue: String
                public init(rawValue: String) {
                    self.rawValue = rawValue
                }
            """
        contents += "\n"
        for definition in staticProperties {
            writeDocComment(definition.docComment)
            contents += "    public static let \(definition.identifierName) = Self(rawValue: \"\(definition.rawValue)\")\n"
        }
        contents += "}\n\n"
    }
    
    mutating func defineGlobalVariable(_ definition: VariableDef) {
        writeDocComment(definition.docComment)
        contents += "\npublic let \(definition.identifierName) = \"\(definition.rawValue)\"\n"
    }
    
    private mutating func writeDocComment(_ text: String) {
//        for line in text.split(whereSeparator: \.isNewline) {
//            contents += "\n\(String(repeating: " ", count: currentIndent))/// \(line)"
//        }
    }
}


extension URL: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self = URL(filePath: argument, relativeTo: .currentDirectory()).absoluteURL
    }
}

#endif
