import XCTest
@testable import Helix

private struct HelpVersionCommand: ParsableCommand {
    @MainActor
    static var runCount = 0

    static var commandDescription: CommandDescription {
        CommandDescription(
            abstract: "Help/version test",
            version: "9.9.9",
            showHelpOnEmptyInvocation: true)
    }

    init() {}

    mutating func run() async throws {
        Self.runCount += 1
    }
}

final class HelpVersionBehaviorTests: XCTestCase {

    @MainActor
    func testHelpFlagSkipsRun() async throws {
        HelpVersionCommand.runCount = 0

        try await HelpVersionCommand.main(arguments: ["--help"])

        XCTAssertEqual(HelpVersionCommand.runCount, 0)
    }

    @MainActor
    func testVersionFlagSkipsRun() async throws {
        HelpVersionCommand.runCount = 0

        try await HelpVersionCommand.main(arguments: ["--version"])

        XCTAssertEqual(HelpVersionCommand.runCount, 0)
    }

    @MainActor
    func testHelpFlagAfterTerminatorSkipsRun() async throws {
        HelpVersionCommand.runCount = 0

        try await HelpVersionCommand.main(arguments: ["--", "--help"])

        XCTAssertEqual(HelpVersionCommand.runCount, 0)
    }

    @MainActor
    func testVersionFlagAfterTerminatorSkipsRun() async throws {
        HelpVersionCommand.runCount = 0

        try await HelpVersionCommand.main(arguments: ["--", "--version"])

        XCTAssertEqual(HelpVersionCommand.runCount, 0)
    }

    @MainActor
    func testShowHelpOnEmptyInvocationSkipsRun() async throws {
        HelpVersionCommand.runCount = 0

        try await HelpVersionCommand.main(arguments: [])

        XCTAssertEqual(HelpVersionCommand.runCount, 0)
    }

    @MainActor
    func testShowHelpOnUnknownSubcommandRunsNoSubcommandAndSkipsRun() async throws {
        UnknownSubcommandHelpCommand.runCount = 0

        try await UnknownSubcommandHelpCommand.main(arguments: ["--help"])

        XCTAssertEqual(UnknownSubcommandHelpCommand.runCount, 0)
    }

    @MainActor
    func testHelpAndVersionFlagsTogetherPrefersHelp() async throws {
        HelpVersionCommand.runCount = 0

        try await HelpVersionCommand.main(arguments: ["--help", "--version"])

        XCTAssertEqual(HelpVersionCommand.runCount, 0)
    }

    @MainActor
    func testVersionFlagSkipsRunWhenVersionMissing() async throws {
        NoVersionCommand.runCount = 0

        try await NoVersionCommand.main(arguments: ["--version"])

        XCTAssertEqual(NoVersionCommand.runCount, 0)
    }
}

private struct UnknownSubcommandHelpCommand: ParsableCommand {
    @MainActor
    static var runCount = 0

    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: "helproot",
            abstract: "Help routing test",
            version: "1.0.0",
            subcommands: [NoopSubcommand.self]
        )
    }

    init() {}

    mutating func run() async throws {
        Self.runCount += 1
    }

    private struct NoopSubcommand: ParsableCommand {
        static var commandDescription: CommandDescription {
            CommandDescription(commandName: "noop", abstract: "No-op subcommand")
        }

        init() {}

        mutating func run() async throws { }
    }
}

private struct NoVersionCommand: ParsableCommand {
    @MainActor
    static var runCount = 0

    static var commandDescription: CommandDescription {
        CommandDescription(abstract: "No version")
    }

    init() {}

    mutating func run() async throws {
        Self.runCount += 1
    }
}
