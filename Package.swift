// swift-tools-version: 6.0
//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2025 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
    name: "swift-ntp",
    products: [
        .library(name: "NTPClient", targets: ["NTPClient"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.81.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "NTP",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio")
            ],
            swiftSettings: [
                .enableUpcomingFeature("InternalImportsByDefault")
            ]
        ),
        .target(
            name: "NTPClient",
            dependencies: [
                .target(name: "NTP"),
                .product(name: "NIOPosix", package: "swift-nio"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("InternalImportsByDefault")
            ]
        ),
        .testTarget(
            name: "NTPTests",
            dependencies: [
                .target(name: "NTP")
            ]
        ),
        .testTarget(
            name: "NTPClientTests",
            dependencies: [
                .target(name: "NTPClient")
            ]
        ),
    ]
)
