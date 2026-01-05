import Foundation

/// Describes a `ParsableCommand` so the lightweight `Program` router can
/// resolve `argv` without instantiating the command immediately.
public struct CommandDescriptor: Sendable {
    public let name: String
    public let abstract: String
    public let discussion: String?
    public let signature: CommandSignature
    public let subcommands: [CommandDescriptor]
    public let defaultSubcommandName: String?

    public init(
        name: String,
        abstract: String,
        discussion: String?,
        signature: CommandSignature,
        subcommands: [CommandDescriptor] = [],
        defaultSubcommandName: String? = nil)
    {
        self.name = name
        self.abstract = abstract
        self.discussion = discussion
        self.signature = signature
        self.subcommands = subcommands
        self.defaultSubcommandName = defaultSubcommandName
    }
}

/// The fully resolved command plus the parsed values for the original `argv`.
public struct CommandInvocation: Sendable {
    public let descriptor: CommandDescriptor
    public let parsedValues: ParsedValues
    public let path: [String]

    public init(descriptor: CommandDescriptor, parsedValues: ParsedValues, path: [String]) {
        self.descriptor = descriptor
        self.parsedValues = parsedValues
        self.path = path
    }
}

/// Errors surfaced while resolving a command path prior to running user code.
public enum HelixError: Error, CustomStringConvertible, Sendable, Equatable {
    case missingCommand
    case unknownCommand(String)
    case missingSubcommand(command: String)
    case unknownSubcommand(command: String, name: String)
    case parsingError(String)
    case missingEnvironmentVariable(String)
    case webAssemblyExit(Int32)
    case optionNotBound(String)
    case argumentNotBound(String)
    case validationError(String)
    case helpRequested
    case versionRequested

    public var description: String {
        switch self {
        case .missingCommand:
            "No command specified"
        case let .unknownCommand(name):
            "Unknown command '\(name)'"
        case let .missingSubcommand(command):
            "Command '\(command)' requires a subcommand"
        case let .unknownSubcommand(command, name):
            "Unknown subcommand '\(name)' for command '\(command)'"
        case let .parsingError(error):
            error
        case let .missingEnvironmentVariable(name):
            "Missing environment variable '\(name)'"
        case let .webAssemblyExit(code):
            "WebAssembly exit with code \(code)"
        case let .optionNotBound(type):
            "Option of type '\(type)' was accessed before being parsed"
        case let .argumentNotBound(type):
            "Argument of type '\(type)' was accessed before being parsed"
        case let .validationError(message):
            "Validation error: \(message)"
        case .helpRequested:
            "Help was requested"
        case .versionRequested:
            "Version was requested"
        }
    }
}

/// Resolves `CommandLine.arguments` into concrete commands using descriptors.
public struct Program: Sendable {
    private let descriptorLookup: [String: CommandDescriptor]

    public init(descriptors: [CommandDescriptor]) {
        self.descriptorLookup = Dictionary(uniqueKeysWithValues: descriptors.map { ($0.name, $0) })
    }

    /// Walks the command tree, parses any remaining arguments, and returns a
    /// `CommandInvocation` ready to `run()`.
    public func resolve(argv: [String]) throws -> CommandInvocation {
        var args = argv
        if !args.isEmpty, args[0].hasSuffix("helix") || args[0].contains("/") {
            args.removeFirst()
        }

        guard let commandName = args.first else {
            throw HelixError.missingCommand
        }
        guard var descriptor = descriptorLookup[commandName] else {
            throw HelixError.unknownCommand(commandName)
        }
        args.removeFirst()
        var remainingArguments = args
        var commandPath = [commandName]
        descriptor = try self.resolveDescriptor(descriptor, arguments: &remainingArguments, path: &commandPath)
        let parser = CommandParser(signature: descriptor.signature)
        let parsed = try parser.parse(arguments: remainingArguments)
        return CommandInvocation(descriptor: descriptor, parsedValues: parsed, path: commandPath)
    }

    private func resolveDescriptor(
        _ descriptor: CommandDescriptor,
        arguments: inout [String],
        path: inout [String]) throws -> CommandDescriptor
    {
        guard !descriptor.subcommands.isEmpty else {
            return descriptor
        }

        if arguments.isEmpty {
            if let defaultChild = lookupDefaultSubcommand(for: descriptor) {
                path.append(defaultChild.name)
                return try self.resolveDescriptor(defaultChild, arguments: &arguments, path: &path)
            }
            throw HelixError.missingSubcommand(command: descriptor.name)
        }

        let nextToken = arguments[0]
        if nextToken.starts(with: "-") {
            if let defaultChild = lookupDefaultSubcommand(for: descriptor) {
                path.append(defaultChild.name)
                return try self.resolveDescriptor(defaultChild, arguments: &arguments, path: &path)
            }
            throw HelixError.missingSubcommand(command: descriptor.name)
        }

        guard let match = descriptor.subcommands.first(where: { $0.name == nextToken }) else {
            throw HelixError.unknownSubcommand(command: descriptor.name, name: nextToken)
        }
        arguments.removeFirst()
        path.append(match.name)
        return try self.resolveDescriptor(match, arguments: &arguments, path: &path)
    }

    private func lookupDefaultSubcommand(for descriptor: CommandDescriptor) -> CommandDescriptor? {
        guard let name = descriptor.defaultSubcommandName else { return nil }
        return descriptor.subcommands.first(where: { $0.name == name })
    }
}
