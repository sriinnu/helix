# Changelog

All notable changes to this project will be documented in this file.

The format is based on "Keep a Changelog", and this project aims to follow Semantic Versioning.

## Unreleased

### Added

- Automatic binding for `@Option`, `@Argument`, `@Flag`, and `@OptionGroup`.
- Built-in `--help` / `--version` handling.
- `--opt=value` and `-o=value` parsing.
- Linux platform context and multi-OS CI (macOS, Linux, Windows).

### Fixed

- `Program.resolve` argv normalization for single-root commands.
- Help output formatting and option rendering.
- Windows environment variable and current directory handling.
- WASI platform context semantics.

