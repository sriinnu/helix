// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Helix",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
        .linux,
        .windows(.v10),
    ],
    products: [
        .library(name: "Helix", targets: ["Helix"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.0"),
    ],
    targets: [
        .target(
            name: "Helix",
            path: "Sources/Helix",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "HelixTests",
            dependencies: ["Helix"],
            path: "Tests/HelixTests"),
    ],
    swiftLanguageModes: [.v6])
