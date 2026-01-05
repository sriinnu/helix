import XCTest
@testable import Helix

final class StdioTests: XCTestCase {

    // MARK: - BufferStdioStream

    func testBufferStdioStreamWrite() throws {
        let stream = BufferStdioStream()
        try stream.write("Hello".data(using: .utf8)!)

        XCTAssertEqual(stream.outputString, "Hello")
    }

    func testBufferStdioStreamWriteMultiple() throws {
        let stream = BufferStdioStream()
        try stream.write("Hello ".data(using: .utf8)!)
        try stream.write("World".data(using: .utf8)!)

        XCTAssertEqual(stream.outputString, "Hello World")
    }

    func testBufferStdioStreamRead() throws {
        let inputData = "test input".data(using: .utf8)!
        let stream = BufferStdioStream(input: inputData)

        let readData = try stream.read(upToCount: 4)
        XCTAssertEqual(String(data: readData!, encoding: .utf8), "test")
    }

    func testBufferStdioStreamReadExhausted() throws {
        let inputData = "ab".data(using: .utf8)!
        let stream = BufferStdioStream(input: inputData)

        _ = try stream.read(upToCount: 10)
        let exhaustedRead = try stream.read(upToCount: 5)

        XCTAssertNil(exhaustedRead)
    }

    func testBufferStdioStreamFlush() throws {
        let stream = BufferStdioStream()
        try stream.flush() // Should not crash
    }
}
