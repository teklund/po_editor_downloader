import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:po_editor_downloader/language.dart';

const baseUrl = 'https://api.poeditor.com/v2';

class PoEditorService {
  final String apiToken;
  final String projectId;
  final String? tags;
  final String? filters;

  const PoEditorService({
    required this.apiToken,
    required this.projectId,
    required this.tags,
    required this.filters,
  });

  Future<List<Language>> getLanguages() async {
    final response = await http.post(
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
      throw Exception('Failed to load languages');
    }
  }

  Future<Map<String, dynamic>> getTranslations(Language language) async {
    final response = await http.post(
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

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final url = json['result']['url'] as String;
    final exportResponse = await http.get(Uri.parse(url));
    if (exportResponse.statusCode == 200) {
      return jsonDecode(exportResponse.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to export language');
    }
  }
}
