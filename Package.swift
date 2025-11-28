// swift-tools-version:6.0

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


let package = Package(
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
        .library(name: "SpeziHealthKitUI", targets: ["SpeziHealthKitUI"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/Spezi.git", from: "1.8.2"),
        .package(url: "https://github.com/StanfordSpezi/SpeziFoundation.git", from: "2.5.2"),
        .package(url: "https://github.com/StanfordSpezi/SpeziStorage.git", from: "2.1.1"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.1"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.17.7"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1")
    ] + swiftLintPackage(),
    targets: [
        .target(
            name: "SpeziHealthKit",
            dependencies: [
                .product(name: "Spezi", package: "Spezi"),
                .product(name: "SpeziFoundation", package: "SpeziFoundation"),
                .product(name: "SpeziLocalStorage", package: "SpeziStorage"),
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            exclude: ["Sample Types/SampleTypes.swift.gyb"],
            resources: [.process("Resources")],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .target(
            name: "SpeziHealthKitBulkExport",
            dependencies: [
                .target(name: "SpeziHealthKit"),
                .product(name: "SpeziFoundation", package: "SpeziFoundation"),
                .product(name: "SpeziLocalStorage", package: "SpeziStorage")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .target(
            name: "SpeziHealthKitUI",
            dependencies: [
                .target(name: "SpeziHealthKit"),
                .product(name: "SpeziFoundation", package: "SpeziFoundation")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .testTarget(
            name: "SpeziHealthKitTests",
            dependencies: [
                .product(name: "XCTSpezi", package: "Spezi"),
                .target(name: "SpeziHealthKit"),
                .target(name: "SpeziHealthKitBulkExport"),
                .target(name: "SpeziHealthKitUI"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            resources: [.process("__Snapshots__")],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
            plugins: [] + swiftLintPlugin()
        ),
        .executableTarget(
            name: "LocalizationsProcessor",
            dependencies: [
                .target(name: "SpeziHealthKit"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)


func swiftLintPlugin() -> [Target.PluginUsage] {
    // Fully quit Xcode and open again with `open --env SPEZI_DEVELOPMENT_SWIFTLINT /Applications/Xcode.app`
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
    } else {
        []
    }
}

func swiftLintPackage() -> [PackageDescription.Package.Dependency] {
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.package(url: "https://github.com/realm/SwiftLint.git", from: "0.55.1")]
    } else {
        []
    }
}
