import Helix

/// Command demonstrating environment variable fallback for options.
struct ConfigCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: "config",
            abstract: "Load configuration from CLI and environment"
        )
    }

    @Option(name: .shortAndLong, envVar: "API_KEY", help: "API key (can use API_KEY env var)")
    var apiKey: String?

    @Option(name: .shortAndLong, envVar: "DATABASE_URL", help: "Database connection URL")
    var databaseURL: String?

    @Option(name: .shortAndLong, envVar: "LOG_LEVEL", help: "Logging level")
    var logLevel: String = "info"

    @Flag(name: .short('v'), help: "Show resolved configuration")
    var showValues: Bool = false

    mutating func run() async throws {
        if showValues {
            print("Configuration:")
            print("  API Key: \(apiKey.map { "***\($0.suffix(4))" } ?? "not set")")
            print("  Database URL: \(databaseURL ?? "not set")")
            print("  Log Level: \(logLevel)")
        }

        print("Configuration loaded successfully")
    }
}

// MARK: - Main Entry Point

try await ConfigCommand.main()
