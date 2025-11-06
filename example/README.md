# po_editor_downloader Example

This example demonstrates how to use the `po_editor_downloader` library programmatically in your Dart or Flutter application.

## Running the Example

```sh
dart run example/example.dart
```

## What the Example Shows

The example demonstrates:

1. **Basic Configuration** - Creating a simple configuration with minimal settings
2. **Advanced Configuration** - Using filtering options (tags, filters) and custom filename patterns
3. **YAML Configuration** - Reading configuration from `pubspec.yaml`
4. **Downloading Translations** - How to use the `PoEditorService` to download translations
5. **String Utilities** - Using the `ReCase` utility for string transformations

## Before Running

To actually download translations, you'll need to:

1. Obtain an API token from POEditor (Settings → API Access)
2. Get your project ID from POEditor
3. Uncomment the download code in `example.dart`
4. Replace the placeholder API token and project ID with your real values

## Using in Your Project

To integrate into your own project:

```dart
import 'package:po_editor_downloader/po_editor_downloader.dart';

void main() async {
  final config = PoEditorConfig(
    apiToken: Platform.environment['PO_EDITOR_API_TOKEN']!,
    projectId: '12345',
    filesPath: 'lib/l10n/',
  );

  final service = PoEditorService(config);
  await service.downloadTranslations();
}
```

## Security Note

**Never hardcode your API token in source code!**
Always use:

- Environment variables (recommended)
- Command-line arguments
- Secure secrets management

Never store API tokens in:

- YAML files
- Git repositories
- Any files that might be committed to version control
