import Foundation

#if os(Windows)

import WinSDK

/// Platform context implementation for Windows.
public struct WindowsPlatformContext: PlatformContext {

    /// Creates a new Windows platform context.
    public init() {}

    public var arguments: [String] {
        let argc = Int(CommandLine.argc)
        var result: [String] = []

        for i in 0..<argc {
            guard let arg = CommandLine.unsafeArgv[i] else { continue }
            if let str = String(validatingUTF8: arg) {
                result.append(str)
            }
        }

        return Array(result.dropFirst())
    }

    public func environmentVariable(_ name: String) -> String? {
        // Try wide string first (Windows API uses UTF-16)
        let wideBuffer = UnsafeMutablePointer<UInt16>.allocate(capacity: 32767)
        defer { wideBuffer.deallocate() }

        let wideName = name.utf16
        for (index, codeUnit) in wideName.enumerated() {
            wideBuffer[index] = codeUnit
        }
        wideBuffer[wideName.count] = 0

        let length = GetEnvironmentVariableW(wideBuffer, nil, 0)
        guard length > 0 else { return nil }

        let valueBuffer = UnsafeMutablePointer<UInt16>.allocate(capacity: length)
        defer { valueBuffer.deallocate() }

        GetEnvironmentVariableW(wideBuffer, valueBuffer, length)

        if let str = String(utf16CodeUnits: valueBuffer, count: length) {
            return str
        }

        // Fallback to _environ (ANSI)
        return nil
    }

    public var stdin: StdioStream {
        FileHandleStdioStream(.stdin)
    }

    public var stdout: StdioStream {
        FileHandleStdioStream(.stdout)
    }

    public var stderr: StdioStream {
        FileHandleStdioStream(.stderr)
    }

    public func exit(code: Int32) -> Never {
        ExitProcess(UInt32(code))
    }

    public var currentWorkingDirectory: PlatformPath {
        let buffer = UnsafeMutablePointer<UInt16>.allocate(capacity: 32767)
        defer { buffer.deallocate() }

        let length = GetCurrentDirectoryW(32767, buffer)
        guard length > 0 else { return PlatformPath("") }

        let path = String(utf16CodeUnits: buffer, count: Int(length))
        return PlatformPath(path)
    }
}

#endif
