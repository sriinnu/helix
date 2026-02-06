import Helix

/// A simple "Hello, World!" command demonstrating basic usage.
struct HelloCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: "hello",
            abstract: "Print a greeting"
        )
    }

    @Option(name: .shortAndLong, help: "Name to greet")
    var name: String = "World"

    @Flag(name: .short('u'), help: "Use uppercase")
    var uppercase: Bool = false

    @Flag(name: .short('f'), help: "Formal greeting")
    var formal: Bool = false

    mutating func run() async throws {
        let greeting: String
        if formal {
            greeting = "Good day, \(name)."
        } else if uppercase {
            greeting = "HELLO, \(name.uppercased())!"
        } else {
            greeting = "Hello, \(name)!"
        }

        print(greeting)
    }
}

// MARK: - Main Entry Point

try await HelloCommand.main()
