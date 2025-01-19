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
        .library(name: "SpeziHealthKit", targets: ["SpeziHealthKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/Spezi.git", from: "1.8.0"),
        .package(url: "https://github.com/StanfordSpezi/SpeziFoundation.git", from: "2.1.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.17.7")
    ] + swiftLintPackage(),
    targets: [
        .target(
            name: "SpeziHealthKit",
            dependencies: [
                .product(name: "Spezi", package: "Spezi"),
                .product(name: "SpeziFoundation", package: "SpeziFoundation")
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
            plugins: [] + swiftLintPlugin()
        ),
        .testTarget(
            name: "SpeziHealthKitTests",
            dependencies: [
                .product(name: "XCTSpezi", package: "Spezi"),
                .target(name: "SpeziHealthKit"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
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
