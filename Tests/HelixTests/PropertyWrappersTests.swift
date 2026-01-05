import XCTest
@testable import Helix

final class PropertyWrappersTests: XCTestCase {

    // MARK: - Option Tests

    func testOptionWithDefaultValue() {
        let option = Option<Int>(wrappedValue: 42, name: .automatic)
        XCTAssertEqual(option.wrappedValue, 42)
    }

    func testOptionRegistration() {
        var signature = CommandSignature()
        let option = Option<String>(name: .shortAndLong, help: "Output file")
        option.register(label: "output", signature: &signature)

        XCTAssertEqual(signature.options.count, 1)
        XCTAssertEqual(signature.options[0].label, "output")
    }

    // MARK: - Argument Tests

    func testArgumentWithDefaultValue() {
        let arg = Argument<String>(wrappedValue: "default", help: "Input file")
        XCTAssertEqual(arg.wrappedValue, "default")
    }

    func testArgumentRegistration() {
        var signature = CommandSignature()
        let arg = Argument<String>(help: "Input file")
        arg.register(label: "input", signature: &signature)

        XCTAssertEqual(signature.arguments.count, 1)
        XCTAssertEqual(signature.arguments[0].label, "input")
    }

    // MARK: - Flag Tests

    func testFlagDefaultValue() {
        let flag = Flag()
        XCTAssertFalse(flag.wrappedValue)
    }

    func testFlagWithDefaultTrue() {
        let flag = Flag(wrappedValue: true)
        XCTAssertTrue(flag.wrappedValue)
    }

    func testFlagRegistration() {
        var signature = CommandSignature()
        let flag = Flag(name: .shortAndLong, help: "Verbose output")
        flag.register(label: "verbose", signature: &signature)

        XCTAssertEqual(signature.flags.count, 1)
        XCTAssertEqual(signature.flags[0].label, "verbose")
    }

    // MARK: - OptionGroup Tests

    func testOptionGroupInitialization() {
        struct GlobalOptions: HelixParsable {
            @Option(name: .shortAndLong)
            var verbose: Bool = false

            @Option(name: .short(Character("o")), help: "Output directory")
            var output: String = "."
        }

        let group = OptionGroup(wrappedValue: GlobalOptions())
        XCTAssertFalse(group.wrappedValue.verbose)
        XCTAssertEqual(group.wrappedValue.output, ".")
    }

    // MARK: - Sanitization Tests

    func testOptionLabelSanitization() {
        var signature = CommandSignature()
        let option = Option<String>(name: .automatic)
        option.register(label: "_internalName", signature: &signature)

        XCTAssertEqual(signature.options[0].label, "internalName")
    }

    func testArgumentLabelSanitization() {
        var signature = CommandSignature()
        let arg = Argument<String>()
        arg.register(label: "_hiddenArg", signature: &signature)

        XCTAssertEqual(signature.arguments[0].label, "hiddenArg")
    }
}
