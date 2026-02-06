// swift-tools-version: 6.0
import PackageDescription

var packageDependencies: [Package.Dependency] = []
#if !os(Windows)
// Swift-DocC is a development-time plugin dependency. It may not be available on all hosts.
packageDependencies.append(.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.0"))
#endif

let package = Package(
    name: "Helix",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "Helix", targets: ["Helix"]),
    ],
    dependencies: packageDependencies,
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
