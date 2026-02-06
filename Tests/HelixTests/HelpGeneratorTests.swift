import XCTest
@testable import Helix

final class HelpGeneratorTests: XCTestCase {

    func testUsageFormatsFlagsAndOptionsWithDashes() {
        var signature = CommandSignature()
        Flag(name: .longName("verbose"), help: "Verbose output").register(label: "verbose", signature: &signature)
        Option<String>(name: .longName("output"), help: "Output file").register(label: "output", signature: &signature)
        Argument<String>(help: "Input file").register(label: "input", signature: &signature)

        let descriptor = CommandDescriptor(
            name: "tool",
            abstract: "",
            discussion: nil,
            signature: signature)

        let output = HelpGenerator(descriptor: descriptor).output

        XCTAssertTrue(output.contains("USAGE: tool [--verbose] [--output <output>] <input>"))
        XCTAssertTrue(output.contains("--output <output>"))
        XCTAssertTrue(output.contains("Output file"))
    }
}
