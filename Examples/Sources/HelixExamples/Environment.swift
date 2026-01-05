import Helix

/// Command demonstrating environment variable support.
struct ConfigCommand: ParsableCommand {
    static var commandName: String = "config"

    @Option(name: .shortAndLong, help: "API key (can use API_KEY env var)")
    var apiKey: String?

    @Option(name: .shortAndLong, envVar: "DATABASE_URL", help: "Database connection URL")
    var databaseURL: String?

    @Option(name: .shortAndLong, envVar: "LOG_LEVEL", help: "Logging level")
    var logLevel: String = "info"

    @Flag(name: .short('v'), help: "Show resolved configuration")
    var showValues: Bool = false

    mutating func run() async throws {
        // Note: Environment variable fallback is handled during parsing
        // The actual values are available after parsing completes

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
