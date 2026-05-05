// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Verity",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "VerityCore", targets: ["VerityCore"]),
        .executable(name: "Verity", targets: ["Verity"])
    ],
    targets: [
        .target(
            name: "VerityCore",
            path: "Sources/VerityCore"
        ),
        .executableTarget(
            name: "Verity",
            dependencies: ["VerityCore"],
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
