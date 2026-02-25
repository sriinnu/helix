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

private struct InvalidIntOptionCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(commandName: "invalid-int-option")
    }

    @Option
    var count: Int

    init() {}

    mutating func run() async throws {}
}

private struct InvalidIntArgumentCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(commandName: "invalid-int-argument")
    }

    @Argument
    var number: Int

    init() {}

    mutating func run() async throws {}
}

private struct InvalidIntArrayOptionCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(commandName: "invalid-int-array-option")
    }

    @Option(wrappedValue: [])
    var values: [Int]

    init() {}

    mutating func run() async throws {}
}

private struct MissingArrayOptionCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(commandName: "missing-array-option")
    }

    @Option
    var values: [Int]

    init() {}

    mutating func run() async throws {}
}

private struct RepeatedArrayOptionCommand: ParsableCommand {
    struct Captured: Sendable, Equatable {
        let values: [Int]
    }

    @MainActor
    static var captured: Captured?

    static var commandDescription: CommandDescription {
        CommandDescription(commandName: "repeated-array-option")
    }

    @Option(wrappedValue: [])
    var values: [Int]

    init() {}

    mutating func run() async throws {
        Self.captured = Captured(values: values)
    }
}

private struct ValidateCountCommand: ParsableCommand {
    struct Captured: Sendable, Equatable {
        let count: Int
    }

    @MainActor
    static var captured: Captured?

    @MainActor
    static var runCount = 0

    static var commandDescription: CommandDescription {
        CommandDescription(commandName: "validate-command")
    }

    @Option
    var count: Int

    init() {}

    mutating func validate() throws {
        if count <= 0 {
            throw ValidationError("count must be non-negative")
        }
    }

    mutating func run() async throws {
        Self.runCount += 1
        Self.captured = Captured(count: count)
    }
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

    @MainActor
    func testInvalidIntOptionThrowsParsingError() async {
        do {
            try await InvalidIntOptionCommand.main(arguments: ["invalid-int-option", "--count", "not-a-number"])
            XCTFail("Expected parsing error")
        } catch {
            XCTAssertEqual(error as? HelixError, .parsingError("Invalid value for option count"))
        }
    }

    @MainActor
    func testInvalidIntArgumentThrowsParsingError() async {
        do {
            try await InvalidIntArgumentCommand.main(arguments: ["invalid-int-argument", "not-a-number"])
            XCTFail("Expected parsing error")
        } catch {
            XCTAssertEqual(error as? HelixError, .parsingError("Invalid value for argument number"))
        }
    }

    @MainActor
    func testInvalidIntArrayOptionThrowsParsingError() async {
        do {
            try await InvalidIntArrayOptionCommand.main(arguments: ["invalid-int-array-option", "--values", "1,2,x"])
            XCTFail("Expected parsing error")
        } catch {
            XCTAssertEqual(error as? HelixError, .parsingError("Invalid value for option values"))
        }
    }

    @MainActor
    func testMissingRequiredArrayOptionThrowsParsingError() async {
        do {
            try await MissingArrayOptionCommand.main(arguments: ["missing-array-option"])
            XCTFail("Expected parsing error")
        } catch {
            XCTAssertEqual(error as? HelixError, .parsingError("Missing value for option values"))
        }
    }

    @MainActor
    func testRepeatedArrayOptionValuesAreFlattenedAndParsed() async throws {
        RepeatedArrayOptionCommand.captured = nil

        try await RepeatedArrayOptionCommand.main(
            arguments: ["repeated-array-option", "--values", "1,2", "--values", "3"]
        )

        XCTAssertEqual(
            RepeatedArrayOptionCommand.captured,
            .init(values: [1, 2, 3])
        )
    }

    @MainActor
    func testValidateMethodRunsBeforeRun() async {
        ValidateCountCommand.runCount = 0
        ValidateCountCommand.captured = nil

        do {
            try await ValidateCountCommand.main(arguments: ["validate-command", "--count", "0"])
            XCTFail("Expected validation error")
        } catch {
            XCTAssertEqual(ValidateCountCommand.runCount, 0)
            XCTAssertEqual(error.localizedDescription, "count must be non-negative")
        }
    }
}
