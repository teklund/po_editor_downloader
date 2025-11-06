import 'dart:io';

import 'package:po_editor_downloader/po_editor_downloader.dart';
import 'package:test/test.dart';

void main() {
  group('PoEditorConfig', () {
    group('fromYaml', () {
      test('should parse valid YAML configuration', () {
        final yaml = {
          'project_id': '12345',
          'files_path': 'assets/l10n/',
          'tags': 'mobile',
          'filters': 'translated',
          'add_metadata': true,
        };

        final config = PoEditorConfig.fromYaml(yaml);

        expect(config.projectId, '12345');
        expect(config.filesPath, 'assets/l10n/');
        expect(config.tags, 'mobile');
        expect(config.filters, 'translated');
        expect(config.addMetadata, true);
        expect(config.apiToken, isNull);
      });

      test('should handle boolean strings', () {
        final yaml = {
          'add_metadata': 'true',
        };

        final config = PoEditorConfig.fromYaml(yaml);

        expect(config.addMetadata, true);
      });

      test('should handle false boolean', () {
        final yaml = {
          'add_metadata': false,
        };

        final config = PoEditorConfig.fromYaml(yaml);

        expect(config.addMetadata, false);
      });

      test('should ignore api_token in YAML (security)', () {
        final yaml = {
          'api_token': 'should_not_be_here',
          'project_id': '12345',
        };

        final config = PoEditorConfig.fromYaml(yaml);

        expect(config.apiToken, isNull);
        expect(config.projectId, '12345');
      });
    });

    group('fromCommandLine', () {
      test('should parse CLI arguments', () {
        final args = {
          'api_token': 'secret123',
          'project_id': '456',
          'files_path': 'lib/l10n/',
          'tags': 'web',
          'filters': 'proofread',
          'add_metadata': 'true',
        };

        final config = PoEditorConfig.fromCommandLine(args);

        expect(config.apiToken, 'secret123');
        expect(config.projectId, '456');
        expect(config.filesPath, 'lib/l10n/');
        expect(config.tags, 'web');
        expect(config.filters, 'proofread');
        expect(config.addMetadata, true);
      });

      test('should handle null values', () {
        final args = <String, String?>{
          'api_token': null,
          'project_id': null,
        };

        final config = PoEditorConfig.fromCommandLine(args);

        expect(config.apiToken, isNull);
        expect(config.projectId, isNull);
      });
    });

    group('fromEnvironment', () {
      test('should read API token from environment', () {
        // Note: This test assumes PO_EDITOR_API_TOKEN might be set
        final config = PoEditorConfig.fromEnvironment();

        // Just verify it doesn't throw and returns a config
        expect(config, isA<PoEditorConfig>());
      });
    });

    group('merge', () {
      test('should prioritize primary over secondary', () {
        final primary = PoEditorConfig(
          apiToken: 'token1',
          projectId: 'project1',
        );

        final secondary = PoEditorConfig(
          apiToken: 'token2',
          projectId: 'project2',
          filesPath: 'path2',
        );

        final merged = PoEditorConfig.merge(primary, secondary);

        expect(merged.apiToken, 'token1');
        expect(merged.projectId, 'project1');
        expect(merged.filesPath, 'path2');
      });

      test('should use secondary when primary is null', () {
        final primary = PoEditorConfig(
          apiToken: 'token1',
        );

        final secondary = PoEditorConfig(
          projectId: 'project2',
          filesPath: 'path2',
        );

        final merged = PoEditorConfig.merge(primary, secondary);

        expect(merged.apiToken, 'token1');
        expect(merged.projectId, 'project2');
        expect(merged.filesPath, 'path2');
      });

      test('should handle tertiary configuration', () {
        final primary = PoEditorConfig(apiToken: 'token1');
        final secondary = PoEditorConfig(projectId: 'project2');
        final tertiary = PoEditorConfig(
          filesPath: 'path3',
          tags: 'tags3',
        );

        final merged = PoEditorConfig.merge(primary, secondary, tertiary);

        expect(merged.apiToken, 'token1');
        expect(merged.projectId, 'project2');
        expect(merged.filesPath, 'path3');
        expect(merged.tags, 'tags3');
      });
    });

    group('validate', () {
      test('should pass with required fields', () {
        final config = PoEditorConfig(
          apiToken: 'token',
          projectId: 'project',
        );

        expect(() => config.validate(), returnsNormally);
      });

      test('should throw when api_token is missing', () {
        final config = PoEditorConfig(
          projectId: 'project',
        );

        expect(
          () => config.validate(),
          throwsA(isA<ConfigurationException>()),
        );
      });

      test('should throw when project_id is missing', () {
        final config = PoEditorConfig(
          apiToken: 'token',
        );

        expect(
          () => config.validate(),
          throwsA(isA<ConfigurationException>()),
        );
      });

      test('should throw when both are missing', () {
        final config = PoEditorConfig();

        expect(
          () => config.validate(),
          throwsA(isA<ConfigurationException>()),
        );
      });

      test('should throw when api_token is empty', () {
        final config = PoEditorConfig(
          apiToken: '',
          projectId: 'project',
        );

        expect(
          () => config.validate(),
          throwsA(isA<ConfigurationException>()),
        );
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        final config = PoEditorConfig(
          apiToken: 'token1',
          projectId: 'project1',
        );

        final copy = config.copyWith(projectId: 'project2');

        expect(copy.apiToken, 'token1');
        expect(copy.projectId, 'project2');
      });

      test('should keep original values if not specified', () {
        final config = PoEditorConfig(
          apiToken: 'token1',
          projectId: 'project1',
          filesPath: 'path1',
        );

        final copy = config.copyWith(projectId: 'project2');

        expect(copy.apiToken, 'token1');
        expect(copy.projectId, 'project2');
        expect(copy.filesPath, 'path1');
      });
    });

    group('toString', () {
      test('should mask API token', () {
        final config = PoEditorConfig(
          apiToken: 'secret123',
          projectId: 'project1',
        );

        final string = config.toString();

        expect(string, contains('***'));
        expect(string, isNot(contains('secret123')));
        expect(string, contains('project1'));
      });

      test('should handle null API token', () {
        final config = PoEditorConfig(
          projectId: 'project1',
        );

        final string = config.toString();

        expect(string, contains('null'));
        expect(string, contains('project1'));
      });
    });
  });

  group('ConfigReader', () {
    late Directory tempDir;
    late String testYamlPath;

    setUp(() async {
      // Create temporary directory for test files
      tempDir = await Directory.systemTemp.createTemp('po_editor_test_');
      testYamlPath = '${tempDir.path}/test_config.yaml';
    });

    tearDown(() async {
      // Clean up temporary directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('readFromFile', () {
      test('should read valid YAML config', () async {
        final yamlContent = '''
po_editor:
  project_id: "12345"
  files_path: "assets/l10n/"
  tags: "mobile"
  add_metadata: true
''';
        await File(testYamlPath).writeAsString(yamlContent);

        final config = await ConfigReader.readFromFile(testYamlPath);

        expect(config, isNotNull);
        expect(config!.projectId, '12345');
        expect(config.filesPath, 'assets/l10n/');
        expect(config.tags, 'mobile');
        expect(config.addMetadata, true);
      });

      test('should return null for non-existent file', () async {
        final config =
            await ConfigReader.readFromFile('non_existent_file.yaml');

        expect(config, isNull);
      });

      test('should return null for YAML without po_editor section', () async {
        final yamlContent = '''
name: my_package
version: 1.0.0
''';
        await File(testYamlPath).writeAsString(yamlContent);

        final config = await ConfigReader.readFromFile(testYamlPath);

        expect(config, isNull);
      });

      test('should handle empty po_editor section', () async {
        final yamlContent = '''
po_editor: {}
''';
        await File(testYamlPath).writeAsString(yamlContent);

        final config = await ConfigReader.readFromFile(testYamlPath);

        expect(config, isNotNull);
        expect(config!.projectId, isNull);
      });

      test('should handle invalid YAML gracefully', () async {
        final yamlContent = '''
po_editor:
  invalid: [unclosed array
''';
        await File(testYamlPath).writeAsString(yamlContent);

        final config = await ConfigReader.readFromFile(testYamlPath);

        expect(config, isNull);
      });
    });

    test('readFromPubspec should look for pubspec.yaml', () async {
      // This test just verifies it doesn't crash
      // In real project root, it might find the actual pubspec
      final config = await ConfigReader.readFromPubspec();

      // Should return null or a config, but not throw
      expect(config, anyOf(isNull, isA<PoEditorConfig>()));
    });
  });

  group('ConfigurationException', () {
    test('should have proper toString representation', () {
      final exception = ConfigurationException('Test error message');
      
      expect(exception.message, 'Test error message');
      expect(exception.toString(), 'ConfigurationException: Test error message');
    });
  });
}
