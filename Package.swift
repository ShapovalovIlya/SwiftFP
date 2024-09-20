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
        .library(
            name: "SwiftFP",
            targets: [
                "SwiftFP",
                "Either",
                "Monad"
            ]
        ),
        .library(name: "Either", targets: ["Either"]),
        .library(name: "Monad", targets: ["Monad"]),
    ],
    targets: [
        .target(name: "SwiftFP"),
        .target(name: "Either"),
        .target(name: "Monad"),
        .testTarget(
            name: "SwiftFPTests",
            dependencies: [
                "SwiftFP",
                "Either",
                "Monad"
            ]
        ),
    ]
)
