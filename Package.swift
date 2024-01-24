// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftFP",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13)
    ],
    products: [
        .library(name: "SwiftFP", targets: ["SwiftFP"]),
    ],
    targets: [
        .target(name: "SwiftFP"),
        .testTarget(name: "SwiftFPTests", dependencies: ["SwiftFP"]),
    ]
)
