import 'dart:io';

import 'package:yaml/yaml.dart';

import 'po_editor_config.dart';

/// Service for reading configuration from YAML files
///
/// This class provides methods to read POEditor configuration from:
/// - The project's `pubspec.yaml` file (default location)
/// - Custom YAML configuration files
///
/// The configuration is expected to be under a `po_editor` key in the YAML.
class ConfigReader {
  /// Read configuration from the project's pubspec.yaml
  ///
  /// Looks for a `po_editor` section in the pubspec.yaml file in the
  /// current directory. Returns null if the file doesn't exist or
  /// doesn't contain a `po_editor` section.
  ///
  /// Example pubspec.yaml:
  /// ```yaml
  /// po_editor:
  ///   project_id: "12345"
  ///   files_path: "lib/l10n/"
  ///   add_metadata: true
  /// ```
  static Future<PoEditorConfig?> readFromPubspec() async {
    return readFromFile('pubspec.yaml');
  }

  /// Read configuration from a custom YAML file
  ///
  /// [path] - Path to the YAML file (relative or absolute)
  ///
  /// Returns null if the file doesn't exist or doesn't contain
  /// a `po_editor` section.
  ///
  /// The YAML file should have a `po_editor` section at the root level.
  static Future<PoEditorConfig?> readFromFile(String path) async {
    try {
      final file = File(path);
      
      if (!await file.exists()) {
        return null;
      }

      final contents = await file.readAsString();
      final yaml = loadYaml(contents);

      if (yaml == null || yaml is! YamlMap) {
        return null;
      }

      // Look for po_editor section
      final poEditorSection = yaml['po_editor'];
      
      if (poEditorSection == null) {
        return null;
      }

      // Convert YamlMap to regular Map
      final configMap = _yamlToMap(poEditorSection);
      
      return PoEditorConfig.fromYaml(configMap);
    } on FileSystemException {
      // File doesn't exist or can't be read
      return null;
    } on YamlException catch (e) {
      stderr.writeln('Error parsing YAML from $path: $e');
      return null;
    } catch (e) {
      stderr.writeln('Unexpected error reading config from $path: $e');
      return null;
    }
  }

  /// Convert YamlMap to regular Map recursively
  static Map<String, dynamic> _yamlToMap(dynamic yaml) {
    if (yaml is YamlMap) {
      final map = <String, dynamic>{};
      for (final entry in yaml.entries) {
        map[entry.key.toString()] = _yamlToValue(entry.value);
      }
      return map;
    }
    return {};
  }

  /// Convert YAML value to regular Dart value recursively
  static dynamic _yamlToValue(dynamic value) {
    if (value is YamlMap) {
      return _yamlToMap(value);
    } else if (value is YamlList) {
      return value.map(_yamlToValue).toList();
    } else {
      return value;
    }
  }
}
