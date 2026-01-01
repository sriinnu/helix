# Helix

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0+-orange.svg" />
  <img src="https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-lightgrey.svg" />
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" />
</p>

A modern, declarative command-line parsing framework for Swift that uses property wrappers to create elegant CLI interfaces. Inspired by Swift ArgumentParser but with a lighter footprint and simplified API.

## ✨ Features

- 🎯 **Declarative Syntax**: Use property wrappers (`@Option`, `@Argument`, `@Flag`) for clean, readable command definitions
- 🔄 **Subcommands**: Built-in support for nested commands with default subcommand routing
- 🌍 **Cross-Platform**: Works seamlessly on macOS 14+, iOS 17+, tvOS 17+, watchOS 10+, and visionOS 1+
- 📦 **Type-Safe**: Leverages Swift's type system for automatic argument parsing and validation
- 🚀 **Zero Dependencies**: Pure Swift implementation with no external dependencies
- 🔍 **Reflection-Based**: Automatic command signature building using Swift's Mirror API
- �� **Smart Naming**: Automatic kebab-case conversion from camelCase property names
- 🛡️ **Swift 6 Ready**: Full concurrency support with `Sendable` conformance throughout

## 📦 Installation

### Swift Package Manager

Add Helix to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sriinnu/Helix", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["Helix"]
)
```

## 🚀 Quick Start

### Basic Command

```swift
import Helix

struct HelloCommand: ParsableCommand {
    @Option(help: "Your name")
    var name: String
    
    @Flag(help: "Use formal greeting")
    var formal: Bool = false
    
    @Argument(help: "Optional message")
    var message: String?
    
    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: "hello",
            abstract: "Greet someone",
            discussion: """
            A friendly greeting command that supports both casual 
            and formal greetings with optional custom messages.
            """
        )
    }
    
    mutating func run() async throws {
        let greeting = formal ? "Good day" : "Hello"
        if let message = message {
            print("\(greeting), \(name)! \(message)")
        } else {
            print("\(greeting), \(name)!")
        }
    }
}

// Run the command
try await HelloCommand.main(arguments: CommandLine.arguments)
```

**Usage:**
```bash
$ hello --name Alice
Hello, Alice!

$ hello --name Bob --formal
Good day, Bob!

$ hello --name Carol "Hope you're doing well"
Hello, Carol! Hope you're doing well
```

## 🎨 Property Wrappers

### `@Option` - Named Options with Values

Options are named parameters that accept values:

```swift
// Simple option (generates --output)
@Option(help: "Output file path")
var output: String

// Short and long names (generates -v/--verbose)
@Option(name: .shortAndLong, help: "Verbosity level")
var verbose: Int = 0

// Custom names
@Option(name: .customLong("out-dir"), help: "Output directory")
var outputDirectory: String

// Optional values with defaults
@Option(help: "Maximum retries")
var maxRetries: Int = 3

// Arrays (comma-separated values)
@Option(help: "Tags to apply")
var tags: [String] = []
```

### `@Argument` - Positional Arguments

Arguments are parsed by position, not by name:

```swift
// Required positional argument
@Argument(help: "Input file")
var input: String

// Optional positional argument
@Argument(help: "Optional config file")
var config: String?

// Multiple positional arguments are parsed in order
@Argument(help: "Source file")
var source: String

@Argument(help: "Destination file")
var destination: String
```

### `@Flag` - Boolean Switches

Flags are boolean options that don't take values:

```swift
// Simple flag (generates --debug)
@Flag(help: "Enable debug mode")
var debug: Bool = false

// Multiple names for the same flag
@Flag(names: [.short("v"), .long("verbose")], help: "Verbose output")
var verbose: Bool = false

// Inverted flag (true by default, false when specified)
@Flag(help: "Disable colors")
var noColor: Bool = false
```

### `@OptionGroup` - Grouped Options

Group related options together:

```swift
struct LoggingOptions: HelixParsable {
    @Option(help: "Log level")
    var logLevel: String = "info"
    
    @Option(help: "Log file path")
    var logFile: String?
    
    @Flag(help: "Enable timestamps")
    var timestamps: Bool = false
}

struct MyCommand: ParsableCommand {
    @OptionGroup
    var logging: LoggingOptions
    
    mutating func run() async throws {
        print("Log level: \(logging.logLevel)")
    }
}
```

## 🔧 Advanced Features

### Subcommands

Create powerful CLI tools with nested commands:

```swift
struct GitCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: "git",
            abstract: "Distributed version control system",
            subcommands: [
                CloneCommand.descriptor,
                CommitCommand.descriptor,
                PushCommand.descriptor
            ],
            defaultSubcommand: "clone" // Optional default
        )
    }
}

