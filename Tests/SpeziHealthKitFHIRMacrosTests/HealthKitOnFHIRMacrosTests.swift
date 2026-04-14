//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if os(macOS) // macro tests can only be run on the host machine
import HealthKit
import SpeziHealthKitFHIRMacros
import SpeziHealthKitFHIRMacrosImpl
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing

let testMacrosSpecs: [String: MacroSpec] = [
    "SynthesizeDisplayProperty": MacroSpec(type: SynthesizeDisplayPropertyMacro.self)
]

@Suite
struct HealthKitOnFHIRMacrosTests {
    @Test
    func macro0() {
        assertMacroExpansion(
            """
            @SynthesizeDisplayProperty(
                HKCategoryValueSleepAnalysis.self,
                .inBed, .asleepUnspecified, .awake, .asleepCore, .asleepDeep, .asleepREM
            )
            extension HKCategoryValueSleepAnalysis: FHIRCodingConvertibleHKEnum {}
            """,
            expandedSource:
            """
            extension HKCategoryValueSleepAnalysis: FHIRCodingConvertibleHKEnum {
            
                var display: String? {
                    switch self {
                    case .inBed:
                        "in bed"
                    case .asleepUnspecified:
                        "asleep unspecified"
                    case .awake:
                        "awake"
                    case .asleepCore:
                        "asleep core"
                    case .asleepDeep:
                        "asleep deep"
                    case .asleepREM:
                        "asleep REM"
                    @unknown default:
                        nil
                    }
                }
            }
            """,
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }
    
    @Test
    func macro1() {
        assertMacroExpansion(
            """
            @SynthesizeDisplayProperty(
                HKCategoryValueSleepAnalysis.self,
                .inBed, .asleepUnspecified, .awake, .asleepCore, .asleepDeep, .asleepREM
            )
            @available(iOS 18.0, macOS 15.0, watchOS 11.0, *)
            extension HKCategoryValueSleepAnalysis: FHIRCodingConvertibleHKEnum {}
            """,
            expandedSource:
            """
            @available(iOS 18.0, macOS 15.0, watchOS 11.0, *)
            extension HKCategoryValueSleepAnalysis: FHIRCodingConvertibleHKEnum {
            
                var display: String? {
                    switch self {
                    case .inBed:
                        "in bed"
                    case .asleepUnspecified:
                        "asleep unspecified"
                    case .awake:
                        "awake"
                    case .asleepCore:
                        "asleep core"
                    case .asleepDeep:
                        "asleep deep"
                    case .asleepREM:
                        "asleep REM"
                    @unknown default:
                        nil
                    }
                }
            }
            """,
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }
    
    @Test
    func macro2() {
        assertMacroExpansion(
            """
            @SynthesizeDisplayProperty(
                HKCategoryValueSleepAnalysis.self,
                .inBed, .asleepUnspecified, .awake, .asleepCore,
                additionalCases: "asleepDeep", "asleepREM"
            )
            extension HKCategoryValueSleepAnalysis: FHIRCodingConvertibleHKEnum {}
            """,
            expandedSource:
            """
            extension HKCategoryValueSleepAnalysis: FHIRCodingConvertibleHKEnum {
            
                var display: String? {
                    switch self {
                    case .inBed:
                        "in bed"
                    case .asleepUnspecified:
                        "asleep unspecified"
                    case .awake:
                        "awake"
                    case .asleepCore:
                        "asleep core"
                    case .asleepDeep:
                        "asleep deep"
                    case .asleepREM:
                        "asleep REM"
                    @unknown default:
                        nil
                    }
                }
            }
            """,
            macroSpecs: testMacrosSpecs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }
}
#endif
