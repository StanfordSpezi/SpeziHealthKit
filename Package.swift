// swift-tools-version:6.0

//
// This source file is part of the Stanford Spezi open-source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import class Foundation.ProcessInfo
import PackageDescription


let package = Package(
    name: "SpeziHealthKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "SpeziHealthKit", targets: ["SpeziHealthKit", "SpeziHealthCharts"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/Spezi", from: "1.7.0")
    ] + swiftLintPackage(),
    targets: [
        .target(
            name: "SpeziHealthKit",
            dependencies: [
                .product(name: "Spezi", package: "Spezi")
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .target(
            name: "SpeziHealthCharts",
            dependencies: [
                .product(name: "Spezi", package: "Spezi")
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .testTarget(
            name: "SpeziHealthKitTests",
            dependencies: [
                .product(name: "XCTSpezi", package: "Spezi"),
                .target(name: "SpeziHealthKit")
            ],
            plugins: [] + swiftLintPlugin()
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
