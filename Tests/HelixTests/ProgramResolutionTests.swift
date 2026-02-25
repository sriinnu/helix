import XCTest
@testable import Helix

final class ProgramResolutionTests: XCTestCase {

    func testSingleRootResolvesWithoutRootName() throws {
        let root = CommandDescriptor(
            name: "tool",
            abstract: "",
            discussion: nil,
            signature: CommandSignature())
        let program = Program(descriptors: [root])

        let invocation = try program.resolve(argv: ["input.txt"])

        XCTAssertEqual(invocation.path, ["tool"])
        XCTAssertEqual(invocation.parsedValues.positional, ["input.txt"])
    }

    func testSingleRootStripsExecutableLikePrefix() throws {
        let root = CommandDescriptor(
            name: "tool",
            abstract: "",
            discussion: nil,
            signature: CommandSignature())
        let program = Program(descriptors: [root])

        let invocation = try program.resolve(argv: ["/usr/bin/tool", "input.txt"])

        XCTAssertEqual(invocation.path, ["tool"])
        XCTAssertEqual(invocation.parsedValues.positional, ["input.txt"])
    }

    func testSingleRootRetainsPathLikePositionalArgument() throws {
        var signature = CommandSignature()
        Argument<String>(help: "Input").register(label: "input", signature: &signature)
        let root = CommandDescriptor(
            name: "tool",
            abstract: "",
            discussion: nil,
            signature: signature)
        let program = Program(descriptors: [root])

        let invocation = try program.resolve(argv: ["/tmp/input.txt"])

        XCTAssertEqual(invocation.path, ["tool"])
        XCTAssertEqual(invocation.parsedValues.positional, ["/tmp/input.txt"])
    }

    func testSingleRootStripsWindowsExecutableLikePrefix() throws {
        let root = CommandDescriptor(
            name: "tool",
            abstract: "",
            discussion: nil,
            signature: CommandSignature())
        let program = Program(descriptors: [root])

        let invocation = try program.resolve(argv: ["C:\\Program Files\\tool", "input.txt"])

        XCTAssertEqual(invocation.path, ["tool"])
        XCTAssertEqual(invocation.parsedValues.positional, ["input.txt"])
    }

    func testSingleRootStripsWindowsExeLikePrefix() throws {
        let root = CommandDescriptor(
            name: "tool",
            abstract: "",
            discussion: nil,
            signature: CommandSignature())
        let program = Program(descriptors: [root])

        let invocation = try program.resolve(argv: ["C:\\Program Files\\tool.EXE", "input.txt"])

        XCTAssertEqual(invocation.path, ["tool"])
        XCTAssertEqual(invocation.parsedValues.positional, ["input.txt"])
    }

    func testSingleRootRetainsWindowsPathLikePositionalArgument() throws {
        var signature = CommandSignature()
        Argument<String>(help: "Input").register(label: "input", signature: &signature)
        let root = CommandDescriptor(
            name: "tool",
            abstract: "",
            discussion: nil,
            signature: signature)
        let program = Program(descriptors: [root])

        let invocation = try program.resolve(argv: ["C:\\Users\\me\\input.txt"])

        XCTAssertEqual(invocation.path, ["tool"])
        XCTAssertEqual(invocation.parsedValues.positional, ["C:\\Users\\me\\input.txt"])
    }

    func testResolveDefaultSubcommandWhenNoneProvided() throws {
        let build = CommandDescriptor(name: "build", abstract: "", discussion: nil, signature: CommandSignature())
        let root = CommandDescriptor(
            name: "tool",
            abstract: "",
            discussion: nil,
            signature: CommandSignature(),
            subcommands: [build],
            defaultSubcommandName: "build"
        )
        let program = Program(descriptors: [root])

        let invocationFromExplicitRoot = try program.resolve(argv: ["tool"])
        XCTAssertEqual(invocationFromExplicitRoot.path, ["tool", "build"])
        XCTAssertTrue(invocationFromExplicitRoot.parsedValues.positional.isEmpty)

        let invocationFromExecutable = try program.resolve(argv: ["/usr/bin/tool"])
        XCTAssertEqual(invocationFromExecutable.path, ["tool", "build"])
        XCTAssertTrue(invocationFromExecutable.parsedValues.positional.isEmpty)
    }

    func testResolveThrowsUnknownSubcommandWhenSubcommandIsInvalid() throws {
        let build = CommandDescriptor(name: "build", abstract: "", discussion: nil, signature: CommandSignature())
        let root = CommandDescriptor(
            name: "tool",
            abstract: "",
            discussion: nil,
            signature: CommandSignature(),
            subcommands: [build]
        )
        let program = Program(descriptors: [root])

        XCTAssertThrowsError(try program.resolve(argv: ["tool", "deploy"])) { error in
            XCTAssertEqual(error as? HelixError, .unknownSubcommand(command: "tool", name: "deploy"))
        }
    }

    func testResolveThrowsMissingSubcommandWhenSubcommandRequired() throws {
        let build = CommandDescriptor(name: "build", abstract: "", discussion: nil, signature: CommandSignature())
        let root = CommandDescriptor(
            name: "tool",
            abstract: "",
            discussion: nil,
            signature: CommandSignature(),
            subcommands: [build]
        )
        let program = Program(descriptors: [root])

        XCTAssertThrowsError(try program.resolve(argv: ["tool"])) { error in
            XCTAssertEqual(error as? HelixError, .missingSubcommand(command: "tool"))
        }
    }

    func testResolveThrowsMissingCommandWhenMultipleRootsGivenNoMatch() throws {
        let first = CommandDescriptor(name: "alpha", abstract: "", discussion: nil, signature: CommandSignature())
        let second = CommandDescriptor(name: "beta", abstract: "", discussion: nil, signature: CommandSignature())
        let program = Program(descriptors: [first, second])

        XCTAssertThrowsError(try program.resolve(argv: ["gamma"])) { error in
            XCTAssertEqual(error as? HelixError, .unknownCommand("gamma"))
        }
    }
}
