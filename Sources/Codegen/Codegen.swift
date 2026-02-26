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
            abstract: "Generates HealthKit sample type identifier constants for use on Linux",
            discussion: """
                The purpose of this tool is to generate the Sources/SpeziHealthKit/Sample Types/Linux/HKTypeIdentifiers+Linux.swift file,
                which provides HealthKit-related identifier definitions (like e.g. HKQuantityTypeIdentifier) on Linux, where HealthKit is
                not available.
                This allows `SampleType` and related APIs to be accessible on Linux.
                
                Q: Why is this a separate CLI tool, instead of simply generating the file via gyb? (Which seems to already be happening anyway?)
                A: The issue is that the list of all sample types (and the names of their identifiers) is available in the gyb file,
                   but the gyb file cannot fetch a sample type's corresponding identifier value (because it would need to evaluate Swift code
                   like e.g. `HKQuantityTyeIdentifier.${sample_type.identifier}.rawValue` for that, which it cannot).
                   So what we need to do instead, is that we use gyb to generate an intermediate file, which contains a Swift array listing
                   all sample type identifier properties and variables, consisting each of the raw name of the property/variable,
                   and also (as a Swift expression, so that we can access the actual value when processing all of this) the underlying identifier
                   raw value.
                   This tool then processes the sample type identifier properties/variables in this array, and generates the actual Swift file
                   containing the fully resolved definitions, for use on Linux. 
                """,
            version: "0.1.0"
        )
    }
    
    @Option(
        name: .customShort("o"),
        help: """
            Output directory path. Should point to 'Sources/SpeziHealthKit/Sample Types/Linux/HKTypeIdentifiers+Linux.swift'.
            May be omitted to perform a dry run, in which case the resulting file will be printed to stdout, but not written to disk.
            """
    )
    var outputUrl: URL?
    
    
    func run() throws {
        guard #available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2, *) else {
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
    
    
    @available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2, *)
    private func makeIdentifierDefsFile() -> String {
        let allDefinitions = SampleTypeIdentifierDefinition.definitions
        let staticPropertiesByStructName = allDefinitions
            .reduce(into: [:] as [String: [SampleTypeIdentifierDefinition.IdentifierConstDef]]) { partialResult, element in
                switch element {
                case .globalVariable:
                    return
                case let .staticProperty(parentStruct, definition):
                    partialResult[parentStruct, default: []].append(definition)
                }
            }
        
        var file = IdentifierDefinitionsFile()
        for (structName, defs) in staticPropertiesByStructName.sorted(using: KeyPathComparator(\.key)) {
            file.defineStruct(
                name: structName,
                staticProperties: defs.sorted(using: KeyPathComparator(\.identifierName))
            )
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
        
        var globalVariables = allDefinitions.compactMap { definition -> SampleTypeIdentifierDefinition.IdentifierConstDef? in
            switch definition {
            case .staticProperty:
                nil
            case .globalVariable(let definition):
                definition
            }
        }
        if !globalVariables.contains(where: { $0.identifierName == "HKActivitySummaryTypeIdentifier" }) {
            globalVariables.append(.init(
                identifierName: "HKActivitySummaryTypeIdentifier",
                rawValue: HKObjectType.activitySummaryType().identifier,
                docComment: ""
            ))
        }
        
        for definition in globalVariables.sorted(using: KeyPathComparator(\.identifierName)) {
            file.defineGlobalVariable(definition)
        }
        return file.finalize()
    }
}


private struct IdentifierDefinitionsFile: ~Copyable {
    typealias VariableDef = SampleTypeIdentifierDefinition.IdentifierConstDef
    
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
        contents += "public let \(definition.identifierName) = \"\(definition.rawValue)\"\n"
    }
    
    private mutating func writeDocComment(_ text: String) {
        let indent = currentIndent
        contents += "\n"
        for line in text.split(whereSeparator: \.isNewline) {
            contents += "\(String(repeating: " ", count: indent))/// \(line)\n"
        }
    }
}


extension URL: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self = URL(filePath: argument, relativeTo: .currentDirectory()).absoluteURL
    }
}

#endif
