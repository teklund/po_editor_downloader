import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:po_editor_downloader/po_editor_downloader.dart';
import 'package:test/test.dart';

// Test constants
const _testApiToken = 'test_token';
const _testProjectId = '12345';

// Test data
final _testLanguage = Language(
  name: 'English',
  code: 'en',
  translations: 100,
  percentage: 100,
  updated: '2024-01-01',
);

const _testLanguagesResponse =
    '{"result": {"languages": [{"name": "English", "code": "en", "translations": 100, "percentage": 100, "updated": "2024-01-01"}]}}';

// Helper function to create a service with standard test values
PoEditorService _createService(MockClient client,
    {String? apiToken, String? projectId, String? tags, String? filters}) {
  return PoEditorService(
    client: client,
    apiToken: apiToken ?? _testApiToken,
    projectId: projectId ?? _testProjectId,
    tags: tags,
    filters: filters,
  );
}

void main() {
  group('PoEditorService with HTTP Client Injection', () {
    test('should require client parameter', () {
      final mockClient = MockClient((request) async {
        return http.Response('{"result": {"languages": []}}', 200);
      });

      final service = _createService(mockClient);

      expect(service.client, isNotNull);
      expect(service.client, equals(mockClient));
    });

    test('should successfully fetch languages with mocked client', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/languages/list')) {
          return http.Response(_testLanguagesResponse, 200);
        }
        return http.Response('Not found', 404);
      });

      final service = _createService(mockClient);

      final languages = await service.getLanguages();
      expect(languages, hasLength(1));
      expect(languages.first.code, equals('en'));
      expect(languages.first.name, equals('English'));
    });

    test('should successfully fetch translations with mocked client', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/projects/export')) {
          return http.Response(
            '{"result": {"url": "https://example.com/download.arb"}}',
            200,
          );
        }
        if (request.url.toString().contains('example.com')) {
          return http.Response('{"hello": "Hello World"}', 200);
        }
        return http.Response('Not found', 404);
      });

      final service = _createService(mockClient);

      final translations = await service.getTranslations(_testLanguage);
      expect(translations, containsPair('hello', 'Hello World'));
    });
  });

  group('PoEditorService Error Handling', () {
    test('should throw PoEditorApiException on 401 status code', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Invalid API token"}', 401);
      });

      final service = _createService(mockClient, apiToken: 'invalid_token');

      expect(
        () => service.getLanguages(),
        throwsA(isA<PoEditorApiException>()),
      );

      try {
        await service.getLanguages();
      } on PoEditorApiException catch (e) {
        expect(e.statusCode, equals(401));
        expect(e.endpoint, contains('/languages/list'));
        expect(e.message, contains('Failed to load languages'));
      }
    });

    test('should throw PoEditorApiException on 404 status code', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Project not found"}', 404);
      });

      final service = _createService(mockClient, projectId: 'invalid_id');

      expect(
        () => service.getLanguages(),
        throwsA(isA<PoEditorApiException>()),
      );
    });

    test('should throw PoEditorApiException on 500 status code', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = _createService(mockClient);

      expect(
        () => service.getLanguages(),
        throwsA(isA<PoEditorApiException>()),
      );
    });

    test('should include response body in PoEditorApiException', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Detailed error message"}', 400);
      });

      final service = _createService(mockClient);

      try {
        await service.getLanguages();
        fail('Should have thrown PoEditorApiException');
      } on PoEditorApiException catch (e) {
        expect(e.responseBody, contains('Detailed error message'));
        expect(e.toString(), contains('Response:'));
        expect(e.toString(), contains('Status Code: 400'));
      }
    });

    test('should throw PoEditorNetworkException on network failure', () async {
      final mockClient = MockClient((request) async {
        throw const SocketException('Network unreachable');
      });

      final service = _createService(mockClient);

      expect(
        () => service.getLanguages(),
        throwsA(isA<PoEditorNetworkException>()),
      );

      try {
        await service.getLanguages();
      } on PoEditorNetworkException catch (e) {
        expect(e.message, contains('Network error'));
        expect(e.endpoint, contains('/languages/list'));
        expect(e.originalError, isA<SocketException>());
        expect(e.stackTrace, isNotNull);
      }
    });

    test('should throw PoEditorNetworkException on timeout', () async {
      final mockClient = MockClient((request) async {
        throw TimeoutException('Request timeout');
      });

      final service = _createService(mockClient);

      expect(
        () => service.getLanguages(),
        throwsA(isA<PoEditorNetworkException>()),
      );
    });

    test('should throw PoEditorApiException when export request fails',
        () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/projects/export')) {
          return http.Response('{"error": "Export failed"}', 400);
        }
        return http.Response('Not found', 404);
      });

      final service = _createService(mockClient);

      expect(
        () => service.getTranslations(_testLanguage),
        throwsA(isA<PoEditorApiException>()),
      );
    });

    test('should throw PoEditorApiException when download fails', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/projects/export')) {
          return http.Response(
            '{"result": {"url": "https://example.com/download.arb"}}',
            200,
          );
        }
        if (request.url.toString().contains('example.com')) {
          return http.Response('File not found', 404);
        }
        return http.Response('Not found', 404);
      });

      final service = _createService(mockClient);

      try {
        await service.getTranslations(_testLanguage);
        fail('Should have thrown PoEditorApiException');
      } on PoEditorApiException catch (e) {
        expect(e.message, contains('Failed to download export file'));
        expect(e.message, contains('en'));
      }
    });
  });

  group('PoEditorService with Tags and Filters', () {
    test('should include tags in export request', () async {
      String? capturedBody;
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/projects/export')) {
          capturedBody = request.body;
          return http.Response(
            '{"result": {"url": "https://example.com/download.arb"}}',
            200,
          );
        }
        if (request.url.toString().contains('example.com')) {
          return http.Response('{}', 200);
        }
        return http.Response('Not found', 404);
      });

      final service = _createService(mockClient, tags: 'mobile,ios');

      await service.getTranslations(_testLanguage);
      expect(capturedBody, contains('tags'));
      // URL encoded comma: %2C
      expect(capturedBody,
          anyOf(contains('mobile,ios'), contains('mobile%2Cios')));
    });

    test('should include filters in export request', () async {
      String? capturedBody;
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/projects/export')) {
          capturedBody = request.body;
          return http.Response(
            '{"result": {"url": "https://example.com/download.arb"}}',
            200,
          );
        }
        if (request.url.toString().contains('example.com')) {
          return http.Response('{}', 200);
        }
        return http.Response('Not found', 404);
      });

      final service = _createService(mockClient, filters: 'translated');

      await service.getTranslations(_testLanguage);
      expect(capturedBody, contains('filters'));
      expect(capturedBody, contains('translated'));
    });
  });

  group('Exception toString() methods', () {
    test('PoEditorApiException should format nicely', () {
      final exception = PoEditorApiException(
        message: 'Test error',
        statusCode: 400,
        responseBody: '{"error": "details"}',
        endpoint: '/test/endpoint',
      );

      final str = exception.toString();
      expect(str, contains('PoEditorApiException'));
      expect(str, contains('Test error'));
      expect(str, contains('Status Code: 400'));
      expect(str, contains('Endpoint: /test/endpoint'));
      expect(str, contains('Response:'));
    });

    test('PoEditorNetworkException should format nicely', () {
      final exception = PoEditorNetworkException(
        message: 'Network failure',
        endpoint: '/test/endpoint',
        originalError: const SocketException('Connection refused'),
      );

      final str = exception.toString();
      expect(str, contains('PoEditorNetworkException'));
      expect(str, contains('Network failure'));
      expect(str, contains('Endpoint: /test/endpoint'));
      expect(str, contains('Original Error:'));
      expect(str, contains('Connection refused'));
    });
  });
}
