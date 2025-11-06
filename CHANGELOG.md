# Changelog

All notable changes to this project will be documented in this file.

## 1.0.1

### Documentation

- Added comprehensive library documentation with usage examples
- Created `example/` directory with working code examples
- Added `example/README.md` with detailed instructions
- Fixes pub.dev score issues (missing documentation and example)

## 1.0.0

### New Features

#### YAML Configuration Support

- Configure project settings in your `pubspec.yaml` instead of passing CLI arguments every time
- Store API token securely in `PO_EDITOR_API_TOKEN` environment variable
- Use custom config files with `--config` option
- Configuration priority: CLI arguments > Environment variables > YAML config > Defaults

#### Progress Indicators & Verbosity Control

- See download progress for each language file: "⏳ Downloading en.arb (1/5)..."
- Color-coded output: ✅ success, ⚠️ warnings, ❌ errors
- `--quiet` mode for CI/CD (only show errors)
- `--verbose` mode for debugging (show detailed information)
- Success summary when complete

#### Improved Reliability

- Automatic retry with exponential backoff for transient failures (network issues, server errors)
- Automatic creation of output directory if it doesn't exist
- Better error messages with detailed information when something goes wrong

#### Custom Filename Patterns

- Customize ARB file naming with `filename_pattern` option
- Use `{locale}` placeholder for language code
- Examples: `{locale}.arb`, `intl_{locale}.arb`, `translations_{locale}.arb`
- Default pattern: `app_{locale}.arb` (maintains backward compatibility)

### Improvements

- All CLI arguments are now optional when using YAML configuration
- Security warning if API token is found in YAML files (use environment variable instead)

**Breaking Changes:** None - fully backward compatible with existing CLI usage

## 0.3.0

- test: Added tests.
- docs: Added docs on methods.

## 0.2.2

- docs: Updated readme.

## 0.2.1

- docs: Updated readme.

## 0.2.0

- Initial script release.
