# Helix 🌀

**Swift command-line parsing framework**

Helix is a modern, cross-platform Swift framework for building command-line tools with declarative property wrappers, intelligent routing, and full Swift 6 concurrency support.

## ✨ Features

- **Declarative syntax** – `@Option`, `@Argument`, `@Flag`, `@OptionGroup`
- **Cross-platform** – macOS, iOS, tvOS, watchOS, visionOS, Linux, Windows
- **Swift 6 ready** – Full concurrency safety
- **Zero dependencies** – Pure Swift
- **Smart routing** – Subcommands, default commands, nested hierarchies
- **Built-in flags** – `-v/--verbose`, `--json`, `--log-level`

## 📦 Installation

```swift
dependencies: [
    .package(url: "https://github.com/sriinnu/Helix.git", from: "1.0.0")
]
```

## 🚀 Quick Start

```swift
import Helix

@MainActor
struct GreetCommand: ParsableCommand {
    @Argument(help: "Name to greet") var name: String
    @Option(help: "Times to repeat") var count: Int = 1
    @Flag(help: "Uppercase output") var loud = false
    
    static var commandDescription = CommandDescription(
        commandName: "greet",
        abstract: "Greet someone"
    )
    
    mutating func run() async throws {
        for _ in 0..<count {
            let msg = "Hello, \(name)!"
            print(loud ? msg.uppercased() : msg)
        }
    }
}
```

## 🌍 Platforms

macOS 14+ • iOS 17+ • tvOS 17+ • watchOS 10+ • visionOS 1+ • Linux • Windows 10+

## 📝 Property Wrappers

```swift
@Argument(help: "Input file") var input: String
@Option(name: .shortAndLong) var port: Int = 8080
@Flag(name: .long("dry-run")) var dryRun = false

struct Options: HelixParsable {
    @Option var host: String = "localhost"
    init() {}
}
```

## 🔧 Advanced

### Subcommands
```swift
static var commandDescription = CommandDescription(
    commandName: "tool",
    subcommands: [Build.self, Run.self],
    defaultSubcommand: Build.self
)
```

### Custom Types
```swift
enum LogLevel: String, ExpressibleFromArgument {
    case debug, info, warning, error
}
```

## 📚 Documentation

```bash
swift package generate-documentation --target Helix
```

## 🧪 Testing

```bash
swift test
```

## �� License

MIT License - Copyright (c) 2026 Srinivas Pendela

---

**GitHub:** https://github.com/sriinnu/Helix  
**Author:** Srinivas Pendela (hello@srinivas.dev)
