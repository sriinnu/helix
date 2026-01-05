import Foundation

/// Generates help text for commands.
public struct HelpGenerator {
    /// The command descriptor to generate help for.
    public let descriptor: CommandDescriptor

    /// Creates a new help generator.
    public init(descriptor: CommandDescriptor) {
        self.descriptor = descriptor
    }

    /// Generates the full help text.
    public var output: String {
        var result = ""

        // Usage line
        result += "USAGE: \(generateUsage())\n\n"

        // Abstract
        if !descriptor.abstract.isEmpty {
            result += "\(descriptor.abstract)\n\n"
        }

        // Discussion
        if let discussion = descriptor.discussion, !discussion.isEmpty {
            result += "\(discussion)\n\n"
        }

        // Options
        let flattened = descriptor.signature.flattened()
        if !flattened.options.isEmpty || !flattened.flags.isEmpty {
            result += "OPTIONS:\n"
            for option in flattened.options {
                result += "  \(formatOption(option))\n"
            }
            for flag in flattened.flags {
                result += "  \(formatFlag(flag))\n"
            }
            result += "\n"
        }

        // Arguments
        if !flattened.arguments.isEmpty {
            result += "ARGUMENTS:\n"
            for arg in flattened.arguments {
                result += "  \(formatArgument(arg))\n"
            }
            result += "\n"
        }

        // Subcommands
        if !descriptor.subcommands.isEmpty {
            result += "SUBCOMMANDS:\n"
            for subcommand in descriptor.subcommands {
                result += "  \(subcommand.name)"
                if !subcommand.abstract.isEmpty {
                    result += " - \(subcommand.abstract)"
                }
                result += "\n"
            }
        }

        return result
    }

    private func generateUsage() -> String {
        var parts: [String] = [descriptor.name]

        // Add subcommands hint
        if !descriptor.subcommands.isEmpty {
            parts.append("<subcommand>")
        }

        let flattened = descriptor.signature.flattened()

        // Add flags
        for flag in flattened.flags {
            if let short = flag.names.first(where: { $0.shortComponent != nil }) {
                parts.append("[\(short.shortComponent!)]")
            } else if let long = flag.names.first(where: { $0.longComponent != nil }) {
                parts.append("[\(long.longComponent!)]")
            }
        }

        // Add options (simplified - just shows placeholders)
        for option in flattened.options {
            parts.append("[\(option.label)>]")
        }

        // Add required arguments
        for arg in flattened.arguments where !arg.isOptional {
            parts.append("<\(arg.label)>")
        }

        // Add optional arguments
        for arg in flattened.arguments where arg.isOptional {
            parts.append("[\(arg.label)]")
        }

        return parts.joined(separator: " ")
    }

    private func formatOption(_ option: OptionDefinition) -> String {
        var parts: [String] = []

        for name in option.names {
            if let short = name.shortComponent {
                parts.append("-\(short) <\(option.label)>")
            }
            if let long = name.longComponent {
                parts.append("--\(long) <\(option.label)>")
            }
        }

        let joined = parts.joined(separator: ", ")
        if let help = option.help {
            return String(format: "%-40s %@", joined, help)
        }
        return joined
    }

    private func formatFlag(_ flag: FlagDefinition) -> String {
        var parts: [String] = []

        for name in flag.names {
            if let short = name.shortComponent {
                parts.append("-\(short)")
            }
            if let long = name.longComponent {
                parts.append("--\(long)")
            }
        }

        let joined = parts.joined(separator: ", ")
        if let help = flag.help {
            return String(format: "%-40s %@", joined, help)
        }
        return joined
    }

    private func formatArgument(_ arg: ArgumentDefinition) -> String {
        let label = arg.isOptional ? "[\(arg.label)]" : "<\(arg.label)>"
        if let help = arg.help {
            return String(format: "%-40s %@", label, help)
        }
        return label
    }
}

// MARK: - Help Text Generation Helper

extension HelixError {
    /// Generates help text for the given descriptor.
    public static func helpText(for descriptor: CommandDescriptor) -> String {
        HelpGenerator(descriptor: descriptor).output
    }
}
