import XCTest
@testable import Helix

final class CommandParserTests: XCTestCase {

    // MARK: - Basic Parsing

    func testParseEmptyArguments() throws {
        let signature = CommandSignature()
        let parser = CommandParser(signature: signature)
        let values = try parser.parse(arguments: [])
        XCTAssertTrue(values.positional.isEmpty)
        XCTAssertTrue(values.options.isEmpty)
        XCTAssertTrue(values.flags.isEmpty)
    }

    func testParsePositionalArgument() throws {
        var signature = CommandSignature()
        Argument<String>(help: "Input file").register(label: "input", signature: &signature)

        let parser = CommandParser(signature: signature)
        let values = try parser.parse(arguments: ["file.txt"])

        XCTAssertEqual(values.positional, ["file.txt"])
    }

    func testParseMultiplePositionalArguments() throws {
        var signature = CommandSignature()
        Argument<String>(help: "Files").register(label: "files", signature: &signature)

        let parser = CommandParser(signature: signature)
        let values = try parser.parse(arguments: ["a.txt", "b.txt", "c.txt"])

        XCTAssertEqual(values.positional, ["a.txt", "b.txt", "c.txt"])
    }

    // MARK: - Options

    func testParseLongOption() throws {
        var signature = CommandSignature()
        Option<String>(name: .longName("output"), help: "Output file").register(label: "output", signature: &signature)

        let parser = CommandParser(signature: signature)
        let values = try parser.parse(arguments: ["--output", "result.txt"])

        XCTAssertEqual(values.options["output"], ["result.txt"])
    }

    func testParseLongOptionWithEquals() throws {
        var signature = CommandSignature()
        Option<String>(name: .longName("output"), help: "Output file").register(label: "output", signature: &signature)

        let parser = CommandParser(signature: signature)
        let values = try parser.parse(arguments: ["--output=result.txt"])

        XCTAssertEqual(values.options["output"], ["result.txt"])
    }

    func testParseShortOption() throws {
        var signature = CommandSignature()
        Option<String>(name: .short(Character("o")), help: "Output file").register(label: "output", signature: &signature)

        let parser = CommandParser(signature: signature)
        let values = try parser.parse(arguments: ["-o", "result.txt"])

        XCTAssertEqual(values.options["output"], ["result.txt"])
    }

    func testParseShortOptionWithEquals() throws {
        var signature = CommandSignature()
        Option<String>(name: .short(Character("o")), help: "Output file").register(label: "output", signature: &signature)

        let parser = CommandParser(signature: signature)
        let values = try parser.parse(arguments: ["-o=result.txt"])

        XCTAssertEqual(values.options["output"], ["result.txt"])
    }

    func testParseShortAndLongOption() throws {
        var signature = CommandSignature()
        Option<String>(name: .shortAndLong, help: "Output file").register(label: "output", signature: &signature)

        let parser = CommandParser(signature: signature)

        let shortValues = try parser.parse(arguments: ["-o", "short.txt"])
        XCTAssertEqual(shortValues.options["output"], ["short.txt"])

        let longValues = try parser.parse(arguments: ["--output", "long.txt"])
        XCTAssertEqual(longValues.options["output"], ["long.txt"])
    }

    func testParseUnknownOptionThrows() throws {
        var signature = CommandSignature()
        Option<String>(name: .automatic, help: "Known option").register(label: "known", signature: &signature)

        let parser = CommandParser(signature: signature)

        XCTAssertThrowsError(try parser.parse(arguments: ["--unknown", "value"])) { error in
            XCTAssertEqual(error as? HelixError, .parsingError("Unknown option --unknown"))
        }
    }

    func testParseOptionWithoutValueThrows() throws {
        var signature = CommandSignature()
        Option<String>(name: .automatic, help: "Option").register(label: "option", signature: &signature)

        let parser = CommandParser(signature: signature)

        XCTAssertThrowsError(try parser.parse(arguments: ["--option"])) { error in
            XCTAssertEqual(error as? HelixError, .parsingError("Missing value for option option"))
        }
    }

    // MARK: - Flags

    func testParseFlag() throws {
        var signature = CommandSignature()
        Flag(name: .shortAndLong).register(label: "verbose", signature: &signature)

        let parser = CommandParser(signature: signature)
        let values = try parser.parse(arguments: ["--verbose"])

        XCTAssertTrue(values.flags.contains("verbose"))
    }

    func testParseShortFlags() throws {
        var signature = CommandSignature()
        Flag(name: .short(Character("v"))).register(label: "verbose", signature: &signature)
        Flag(name: .short(Character("f"))).register(label: "force", signature: &signature)

        let parser = CommandParser(signature: signature)
        let values = try parser.parse(arguments: ["-vf"])

        XCTAssertTrue(values.flags.contains("verbose"))
        XCTAssertTrue(values.flags.contains("force"))
    }

    func testParseUnknownFlagThrows() throws {
        var signature = CommandSignature()
        Flag(name: .short(Character("v"))).register(label: "verbose", signature: &signature)

        let parser = CommandParser(signature: signature)

        // -x is parsed as an option with value "x" since -x could be short for --x
        XCTAssertThrowsError(try parser.parse(arguments: ["-x"])) { error in
            XCTAssertEqual(error as? HelixError, .parsingError("Unknown option --x"))
        }
    }

    // MARK: - Mixed Arguments

    func testParseMixedOptionsAndPositionals() throws {
        var signature = CommandSignature()
        Option<String>(name: .shortAndLong, help: "Output").register(label: "output", signature: &signature)
        Flag(name: .short(Character("v")), help: "Verbose").register(label: "verbose", signature: &signature)
        Argument<String>(help: "Input file").register(label: "input", signature: &signature)

        let parser = CommandParser(signature: signature)
        let values = try parser.parse(arguments: ["--output", "out.txt", "-v", "in.txt"])

        XCTAssertEqual(values.options["output"], ["out.txt"])
        XCTAssertTrue(values.flags.contains("verbose"))
        XCTAssertEqual(values.positional, ["in.txt"])
    }

    func testParseTerminator() throws {
        var signature = CommandSignature()
        Option<String>(name: .automatic, help: "Option").register(label: "option", signature: &signature)

        let parser = CommandParser(signature: signature)
        let values = try parser.parse(arguments: ["--option", "value", "--", "-not-an-option.txt"])

        XCTAssertEqual(values.options["option"], ["value"])
        XCTAssertEqual(values.positional, ["-not-an-option.txt"])
    }

    // MARK: - Multiple Options

    func testParseMultipleOptionValues() throws {
        var signature = CommandSignature()
        Option<String>(name: .shortAndLong, help: "Files").register(label: "files", signature: &signature)

        let parser = CommandParser(signature: signature)
        let values = try parser.parse(arguments: ["--files", "a.txt", "--files", "b.txt"])

        XCTAssertEqual(values.options["files"], ["a.txt", "b.txt"])
    }

    func testParseArrayOption() throws {
        var signature = CommandSignature()
        Option<[String]>(name: .shortAndLong, help: "Tags").register(label: "tags", signature: &signature)

        let parser = CommandParser(signature: signature)
        let values = try parser.parse(arguments: ["--tags", "swift,cli,macos"])

        XCTAssertEqual(values.options["tags"], ["swift,cli,macos"])
    }
}
