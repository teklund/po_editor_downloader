import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:po_editor_downloader/po_editor_downloader.dart';
import 'package:po_editor_downloader/src/retry_helper.dart';

const apiTokenOption = 'api_token';
const projectIdOption = 'project_id';
const tagsOption = 'tags';
const filtersOption = 'filters';
const filesPathOption = 'files_path';
const defaultFilesPath = 'lib/l10n/';
const addMetaDataOption = 'add_metadata';

/// Ensure the output directory exists and is writable
Future<void> ensureOutputDirectory(String path) async {
  final dir = Directory(path);
  
  // Create directory if it doesn't exist
  if (!await dir.exists()) {
    print('Creating output directory: $path');
    try {
      await dir.create(recursive: true);
    } catch (e) {
      throw Exception(
        'Failed to create output directory: $path\n'
        'Error: $e',
      );
    }
  }
  
  // Test if directory is writable
  try {
    final testFile = File('${dir.path}/.write_test_${DateTime.now().millisecondsSinceEpoch}');
    await testFile.writeAsString('test');
    await testFile.delete();
  } catch (e) {
    throw Exception(
      'Output directory is not writable: $path\n'
      'Error: $e\n'
      'Please check directory permissions.',
    );
  }
}

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
      filesPathOption,
      mandatory: false,
      help: 'Output directory path (default: $defaultFilesPath)',
    )
    ..addOption(
      filtersOption,
      mandatory: false,
      help: 'Filter by status (e.g., translated, untranslated)',
    )
    ..addOption(
      addMetaDataOption,
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
    print('    files_path: "lib/l10n/"');
    print('    tags: "mobile"');
    print('    filters: "translated"');
    print('    add_metadata: true\n');
    print('Examples:');
    print('  # Use YAML config + env var (recommended)');
    print('  export PO_EDITOR_API_TOKEN="your_token"');
    print('  dart run po_editor_downloader\n');
    print('  # Override specific settings');
    print('  dart run po_editor_downloader --tags=web\n');
    print('  # Full CLI usage');
    print('  dart run po_editor_downloader --api_token=token --project_id=123\n');
    exit(0);
  }

  // 1. Read from CLI arguments
  final cliConfig = PoEditorConfig.fromCommandLine({
    'api_token': result[apiTokenOption],
    'project_id': result[projectIdOption],
    'files_path': result[filesPathOption],
    'tags': result[tagsOption],
    'filters': result[filtersOption],
    'add_metadata': result[addMetaDataOption],
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

/// Download translations for all languages in a project
Future<void> downloadTranslations(PoEditorConfig config) async {
  final filesPath = config.filesPath ?? defaultFilesPath;
  if (config.filesPath == null) {
    print('No "files_path" specified, will default to $defaultFilesPath');
  }

  // Ensure output directory exists and is writable
  await ensureOutputDirectory(filesPath);

  final service = PoEditorService(
    apiToken: config.apiToken!,
    projectId: config.projectId!,
    tags: config.tags,
    filters: config.filters,
  );

  // Fetch languages with retry logic
  final languages = await withRetry(
    () => service.getLanguages(),
    onRetry: (attempt, delay, error) {
      print('⚠️  Retry $attempt/3 after ${delay.inSeconds}s (${error.toString().split('\n').first})');
    },
  );

  for (final language in languages) {
    print("$language");

    // Fetch translations with retry logic
    final translations = await withRetry(
      () => service.getTranslations(language),
      onRetry: (attempt, delay, error) {
        print('⚠️  Retry $attempt/3 for ${language.code} after ${delay.inSeconds}s');
      },
    ).then(
      (value) {
        return value.map(
          (key, value) {
            return MapEntry(ReCase(key).toCamelCase(), value);
          },
        );
      },
    );

    await writeArbFile(
      language: language,
      translations: translations,
      outputPath: filesPath,
      includeMetadata: config.addMetadata,
    );
  }
}

/// Write an ARB file for a specific language
Future<void> writeArbFile({
  required Language language,
  required Map<String, dynamic> translations,
  required String outputPath,
  bool? includeMetadata,
}) async {
  final Map<String, dynamic> translationResult = {};

  // Add metadata if requested
  if (includeMetadata == true) {
    final metadata = <String, dynamic>{
      '@@locale': language.code,
      '@@updated': language.updated,
      '@@language': language.name,
      '@@percentage': '${language.percentage}',
    };
    translationResult.addAll(metadata);
  }

  // Add translations
  translationResult.addAll(translations);

  // Format and write file
  final encoder = JsonEncoder.withIndent("    ");
  final arbText = encoder.convert(translationResult);
  final file = File('$outputPath/app_${language.code}.arb');
  await file.writeAsString(arbText);
}

Future<void> main(List<String> arguments) async {
  try {
    final config = await loadConfiguration(arguments);
    await downloadTranslations(config);
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