struct CloneCommand: ParsableCommand {
    @Argument(help: "Repository URL")
    var url: String
    
    @Option(help: "Clone into directory")
    var directory: String?
    
    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: "clone",
            abstract: "Clone a repository into a new directory"
        )
    }
    
    mutating func run() async throws {
        print("Cloning \(url)...")
    }
}
```

**Usage:**
```bash
$ git clone https://github.com/user/repo
$ git clone --directory myproject https://github.com/user/repo
```

### Custom Types

Extend Helix to parse your custom types:

```swift
enum LogLevel: String, ExpressibleFromArgument {
    case debug, info, warning, error
    
    init?(argument: String) {
        self.init(rawValue: argument.lowercased())
    }
}

struct Config: ExpressibleFromArgument {
    let host: String
    let port: Int
    
    init?(argument: String) {
        let parts = argument.split(separator: ":")
        guard parts.count == 2,
              let port = Int(parts[1]) else { return nil }
        self.host = String(parts[0])
        self.port = port
    }
}

struct ServerCommand: ParsableCommand {
    @Option(help: "Log level (debug, info, warning, error)")
    var logLevel: LogLevel = .info
    
    @Option(help: "Server address (host:port)")
    var server: Config
    
    mutating func run() async throws {
        print("Starting server at \(server.host):\(server.port)")
        print("Log level: \(logLevel)")
    }
}
```

### Validation

Add custom validation logic:

```swift
struct DownloadCommand: ParsableCommand {
    @Option(help: "Number of concurrent downloads")
    var concurrency: Int = 4
    
    @Argument(help: "URL to download")
    var url: String
    
    mutating func validate() throws {
        guard concurrency > 0 && concurrency <= 10 else {
            throw ValidationError("Concurrency must be between 1 and 10")
        }
        
        guard url.hasPrefix("http://") || url.hasPrefix("https://") else {
            throw ValidationError("URL must start with http:// or https://")
        }
    }
    
    mutating func run() async throws {
        print("Downloading \(url) with \(concurrency) connections")
    }
}
```

### Error Handling

Handle errors gracefully with exit codes:

```swift
struct ProcessCommand: ParsableCommand {
    mutating func run() async throws {
        do {
            try await processFiles()
        } catch let error as FileError {
            print("Error: \(error.localizedDescription)")
            throw ExitCode.failure
        }
    }
}
```

## 📱 Platform Support

| Platform | Minimum Version | Status |
|----------|----------------|---------|
| macOS | 14.0+ | ✅ Fully Supported |
| iOS | 17.0+ | ✅ Fully Supported |
| tvOS | 17.0+ | ✅ Fully Supported |
| watchOS | 10.0+ | ✅ Fully Supported |
| visionOS | 1.0+ | ✅ Fully Supported |

## 🎯 Real-World Examples

### File Processor

```swift
struct ProcessCommand: ParsableCommand {
    @Argument(help: "Files to process")
    var files: [String]
    
    @Option(help: "Output format")
    var format: String = "json"
    
    @Flag(help: "Overwrite existing files")
    var force: Bool = false
    
    @Flag(help: "Verbose output")
    var verbose: Bool = false
    
    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: "process",
            abstract: "Process files with various options"
        )
    }
    
    mutating func run() async throws {
        for file in files {
            if verbose {
                print("Processing \(file)...")
            }
            // Process file logic here
        }
    }
}
```

### Build Tool

```swift
struct BuildCommand: ParsableCommand {
    @Option(help: "Build configuration")
    var configuration: String = "debug"
    
    @Option(help: "Target platform")
    var platform: String = "macos"
    
    @Flag(help: "Clean before building")
    var clean: Bool = false
    
    @Flag(names: [.short("j"), .long("parallel")], help: "Build in parallel")
    var parallel: Bool = false
    
    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: "build",
            abstract: "Build the project",
            discussion: "Builds the project for the specified platform and configuration."
        )
    }
    
    mutating func run() async throws {
        if clean {
            print("Cleaning build directory...")
        }
        
        print("Building for \(platform) in \(configuration) mode...")
        
        if parallel {
            print("Using parallel builds")
        }
    }
}
```

## �� Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

Helix is released under the MIT License. See [LICENSE](LICENSE) for details.

## 👤 Author

**Srinivas Pendela**  
- Email: hello@srinivas.dev  
- GitHub: [@sriinnu](https://github.com/sriinnu)
- Package: [Helix](https://github.com/sriinnu/Helix)

## 🙏 Acknowledgments

Inspired by Swift's ArgumentParser and Commander, Helix aims to provide a lightweight, modern alternative for command-line parsing in Swift.

---

<p align="center">Made with ❤️ for the Swift community</p>
