import 'dart:io';

/// Configuration model for POEditor downloader
///
/// This class holds all configuration values that can be sourced from:
/// - Command-line arguments (highest priority)
/// - Environment variables (for API token)
/// - YAML configuration files (pubspec.yaml or custom config)
/// - Default values (lowest priority)
///
/// **Security Note**: The API token should NEVER be stored in YAML files.
/// Use environment variables or CLI arguments instead.
class PoEditorConfig {
  /// POEditor API token (should come from CLI or environment variable only)
  final String? apiToken;

  /// POEditor project ID
  final String? projectId;

  /// Output directory path for ARB files
  final String? filesPath;

  /// Tags to filter terms (comma-separated or single tag)
  final String? tags;

  /// Filters for terms (e.g., translated, untranslated, fuzzy)
  final String? filters;

  /// Whether to include metadata in ARB files
  final bool? addMetadata;

  /// Create a configuration instance
  const PoEditorConfig({
    this.apiToken,
    this.projectId,
    this.filesPath,
    this.tags,
    this.filters,
    this.addMetadata,
  });

  /// Create configuration from YAML map
  ///
  /// **Note**: This method intentionally ignores `api_token` from YAML
  /// for security reasons. API tokens should come from environment variables
  /// or CLI arguments only.
  factory PoEditorConfig.fromYaml(Map<String, dynamic> yaml) {
    // Warn if api_token is found in YAML
    if (yaml.containsKey('api_token')) {
      stderr.writeln(
        'WARNING: Found "api_token" in YAML configuration. '
        'For security reasons, API tokens should not be stored in YAML files. '
        'Use PO_EDITOR_API_TOKEN environment variable or --api_token CLI argument instead.',
      );
    }

    return PoEditorConfig(
      // Intentionally NOT reading api_token from YAML for security
      projectId: yaml['project_id']?.toString(),
      filesPath: yaml['files_path']?.toString(),
      tags: yaml['tags']?.toString(),
      filters: yaml['filters']?.toString(),
      addMetadata: _parseBool(yaml['add_metadata']),
    );
  }

  /// Create configuration from command-line arguments map
  factory PoEditorConfig.fromCommandLine(Map<String, String?> args) {
    return PoEditorConfig(
      apiToken: args['api_token'],
      projectId: args['project_id'],
      filesPath: args['files_path'],
      tags: args['tags'],
      filters: args['filters'],
      addMetadata: _parseBool(args['add_metadata']),
    );
  }

  /// Create configuration from environment variables
  ///
  /// Currently only reads the API token from PO_EDITOR_API_TOKEN
  factory PoEditorConfig.fromEnvironment() {
    return PoEditorConfig(
      apiToken: Platform.environment['PO_EDITOR_API_TOKEN'],
    );
  }

  /// Merge multiple configurations with priority: primary > secondary > tertiary
  ///
  /// This allows CLI arguments to override environment variables,
  /// which override YAML configuration.
  factory PoEditorConfig.merge(
    PoEditorConfig primary,
    PoEditorConfig secondary, [
    PoEditorConfig? tertiary,
  ]) {
    return PoEditorConfig(
      apiToken: primary.apiToken ?? secondary.apiToken ?? tertiary?.apiToken,
      projectId:
          primary.projectId ?? secondary.projectId ?? tertiary?.projectId,
      filesPath:
          primary.filesPath ?? secondary.filesPath ?? tertiary?.filesPath,
      tags: primary.tags ?? secondary.tags ?? tertiary?.tags,
      filters: primary.filters ?? secondary.filters ?? tertiary?.filters,
      addMetadata:
          primary.addMetadata ?? secondary.addMetadata ?? tertiary?.addMetadata,
    );
  }

  /// Validate that required fields are present
  ///
  /// Throws [ConfigurationException] if validation fails
  void validate() {
    final errors = <String>[];

    if (apiToken == null || apiToken!.isEmpty) {
      errors.add(
        'API token is required. Provide via:\n'
        '  - Command line: --api_token=YOUR_TOKEN\n'
        '  - Environment variable: PO_EDITOR_API_TOKEN=YOUR_TOKEN',
      );
    }

    if (projectId == null || projectId!.isEmpty) {
      errors.add(
        'Project ID is required. Provide via:\n'
        '  - Command line: --project_id=YOUR_PROJECT_ID\n'
        '  - YAML config: po_editor.project_id in pubspec.yaml',
      );
    }

    if (errors.isNotEmpty) {
      throw ConfigurationException(errors.join('\n\n'));
    }
  }

  /// Create a copy with some fields replaced
  PoEditorConfig copyWith({
    String? apiToken,
    String? projectId,
    String? filesPath,
    String? tags,
    String? filters,
    bool? addMetadata,
  }) {
    return PoEditorConfig(
      apiToken: apiToken ?? this.apiToken,
      projectId: projectId ?? this.projectId,
      filesPath: filesPath ?? this.filesPath,
      tags: tags ?? this.tags,
      filters: filters ?? this.filters,
      addMetadata: addMetadata ?? this.addMetadata,
    );
  }

  @override
  String toString() {
    return 'PoEditorConfig('
        'apiToken: ${apiToken != null ? "***" : "null"}, '
        'projectId: $projectId, '
        'filesPath: $filesPath, '
        'tags: $tags, '
        'filters: $filters, '
        'addMetadata: $addMetadata)';
  }

  /// Parse a boolean value from various input types
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
    }
    return null;
  }
}

/// Exception thrown when configuration validation fails
class ConfigurationException implements Exception {
  /// The error message describing why validation failed
  final String message;

  /// Create a configuration exception with the given error [message]
  ConfigurationException(this.message);

  @override
  String toString() => 'ConfigurationException: $message';
}
