# Contributing to Helix

## Development Setup

- Swift 6.x
- macOS, Linux, or Windows

Run tests:

```bash
swift test
```

## Scope and Expectations

- Keep public API changes intentional and documented.
- Prefer additive changes over breaking changes.
- Add tests for behavior changes and bug fixes.
- Keep help output stable (tests should cover formatting when possible).

## Pull Requests

- Keep PRs focused (one logical change set).
- Include a short description of user-facing behavior changes.
- Ensure `swift test` passes.

## Code Style

- Swift 6 strict concurrency is enabled.
- Avoid private runtime reflection and SPI.
- Prefer clear error messages (`HelixError.parsingError(...)`) over `fatalError` for user input failures.

