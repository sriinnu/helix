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
    func testShowHelpOnEmptyInvocationSkipsRun() async throws {
        HelpVersionCommand.runCount = 0

        try await HelpVersionCommand.main(arguments: [])

        XCTAssertEqual(HelpVersionCommand.runCount, 0)
    }
}
