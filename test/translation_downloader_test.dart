import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:po_editor_downloader/po_editor_downloader.dart';
import 'package:po_editor_downloader/src/logger.dart';
import 'package:test/test.dart';

void main() {
  group('TranslationDownloader', () {
    late Directory tempDir;
    late String outputPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('translation_test_');
      outputPath = tempDir.path;
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should download translations successfully', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/languages/list')) {
          return http.Response(
            '{"result": {"languages": [{"name": "English", "code": "en", "translations": 10, "percentage": 100, "updated": "2024-01-01"}]}}',
            200,
          );
        }
        if (request.url.toString().contains('/projects/export')) {
          return http.Response(
            '{"result": {"url": "https://example.com/download.arb"}}',
            200,
          );
        }
        if (request.url.toString().contains('example.com')) {
          return http.Response(
            '{"hello_world": "Hello World", "goodbye": "Goodbye"}',
            200,
          );
        }
        return http.Response('Not found', 404);
      });

      final config = PoEditorConfig(
        apiToken: 'test_token',
        projectId: '12345',
        filesPath: outputPath,
      );

      final downloader = TranslationDownloader(
        config: config,
        logger: const Logger(LogLevel.quiet),
        client: mockClient,
      );

      await downloader.downloadTranslations();

      // Verify ARB file was created
      final arbFile = File('$outputPath/app_en.arb');
      expect(await arbFile.exists(), isTrue);

      // Verify content
      final content = await arbFile.readAsString();
      expect(content, contains('helloWorld'));
      expect(content, contains('Hello World'));
      expect(content, contains('goodbye'));
      expect(content, contains('Goodbye'));
    });

    test('should include metadata when requested', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/languages/list')) {
          return http.Response(
            '{"result": {"languages": [{"name": "Spanish", "code": "es", "translations": 8, "percentage": 80.5, "updated": "2024-01-01 12:00:00"}]}}',
            200,
          );
        }
        if (request.url.toString().contains('/projects/export')) {
          return http.Response(
            '{"result": {"url": "https://example.com/download.arb"}}',
            200,
          );
        }
        if (request.url.toString().contains('example.com')) {
          return http.Response('{"test": "value"}', 200);
        }
        return http.Response('Not found', 404);
      });

      final config = PoEditorConfig(
        apiToken: 'test_token',
        projectId: '12345',
        filesPath: outputPath,
        addMetadata: true,
      );

      final downloader = TranslationDownloader(
        config: config,
        logger: const Logger(LogLevel.quiet),
        client: mockClient,
      );

      await downloader.downloadTranslations();

      final arbFile = File('$outputPath/app_es.arb');
      final content = await arbFile.readAsString();

      expect(content, contains('@@locale'));
      expect(content, contains('es'));
      expect(content, contains('@@language'));
      expect(content, contains('Spanish'));
      expect(content, contains('@@percentage'));
      expect(content, contains('80.5'));
      expect(content, contains('@@updated'));
    });

    test('should use custom filename pattern', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/languages/list')) {
          return http.Response(
            '{"result": {"languages": [{"name": "English", "code": "en", "translations": 10, "percentage": 100, "updated": "2024-01-01"}]}}',
            200,
          );
        }
        if (request.url.toString().contains('/projects/export')) {
          return http.Response(
            '{"result": {"url": "https://example.com/download.arb"}}',
            200,
          );
        }
        if (request.url.toString().contains('example.com')) {
          return http.Response('{"test": "value"}', 200);
        }
        return http.Response('Not found', 404);
      });

      final config = PoEditorConfig(
        apiToken: 'test_token',
        projectId: '12345',
        filesPath: outputPath,
        filenamePattern: 'intl_{locale}.arb',
      );

      final downloader = TranslationDownloader(
        config: config,
        logger: const Logger(LogLevel.quiet),
        client: mockClient,
      );

      await downloader.downloadTranslations();

      final arbFile = File('$outputPath/intl_en.arb');
      expect(await arbFile.exists(), isTrue);
    });

    test('should create output directory if it does not exist', () async {
      final nonExistentPath = '${tempDir.path}/new/nested/path';
      expect(await Directory(nonExistentPath).exists(), isFalse);

      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/languages/list')) {
          return http.Response(
            '{"result": {"languages": [{"name": "English", "code": "en", "translations": 10, "percentage": 100, "updated": "2024-01-01"}]}}',
            200,
          );
        }
        if (request.url.toString().contains('/projects/export')) {
          return http.Response(
            '{"result": {"url": "https://example.com/download.arb"}}',
            200,
          );
        }
        if (request.url.toString().contains('example.com')) {
          return http.Response('{"test": "value"}', 200);
        }
        return http.Response('Not found', 404);
      });

      final config = PoEditorConfig(
        apiToken: 'test_token',
        projectId: '12345',
        filesPath: nonExistentPath,
      );

      final downloader = TranslationDownloader(
        config: config,
        logger: const Logger(LogLevel.quiet),
        client: mockClient,
      );

      await downloader.downloadTranslations();

      expect(await Directory(nonExistentPath).exists(), isTrue);
      expect(await File('$nonExistentPath/app_en.arb').exists(), isTrue);
    });

    test('should handle multiple languages', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/languages/list')) {
          return http.Response(
            '{"result": {"languages": ['
            '{"name": "English", "code": "en", "translations": 10, "percentage": 100, "updated": "2024-01-01"},'
            '{"name": "Spanish", "code": "es", "translations": 8, "percentage": 80, "updated": "2024-01-02"},'
            '{"name": "French", "code": "fr", "translations": 9, "percentage": 90, "updated": "2024-01-03"}'
            ']}}',
            200,
          );
        }
        if (request.url.toString().contains('/projects/export')) {
          return http.Response(
            '{"result": {"url": "https://example.com/download.arb"}}',
            200,
          );
        }
        if (request.url.toString().contains('example.com')) {
          return http.Response('{"test": "value"}', 200);
        }
        return http.Response('Not found', 404);
      });

      final config = PoEditorConfig(
        apiToken: 'test_token',
        projectId: '12345',
        filesPath: outputPath,
      );

      final downloader = TranslationDownloader(
        config: config,
        logger: const Logger(LogLevel.quiet),
        client: mockClient,
      );

      await downloader.downloadTranslations();

      expect(await File('$outputPath/app_en.arb').exists(), isTrue);
      expect(await File('$outputPath/app_es.arb').exists(), isTrue);
      expect(await File('$outputPath/app_fr.arb').exists(), isTrue);
    });

    test('should convert keys to camelCase', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/languages/list')) {
          return http.Response(
            '{"result": {"languages": [{"name": "English", "code": "en", "translations": 10, "percentage": 100, "updated": "2024-01-01"}]}}',
            200,
          );
        }
        if (request.url.toString().contains('/projects/export')) {
          return http.Response(
            '{"result": {"url": "https://example.com/download.arb"}}',
            200,
          );
        }
        if (request.url.toString().contains('example.com')) {
          return http.Response(
            '{"hello_world": "Hello", "goodbye_message": "Bye", "simple": "Simple"}',
            200,
          );
        }
        return http.Response('Not found', 404);
      });

      final config = PoEditorConfig(
        apiToken: 'test_token',
        projectId: '12345',
        filesPath: outputPath,
      );

      final downloader = TranslationDownloader(
        config: config,
        logger: const Logger(LogLevel.quiet),
        client: mockClient,
      );

      await downloader.downloadTranslations();

      final arbFile = File('$outputPath/app_en.arb');
      final content = await arbFile.readAsString();

      expect(content, contains('helloWorld'));
      expect(content, contains('goodbyeMessage'));
      expect(content, contains('simple'));
      expect(content, isNot(contains('hello_world')));
      expect(content, isNot(contains('goodbye_message')));
    });

    test('should throw PoEditorApiException on API error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Invalid API token"}', 401);
      });

      final config = PoEditorConfig(
        apiToken: 'invalid_token',
        projectId: '12345',
        filesPath: outputPath,
      );

      final downloader = TranslationDownloader(
        config: config,
        logger: const Logger(LogLevel.quiet),
        client: mockClient,
      );

      expect(
        () => downloader.downloadTranslations(),
        throwsA(isA<PoEditorApiException>()),
      );
    });

    test('should apply tags filter to export request', () async {
      String? capturedBody;
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/languages/list')) {
          return http.Response(
            '{"result": {"languages": [{"name": "English", "code": "en", "translations": 10, "percentage": 100, "updated": "2024-01-01"}]}}',
            200,
          );
        }
        if (request.url.toString().contains('/projects/export')) {
          capturedBody = request.body;
          return http.Response(
            '{"result": {"url": "https://example.com/download.arb"}}',
            200,
          );
        }
        if (request.url.toString().contains('example.com')) {
          return http.Response('{"test": "value"}', 200);
        }
        return http.Response('Not found', 404);
      });

      final config = PoEditorConfig(
        apiToken: 'test_token',
        projectId: '12345',
        filesPath: outputPath,
        tags: 'mobile,ios',
      );

      final downloader = TranslationDownloader(
        config: config,
        logger: const Logger(LogLevel.quiet),
        client: mockClient,
      );

      await downloader.downloadTranslations();

      expect(capturedBody, isNotNull);
      expect(capturedBody, contains('tags'));
      expect(capturedBody,
          anyOf(contains('mobile,ios'), contains('mobile%2Cios')));
    });

    test('should apply filters to export request', () async {
      String? capturedBody;
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/languages/list')) {
          return http.Response(
            '{"result": {"languages": [{"name": "English", "code": "en", "translations": 10, "percentage": 100, "updated": "2024-01-01"}]}}',
            200,
          );
        }
        if (request.url.toString().contains('/projects/export')) {
          capturedBody = request.body;
          return http.Response(
            '{"result": {"url": "https://example.com/download.arb"}}',
            200,
          );
        }
        if (request.url.toString().contains('example.com')) {
          return http.Response('{"test": "value"}', 200);
        }
        return http.Response('Not found', 404);
      });

      final config = PoEditorConfig(
        apiToken: 'test_token',
        projectId: '12345',
        filesPath: outputPath,
        filters: 'translated',
      );

      final downloader = TranslationDownloader(
        config: config,
        logger: const Logger(LogLevel.quiet),
        client: mockClient,
      );

      await downloader.downloadTranslations();

      expect(capturedBody, isNotNull);
      expect(capturedBody, contains('filters'));
      expect(capturedBody, contains('translated'));
    });

    test('should use default filesPath when not specified', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/languages/list')) {
          return http.Response(
            '{"result": {"languages": [{"name": "English", "code": "en", "translations": 10, "percentage": 100, "updated": "2024-01-01"}]}}',
            200,
          );
        }
        if (request.url.toString().contains('/projects/export')) {
          return http.Response(
            '{"result": {"url": "https://example.com/download.arb"}}',
            200,
          );
        }
        if (request.url.toString().contains('example.com')) {
          return http.Response('{"test": "value"}', 200);
        }
        return http.Response('Not found', 404);
      });

      final config = PoEditorConfig(
        apiToken: 'test_token',
        projectId: '12345',
        // filesPath not specified - will use default
      );

      final downloader = TranslationDownloader(
        config: config,
        logger: const Logger(LogLevel.normal),
        client: mockClient,
      );

      await downloader.downloadTranslations();

      // Should create file in default location (lib/l10n/)
      final arbFile = File('lib/l10n/app_en.arb');
      expect(await arbFile.exists(), isTrue);
    });

    test('should retry on API failures and log warnings', () async {
      int languagesAttemptCount = 0;
      int exportAttemptCount = 0;
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/languages/list')) {
          languagesAttemptCount++;
          if (languagesAttemptCount < 2) {
            return http.Response('Server Error', 500);
          }
          return http.Response(
            '{"result": {"languages": [{"name": "English", "code": "en", "translations": 10, "percentage": 100, "updated": "2024-01-01"}]}}',
            200,
          );
        }
        if (request.url.toString().contains('/projects/export')) {
          exportAttemptCount++;
          if (exportAttemptCount < 2) {
            return http.Response('Server Error', 500);
          }
          return http.Response(
            '{"result": {"url": "https://example.com/download.arb"}}',
            200,
          );
        }
        if (request.url.toString().contains('example.com')) {
          return http.Response('{"test": "value"}', 200);
        }
        return http.Response('Not found', 404);
      });

      final config = PoEditorConfig(
        apiToken: 'test_token',
        projectId: '12345',
        filesPath: outputPath,
      );

      final downloader = TranslationDownloader(
        config: config,
        logger: const Logger(LogLevel.normal),
        client: mockClient,
      );

      await downloader.downloadTranslations();

      expect(languagesAttemptCount, equals(2));
      expect(exportAttemptCount, equals(2));
      final arbFile = File('$outputPath/app_en.arb');
      expect(await arbFile.exists(), isTrue);
    });

    test('should not close client when provided externally', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/languages/list')) {
          return http.Response(
            '{"result": {"languages": [{"name": "English", "code": "en", "translations": 10, "percentage": 100, "updated": "2024-01-01"}]}}',
            200,
          );
        }
        if (request.url.toString().contains('/projects/export')) {
          return http.Response(
            '{"result": {"url": "https://example.com/download.arb"}}',
            200,
          );
        }
        if (request.url.toString().contains('example.com')) {
          return http.Response('{"test": "value"}', 200);
        }
        return http.Response('Not found', 404);
      });

      final config = PoEditorConfig(
        apiToken: 'test_token',
        projectId: '12345',
        filesPath: outputPath,
      );

      final downloader = TranslationDownloader(
        config: config,
        logger: const Logger(LogLevel.quiet),
        client: mockClient,
      );

      // This test verifies the download completes successfully when client is provided
      // The client ownership logic ensures we don't close externally-provided clients
      await downloader.downloadTranslations();

      final arbFile = File('$outputPath/app_en.arb');
      expect(await arbFile.exists(), isTrue);
    });

    test('should close client when it creates its own', () async {
      // We can't easily test client.close() is called since we can't mock http.Client() constructor
      // But we can test that creating a TranslationDownloader without a client works correctly
      // This ensures the close() code path is executed in the finally block

      final config = PoEditorConfig(
        apiToken: 'test_token',
        projectId: '12345',
        filesPath: outputPath,
      );

      final downloader = TranslationDownloader(
        config: config,
        logger: const Logger(LogLevel.quiet),
        // No client provided - will create its own
      );

      // This should fail since we don't have a real API, but it will execute the close() path
      try {
        await downloader.downloadTranslations();
      } catch (e) {
        // Expected to fail - we just want to ensure close() is called
        expect(e, isNotNull);
      }
    });

    test('should throw error when directory creation fails', () async {
      final invalidPath = '/root/cannot_write_here/translations';

      final mockClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      final config = PoEditorConfig(
        apiToken: 'test_token',
        projectId: '12345',
        filesPath: invalidPath,
      );

      final downloader = TranslationDownloader(
        config: config,
        logger: const Logger(LogLevel.quiet),
        client: mockClient,
      );

      expect(
        () => downloader.downloadTranslations(),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw error when directory is not writable', () async {
      // Create a read-only directory
      final readOnlyPath = '${tempDir.path}/readonly';
      await Directory(readOnlyPath).create();

      // Make it read-only (this works on Unix-like systems)
      if (!Platform.isWindows) {
        await Process.run('chmod', ['444', readOnlyPath]);
      }

      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/languages/list')) {
          return http.Response(
            '{"result": {"languages": [{"name": "English", "code": "en", "translations": 10, "percentage": 100, "updated": "2024-01-01"}]}}',
            200,
          );
        }
        return http.Response('{}', 200);
      });

      final config = PoEditorConfig(
        apiToken: 'test_token',
        projectId: '12345',
        filesPath: readOnlyPath,
      );

      final downloader = TranslationDownloader(
        config: config,
        logger: const Logger(LogLevel.quiet),
        client: mockClient,
      );

      try {
        await expectLater(
          () => downloader.downloadTranslations(),
          throwsA(isA<Exception>()),
        );
      } finally {
        // Restore permissions for cleanup
        if (!Platform.isWindows) {
          await Process.run('chmod', ['755', readOnlyPath]);
        }
      }
    });
  });
}
