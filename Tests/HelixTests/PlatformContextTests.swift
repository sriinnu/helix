import XCTest
@testable import Helix

final class PlatformContextTests: XCTestCase {

    // MARK: - Mock Platform Context

    func testMockPlatformContextArguments() {
        let ctx = MockPlatformContext(arguments: ["arg1", "arg2"])
        XCTAssertEqual(ctx.arguments, ["arg1", "arg2"])
    }

    func testMockPlatformContextEnvironmentVariable() {
        let ctx = MockPlatformContext(environment: ["KEY": "value"])
        XCTAssertEqual(ctx.environmentVariable("KEY"), "value")
        XCTAssertNil(ctx.environmentVariable("UNKNOWN"))
    }

    func testMockPlatformContextEnvironmentDict() {
        let ctx = MockPlatformContext(environment: ["A": "1", "B": "2"])
        XCTAssertEqual(ctx.environment["A"], "1")
        XCTAssertEqual(ctx.environment["B"], "2")
    }

    func testMockPlatformContextWorkingDirectory() {
        let ctx = MockPlatformContext(currentDirectory: "/test/path")
        XCTAssertEqual(ctx.currentWorkingDirectory.string, "/test/path")
    }

    // MARK: - Default Platform Context

    func testDefaultPlatformContextNotNil() {
        let ctx = DefaultPlatformContext.shared
        XCTAssertNotNil(ctx)
    }

    func testDefaultPlatformContextHasArguments() {
        let ctx = DefaultPlatformContext.shared
        XCTAssertFalse(ctx.arguments.isEmpty)
    }

    func testDefaultPlatformContextEnvironmentAccess() {
        let ctx = DefaultPlatformContext.shared
        _ = ctx.environment
    }
}
