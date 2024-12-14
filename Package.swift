// swift-tools-version: 5.8
// swift-tools-version: 6.0
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
                Submodule.Either.dependency,
                Submodule.Monad.dependency,
                Submodule.NotEmptyArray.dependency,
                Submodule.Validated.dependency,
                Submodule.Zipper.dependency,
                Submodule.Readers.dependency,
                Submodule.Effects.dependency,
                Submodule.FoundationFX.dependency,
                Submodule.State.dependency,
                Submodule.Future.dependency,
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
    
    @inlinable
    @inline(__always)
    var name: String { rawValue }
    
    @inlinable
    @inline(__always)
    var dependency: Target.Dependency { .init(stringLiteral: name) }
    
    @inlinable
    @inline(__always)
    var target: Target {
        switch self {
        case .Validated:
                .target(
                    name: name,
                    dependencies: [
                        Submodule.NotEmptyArray.dependency
                    ],
                    swiftSettings: [
                        .enableExperimentalFeature("StrictConcurrency")
                    ]
                )
        default:
                .target(
                    name: name,
                    swiftSettings: [
                        .enableExperimentalFeature("StrictConcurrency")
                    ]
                )
        }
    }
    
    @inlinable
    @inline(__always)
    var product: Product { .library(name: name, targets: [name]) }
}
