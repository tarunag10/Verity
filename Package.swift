// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Verity",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "VerityCore", targets: ["VerityCore"]),
        .library(name: "VerityMLX", targets: ["VerityMLX"]),
        .executable(name: "Verity", targets: ["Verity"])
    ],
    dependencies: [
        .package(url: "https://github.com/ml-explore/mlx-swift.git", .upToNextMinor(from: "0.31.3")),
        .package(url: "https://github.com/ml-explore/mlx-swift-lm.git", from: "3.31.3"),
        .package(url: "https://github.com/DePasqualeOrg/swift-tokenizers-mlx.git", from: "0.1.0"),
        .package(url: "https://github.com/DePasqualeOrg/swift-hf-api-mlx.git", from: "0.1.0"),
        .package(url: "https://github.com/DePasqualeOrg/swift-jinja.git", "0.2.0"..<"0.3.0"),
        .package(url: "https://github.com/ibireme/yyjson.git", exact: "0.12.0")
    ],
    targets: [
        .target(
            name: "VerityCore",
            path: "Sources/VerityCore"
        ),
        .target(
            name: "VerityMLX",
            dependencies: [
                "VerityCore",
                .product(name: "MLX", package: "mlx-swift"),
                .product(name: "MLXEmbedders", package: "mlx-swift-lm"),
                .product(name: "MLXLLM", package: "mlx-swift-lm"),
                .product(name: "MLXLMCommon", package: "mlx-swift-lm"),
                .product(name: "MLXEmbeddersHFAPI", package: "swift-hf-api-mlx"),
                .product(name: "MLXLMHFAPI", package: "swift-hf-api-mlx"),
                .product(name: "MLXEmbeddersTokenizers", package: "swift-tokenizers-mlx"),
                .product(name: "MLXLMTokenizers", package: "swift-tokenizers-mlx")
            ],
            path: "Sources/VerityMLX"
        ),
        .executableTarget(
            name: "Verity",
            dependencies: ["VerityCore", "VerityMLX"],
            path: "Sources/Verity"
        ),
        .testTarget(
            name: "VerityCoreTests",
            dependencies: ["VerityCore"],
            path: "Tests/VerityCoreTests"
        )
    ],
    swiftLanguageModes: [.v6]
)
