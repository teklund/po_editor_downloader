# Changelog

All notable changes to this project will be documented in this file.

## 1.0.2

- fix: resolve 10-second hang after CLI execution by properly closing HTTP client connections
- fix: improve resource cleanup to prevent lingering network connections
- docs: update example documentation to reflect current API usage

## 1.0.1

- docs: add comprehensive library documentation with usage examples
- docs: create `example/` directory with working code examples
- docs: add `example/README.md` with detailed instructions
- fix: resolve pub.dev score issues (missing documentation and example)

## 1.0.0

- feat: add YAML configuration support in `pubspec.yaml`
- feat: add `PO_EDITOR_API_TOKEN` environment variable support
- feat: add custom config files with `--config` option
- feat: implement configuration priority (CLI > Environment > YAML > Defaults)
- feat: add progress indicators for each language download
- feat: add color-coded output (✅ success, ⚠️ warnings, ❌ errors)
- feat: add `--quiet` mode for CI/CD
- feat: add `--verbose` mode for debugging
- feat: add automatic retry with exponential backoff for transient failures
- feat: add automatic output directory creation
- feat: add custom filename patterns with `{locale}` placeholder
- feat: make all CLI arguments optional when using YAML configuration
- feat: add security warning if API token is found in YAML files
- improve: enhance error messages with detailed information

## 0.3.0

- test: Added tests.
- docs: Added docs on methods.

## 0.2.2

- docs: Updated readme.

## 0.2.1

- docs: Updated readme.

## 0.2.0

- Initial script release.
