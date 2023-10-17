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
    dependencies: [
        .package(url: "https://github.com/ShapovalovIlya/PropertyWrappers.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "SwiftFP",
            dependencies: [
                .product(name: "PropertyWrappers", package: "PropertyWrappers"),
            ]),
        .testTarget(
            name: "SwiftFPTests",
            dependencies: ["SwiftFP"]),
    ]
)
