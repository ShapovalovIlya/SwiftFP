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
        .library(name: "SwiftFP", targets: ["SwiftFP"]),
    ],
    targets: [
        .target(name: "SwiftFP"),
        .testTarget(name: "SwiftFPTests", dependencies: ["SwiftFP"]),
    ]
)
