import Helix
import Foundation

/// Command demonstrating file operations with options and arguments.
struct FilesCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: "files",
            abstract: "A file management utility",
            discussion: """
            This command demonstrates various Helix features including:
            - Options with custom names
            - Positional arguments
            - Flags for boolean options
            - Help text and usage
            """
        )
    }

    @Option(name: .shortAndLong, help: "Source directory")
    var source: String = "."

    @Option(name: .short('o'), help: "Output directory")
    var output: String?

    @Flag(name: .short('r'), help: "Recursively process directories")
    var recursive: Bool = false

    @Flag(name: .short('v'), help: "Verbose output")
    var verbose: Bool = false

    @Argument(help: "File patterns to process")
    var patterns: [String] = ["*"]

    @OptionGroup
    var globalOptions: GlobalFileOptions

    mutating func run() async throws {
        if verbose {
            print("Source: \(source)")
            print("Output: \(output ?? "default")")
            print("Recursive: \(recursive)")
            print("Patterns: \(patterns.joined(separator: ", "))")
        }

        // Simulate file processing
        for pattern in patterns {
            if verbose {
                print("Processing pattern: \(pattern)")
            }
        }

        print("Processed \(patterns.count) pattern(s)")
    }
}

// MARK: - Option Group

struct GlobalFileOptions: HelixParsable {
    @Flag(name: .short('f'), help: "Force overwrite existing files")
    var force: Bool = false

    @Option(name: .short('e'), help: "Encoding (utf-8, ascii, etc.)")
    var encoding: String = "utf-8"
}

// MARK: - Main Entry Point

try await FilesCommand.main()
