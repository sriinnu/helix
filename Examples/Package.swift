// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HelixExamples",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .custom("linux", versionString: "0"),
        .custom("windows", versionString: "10"),
        .custom("wasi", versionString: "0"),
    ],
    dependencies: [
        .package(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "Hello",
            dependencies: ["Helix"],
            path: "Sources/HelixExamples",
            exclude: ["Files.swift", "Environment.swift", "Subcommands.swift"],
            sources: ["Hello.swift"]
        ),
        .executableTarget(
            name: "Files",
            dependencies: ["Helix"],
            path: "Sources/HelixExamples",
            exclude: ["Hello.swift", "Environment.swift", "Subcommands.swift"],
            sources: ["Files.swift"]
        ),
        .executableTarget(
            name: "Tool",
            dependencies: ["Helix"],
            path: "Sources/HelixExamples",
            exclude: ["Hello.swift", "Environment.swift", "Files.swift"],
            sources: ["Subcommands.swift"]
        ),
        .executableTarget(
            name: "Config",
            dependencies: ["Helix"],
            path: "Sources/HelixExamples",
            exclude: ["Hello.swift", "Files.swift", "Subcommands.swift"],
            sources: ["Environment.swift"]
        ),
    ]
)
