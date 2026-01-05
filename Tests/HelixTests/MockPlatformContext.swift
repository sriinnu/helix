import Foundation
@testable import Helix

/// A mock platform context for testing.
public final class MockPlatformContext: @unchecked Sendable, PlatformContext {
    private let _arguments: [String]
    private let _environment: [String: String]
    private let _currentDirectory: PlatformPath

    public init(
        arguments: [String] = [],
        environment: [String: String] = [:],
        currentDirectory: String = "/mock/workspace"
    ) {
        self._arguments = arguments
        self._environment = environment
        self._currentDirectory = PlatformPath(currentDirectory)
    }

    public var arguments: [String] {
        _arguments
    }

    public func environmentVariable(_ name: String) -> String? {
        _environment[name]
    }

    public var stdin: StdioStream {
        BufferStdioStream()
    }

    public var stdout: StdioStream {
        BufferStdioStream()
    }

    public var stderr: StdioStream {
        BufferStdioStream()
    }

    public func exit(code: Int32) -> Never {
        // In tests, we use preconditionFailure instead of exit
        // since exit(code:) is marked as Never
        preconditionFailure("exit(code:) called with code: \(code)")
    }

    public var currentWorkingDirectory: PlatformPath {
        _currentDirectory
    }

    public var environment: [String: String] {
        _environment
    }
}
