// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftFP",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "Either", targets: ["Either"]),
        .library(name: "Monad", targets: ["Monad"]),
        .library(name: "NotEmptyArray", targets: ["NotEmptyArray"]),
        .library(name: "Validated", targets: ["Validated"]),
        .library(
            name: "SwiftFP",
            targets: [
                "SwiftFP",
                "Either",
                "Monad",
                "NotEmptyArray",
                "Validated"
            ]
        ),
    ],
    targets: [
        .target(
            name: "SwiftFP",
            dependencies: [
                "Either",
                "Monad",
                "NotEmptyArray",
                "Validated"
            ]
        ),
        .target(name: "Either"),
        .target(name: "Monad"),
        .target(name: "NotEmptyArray"),
        .target(name: "Validated", dependencies: ["NotEmptyArray"]),
        .testTarget(
            name: "SwiftFPTests",
            dependencies: ["SwiftFP"]
        ),
    ]
)
