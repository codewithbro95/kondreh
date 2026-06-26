// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Kondreh",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Kondreh", targets: ["KondrehApp"]),
        .library(name: "KondrehCore", targets: ["KondrehCore"])
    ],
    targets: [
        .target(
            name: "KondrehCore",
            path: "Sources/KondrehCore"
        ),
        .executableTarget(
            name: "KondrehApp",
            dependencies: ["KondrehCore"],
            path: "Sources/KondrehApp",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .define("DEVELOPMENT_LICENSE_PROVIDER")
            ]
        ),
        .testTarget(
            name: "KondrehCoreTests",
            dependencies: ["KondrehCore"],
            path: "Tests/KondrehCoreTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
