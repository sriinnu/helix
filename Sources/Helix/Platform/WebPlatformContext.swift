import Foundation

#if os(WASI)

/// Platform context implementation for WebAssembly (WASI).
public struct WebPlatformContext: PlatformContext {

    /// Creates a new WebAssembly platform context.
    public init() {}

    public var arguments: [String] {
        // WASM doesn't have command-line arguments in the traditional sense
        // Arguments can be provided via JavaScript interop or query params
        #if canImport(JavaScriptKit)
        return WASMArguments.getArguments()
        #else
        return []
        #endif
    }

    public func environmentVariable(_ name: String) -> String? {
        // WASM doesn't have environment variables
        return nil
    }

    public var stdin: StdioStream {
        WebStdioStream(type: .stdin)
    }

    public var stdout: StdioStream {
        WebStdioStream(type: .stdout)
    }

    public var stderr: StdioStream {
        WebStdioStream(type: .stderr)
    }

    public func exit(code: Int32) -> Never {
        // WASM can't actually exit - we throw instead
        throw HelixError.webAssemblyExit(code)
    }

    public var currentWorkingDirectory: PlatformPath {
        // WASM has no file system concept
        return PlatformPath("/")
    }
}

// MARK: - Web Stdio Stream

#if canImport(JavaScriptKit)
import JavaScriptKit

struct WebStdioStream: StdioStream {
    enum StreamType {
        case stdin
        case stdout
        case stderr
    }

    let type: StreamType

    func read(upToCount count: Int) throws -> Data? {
        // JavaScript interop for reading stdin would go here
        return nil
    }

    func write(_ data: Data) throws {
        guard let string = String(data: data, encoding: .utf8) else { return }

        switch type {
        case .stdout:
            JavaScriptKit.console.log(string)
        case .stderr:
            JavaScriptKit.console.error(string)
        case .stdin:
            break // Can't write to stdin
        }
    }

    func flush() throws {
        // No-op for web
    }
}

#elseif FOUNDATION_FRAMEWORK

import Foundation

struct WebStdioStream: StdioStream {
    enum StreamType {
        case stdin
        case stdout
        case stderr
    }

    let type: StreamType

    func read(upToCount count: Int) throws -> Data? {
        return nil
    }

    func write(_ data: Data) throws {
        guard let string = String(data: data, encoding: .utf8) else { return }

        // Use Foundation's file descriptor to write to console
        switch type {
        case .stdout:
            FileHandle.standardOutput.write(data)
        case .stderr:
            FileHandle.standardError.write(data)
        case .stdin:
            break
        }
    }

    func flush() throws {
        FileHandle.standardOutput.synchronizeFile()
    }
}

#endif

// MARK: - WASM Arguments Helper

#if canImport(JavaScriptKit)
enum WASMArguments {
    static func getArguments() -> [String] {
        // This would use JavaScriptKit to access arguments
        // passed via the `args` property in wasi_snapshot_preview1
        return []
    }
}
#endif

#endif
