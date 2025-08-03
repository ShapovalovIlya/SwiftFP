// swift-tools-version: 5.8
// swift-tools-version: 6.0
// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

//MARK: - Package
let package = Package(
    name: "SwiftFP",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        Submodule.Either.product,
        Submodule.Monad.product,
        Submodule.NotEmptyArray.product,
        Submodule.Validated.product,
        Submodule.Zipper.product,
        Submodule.Readers.product,
        Submodule.Effects.product,
        Submodule.FoundationFX.product,
        Submodule.State.product,
        Submodule.Future.product,
        .library(
            name: "SwiftFP",
            targets: [
                "SwiftFP",
                Submodule.Either.name,
                Submodule.Monad.name,
                Submodule.NotEmptyArray.name,
                Submodule.Validated.name,
                Submodule.Zipper.name,
                Submodule.Readers.name,
                Submodule.Effects.name,
                Submodule.State.name,
                Submodule.Future.name,
                Submodule.FoundationFX.name
            ]
        ),
    ],
    targets: [
        Submodule.Either.target,
        Submodule.Monad.target,
        Submodule.NotEmptyArray.target,
        Submodule.Zipper.target,
        Submodule.Readers.target,
        Submodule.Effects.target,
        Submodule.Validated.target,
        Submodule.FoundationFX.target,
        Submodule.State.target,
        Submodule.Future.target,
        .target(
            name: "SwiftFP",
            dependencies: [
                Submodule.Either.asDependency,
                Submodule.Monad.asDependency,
                Submodule.NotEmptyArray.asDependency,
                Submodule.Validated.asDependency,
                Submodule.Zipper.asDependency,
                Submodule.Readers.asDependency,
                Submodule.Effects.asDependency,
                Submodule.FoundationFX.asDependency,
                Submodule.State.asDependency,
                Submodule.Future.asDependency,
            ]
        ),
        .testTarget(
            name: "SwiftFPTests",
            dependencies: ["SwiftFP"]
        ),
    ]
)

//MARK: - Submodule
fileprivate enum Submodule: String {
    case Either
    case Monad
    case NotEmptyArray
    case Validated
    case Zipper
    case Readers
    case Effects
    case FoundationFX
    case State
    case Future
    
    @inlinable var name: String { rawValue }
    
    @inlinable
    var asDependency: Target.Dependency {
        Target.Dependency(stringLiteral: name)
    }
    
    @inlinable
    var dependencies: [Target.Dependency] {
        switch self {
        case .Validated: [
            Submodule.NotEmptyArray.asDependency
        ]
        case .FoundationFX: [
            Submodule.Either.asDependency
        ]
        default: []
        }
    }
    
    @inlinable
    var swiftSettings: [SwiftSetting] {
        [
            .enableExperimentalFeature("StrictConcurrency"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances")
        ]
    }
    
    @inlinable
    var target: Target {
        Target.target(
            name: name,
            dependencies: dependencies,
            swiftSettings: swiftSettings
        )
    }
    
    @inlinable
    var product: Product { .library(name: name, targets: [name]) }
}
