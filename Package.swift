// swift-tools-version:5.7

//
// This source file is part of the Stanford Spezi open-source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "SpeziHealthKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "SpeziHealthKit", targets: ["SpeziHealthKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/Spezi", .upToNextMinor(from: "0.7.0"))
    ],
    targets: [
        .target(
            name: "SpeziHealthKit",
            dependencies: [
                .product(name: "Spezi", package: "Spezi")
            ]
        ),
        .testTarget(
            name: "SpeziHealthKitTests",
            dependencies: [
                .product(name: "XCTSpezi", package: "Spezi"),
                .target(name: "SpeziHealthKit")
            ]
        )
    ]
)
