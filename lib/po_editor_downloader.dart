/// A command-line tool and library for downloading translations from POEditor.
///
/// This package provides:
/// - A CLI tool for downloading translations in ARB format
/// - A programmatic API for integrating POEditor downloads into your Dart/Flutter apps
/// - Support for YAML configuration files
/// - Filtering by tags and language codes
/// - Automatic retry logic with exponential backoff
/// - Progress indicators and detailed logging
///
/// ## CLI Usage
///
/// ```sh
/// # Using command-line arguments
/// dart run po_editor_downloader \
///   --api_token="your-api-token" \
///   --project_id="12345" \
///   --files_path="lib/l10n/"
///
/// # Using YAML configuration
/// dart run po_editor_downloader
/// ```
///
/// ## Programmatic Usage
///
/// ```dart
/// import 'package:po_editor_downloader/po_editor_downloader.dart';
///
/// void main() async {
///   final config = PoEditorConfig(
///     apiToken: 'your-api-token',
///     projectId: '12345',
///     filesPath: 'lib/l10n/',
///   );
///
///   final service = PoEditorService(config);
///   await service.downloadTranslations();
/// }
/// ```
library;

export 'src/config_reader.dart';
export 'src/language.dart';
export 'src/po_editor_config.dart';
export 'src/po_editor_exceptions.dart';
export 'src/po_editor_service.dart';
export 'src/re_case.dart';
