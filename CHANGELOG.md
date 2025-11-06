# Changelog

All notable changes to this project will be documented in this file.

## 0.5.0

- refactor: Remove redundant `ArgumentValueParser` class (use `ArgParser` directly)
- refactor: Extract `downloadTranslations()` and `writeArbFile()` functions from main
- refactor: Simplify main() function to orchestrate workflow only
- feat: Add retry logic with exponential backoff for API calls
- feat: Retry on transient failures (5xx errors, network errors)
- feat: Skip retry on client errors (4xx errors)
- feat: Add `onRetry` callback for monitoring retry attempts
- test: Add 13 new tests for retry logic (144 total)
- refactor: Improve error handling with specific exception catches
- refactor: Use `ArgResult` subscript operator instead of custom parser

**Breaking Changes:** None - fully backward compatible

**Internal Improvements:**
- Main function reduced from 60+ lines to ~15 lines
- Better separation of concerns
- More testable architecture
- Removed 8 redundant ArgumentValueParser tests

## 0.4.1

- feat: Add HTTP client injection to `PoEditorService` for better testability
- feat: Add custom exception classes (`PoEditorApiException`, `PoEditorNetworkException`) with detailed error information
- feat: Add automatic output directory creation and validation
- feat: Add directory writability checks before downloading
- fix: Lower Dart SDK constraint to `^3.0.0` for broader compatibility
- test: Add 30 new tests for HTTP client injection, error handling, and directory validation (138 total)
- refactor: Improve error messages with HTTP status codes and response bodies
- refactor: Network errors now include original error and stack trace

**Breaking Changes:** None - fully backward compatible

## 0.4.0

- feat: Add YAML configuration support - configure project settings in `pubspec.yaml`
- feat: Add environment variable support for API token (`PO_EDITOR_API_TOKEN`)
- feat: Add configuration priority system (CLI > ENV > YAML > Defaults)
- feat: Add custom config file support with `--config` option
- feat: Add security warning when API token found in YAML files
- refactor: Make all CLI arguments optional (can use YAML config instead)
- test: Add comprehensive configuration and integration tests
- docs: Update README with new configuration options and security best practices
- chore: Add `yaml` package dependency

**Breaking Changes:** None - fully backward compatible with existing CLI usage

**Migration Guide:**

- Existing CLI-only usage continues to work without changes
- Recommended: Move project settings to `pubspec.yaml` and use `PO_EDITOR_API_TOKEN` environment variable
- See README for new configuration options

- feat: Add YAML configuration support - configure project settings in `pubspec.yaml`
- feat: Add environment variable support for API token (`PO_EDITOR_API_TOKEN`)
- feat: Add configuration priority system (CLI > ENV > YAML > Defaults)
- feat: Add custom config file support with `--config` option
- feat: Add security warning when API token found in YAML files
- refactor: Make all CLI arguments optional (can use YAML config instead)
- test: Add comprehensive configuration and integration tests
- docs: Update README with new configuration options and security best practices
- chore: Add `yaml` package dependency

**Breaking Changes:** None - fully backward compatible with existing CLI usage

**Migration Guide:**

- Existing CLI-only usage continues to work without changes
- Recommended: Move project settings to `pubspec.yaml` and use `PO_EDITOR_API_TOKEN` environment variable
- See README for new configuration options

## 0.3.1

- chore: Bump minimum Dart SDK version to ^3.9.0

## 0.3.0

- test: Added tests.
- docs: Added docs on methods.

## 0.2.2

- docs: Updated readme.

## 0.2.1

- docs: Updated readme.

## 0.2.0

- Initial script release.
