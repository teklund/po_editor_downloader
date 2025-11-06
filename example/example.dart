import 'package:po_editor_downloader/po_editor_downloader.dart';

/// Example of using the po_editor_downloader library programmatically.
///
/// This example shows how to:
/// 1. Create a configuration object
/// 2. Initialize the POEditor service
/// 3. Download translations
///
/// For CLI usage, see the README.md file.
void main() async {
  // Example 1: Basic configuration
  print('Example 1: Basic configuration');
  print('=' * 50);
  
  final basicConfig = PoEditorConfig(
    apiToken: 'your-api-token-here',
    projectId: '12345',
    filesPath: 'lib/l10n/',
  );

  print('Configuration created:');
  print('  Project ID: ${basicConfig.projectId}');
  print('  Output path: ${basicConfig.filesPath}');
  print('  Add metadata: ${basicConfig.addMetadata}');
  print('');

  // Example 2: Advanced configuration with filtering
  print('Example 2: Advanced configuration with filtering');
  print('=' * 50);
  
  final advancedConfig = PoEditorConfig(
    apiToken: 'your-api-token-here',
    projectId: '12345',
    filesPath: 'lib/l10n/',
    tags: 'mobile,released',
    filters: 'translated',
    filenamePattern: 'app_{code}.arb',
    addMetadata: true,
  );

  print('Configuration with filters:');
  print('  Tags: ${advancedConfig.tags}');
  print('  Filters: ${advancedConfig.filters}');
  print('  Filename pattern: ${advancedConfig.filenamePattern}');
  print('');

  // Example 3: Reading configuration from YAML
  print('Example 3: Reading from pubspec.yaml');
  print('=' * 50);
  
  final yamlConfig = await ConfigReader.readFromPubspec();
  
  if (yamlConfig != null) {
    print('Configuration loaded from pubspec.yaml:');
    print('  Project ID: ${yamlConfig.projectId}');
    print('  Output path: ${yamlConfig.filesPath}');
    print('');
  } else {
    print('No po_editor configuration found in pubspec.yaml');
    print('');
  }

  // Example 4: Downloading translations
  print('Example 4: Downloading translations');
  print('=' * 50);
  print('To actually download translations, uncomment the code below');
  print('and replace with your real API token and project ID:');
  print('');
  print('  final service = PoEditorService(basicConfig);');
  print('  await service.downloadTranslations();');
  print('');

  // Uncomment to actually download (requires valid credentials):
  /*
  final service = PoEditorService(basicConfig);
  try {
    await service.downloadTranslations();
    print('✅ Download completed successfully!');
  } on PoEditorException catch (e) {
    print('❌ Error: ${e.message}');
  }
  */

  // Example 5: Using ReCase for string transformations
  print('Example 5: String case transformations');
  print('=' * 50);
  
  final rc = ReCase('hello_world');
  print('Original: hello_world');
  print('  camelCase: ${rc.toCamelCase()}');
  print('');
}
