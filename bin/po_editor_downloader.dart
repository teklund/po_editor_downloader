import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:po_editor_downloader/po_editor_downloader.dart';

const apiTokenOption = 'api_token';
const projectIdOption = 'project_id';
const tagsOption = 'tags';
const filtersOption = 'filters';
const filesPathOption = 'files_path';
const defaultFilesPath = 'lib/l10n/';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(apiTokenOption, mandatory: true)
    ..addOption(projectIdOption, mandatory: true)
    ..addOption(tagsOption, mandatory: false)
    ..addOption(filesPathOption, mandatory: false)
    ..addOption(filtersOption, mandatory: false);

  final result = parser.parse(arguments);

  final apiKey = ArgumentValueParser.parse(apiTokenOption, result.arguments);
  final projectId =
      ArgumentValueParser.parse(projectIdOption, result.arguments);

  if (apiKey == null || projectId == null) {
    throw Exception(
        'Please provide an API token with project ID "api_token" and "project_id"');
  }
  var filesPath = ArgumentValueParser.parse(filesPathOption, result.arguments);

  if (filesPath == null) {
    print('No "files_path" specified, will default to $defaultFilesPath');
    filesPath = defaultFilesPath;
  }

  final tags = ArgumentValueParser.parse(tagsOption, result.arguments);

  final filters = ArgumentValueParser.parse(filtersOption, result.arguments);

  final service = PoEditorService(
    apiToken: apiKey,
    projectId: projectId,
    tags: tags,
    filters: filters,
  );

  final languages = await service.getLanguages();

  for (final language in languages) {
    print("$language");

    final translationsDetails = <String, dynamic>{
      '@@locale': language.code,
      '@@updated': language.updated,
      '@@language': language.name,
      '@@percentage': '${language.percentage}',
    };

    final translations = await service.getTranslations(language).then(
      (value) {
        return value.map(
          (key, value) {
            return MapEntry(ReCase(key).toCamelCase(), value);
          },
        );
      },
    );

    translationsDetails.addAll(translations);

    var encoder = JsonEncoder.withIndent("    ");
    final arbText = encoder.convert(translationsDetails);

    //print(arbText);

    final file = File('$filesPath/app_${language.code}.arb');
    file.writeAsStringSync(arbText);
  }
}
