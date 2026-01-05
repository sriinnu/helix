import Foundation

/// Protocol every Helix command adopts. Provide metadata via
/// `commandDescription` and implement `run()` to perform the command's work.
@MainActor
public protocol ParsableCommand: Sendable {
    init()
    static var commandDescription: CommandDescription { get }
    mutating func run() async throws

    /// Optional validation method called after parsing but before run().
    /// Throw `ValidationError` if validation fails.
    mutating func validate() throws
}

extension ParsableCommand {
    /// Default implementation - does nothing.
    public mutating func validate() throws {
        // Default: no validation
    }

    public static var commandDescription: CommandDescription {
        CommandDescription()
    }

    /// Creates a command descriptor from this command type.
    public static var descriptor: CommandDescriptor {
        let signature = CommandSignature.describe(Self())
        let typeName = String(describing: Self.self)
        let name: String
        if let cmdName = commandDescription.commandName {
            name = cmdName
        } else {
            // Remove "Command" suffix if present
            name = typeName.hasSuffix("Command") ? String(typeName.dropLast(7)) : typeName
        }
        return CommandDescriptor(
            name: name,
            abstract: commandDescription.abstract,
            discussion: commandDescription.discussion,
            signature: signature,
            subcommands: commandDescription.subcommands.map { $0.descriptor },
            defaultSubcommandName: commandDescription.defaultSubcommand.map {
                let defaultTypeName = String(describing: $0)
                let defaultName = defaultTypeName.hasSuffix("Command") ? String(defaultTypeName.dropLast(7)) : defaultTypeName
                return defaultName.lowercased()
            }
        )
    }

    /// Runs the command with arguments from the current platform context.
    public static func main() async throws {
        try await main(arguments: DefaultPlatformContext.shared.arguments)
    }

    /// Runs the command with the specified arguments.
    public static func main(arguments argv: [String]) async throws {
        // Build descriptor
        let descriptor = Self.descriptor

        // Create program and resolve
        let program = Program(descriptors: [descriptor])

        do {
            let invocation = try program.resolve(argv: argv)
            var parsedCommand = Self()

            // Bind parsed values to command properties
            try bindValues(from: invocation, to: &parsedCommand)

            // Run validation
            try parsedCommand.validate()

            // Run the command
            try await parsedCommand.run()
        } catch let error as HelixError {
            switch error {
            default:
                throw error
            }
        }
    }

    /// Binds parsed values from invocation to command properties using reflection.
    /// This method uses Mirror to traverse command properties and set values from parsed arguments.
    private static func bindValues(from invocation: CommandInvocation, to command: inout Self) throws {
        // Reflection-based property binding is complex
        // For now, this is a placeholder that demonstrates the architecture
        // A full implementation would use Mirror to set property values
        // based on the parsed invocation data
    }

    /// Binds values for an option group (placeholder for full implementation).
    private static func bindGroupValues(
        from invocation: CommandInvocation,
        groupMirror: Mirror,
        to group: Any
    ) throws {
        // Full implementation would recursively bind group properties
    }

    /// Binds top-level property values (placeholder for full implementation).
    private static func bindTopLevelValues(from invocation: CommandInvocation, to command: inout Self) throws {
        // Full implementation would use Mirror to set property values
    }

    private static func countBoundPositional(in mirror: Mirror, upToLabel targetLabel: String) -> Int {
        // Placeholder implementation
        return 0
    }

    private static func bindOption(label: String, value: String?, to command: inout Self, in mirror: Mirror) throws {
        // Placeholder: Full implementation would parse string value to correct type
    }

    private static func bindArgument(label: String, value: String?, to command: inout Self, in mirror: Mirror) throws {
        // Placeholder: Full implementation would parse string value to correct type
    }

    private static func setProperty<T>(on instance: inout Any, in mirror: Mirror, label: String, value: T) {
        // Placeholder: Full implementation would use Mirror's children mutation
    }
}

/// Helper type for Option wrapper inspection
public struct OptionWrapperHolder {
    let storage: Any?
    let nameSpecifications: [NameSpecification]
}

/// Helper type for Argument wrapper inspection
public struct ArgumentWrapperHolder {
    let storage: Any?
}

/// Helper type for Flag wrapper inspection
public struct FlagWrapperHolder {
    let wrappedValue: Bool
}

/// Declarative metadata describing a command built with `ParsableCommand`.
public struct CommandDescription: Sendable {
    public var commandName: String?
    public var abstract: String
    public var discussion: String?
    public var version: String?
    public var subcommands: [any ParsableCommand.Type]
    public var defaultSubcommand: (any ParsableCommand.Type)?
    public var showHelpOnEmptyInvocation: Bool

    public init(
        commandName: String? = nil,
        abstract: String = "",
        discussion: String? = nil,
        version: String? = nil,
        subcommands: [any ParsableCommand.Type] = [],
        defaultSubcommand: (any ParsableCommand.Type)? = nil,
        showHelpOnEmptyInvocation: Bool = false)
    {
        self.commandName = commandName
        self.abstract = abstract
        self.discussion = discussion
        self.version = version
        self.subcommands = subcommands
        self.defaultSubcommand = defaultSubcommand
        self.showHelpOnEmptyInvocation = showHelpOnEmptyInvocation
    }
}

/// Thrown from `ParsableCommand/run()` when user input fails validation.
public struct ValidationError: Error, LocalizedError, CustomStringConvertible, Sendable {
    private let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var errorDescription: String? { self.message }
    public var description: String { self.message }
}

/// Exit sentinel understood by CLI harnesses.
public struct ExitCode: Error, Equatable, CustomStringConvertible, Sendable {
    public let rawValue: Int32

    public init(_ rawValue: Int32) {
        self.rawValue = rawValue
    }

    public static let success = ExitCode(0)
    public static let failure = ExitCode(1)

    public var description: String { "ExitCode(\(self.rawValue))" }
}
