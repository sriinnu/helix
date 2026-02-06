import Helix

/// A command with subcommands demonstrating hierarchical CLI structure.
struct ToolCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: "tool",
            abstract: "A multi-purpose CLI tool",
            discussion: """
            This demonstrates subcommand support where:
            - A parent command delegates to child commands
            - Each subcommand can have its own options and arguments
            - Default subcommands can be configured
            """,
            subcommands: [
                InitCommand.self,
                BuildCommand.self,
                TestCommand.self,
                DeployCommand.self
            ],
            defaultSubcommand: BuildCommand.self
        )
    }

    mutating func run() async throws {
        print("Tool - use 'tool --help' to see available commands")
    }
}

// MARK: - Subcommand: Init

struct InitCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: "init",
            abstract: "Initialize a new project"
        )
    }

    @Option(name: .shortAndLong, help: "Project template")
    var template: String = "default"

    @Flag(name: .short('f'), help: "Force initialization (overwrite)")
    var force: Bool = false

    @Argument(help: "Project name")
    var name: String?

    mutating func run() async throws {
        let projectName = name ?? "my-project"
        print("Initializing \(projectName) with template '\(template)'")
        print("Force: \(force)")
    }
}

// MARK: - Subcommand: Build

struct BuildCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: "build",
            abstract: "Build the project"
        )
    }

    @Option(name: .shortAndLong, help: "Build configuration")
    var configuration: String = "debug"

    @Option(name: .short('p'), help: "Platform (macos, ios, linux)")
    var platform: String = "macos"

    @Flag(name: .short('v'), help: "Verbose build output")
    var verbose: Bool = false

    mutating func run() async throws {
        print("Building for \(platform) with \(configuration) configuration")
        print("Verbose: \(verbose)")
    }
}

// MARK: - Subcommand: Test

struct TestCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: "test",
            abstract: "Run tests"
        )
    }

    @Option(name: .shortAndLong, help: "Test filter")
    var filter: String?

    @Flag(name: .short('x'), help: "Fail fast (stop on first failure)")
    var failFast: Bool = false

    @Flag(name: .short('c'), help: "Collect code coverage")
    var coverage: Bool = false

    mutating func run() async throws {
        print("Running tests...")
        print("Filter: \(filter ?? "all")")
        print("Fail fast: \(failFast)")
        print("Coverage: \(coverage)")
    }
}

// MARK: - Subcommand: Deploy

struct DeployCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: "deploy",
            abstract: "Deploy the project"
        )
    }

    @Option(name: .shortAndLong, help: "Target environment")
    var environment: String = "staging"

    @Option(name: .short('t'), help: "Timeout in seconds")
    var timeout: Int = 300

    @Flag(name: .short('d'), help: "Dry run (no actual deployment)")
    var dryRun: Bool = false

    mutating func run() async throws {
        print("Deploying to \(environment)")
        print("Timeout: \(timeout)s")
        print("Dry run: \(dryRun)")
    }
}

// MARK: - Main Entry Point

try await ToolCommand.main()
