//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Algorithms
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros


/// The `@SynthesizeDisplayPropertyMacro` macro.
public struct SynthesizeDisplayPropertyMacro {}

extension SynthesizeDisplayPropertyMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let caseNames: [String] = try { () -> [String] in
            guard let argsList = node.arguments?.as(LabeledExprListSyntax.self) else {
                throw MacroExpansionErrorMessage("missing arguments?")
            }
            return try argsList.dropFirst().map { syntax in
                if let syntax = syntax.expression.as((MemberAccessExprSyntax.self)) {
                    return syntax.declName.baseName.text
                } else if let syntax = syntax.expression.as(StringLiteralExprSyntax.self) {
                    return try syntax.segments.reduce(into: "") { partialResult, segment in
                        switch segment {
                        case .stringSegment(let segment):
                            partialResult.append(contentsOf: segment.content.text)
                        case .expressionSegment:
                            throw MacroExpansionErrorMessage("Argument String isn't allowed to contain interpolations!")
                        }
                    }
                } else {
                    throw MacroExpansionErrorMessage("Arhument must be an enum case expression!")
                }
            }
        }()
        let displayProperty = try VariableDeclSyntax("var display: String?") {
            SwitchExprSyntax(subject: "self" as ExprSyntax) {
                for name in caseNames {
                    .switchCase(SwitchCaseSyntax("case .\(raw: name):") {
                        #""\#(raw: displayText(for: name))""#
                    })
                }
                SwitchCaseListSyntax.Element.switchCase(SwitchCaseSyntax("@unknown default:") {
                    "nil" as ExprSyntax
                })
            }
        }
        return [DeclSyntax(fromProtocol: displayProperty)]
    }
    
    private static func displayText(for enumCaseName: String) -> String {
        let separatorIndices: [String.Index] = enumCaseName.indices.adjacentPairs().compactMap { lhsIdx, rhsIdx in
            enumCaseName[lhsIdx].isLowercase && enumCaseName[rhsIdx].isUppercase ? rhsIdx : nil
        }
        guard !separatorIndices.isEmpty else {
            return enumCaseName
        }
        let components = chain(CollectionOfOne(enumCaseName.startIndex), chain(separatorIndices, CollectionOfOne(enumCaseName.endIndex)))
            .adjacentPairs().map { enumCaseName[$0..<$1] }
        return components
            .map { component -> String in
                if component.allSatisfy(\.isUppercase) {
                    // eg: we want "asleepREM" to become "asleep REM", i.e. the "REM" part should remain uppercase
                    String(component)
                } else if component.allSatisfy(\.isLowercase) {
                    component.lowercased()
                } else {
                    String(component.lowercased())
                }
            }
            .joined(separator: " ")
    }
}
