// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HelixExamples",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    dependencies: [
        .path(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "Hello",
            dependencies: ["Helix"],
            sources: ["Sources/HelixExamples/Hello.swift"]
        ),
        .executableTarget(
            name: "Files",
            dependencies: ["Helix"],
            sources: ["Sources/HelixExamples/Files.swift"]
        ),
        .executableTarget(
            name: "Tool",
            dependencies: ["Helix"],
            sources: ["Sources/HelixExamples/Subcommands.swift"]
        ),
        .executableTarget(
            name: "Config",
            dependencies: ["Helix"],
            sources: ["Sources/HelixExamples/Environment.swift"]
        ),
    ]
)
