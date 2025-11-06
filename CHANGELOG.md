# Changelog

All notable changes to this project will be documented in this file.

## 0.4.0

### New Features

**YAML Configuration Support**

- Configure project settings in your `pubspec.yaml` instead of passing CLI arguments every time
- Store API token securely in `PO_EDITOR_API_TOKEN` environment variable
- Use custom config files with `--config` option
- Configuration priority: CLI arguments > Environment variables > YAML config > Defaults

**Progress Indicators & Verbosity Control**

- See download progress for each language file: "⏳ Downloading en.arb (1/5)..."
- Color-coded output: ✅ success, ⚠️ warnings, ❌ errors
- `--quiet` mode for CI/CD (only show errors)
- `--verbose` mode for debugging (show detailed information)
- Success summary when complete

**Improved Reliability**

- Automatic retry with exponential backoff for transient failures (network issues, server errors)
- Automatic creation of output directory if it doesn't exist
- Better error messages with detailed information when something goes wrong

### Improvements

- Lower Dart SDK requirement to `^3.0.0` for broader compatibility
- All CLI arguments are now optional when using YAML configuration
- Security warning if API token is found in YAML files (use environment variable instead)

**Breaking Changes:** None - fully backward compatible with existing CLI usage

**Getting Started:**

```yaml
# pubspec.yaml
po_editor:
  project_id: "12345"
  files_path: "lib/l10n/"
```

```bash
# Set API token as environment variable
export PO_EDITOR_API_TOKEN="your_token_here"

# Run with minimal arguments
dart run po_editor_downloader
```

See README for complete configuration options.

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
