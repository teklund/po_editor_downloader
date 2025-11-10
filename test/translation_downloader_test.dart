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
      expect(capturedBody, anyOf(contains('mobile,ios'), contains('mobile%2Cios')));
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
  });
}
