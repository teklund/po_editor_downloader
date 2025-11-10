import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:po_editor_downloader/src/language.dart';
import 'package:po_editor_downloader/src/logger.dart';
import 'package:po_editor_downloader/src/po_editor_config.dart';
import 'package:po_editor_downloader/src/po_editor_service.dart';
import 'package:po_editor_downloader/src/re_case.dart';
import 'package:po_editor_downloader/src/retry_helper.dart';

/// Default output directory for translation files
const defaultFilesPath = 'lib/l10n/';

/// Default filename pattern for ARB files
const defaultFilenamePattern = 'app_{locale}.arb';

/// Handles the complete translation download workflow
///
/// This class orchestrates the entire process of downloading translations
/// from POEditor, including:
/// - Fetching available languages
/// - Downloading translations for each language
/// - Converting term keys to camelCase
/// - Writing ARB files with proper formatting
/// - Managing HTTP client lifecycle
class TranslationDownloader {
  /// Configuration for the download operation
  final PoEditorConfig config;

  /// Logger for progress and status messages
  final Logger logger;

  /// Creates a new translation downloader
  ///
  /// [config] - Required configuration including API token and project ID
  /// [logger] - Optional logger for output (defaults to normal verbosity)
  TranslationDownloader({
    required this.config,
    this.logger = const Logger(LogLevel.normal),
  });

  /// Download translations for all languages in a project
  Future<void> downloadTranslations() async {
    final filesPath = config.filesPath ?? defaultFilesPath;
    if (config.filesPath == null) {
      logger
          .info('No "files_path" specified, will default to $defaultFilesPath');
    }

    logger.debug('Ensuring output directory exists: $filesPath');
    await _ensureOutputDirectory(filesPath);

    final client = http.Client();
    try {
      final service = PoEditorService(
        client: client,
        apiToken: config.apiToken!,
        projectId: config.projectId!,
        tags: config.tags,
        filters: config.filters,
      );

      logger.progress('Downloading translations...');
      final languages = await withRetry(
        () => service.getLanguages(),
        onRetry: (attempt, delay, error) {
          logger.warning(
              'Retry $attempt/3 after ${delay.inSeconds}s (${error.toString().split('\n').first})');
        },
      );

      logger.info('Found ${languages.length} language(s)');

      int completed = 0;
      for (final language in languages) {
        completed++;
        logger.info(
            '[$completed/${languages.length}] ${language.name} (${language.code})...');

        final translations = await withRetry(
          () => service.getTranslations(language),
          onRetry: (attempt, delay, error) {
            logger.warning(
                'Retry $attempt/3 for ${language.code} after ${delay.inSeconds}s');
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

        await _writeArbFile(
          language: language,
          translations: translations,
          outputPath: filesPath,
          includeMetadata: config.addMetadata,
          filenamePattern: config.filenamePattern ?? defaultFilenamePattern,
        );
      }

      logger.success(
          'Done! Downloaded ${languages.length} language(s) to $filesPath');
    } finally {
      client.close();
    }
  }

  /// Ensure the output directory exists and is writable
  Future<void> _ensureOutputDirectory(String path) async {
    final dir = Directory(path);

    if (!await dir.exists()) {
      logger.info('Creating output directory: $path');
      try {
        await dir.create(recursive: true);
      } catch (e) {
        throw Exception(
          'Failed to create output directory: $path\n'
          'Error: $e',
        );
      }
    }

    try {
      final testFile = File(
          '${dir.path}/.write_test_${DateTime.now().millisecondsSinceEpoch}');
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

  /// Write an ARB file for a specific language
  Future<void> _writeArbFile({
    required Language language,
    required Map<String, dynamic> translations,
    required String outputPath,
    bool? includeMetadata,
    required String filenamePattern,
  }) async {
    final Map<String, dynamic> translationResult = {};

    if (includeMetadata == true) {
      final metadata = <String, dynamic>{
        '@@locale': language.code,
        '@@updated': language.updated,
        '@@language': language.name,
        '@@percentage': '${language.percentage}',
      };
      translationResult.addAll(metadata);
      logger.debug('Added metadata for ${language.code}');
    }

    translationResult.addAll(translations);

    final filename = filenamePattern.replaceAll('{locale}', language.code);

    final encoder = JsonEncoder.withIndent("    ");
    final arbText = encoder.convert(translationResult);
    final file = File('$outputPath/$filename');
    await file.writeAsString(arbText);

    logger.success('Saved: $filename (${translations.length} terms)');
  }
}
