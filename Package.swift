// swift-tools-version:6.2

//
// This source file is part of the Stanford Spezi open-source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import CompilerPluginSupport
import class Foundation.ProcessInfo
import PackageDescription


let enableSwiftLintPlugin = false

var package = Package(
    name: "SpeziHealthKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v14),
        .macCatalyst(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "SpeziHealthKit", targets: ["SpeziHealthKit"]),
        .library(name: "SpeziHealthKitBulkExport", targets: ["SpeziHealthKitBulkExport"]),
        .library(name: "SpeziHealthKitUI", targets: ["SpeziHealthKitUI"]),
        .library(name: "SpeziHealthKitFHIR", targets: ["SpeziHealthKitFHIR"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/Spezi.git", from: "1.10.0"),
        .package(url: "https://github.com/StanfordSpezi/SpeziFoundation.git", from: "2.7.5"),
        .package(url: "https://github.com/StanfordSpezi/SpeziStorage.git", from: "2.1.4"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.1"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.1.3"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.17.7"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
        
//        .package(url: "https://github.com/apple/FHIRModels.git", "0.8.0"..<"0.9.0"),
//        .package(url: "https://github.com/StanfordSpezi/SpeziFHIR.git", branch: "lukas/movin-and-shakin"),
        .package(url: "https://github.com/lukaskollmer/FHIRModels.git", branch: "lukas/try-to-fix"),
        .package(path: "../SpeziFHIR"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "602.0.0"..<"605.0.0")
    ] + swiftLintPackage,
    targets: [
        .target(
            name: "SpeziHealthKit",
            dependencies: [
                .product(name: "Spezi", package: "Spezi"),
                .product(name: "SpeziFoundation", package: "SpeziFoundation"),
                .product(
                    name: "SpeziLocalStorage",
                    package: "SpeziStorage",
                    condition: .when(platforms: [.macOS, .macCatalyst, .iOS, .tvOS, .watchOS, .visionOS])
                ),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ],
            exclude: [
                "Sample Types/SampleTypeDefs.py",
                "Sample Types/SampleTypes.swift.gyb"
            ],
            resources: [
                // NOTE: the SpeziHealthKit target intentionally does not contain any xcstrings files,
                // since these would, when building with `swift build` instead of `xcodebuild`, conflict
                // with the lproj folders we have for the sample type display title localizations.
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin
        ),
        .target(
            name: "SpeziHealthKitBulkExport",
            dependencies: [
                "SpeziHealthKit",
                .product(name: "SpeziFoundation", package: "SpeziFoundation"),
                .product(
                    name: "SpeziLocalStorage",
                    package: "SpeziStorage",
                    condition: .when(platforms: [.macOS, .macCatalyst, .iOS, .tvOS, .watchOS, .visionOS])
                )
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin
        ),
        .target(
            name: "SpeziHealthKitUI",
            dependencies: [
                "SpeziHealthKit",
                .product(name: "SpeziFoundation", package: "SpeziFoundation")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin
        ),
        .testTarget(
            name: "SpeziHealthKitTests",
            dependencies: [
                "SpeziHealthKit",
                "SpeziHealthKitBulkExport",
                "SpeziHealthKitUI",
                .product(name: "XCTSpezi", package: "Spezi"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            resources: [.process("__Snapshots__")],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
            plugins: [] + swiftLintPlugin
        ),
        .macro(
            name: "SpeziHealthKitFHIRMacrosImpl",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
            plugins: [] + swiftLintPlugin
        ),
        .target(
            name: "SpeziHealthKitFHIRMacros",
            dependencies: [
                .target(name: "SpeziHealthKitFHIRMacrosImpl")
            ],
            plugins: [] + swiftLintPlugin
        ),
        .target(
            name: "SpeziHealthKitFHIR",
            dependencies: [
                "SpeziHealthKitFHIRMacros",
                "SpeziHealthKit",
                .product(name: "SpeziFoundation", package: "SpeziFoundation"),
                .product(name: "SpeziFHIR", package: "SpeziFHIR"),
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "ModelsDSTU2", package: "FHIRModels"),
                .product(name: "FHIRModelsExtensions", package: "SpeziFHIR")
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
            plugins: [] + swiftLintPlugin
        ),
        .testTarget(
            name: "SpeziHealthKitFHIRTests",
            dependencies: [
                .target(name: "SpeziHealthKitFHIR"),
                .product(name: "SpeziFoundation", package: "SpeziFoundation")
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
            plugins: [] + swiftLintPlugin
        ),
        .testTarget(
            name: "SpeziHealthKitFHIRMacrosTests",
            dependencies: [
                .target(name: "SpeziHealthKitFHIRMacros"),
                .target(name: "SpeziHealthKitFHIRMacrosImpl"),
                .product(name: "FHIRModelsExtensions", package: "SpeziFHIR"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ],
            plugins: [] + swiftLintPlugin
        )
    ]
)

#if canImport(HealthKit)
package.targets += [
    .executableTarget(
        name: "LocalizationsProcessor",
        dependencies: [
            .target(name: "SpeziHealthKit"),
            .product(name: "ArgumentParser", package: "swift-argument-parser")
        ]
    ),
    .executableTarget(
        name: "Codegen",
        dependencies: [
            .target(name: "SpeziHealthKit"),
            .product(name: "ArgumentParser", package: "swift-argument-parser")
        ],
        exclude: ["HKTypeIdentifierDefs+Linux.swift.gyb"]
    )
]
#endif


// MARK: SwiftLint support

var swiftLintPlugin: [Target.PluginUsage] {
    if enableSwiftLintPlugin {
        [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
    } else {
        []
    }
}

var swiftLintPackage: [PackageDescription.Package.Dependency] {
    if enableSwiftLintPlugin {
        [.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins.git", from: "0.63.2")]
    } else {
        []
    }
}
