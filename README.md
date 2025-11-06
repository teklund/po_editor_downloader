# POEditor Downloader

A CLI tool for downloading and converting translations from [POEditor](https://poeditor.com/) to Flutter ARB (Application Resource Bundle) files for Flutter localization.

[![Pub Version](https://img.shields.io/pub/v/po_editor_downloader)](https://pub.dev/packages/po_editor_downloader)
[![Dart SDK](https://img.shields.io/badge/Dart%20SDK-%5E3.4.0-blue)](https://dart.dev)
[![CI](https://github.com/teklund/po_editor_downloader/actions/workflows/pull_request.yml/badge.svg)](https://github.com/teklund/po_editor_downloader/actions/workflows/pull_request.yml)
[![codecov](https://codecov.io/gh/teklund/po_editor_downloader/branch/main/graph/badge.svg)](https://codecov.io/gh/teklund/po_editor_downloader)

## Features

- 📥 Downloads translations from POEditor projects
- 🔄 Converts POEditor exports to Flutter ARB format
- 🏷️ Supports filtering by tags and translation status
- 🔑 Converts translation keys to camelCase automatically
- 📊 Optional metadata inclusion (locale, language, percentage, last updated)
- 🎯 Generates separate ARB files per language (e.g., `app_en.arb`, `app_es.arb`)

## Prerequisites

- Dart SDK ^3.4.0 or higher
- A [POEditor](https://poeditor.com/) account with an active project
- POEditor API token (get it from [Account Settings → API Access](https://poeditor.com/account/api))

## Installation

```sh
flutter pub add dev:po_editor_downloader
```

## Configuration

POEditor Downloader supports multiple configuration methods with a clear priority order:

1. **Command-line arguments** (highest priority)
2. **Environment variables** (for API token)
3. **YAML configuration** in `pubspec.yaml` (for project settings)

### YAML Configuration (Recommended)

Add a `po_editor` section to your `pubspec.yaml`:

```yaml
po_editor:
  # IMPORTANT: Do NOT store api_token here for security reasons!
  project_id: "your_project_id"
  files_path: "lib/l10n/"
  tags: "mobile"
  filters: "translated"
  add_metadata: true
```

**Security Note:** Never commit your API token to version control. Use environment variables or command-line arguments instead.

### Environment Variable (Recommended for API Token)

Set your API token as an environment variable:

```sh
export PO_EDITOR_API_TOKEN="your_api_token"
```

Or add it to your shell profile (`~/.zshrc`, `~/.bashrc`, etc.):

```sh
echo 'export PO_EDITOR_API_TOKEN="your_api_token"' >> ~/.zshrc
```

## Usage

### With YAML + Environment Variable (Recommended)

1. Configure your `pubspec.yaml` with project settings (shown above)
2. Set `PO_EDITOR_API_TOKEN` environment variable
3. Run:

```sh
dart run po_editor_downloader
```

### Command-Line Only

```sh
dart run po_editor_downloader --api_token=your_api_token --project_id=your_project_id
```

### Override YAML Settings

Use command-line arguments to override YAML configuration:

```sh
# Override tags for a specific build
dart run po_editor_downloader --tags=web

# Override filters
dart run po_editor_downloader --filters=proofread

# Override multiple settings
dart run po_editor_downloader --tags=mobile,ios --filters=translated --files_path=assets/l10n/
```

### Custom Configuration File

Use a custom YAML configuration file:

```sh
dart run po_editor_downloader --config=po_editor_config.yaml
```

### Additional Examples

```sh
# Custom file path
dart run po_editor_downloader --files_path=assets/translations/

# Filter by tags (single tag)
dart run po_editor_downloader --tags=mobile

# Filter by multiple tags (comma-separated)
dart run po_editor_downloader --tags=mobile,web

# Filter by status
dart run po_editor_downloader --filters=translated

# Include metadata in ARB files
dart run po_editor_downloader --add_metadata=true
```

## Parameters

### Required

| Parameter | Source | Description |
|-----------|--------|-------------|
| `api_token` | ENV var or CLI | POEditor API token. **Never store in YAML!** |
| `project_id` | YAML or CLI | POEditor project ID |

### Optional

| Parameter | Source | Description | Default |
|-----------|--------|-------------|---------|
| `files_path` | YAML or CLI | Output directory path | `lib/l10n/` |
| `tags` | YAML or CLI | Filter by tags (single tag or comma-separated list) | - |
| `filters` | YAML or CLI | Filter by status: `translated`, `untranslated`, `fuzzy`, `not_fuzzy`, `automatic`, `not_automatic`, `proofread`, `not_proofread` | - |
| `add_metadata` | YAML or CLI | Include metadata (locale, language name, percentage, last updated) in ARB files | `false` |
| `filename_pattern` | YAML or CLI | Filename pattern for ARB files. Use `{locale}` as placeholder (e.g., `{locale}.arb`, `intl_{locale}.arb`) | `app_{locale}.arb` |
| `config` | CLI only | Path to custom YAML configuration file | `pubspec.yaml` |
| `--quiet`, `-q` | CLI only | Quiet mode - show only errors (useful for CI/CD) | - |
| `--verbose`, `-v` | CLI only | Verbose mode - show debug information (useful for troubleshooting) | - |

### Configuration Priority

When the same parameter is provided from multiple sources:

**For API Token (Security Sensitive):**

1. `--api_token` CLI argument (highest priority)
2. `PO_EDITOR_API_TOKEN` environment variable
3. ❌ Never from YAML (will show warning)

**For Other Parameters:**

1. Command-line arguments (highest priority)
2. Custom config file (if `--config` specified)
3. `pubspec.yaml` `po_editor` section
4. Default values (lowest priority)

## Getting Started

1. **Get API Token**: Go to [POEditor Account Settings](https://poeditor.com/account/api) → API Access
1. **Get Project ID**: Found in your POEditor project URL or project settings page
1. **Run the tool** with your credentials
1. **Configure Flutter localization** in your `pubspec.yaml`:

   ```yaml
   flutter:
     generate: true
   ```

1. **Create `l10n.yaml`** in your project root:

   ```yaml
   arb-dir: lib/l10n
   template-arb-file: app_en.arb
   output-localization-file: app_localizations.dart
   ```

1. **Run** `flutter gen-l10n` to generate localization classes

## Output Format

The tool generates ARB files for each language in your POEditor project:

```text
lib/l10n/
  ├── app_en.arb
  ├── app_es.arb
  ├── app_fr.arb
  └── ...
```

**Example ARB file** (`app_en.arb`):

```json
{
    "@@locale": "en",
    "@@updated": "2025-11-06 12:30:00",
    "@@language": "English",
    "@@percentage": "95.5",
    "welcomeMessage": "Welcome to our app",
    "loginButton": "Login",
    "errorMessage": "Something went wrong"
}
```

**Note**: Translation keys are automatically converted to camelCase for consistency with Dart naming conventions.

## Key Features Explained

### Tag Filtering

Filter translations by POEditor tags to manage different contexts or platforms:

```sh
dart run po_editor_downloader --api_token=token --project_id=id --tags=mobile,ios
```

### Status Filtering

Download only translations with specific statuses:

- `translated` - Only translated terms
- `untranslated` - Only untranslated terms
- `fuzzy` - Terms marked as fuzzy
- `not_fuzzy` - Terms not marked as fuzzy
- `automatic` - Automatically translated terms
- `proofread` - Proofread terms

### Metadata

Include additional information in ARB files for tracking and debugging:

```sh
dart run po_editor_downloader --api_token=token --project_id=id --add_metadata=true
```

This adds:

- `@@locale` - Language code
- `@@language` - Language name
- `@@percentage` - Translation completion percentage
- `@@updated` - Last update timestamp

### Verbosity Control

Control the amount of output:

```sh
# Quiet mode - only show errors (useful for CI/CD)
dart run po_editor_downloader --quiet

# Verbose mode - show debug information (useful for troubleshooting)
dart run po_editor_downloader --verbose

# Normal mode (default) - show progress and success messages
dart run po_editor_downloader
```

### Custom Filename Patterns

Customize how ARB files are named using the `filename_pattern` option with `{locale}` as a placeholder:

```sh
# Use simple locale names: en.arb, es.arb
dart run po_editor_downloader --filename_pattern="{locale}.arb"

# Use intl prefix: intl_en.arb, intl_es.arb
dart run po_editor_downloader --filename_pattern="intl_{locale}.arb"

# Use translations prefix: translations_en.arb, translations_es.arb
dart run po_editor_downloader --filename_pattern="translations_{locale}.arb"
```

Or configure in `pubspec.yaml`:

```yaml
po_editor:
  project_id: "12345"
  filename_pattern: "{locale}.arb"  # Generates: en.arb, es.arb, etc.
```

**Common patterns:**

- `app_{locale}.arb` (default) → `app_en.arb`, `app_es.arb`
- `{locale}.arb` → `en.arb`, `es.arb`
- `intl_{locale}.arb` → `intl_en.arb`, `intl_es.arb`
- `l10n_{locale}.arb` → `l10n_en.arb`, `l10n_es.arb`

## Troubleshooting

### Common Issues

#### "Failed to load languages"

- Verify your API token is correct
- Check that the project ID exists and you have access to it
- Ensure your POEditor account has API access enabled

#### "No files generated"

- Check that your POEditor project has languages added
- Verify the output directory exists or can be created
- Ensure there are translations available for the filtered criteria

#### "Permission denied" when writing files

- Verify write permissions for the output directory
- Try running with elevated permissions if needed

#### Empty ARB files

- Check if your filters are too restrictive
- Verify that translations exist in POEditor for the specified tags/filters

## Links

- [POEditor API Docs](https://poeditor.com/docs/api)
- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [Contributing](CONTRIBUTING.md)
- [License](LICENSE)
