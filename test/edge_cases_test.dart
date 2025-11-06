import 'dart:io';

import 'package:args/args.dart';
import 'package:po_editor_downloader/po_editor_downloader.dart';
import 'package:test/test.dart';

void main() {
  group('Edge Cases and Error Scenarios', () {
    group('Configuration Edge Cases', () {
      test('should handle null values in YAML gracefully', () {
        final yaml = {
          'project_id': null,
          'files_path': null,
        };

        final config = PoEditorConfig.fromYaml(yaml);

        expect(config.projectId, isNull);
        expect(config.filesPath, isNull);
      });

      test('should handle empty strings in configuration', () {
        final config = PoEditorConfig(
          apiToken: '',
          projectId: '',
        );

        // Validation should fail
        expect(() => config.validate(), throwsA(isA<ConfigurationException>()));
      });

      test('should handle whitespace-only strings', () {
        final yaml = {
          'project_id': '   ',
          'files_path': '\t\n',
        };

        final config = PoEditorConfig.fromYaml(yaml);

        expect(config.projectId, '   ');
        expect(config.filesPath, '\t\n');
      });

      test('should handle very long configuration values', () {
        final longString = 'a' * 10000;
        final config = PoEditorConfig(
          apiToken: longString,
          projectId: longString,
        );

        expect(config.apiToken?.length, 10000);
        expect(config.projectId?.length, 10000);
      });

      test('should handle special characters in configuration', () {
        final yaml = {
          'project_id': '123!@#\$%^&*()_+-={}[]|\\:";\'<>,.?/',
          'tags': 'mobile,我的标签,العربية',
          'filters': 'translated|untranslated',
        };

        final config = PoEditorConfig.fromYaml(yaml);

        expect(config.projectId, contains('!@#\$'));
        expect(config.tags, contains('我的标签'));
        expect(config.filters, contains('|'));
      });

      test('should handle unicode in file paths', () {
        final config = PoEditorConfig(
          filesPath: 'assets/翻訳/l10n/',
        );

        expect(config.filesPath, contains('翻訳'));
      });
    });

    group('Boolean Parsing Edge Cases', () {
      test('should handle various boolean representations', () {
        final testCases = {
          'true': true,
          'TRUE': true,
          'True': true,
          '1': true,
          'yes': true,
          'YES': true,
          'false': false,
          'FALSE': false,
          'False': false,
          '0': false,
          'no': false,
          'NO': false,
        };

        for (final entry in testCases.entries) {
          final yaml = {'add_metadata': entry.key};
          final config = PoEditorConfig.fromYaml(yaml);
          expect(
            config.addMetadata,
            entry.value,
            reason: 'Expected "${entry.key}" to be ${entry.value}',
          );
        }
      });

      test('should handle invalid boolean values', () {
        final yaml = {'add_metadata': 'maybe'};
        final config = PoEditorConfig.fromYaml(yaml);
        
        expect(config.addMetadata, isNull);
      });

      test('should handle numeric boolean values', () {
        final yaml1 = {'add_metadata': 1};
        final config1 = PoEditorConfig.fromYaml(yaml1);
        expect(config1.addMetadata, isNull); // Not a string '1'

        final yaml2 = {'add_metadata': 0};
        final config2 = PoEditorConfig.fromYaml(yaml2);
        expect(config2.addMetadata, isNull); // Not a string '0'
      });
    });

    group('Configuration Merging Edge Cases', () {
      test('should handle merging three empty configurations', () {
        final config1 = PoEditorConfig();
        final config2 = PoEditorConfig();
        final config3 = PoEditorConfig();

        final merged = PoEditorConfig.merge(config1, config2, config3);

        expect(merged.apiToken, isNull);
        expect(merged.projectId, isNull);
      });

      test('should handle partial overlapping configurations', () {
        final config1 = PoEditorConfig(apiToken: 'token1');
        final config2 = PoEditorConfig(projectId: 'project2', tags: 'tag2');
        final config3 = PoEditorConfig(
          filesPath: 'path3',
          filters: 'filter3',
          addMetadata: true,
        );

        final merged = PoEditorConfig.merge(config1, config2, config3);

        expect(merged.apiToken, 'token1');
        expect(merged.projectId, 'project2');
        expect(merged.tags, 'tag2');
        expect(merged.filesPath, 'path3');
        expect(merged.filters, 'filter3');
        expect(merged.addMetadata, true);
      });

      test('should handle merging with only tertiary having values', () {
        final config1 = PoEditorConfig();
        final config2 = PoEditorConfig();
        final config3 = PoEditorConfig(
          apiToken: 'token3',
          projectId: 'project3',
        );

        final merged = PoEditorConfig.merge(config1, config2, config3);

        expect(merged.apiToken, 'token3');
        expect(merged.projectId, 'project3');
      });
    });

    group('Validation Error Messages', () {
      test('should provide helpful error for missing api_token', () {
        final config = PoEditorConfig(projectId: '12345');

        try {
          config.validate();
          fail('Should have thrown ConfigurationException');
        } on ConfigurationException catch (e) {
          expect(e.message, contains('API token'));
          expect(e.message, contains('--api_token'));
          expect(e.message, contains('PO_EDITOR_API_TOKEN'));
        }
      });

      test('should provide helpful error for missing project_id', () {
        final config = PoEditorConfig(apiToken: 'token');

        try {
          config.validate();
          fail('Should have thrown ConfigurationException');
        } on ConfigurationException catch (e) {
          expect(e.message, contains('Project ID'));
          expect(e.message, contains('--project_id'));
          expect(e.message, contains('pubspec.yaml'));
        }
      });

      test('should combine error messages when both are missing', () {
        final config = PoEditorConfig();

        try {
          config.validate();
          fail('Should have thrown ConfigurationException');
        } on ConfigurationException catch (e) {
          expect(e.message, contains('API token'));
          expect(e.message, contains('Project ID'));
        }
      });
    });

    group('copyWith Edge Cases', () {
      test('should handle copying with all null values', () {
        final config = PoEditorConfig(
          apiToken: 'token',
          projectId: 'project',
        );

        final copy = config.copyWith();

        expect(copy.apiToken, 'token');
        expect(copy.projectId, 'project');
      });

      test('should handle replacing values with null', () {
        final config = PoEditorConfig(
          apiToken: 'token',
          projectId: 'project',
          tags: 'mobile',
        );

        // Note: copyWith doesn't explicitly set to null in current implementation
        // but we can verify behavior
        final copy = config.copyWith(projectId: 'new_project');

        expect(copy.apiToken, 'token');
        expect(copy.projectId, 'new_project');
        expect(copy.tags, 'mobile');
      });

      test('should handle copying boolean false value', () {
        final config = PoEditorConfig(addMetadata: true);
        final copy = config.copyWith(addMetadata: false);

        expect(copy.addMetadata, false);
      });
    });

    group('toString Edge Cases', () {
      test('should handle configuration with all null values', () {
        final config = PoEditorConfig();
        final string = config.toString();

        expect(string, contains('null'));
      });

      test('should mask very long API tokens', () {
        final longToken = 'x' * 1000;
        final config = PoEditorConfig(apiToken: longToken);
        final string = config.toString();

        expect(string, contains('***'));
        expect(string, isNot(contains('x' * 10))); // Should not contain actual token
      });

      test('should handle special characters in toString', () {
        final config = PoEditorConfig(
          projectId: 'project\n\t\r',
          tags: 'mobile,web',
        );
        final string = config.toString();

        expect(string, contains('project'));
        expect(string, contains('mobile,web'));
      });
    });

    group('File System Edge Cases', () {
      late Directory tempDir;

      setUp(() async {
        tempDir = await Directory.systemTemp.createTemp('po_editor_edge_');
      });

      tearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('should handle reading non-existent config file', () async {
        final result = await ConfigReader.readFromFile('non_existent.yaml');
        expect(result, isNull);
      });

      test('should handle empty YAML file', () async {
        final yamlPath = '${tempDir.path}/empty.yaml';
        await File(yamlPath).writeAsString('');

        final result = await ConfigReader.readFromFile(yamlPath);
        expect(result, isNull);
      });

      test('should handle YAML file with only whitespace', () async {
        final yamlPath = '${tempDir.path}/whitespace.yaml';
        await File(yamlPath).writeAsString('   \n\t\n   ');

        final result = await ConfigReader.readFromFile(yamlPath);
        expect(result, isNull);
      });

      test('should handle YAML with only comments', () async {
        final yamlPath = '${tempDir.path}/comments.yaml';
        await File(yamlPath).writeAsString('''
# This is a comment
# Another comment
# po_editor: (commented out)
''');

        final result = await ConfigReader.readFromFile(yamlPath);
        expect(result, isNull);
      });

      test('should handle nested YAML structures', () async {
        final yamlPath = '${tempDir.path}/nested.yaml';
        await File(yamlPath).writeAsString('''
po_editor:
  project_id: "12345"
  nested:
    deeply:
      nested: "value"
''');

        final result = await ConfigReader.readFromFile(yamlPath);
        expect(result, isNotNull);
        expect(result!.projectId, '12345');
      });
    });

    group('Security Edge Cases', () {
      test('should warn when API token is in YAML', () async {
        final tempDir = await Directory.systemTemp.createTemp();
        final yamlPath = '${tempDir.path}/pubspec.yaml';
        
        await File(yamlPath).writeAsString('''
po_editor:
  api_token: "should_not_be_here"
  project_id: "12345"
''');

        // This should trigger warning in stderr
        final result = await ConfigReader.readFromFile(yamlPath);
        
        expect(result, isNotNull);
        expect(result!.apiToken, isNull); // Should be ignored
        expect(result.projectId, '12345'); // Should be read

        await tempDir.delete(recursive: true);
      });

      test('should handle API token from environment', () {
        final envConfig = PoEditorConfig.fromEnvironment();
        
        // Should not throw, even if env var not set
        expect(envConfig, isA<PoEditorConfig>());
      });
    });

    group('ArgParser Edge Cases', () {
      test('should handle empty argument list', () {
        final parser = ArgParser()
          ..addOption('api_token', mandatory: false);
        final result = parser.parse([]);
        
        expect(result['api_token'], isNull);
      });

      test('should handle argument with equals in value', () {
        final parser = ArgParser()
          ..addOption('api_token', mandatory: false);
        final result = parser.parse(['--api_token=key=value=test']);
        
        expect(result['api_token'], 'key=value=test');
      });

      test('should handle argument with spaces in value', () {
        final parser = ArgParser()
          ..addOption('api_token', mandatory: false);
        final result = parser.parse(['--api_token=test value']);
        
        expect(result['api_token'], 'test value');
      });

      test('should handle multiple arguments', () {
        final parser = ArgParser()
          ..addOption('api_token', mandatory: false)
          ..addOption('project_id', mandatory: false);
        final result = parser.parse(['--api_token=token123', '--project_id=456']);
        
        expect(result['api_token'], 'token123');
        expect(result['project_id'], '456');
      });
    });
  });
}
