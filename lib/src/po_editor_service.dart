import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:po_editor_downloader/src/language.dart';
import 'package:po_editor_downloader/src/po_editor_exceptions.dart';

/// Base url for POEditor
const baseUrl = 'https://api.poeditor.com/v2';

/// Service for retrieving data from POEditor
class PoEditorService {
  /// Api Token to get access to POEditor
  final String apiToken;

  /// Project Id of target project in POEditor
  final String projectId;

  /// (optional) Tags to filter terms
  final String? tags;

  /// (optional) Filters for terms
  final String? filters;

  /// HTTP client for making requests
  ///
  /// The caller is responsible for creating and closing this client.
  /// This makes lifecycle management explicit and clear.
  final http.Client client;

  /// Construct POEditor Service
  ///
  /// [client] - Required HTTP client. The caller is responsible for closing it
  /// when done. This makes lifecycle management explicit.
  ///
  /// Example:
  /// ```dart
  /// final client = http.Client();
  /// try {
  ///   final service = PoEditorService(
  ///     client: client,
  ///     apiToken: 'token',
  ///     projectId: '123',
  ///   );
  ///   // use service...
  /// } finally {
  ///   client.close();
  /// }
  /// ```
  PoEditorService({
    required this.client,
    required this.apiToken,
    required this.projectId,
    this.tags,
    this.filters,
  });

  /// Get Languages for project
  Future<List<Language>> getLanguages() async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/languages/list'),
        body: {'api_token': apiToken, 'id': projectId},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final languages = (json['result']['languages'] as List<dynamic>).map(
          (language) => Language.fromJson(language as Map<String, dynamic>),
        );
        return languages.toList();
      } else {
        throw PoEditorApiException(
          message: 'Failed to load languages from POEditor',
          statusCode: response.statusCode,
          responseBody: response.body,
          endpoint: '$baseUrl/languages/list',
        );
      }
    } on PoEditorApiException {
      rethrow;
    } catch (e, stackTrace) {
      throw PoEditorNetworkException(
        message: 'Network error while fetching languages',
        endpoint: '$baseUrl/languages/list',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get translations for language
  Future<Map<String, dynamic>> getTranslations(Language language) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/projects/export'),
        body: {
          'api_token': apiToken,
          'id': projectId,
          'language': language.code,
          'type': 'arb',
          'order': 'terms',
          if (tags != null) 'tags': tags,
          if (filters != null) 'filters': filters,
        },
      );

      if (response.statusCode != 200) {
        throw PoEditorApiException(
          message: 'Failed to request export for language ${language.code}',
          statusCode: response.statusCode,
          responseBody: response.body,
          endpoint: '$baseUrl/projects/export',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final url = json['result']['url'] as String;
      final exportResponse = await client.get(Uri.parse(url));

      if (exportResponse.statusCode == 200) {
        return jsonDecode(exportResponse.body) as Map<String, dynamic>;
      } else {
        throw PoEditorApiException(
          message:
              'Failed to download export file for language ${language.code}',
          statusCode: exportResponse.statusCode,
          responseBody: exportResponse.body,
          endpoint: url,
        );
      }
    } on PoEditorApiException {
      rethrow;
    } catch (e, stackTrace) {
      throw PoEditorNetworkException(
        message:
            'Network error while fetching translations for language ${language.code}',
        endpoint: '$baseUrl/projects/export',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
