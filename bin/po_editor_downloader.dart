import 'dart:io';

import 'package:args/args.dart';
import 'package:po_editor_downloader/po_editor_downloader.dart';
import 'package:po_editor_downloader/src/logger.dart';

const apiTokenOption = 'api_token';
const projectIdOption = 'project_id';
const tagsOption = 'tags';
const filtersOption = 'filters';
const filesPathOption = 'files_path';
const filenamePatternOption = 'filename_pattern';
const addMetadataOption = 'add_metadata';

/// Load configuration from multiple sources with priority:
/// 1. Command-line arguments (highest)
/// 2. Environment variables
/// 3. Custom config file (if --config is specified)
/// 4. pubspec.yaml
Future<PoEditorConfig> loadConfiguration(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      apiTokenOption,
      mandatory: false,
      help: 'POEditor API token (or use PO_EDITOR_API_TOKEN env var)',
    )
    ..addOption(
      projectIdOption,
      mandatory: false,
      help: 'POEditor project ID',
    )
    ..addOption(
      tagsOption,
      mandatory: false,
      help: 'Filter by tags (comma-separated)',
    )
    ..addOption(
      filtersOption,
      mandatory: false,
      help: 'Filter by status (e.g., translated, untranslated)',
    )
    ..addOption(
      filesPathOption,
      mandatory: false,
      help: 'Output directory path (default: $defaultFilesPath)',
    )
    ..addOption(
      filenamePatternOption,
      mandatory: false,
      help:
          'Filename pattern for ARB files. Use {locale} as placeholder (default: $defaultFilenamePattern)',
    )
    ..addOption(
      addMetadataOption,
      mandatory: false,
      help: 'Include metadata in ARB files (true/false)',
    )
    ..addOption(
      'config',
      mandatory: false,
      help: 'Path to custom config file',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message',
    )
    ..addFlag(
      'quiet',
      abbr: 'q',
      negatable: false,
      help: 'Quiet mode - show only errors',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Verbose mode - show debug information',
    );

  final result = parser.parse(arguments);

  // Check for help flag
  if (result['help'] == true) {
    print('POEditor Downloader - Download translations from POEditor\n');
    print('Usage: dart run po_editor_downloader [options]\n');
    print('Configuration Priority:');
    print('  1. Command-line arguments (highest)');
    print('  2. Environment variables (for api_token)');
    print('  3. YAML config file (pubspec.yaml or --config)');
    print('  4. Default values\n');
    print('Options:');
    print(parser.usage);
    print('\nEnvironment Variables:');
    print('  PO_EDITOR_API_TOKEN - Your POEditor API token (recommended)\n');
    print('YAML Configuration (pubspec.yaml):');
    print('  po_editor:');
    print('    project_id: "12345"');
    print('    tags: "mobile"');
    print('    filters: "translated"');
    print('    files_path: "lib/l10n/"');
    print('    filename_pattern: "app_{locale}.arb"  # Default');
    print('    add_metadata: true\n');
    print('Filename Patterns:');
    print('  Use {locale} as placeholder for the language code');
    print('  Examples:');
    print('    "app_{locale}.arb"        -> app_en.arb, app_es.arb');
    print('    "{locale}.arb"            -> en.arb, es.arb');
    print('    "intl_{locale}.arb"       -> intl_en.arb, intl_es.arb');
    print('    "translations_{locale}.arb" -> translations_en.arb\n');
    print('Examples:');
    print('  # Use YAML config + env var (recommended)');
    print('  export PO_EDITOR_API_TOKEN="your_token"');
    print('  dart run po_editor_downloader\n');
    print('  # Custom filename pattern');
    print(
        '  dart run po_editor_downloader --filename_pattern="{locale}.arb"\n');
    print('  # Override specific settings');
    print('  dart run po_editor_downloader --tags=web\n');
    print('  # Full CLI usage');
    print(
        '  dart run po_editor_downloader --api_token=token --project_id=123\n');
    exit(0);
  }

  // 1. Read from CLI arguments
  final cliConfig = PoEditorConfig.fromCommandLine({
    'api_token': result[apiTokenOption],
    'project_id': result[projectIdOption],
    'tags': result[tagsOption],
    'filters': result[filtersOption],
    'files_path': result[filesPathOption],
    'filename_pattern': result[filenamePatternOption],
    'add_metadata': result[addMetadataOption],
  });

  // 2. Read from environment variables
  final envConfig = PoEditorConfig.fromEnvironment();

  // 3. Read from config file (custom or pubspec.yaml)
  PoEditorConfig? yamlConfig;
  final customConfigPath = result['config'] as String?;

  if (customConfigPath != null) {
    yamlConfig = await ConfigReader.readFromFile(customConfigPath);
    if (yamlConfig == null) {
      stderr.writeln('Warning: Could not read config file: $customConfigPath');
    }
  } else {
    yamlConfig = await ConfigReader.readFromPubspec();
  }

  // Merge configurations: CLI > ENV > YAML
  final mergedConfig = PoEditorConfig.merge(
    cliConfig,
    envConfig,
    yamlConfig ?? const PoEditorConfig(),
  );

  // Validate the final configuration
  mergedConfig.validate();

  return mergedConfig;
}

Future<void> main(List<String> arguments) async {
  try {
    // Determine log level by checking for flags in arguments
    final isQuiet = arguments.contains('--quiet') || arguments.contains('-q');
    final isVerbose =
        arguments.contains('--verbose') || arguments.contains('-v');

    final logLevel = isQuiet
        ? LogLevel.quiet
        : isVerbose
            ? LogLevel.verbose
            : LogLevel.normal;

    final logger = Logger(logLevel);

    final config = await loadConfiguration(arguments);

    final downloader = TranslationDownloader(config: config, logger: logger);
    await downloader.downloadTranslations();
  } on ConfigurationException catch (e) {
    stderr.writeln('\n❌ Configuration Error:\n${e.message}');
    exit(1);
  } on PoEditorApiException catch (e) {
    stderr.writeln('\n❌ API Error:\n$e');
    exit(1);
  } on PoEditorNetworkException catch (e) {
    stderr.writeln('\n❌ Network Error:\n$e');
    exit(1);
  } catch (e) {
    stderr.writeln('\n❌ Error: $e');
    exit(1);
  }
}
