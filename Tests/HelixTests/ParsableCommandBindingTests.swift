import XCTest
@testable import Helix

private struct OptionFlagArgumentCommand: ParsableCommand {
    struct Captured: Sendable, Equatable {
        let count: Int
        let verbose: Bool
        let input: String
    }

    @MainActor
    static var captured: Captured?

    static var commandDescription: CommandDescription {
        CommandDescription(commandName: "option-flag-argument")
    }

    @Option
    var count: Int

    @Flag
    var verbose: Bool = false

    @Argument
    var input: String

    init() {}

    mutating func run() async throws {
        Self.captured = Captured(count: count, verbose: verbose, input: input)
    }
}

private struct OptionGroupCommand: ParsableCommand {
    struct GlobalOptions: HelixParsable {
        @Flag
        var verbose: Bool = false

        @Option
        var output: String = "."

        init() {}
    }

    struct Captured: Sendable, Equatable {
        let verbose: Bool
        let output: String
    }

    @MainActor
    static var captured: Captured?

    static var commandDescription: CommandDescription {
        CommandDescription(commandName: "option-group")
    }

    @OptionGroup
    var global: GlobalOptions

    init() {}

    mutating func run() async throws {
        Self.captured = Captured(verbose: global.verbose, output: global.output)
    }
}

private struct RequiredOptionCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(commandName: "required-option")
    }

    @Option
    var required: String

    init() {}

    mutating func run() async throws {}
}

private struct RequiredArgumentCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(commandName: "required-argument")
    }

    @Argument
    var required: String

    init() {}

    mutating func run() async throws {}
}

private struct VariadicConsumesRemainderCommand: ParsableCommand {
    struct Captured: Sendable, Equatable {
        let first: String
        let rest: [String]
    }

    @MainActor
    static var captured: Captured?

    static var commandDescription: CommandDescription {
        CommandDescription(commandName: "variadic-consumes")
    }

    @Argument
    var first: String

    @Argument
    var rest: [String]

    init() {}

    mutating func run() async throws {
        Self.captured = Captured(first: first, rest: rest)
    }
}

private struct VariadicMustBeLastCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(commandName: "variadic-must-be-last")
    }

    @Argument
    var rest: [String]

    @Argument
    var trailing: String

    init() {}

    mutating func run() async throws {}
}

private struct ExtraPositionalsCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(commandName: "extra-positionals")
    }

    @Argument
    var first: String

    init() {}

    mutating func run() async throws {}
}

final class ParsableCommandBindingTests: XCTestCase {

    @MainActor
    func testMainBindsOptionFlagAndArgument() async throws {
        OptionFlagArgumentCommand.captured = nil

        try await OptionFlagArgumentCommand.main(
            arguments: ["option-flag-argument", "--count", "3", "--verbose", "file.txt"]
        )

        XCTAssertEqual(
            OptionFlagArgumentCommand.captured,
            .init(count: 3, verbose: true, input: "file.txt")
        )
    }

    @MainActor
    func testMainBindsOptionGroup() async throws {
        OptionGroupCommand.captured = nil

        try await OptionGroupCommand.main(
            arguments: ["option-group", "--verbose", "--output", "out"]
        )

        XCTAssertEqual(
            OptionGroupCommand.captured,
            .init(verbose: true, output: "out")
        )
    }

    @MainActor
    func testMissingRequiredOptionThrowsParsingError() async {
        do {
            try await RequiredOptionCommand.main(arguments: ["required-option"])
            XCTFail("Expected parsing error")
        } catch {
            XCTAssertEqual(error as? HelixError, .parsingError("Missing value for option required"))
        }
    }

    @MainActor
    func testMissingRequiredArgumentThrowsParsingError() async {
        do {
            try await RequiredArgumentCommand.main(arguments: ["required-argument"])
            XCTFail("Expected parsing error")
        } catch {
            XCTAssertEqual(error as? HelixError, .parsingError("Missing argument required"))
        }
    }

    @MainActor
    func testVariadicPositionalArrayConsumesRemainder() async throws {
        VariadicConsumesRemainderCommand.captured = nil

        try await VariadicConsumesRemainderCommand.main(
            arguments: ["variadic-consumes", "one", "two", "three"]
        )

        XCTAssertEqual(
            VariadicConsumesRemainderCommand.captured,
            .init(first: "one", rest: ["two", "three"])
        )
    }

    @MainActor
    func testVariadicPositionalArrayMustBeLast() async {
        do {
            try await VariadicMustBeLastCommand.main(
                arguments: ["variadic-must-be-last", "a", "b"]
            )
            XCTFail("Expected parsing error")
        } catch {
            XCTAssertEqual(error as? HelixError, .parsingError("Variadic argument rest must be last"))
        }
    }

    @MainActor
    func testExtraPositionalArgumentsThrow() async {
        do {
            try await ExtraPositionalsCommand.main(arguments: ["extra-positionals", "one", "extra"])
            XCTFail("Expected parsing error")
        } catch {
            XCTAssertEqual(error as? HelixError, .parsingError("Unexpected arguments: extra"))
        }
    }
}

