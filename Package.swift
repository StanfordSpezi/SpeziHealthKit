// swift-tools-version:5.7

//
// This source file is part of the CardinalKit open-source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "CardinalKitHealthKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "CardinalKitHealthKit", targets: ["CardinalKitHealthKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordBDHG/CardinalKit", .upToNextMinor(from: "0.4.1"))
    ],
    targets: [
        .target(
            name: "CardinalKitHealthKit",
            dependencies: [
                .product(name: "CardinalKit", package: "CardinalKit")
            ]
        ),
        .testTarget(
            name: "CardinalKitHealthKitTests",
            dependencies: [
                .target(name: "CardinalKitHealthKit")
            ]
        )
    ]
)
