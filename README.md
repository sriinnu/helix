# Commander 🎛️

**Swift-first command-line parsing. Total command over your CLI.**

Commander is a Swift-native command-line framework providing declarative property wrappers, lightweight parsing/routing, and modern concurrency support.

## ✨ Features

- **Property-wrapper ergonomics** – `@Option`, `@Argument`, `@Flag`, and `@OptionGroup`
- **Cross-platform** – macOS, iOS, tvOS, watchOS, visionOS, Linux, Windows
- **Swift 6** – Full concurrency support with strict safety
- **Zero dependencies** – Pure Swift implementation
- **Command routing** – Program-level command resolution with subcommands
- **Standard runtime options** – Built-in `-v/--verbose`, `--json`, `--log-level`

## 📦 Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/srinivaspendela/Commander.git", from: "1.0.0")
]
```

Or use local path:
```swift
dependencies: [
    .package(path: "../Packages/Commander")
]
```

## 🚀 Quick Start

```swift
import Commander

@MainActor
struct GreetCommand: ParsableCommand {
    @Argument(help: "Name to greet") var name: String
    @Option(help: "Number of times to greet") var count: Int = 1
    @Flag(help: "Shout the greeting") var loud = false
    
    static var commandDescription = CommandDescription(
        commandName: "greet",
        abstract: "Greet someone"
    )
    
    mutating func run() async throws {
        for _ in 0..<count {
            let message = "Hello, \(name)!"
            print(loud ? message.uppercased() : message)
        }
    }
}

// Run it
let descriptor = GreetCommand.descriptor()
let program = Program(descriptors: [descriptor])
let invocation = try program.resolve(argv: CommandLine.arguments)
// Execute the command...
```

## 🌍 Platform Support

Commander targets all major platforms:
- **macOS** 14+
- **iOS** 17+
- **tvOS** 17+
- **watchOS** 10+
- **visionOS** 1+
- **Linux** (Swift 6+)
- **Windows** 10+ (Swift 6+)

## 📝 Property Wrappers

### @Argument
Positional arguments:
```swift
@Argument(help: "Input file") var input: String
@Argument(help: "Optional output") var output: String?
```

### @Option
Named options with values:
```swift
@Option(name: .shortAndLong, help: "Port number") var port: Int = 8080
@Option(names: [.short("o"), .long("output")], help: "Output path") var outputPath: String?
```

### @Flag
Boolean switches:
```swift
@Flag(name: .shortAndLong, help: "Verbose output") var verbose = false
@Flag(names: [.long("dry-run")], help: "Don't make changes") var dryRun = false
```

### @OptionGroup
Reusable option sets:
```swift
struct NetworkOptions: CommanderParsable {
    @Option var host: String = "localhost"
    @Option var port: Int = 8080
    init() {}
}

struct ServerCommand: ParsableCommand {
    @OptionGroup var network: NetworkOptions
    // ...
}
```

## 🔧 Advanced Features

### Subcommands
```swift
@MainActor
struct RootCommand: ParsableCommand {
    static var commandDescription = CommandDescription(
        commandName: "tool",
        abstract: "Multi-purpose tool",
        subcommands: [BuildCommand.self, RunCommand.self],
        defaultSubcommand: BuildCommand.self
    )
}
```

### Option Parsing Strategies
```swift
@Option(parsing: .singleValue) var file: String           // Takes exactly one value
@Option(parsing: .upToNextOption) var include: [String]   // Multiple values until next option
@Option(parsing: .remaining) var args: [String]           // All remaining arguments
```

### Custom Types
Conform to `ExpressibleFromArgument`:
```swift
enum LogLevel: String, ExpressibleFromArgument {
    case debug, info, warning, error
    
    init?(argument: String) {
        self.init(rawValue: argument.lowercased())
    }
}

@Option var logLevel: LogLevel = .info
```

## 🌐 Cross-Platform Best Practices

### Windows Support
- Use `URL(fileURLWithPath:)` for paths
- Avoid POSIX-specific assumptions
- Test path separators (`\` vs `/`)

### Linux Support
- No Keychain or platform-specific APIs
- Use `FileManager` for all file operations
- Test with Docker or CI

### Mobile Platforms (iOS/tvOS/watchOS)
- Useful for command parsing in apps
- Can drive UI flows from command patterns
- Great for testing and scriptability

## 📚 Documentation

Generate DocC documentation:
```bash
swift package generate-documentation \
  --target Commander \
  --output-path .build/Commander.doccarchive
```

## 🧪 Testing

```bash
swift test
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

Inspired by Swift Argument Parser, designed for modern Swift concurrency and cross-platform usage.
