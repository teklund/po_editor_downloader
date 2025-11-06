import 'dart:io';

import 'package:po_editor_downloader/po_editor_downloader.dart';
import 'package:test/test.dart';

void main() {
  group('Configuration Integration Tests', () {
    late Directory tempDir;
    late String testYamlPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('po_editor_integration_');
      testYamlPath = '${tempDir.path}/test_pubspec.yaml';
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('CLI arguments override YAML configuration', () async {
      // Create YAML config
      final yamlContent = '''
po_editor:
  project_id: "yaml_project"
  files_path: "yaml/path/"
  tags: "yaml_tag"
''';
      await File(testYamlPath).writeAsString(yamlContent);

      final yamlConfig = await ConfigReader.readFromFile(testYamlPath);
      final cliConfig = PoEditorConfig.fromCommandLine({
        'project_id': 'cli_project',
        'tags': 'cli_tag',
      });

      final merged = PoEditorConfig.merge(cliConfig, yamlConfig!);

      expect(merged.projectId, 'cli_project'); // CLI overrides
      expect(merged.tags, 'cli_tag'); // CLI overrides
      expect(merged.filesPath, 'yaml/path/'); // YAML fallback
    });

    test('Environment variable takes precedence for API token', () async {
      final envConfig = PoEditorConfig(apiToken: 'env_token');
      final cliConfig = PoEditorConfig(projectId: 'cli_project');

      final merged = PoEditorConfig.merge(cliConfig, envConfig);

      expect(merged.apiToken, 'env_token');
      expect(merged.projectId, 'cli_project');
    });

    test('CLI > ENV > YAML priority chain', () async {
      // Create YAML config
      final yamlContent = '''
po_editor:
  project_id: "yaml_project"
  files_path: "yaml/path/"
  tags: "yaml_tag"
  filters: "yaml_filter"
''';
      await File(testYamlPath).writeAsString(yamlContent);

      final yamlConfig = await ConfigReader.readFromFile(testYamlPath);
      final envConfig = PoEditorConfig(
        apiToken: 'env_token',
        tags: 'env_tag',
      );
      final cliConfig = PoEditorConfig(
        apiToken: 'cli_token',
        projectId: 'cli_project',
      );

      final merged =
          PoEditorConfig.merge(cliConfig, envConfig, yamlConfig);

      expect(merged.apiToken, 'cli_token'); // CLI wins
      expect(merged.projectId, 'cli_project'); // CLI only
      expect(merged.tags, 'env_tag'); // ENV over YAML
      expect(merged.filters, 'yaml_filter'); // YAML fallback
      expect(merged.filesPath, 'yaml/path/'); // YAML fallback
    });

    test('Partial CLI args merge with YAML config', () async {
      // Create YAML with full config
      final yamlContent = '''
po_editor:
  project_id: "12345"
  files_path: "lib/l10n/"
  tags: "mobile,ios"
  filters: "translated"
  add_metadata: true
''';
      await File(testYamlPath).writeAsString(yamlContent);

      final yamlConfig = await ConfigReader.readFromFile(testYamlPath);
      
      // CLI only provides filters override
      final cliConfig = PoEditorConfig.fromCommandLine({
        'filters': 'proofread',
      });

      final merged = PoEditorConfig.merge(cliConfig, yamlConfig!);

      expect(merged.projectId, '12345');
      expect(merged.filesPath, 'lib/l10n/');
      expect(merged.tags, 'mobile,ios');
      expect(merged.filters, 'proofread'); // Override
      expect(merged.addMetadata, true);
    });

    test('Validation fails when API token missing from all sources', () async {
      // Create YAML without API token (correct practice)
      final yamlContent = '''
po_editor:
  project_id: "12345"
''';
      await File(testYamlPath).writeAsString(yamlContent);

      final yamlConfig = await ConfigReader.readFromFile(testYamlPath);
      final cliConfig = PoEditorConfig.fromCommandLine({});
      final envConfig = PoEditorConfig();

      final merged =
          PoEditorConfig.merge(cliConfig, envConfig, yamlConfig);

      expect(() => merged.validate(), throwsA(isA<ConfigurationException>()));
    });

    test('Validation succeeds with CLI API token and YAML project ID', () async {
      // Create YAML with project config
      final yamlContent = '''
po_editor:
  project_id: "12345"
  files_path: "lib/l10n/"
''';
      await File(testYamlPath).writeAsString(yamlContent);

      final yamlConfig = await ConfigReader.readFromFile(testYamlPath);
      final cliConfig = PoEditorConfig.fromCommandLine({
        'api_token': 'secret_token',
      });

      final merged = PoEditorConfig.merge(cliConfig, yamlConfig!);

      expect(() => merged.validate(), returnsNormally);
      expect(merged.apiToken, 'secret_token');
      expect(merged.projectId, '12345');
    });

    test('Boolean add_metadata can be overridden', () async {
      // YAML has add_metadata = true
      final yamlContent = '''
po_editor:
  project_id: "12345"
  add_metadata: true
''';
      await File(testYamlPath).writeAsString(yamlContent);

      final yamlConfig = await ConfigReader.readFromFile(testYamlPath);
      
      // CLI sets it to false
      final cliConfig = PoEditorConfig.fromCommandLine({
        'add_metadata': 'false',
      });

      final merged = PoEditorConfig.merge(cliConfig, yamlConfig!);

      expect(merged.addMetadata, false);
    });

    test('Empty CLI config uses all YAML values', () async {
      final yamlContent = '''
po_editor:
  project_id: "12345"
  files_path: "assets/translations/"
  tags: "mobile,web"
  filters: "translated"
  add_metadata: true
''';
      await File(testYamlPath).writeAsString(yamlContent);

      final yamlConfig = await ConfigReader.readFromFile(testYamlPath);
      final cliConfig = PoEditorConfig(); // Empty

      final merged = PoEditorConfig.merge(cliConfig, yamlConfig!);

      expect(merged.projectId, '12345');
      expect(merged.filesPath, 'assets/translations/');
      expect(merged.tags, 'mobile,web');
      expect(merged.filters, 'translated');
      expect(merged.addMetadata, true);
    });

    test('Complex tag override scenario', () async {
      final yamlContent = '''
po_editor:
  project_id: "12345"
  tags: "mobile,ios,android"
''';
      await File(testYamlPath).writeAsString(yamlContent);

      final yamlConfig = await ConfigReader.readFromFile(testYamlPath);
      final cliConfig = PoEditorConfig.fromCommandLine({
        'tags': 'web,desktop',
      });

      final merged = PoEditorConfig.merge(cliConfig, yamlConfig!);

      expect(merged.tags, 'web,desktop'); // Complete override, not merge
    });
  });

  group('Real-world Scenarios', () {
    test('Developer workflow: YAML config + ENV token', () async {
      // Simulate typical developer setup
      final yamlConfig = PoEditorConfig.fromYaml({
        'project_id': '12345',
        'files_path': 'lib/l10n/',
        'add_metadata': true,
      });

      // Developer has PO_EDITOR_API_TOKEN in their environment
      final envConfig = PoEditorConfig(apiToken: 'dev_secret_token');

      // No CLI args needed for regular workflow
      final cliConfig = PoEditorConfig();

      final merged = PoEditorConfig.merge(cliConfig, envConfig, yamlConfig);

      expect(() => merged.validate(), returnsNormally);
      expect(merged.apiToken, 'dev_secret_token');
      expect(merged.projectId, '12345');
      expect(merged.filesPath, 'lib/l10n/');
      expect(merged.addMetadata, true);
    });

    test('CI/CD workflow: Only CLI arguments', () async {
      // CI/CD might not have YAML or might override everything
      final cliConfig = PoEditorConfig.fromCommandLine({
        'api_token': 'ci_secret_token',
        'project_id': '99999',
        'files_path': 'build/l10n/',
        'filters': 'translated',
      });

      expect(() => cliConfig.validate(), returnsNormally);
      expect(cliConfig.apiToken, 'ci_secret_token');
      expect(cliConfig.projectId, '99999');
      expect(cliConfig.filesPath, 'build/l10n/');
    });

    test('Override tags for specific build', () async {
      // Base config from YAML
      final yamlConfig = PoEditorConfig.fromYaml({
        'project_id': '12345',
        'tags': 'mobile',
        'filters': 'translated',
      });

      final envConfig = PoEditorConfig(apiToken: 'token123');

      // Override just tags for web build
      final cliConfig = PoEditorConfig.fromCommandLine({
        'tags': 'web',
      });

      final merged = PoEditorConfig.merge(cliConfig, envConfig, yamlConfig);

      expect(merged.tags, 'web'); // Overridden
      expect(merged.filters, 'translated'); // From YAML
      expect(merged.projectId, '12345'); // From YAML
    });
  });
}
