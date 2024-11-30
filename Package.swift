// swift-tools-version: 5.8
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
        .library(name: "Zipper", targets: ["Zipper"]),
        .library(name: "Readers", targets: ["Readers"]),
        .library(name: "Effects", targets: ["Effects"]),
        .library(
            name: "SwiftFP",
            targets: [
                "SwiftFP",
                "Either",
                "Monad",
                "NotEmptyArray",
                "Validated",
                "Zipper",
                "Readers",
                "Effects"
            ]
        ),
    ],
    targets: [
        .target(
            name: "Either",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "Monad",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "NotEmptyArray",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(name: "Zipper"),
        .target(name: "Readers"),
        .target(name: "Effects"),
        .target(
            name: "SwiftFP",
            dependencies: [
                "Either",
                "Monad",
                "NotEmptyArray",
                "Validated",
                "Zipper",
                "Readers",
                "Effects"
            ]
        ),
        .target(
            name: "Validated",
            dependencies: [
                "NotEmptyArray"
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SwiftFPTests",
            dependencies: ["SwiftFP"]
        ),
    ]
)
