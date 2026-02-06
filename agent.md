# Helix Agent

This document provides specialized guidance for developing and maintaining the **Helix** Swift CLI framework.

## Project Overview

Helix is a lightweight, declarative CLI framework inspired by Swift ArgumentParser. It uses Swift's property wrappers and reflection to create elegant command-line interfaces with zero external dependencies.

- **Platforms**: macOS 14+, iOS 17+, tvOS 17+, watchOS 10+, visionOS 1+, plus Windows and WASI support via platform contexts in `Sources/Helix/Platform`
- **Language**: Swift 6 (strict concurrency)
- **Structure**: Single-target library in `Sources/Helix/`

## Architecture

### Core Components

| File | Purpose |
|------|---------|
| `ParsableCommand.swift` | Main protocol all commands conform to (`@MainActor`, `Sendable`) |
| `Program.swift` | Routes `argv` to commands, handles subcommand resolution |
| `CommandParser.swift` | Tokenizes and parses CLI arguments |
| `CommandSignature.swift` | Declarative description of options, flags, positional args |
| `PropertyWrappers.swift` | `@Option`, `@Argument`, `@Flag`, `@OptionGroup` |
| `ExpressibleFromArgument.swift` | Protocol for string-to-type conversion |
| `NameSpecification.swift` | Customize short/long option names |

### Key Protocols

```swift
@MainActor
public protocol ParsableCommand: Sendable {
    init()
    static var commandDescription: CommandDescription { get }
    mutating func run() async throws
}

public protocol ExpressibleFromArgument {
    init?(argument: String)
}
```

### Command Resolution Flow

```
CommandLine.arguments
    → Program.resolve(argv:)
    → CommandParser.parse()
    → CommandInvocation
    → bind (property wrapper binding + option groups)
    → validate()
    → run()
```

Note: When `Program` is initialized with a single root descriptor, `Program.resolve` can select it even if `argv` does not include the root command name. If multiple root descriptors exist, the first argument must select the root command.

## Development Patterns

### Creating a New Command

```swift
struct MyCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(commandName: "my")
    }

    @Option(name: .shortAndLong, help: "Output file")
    var output: String = "output.txt"

    @Argument(help: "Input files")
    var inputs: [String]

    @Flag(name: .short, help: "Verbose output")
    var verbose: Bool = false

    mutating func run() async throws {
        // Command implementation
    }
}

try await MyCommand.main()
```

### Property Wrapper Patterns

| Wrapper | Description |
|---------|-------------|
| `@Option<Value>` | Named parameters (`--name value`) |
| `@Argument<Value>` | Positional arguments |
| `@Flag` | Boolean switches |
| `@OptionGroup<Value>` | Reusable option groups |

When parsing manually, use `Self.descriptor.signature.flattened()` so option groups are included in `CommandParser`.

### Name Specification Options

- `.automatic` → `--property-name`
- `.short('n')` → `-n`
- `.longName("name")` → `--name`
- `.shortAndLong` → `-n / --name`
- `.customShort('x')` → `-x value`

Note: `--name=value` and `-n=value` are supported. Joined short option values (e.g. `-nvalue`) are not supported.

### Supported Types

- `String`, `Substring`
- `Int`, `Int32`, `Int64`
- `Double`, `Float`
- `Bool` (true/false, t/f, 1/0, yes/no)
- `Optional<T>`
- `Array<T>` (comma-separated)
- Custom types conforming to `ExpressibleFromArgument`

## Naming Conventions

- **CamelCase** to **kebab-case** auto-conversion: `maxRetries` → `--max-retries`
- Leading underscore removal: `_name` → `name`
- Option groups are flattened; labels keep the original property names

## Error Handling

- `HelixError` enum: `missingCommand`, `unknownCommand`, `parsingError`, etc.
- `ValidationError` for user input validation failures
- `ExitCode` for programmatic exit (`success=0`, `failure=1`)

## Testing

Test files go in `Tests/HelixTests/` and include:
- `CommandParserTests.swift`
- `HelpGeneratorTests.swift`
- `HelpVersionBehaviorTests.swift`
- `ParsableCommandBindingTests.swift`
- `PropertyWrappersTests.swift`
- `PlatformContextTests.swift`
- `PlatformPathTests.swift`
- `StdioTests.swift`

Run tests:
```bash
swift test
```

## Documentation

Generate documentation with Swift DocC:
```bash
swift package generate-documentation
```

## Common Tasks

### Adding a New Property Wrapper Type

1. Add wrapper struct in `PropertyWrappers.swift`
2. Conform to `HelixParsable` and `ExpressibleFromArgument`
3. Register in `CommandSignature`'s reflection-based building
4. Add parser case in `CommandParser`

### Adding New Argument Type

1. Extend type with `ExpressibleFromArgument` in `ExpressibleFromArgument.swift`
2. Implement `init?(argument: String)` with proper parsing logic

### Extending Name Specification

1. Add case to `NameSpecification` enum
2. Implement `specification(for:)` method
3. Update `ArgumentDescriptor`'s name generation logic

## Concurrency Requirements

All command code runs on the main actor. The `@MainActor` annotation on `ParsableCommand` ensures this. Avoid `nonisolated` unless absolutely necessary.

## Code Style

- Swift 6 strict concurrency
- Protocol-oriented design
- Property wrapper pattern for declarative APIs
- Full `Sendable` conformance where applicable
