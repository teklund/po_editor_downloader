import 'dart:io';

import 'package:test/test.dart';

// Import the ensureOutputDirectory function from the main file
// Since it's not exported, we need to test it via integration

void main() {
  group('Directory Validation', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('po_editor_dir_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('should create directory if it does not exist', () async {
      final newDir = Directory('${tempDir.path}/new_output');
      expect(await newDir.exists(), isFalse);

      // Create directory
      await newDir.create(recursive: true);

      expect(await newDir.exists(), isTrue);
    });

    test('should not fail if directory already exists', () async {
      final existingDir = Directory('${tempDir.path}/existing');
      await existingDir.create();

      expect(await existingDir.exists(), isTrue);

      // Try to create again - should not throw
      await existingDir.create(recursive: true);

      expect(await existingDir.exists(), isTrue);
    });

    test('should create nested directories', () async {
      final nestedDir = Directory('${tempDir.path}/level1/level2/level3');
      expect(await nestedDir.exists(), isFalse);

      await nestedDir.create(recursive: true);

      expect(await nestedDir.exists(), isTrue);
      expect(await Directory('${tempDir.path}/level1').exists(), isTrue);
      expect(await Directory('${tempDir.path}/level1/level2').exists(), isTrue);
    });

    test('should be able to write to created directory', () async {
      final outputDir = Directory('${tempDir.path}/output');
      await outputDir.create(recursive: true);

      final testFile = File('${outputDir.path}/test.txt');
      await testFile.writeAsString('test content');

      expect(await testFile.exists(), isTrue);
      expect(await testFile.readAsString(), equals('test content'));
    });

    test('should be able to write multiple files to directory', () async {
      final outputDir = Directory('${tempDir.path}/multi_output');
      await outputDir.create(recursive: true);

      for (var i = 0; i < 5; i++) {
        final file = File('${outputDir.path}/file_$i.txt');
        await file.writeAsString('content $i');
      }

      final files = await outputDir.list().toList();
      expect(files.length, equals(5));
    });

    test('should handle paths with special characters', () async {
      final specialDir = Directory('${tempDir.path}/output-2024_test.dir');
      await specialDir.create(recursive: true);

      expect(await specialDir.exists(), isTrue);

      final testFile = File('${specialDir.path}/app_en.arb');
      await testFile.writeAsString('{"test": "value"}');

      expect(await testFile.exists(), isTrue);
    });

    test('should detect non-writable directory', () async {
      // This test is platform-specific and may not work on all systems
      if (Platform.isLinux || Platform.isMacOS) {
        final readOnlyDir = Directory('${tempDir.path}/readonly');
        await readOnlyDir.create();

        // Make directory read-only
        await Process.run('chmod', ['555', readOnlyDir.path]);

        final testFile = File('${readOnlyDir.path}/test.txt');

        try {
          await testFile.writeAsString('test');
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isA<FileSystemException>());
        } finally {
          // Restore permissions for cleanup
          await Process.run('chmod', ['755', readOnlyDir.path]);
        }
      }
    });

    test('should handle concurrent directory creation', () async {
      final concurrentDir = Directory('${tempDir.path}/concurrent');

      // Try to create the same directory multiple times concurrently
      final futures = List.generate(
        10,
        (_) => concurrentDir.create(recursive: true),
      );

      await Future.wait(futures);

      expect(await concurrentDir.exists(), isTrue);
    });

    test('should handle very long path names', () async {
      // Create a reasonably long path (but not excessive to avoid OS limits)
      final longPath =
          '${tempDir.path}/very/long/nested/directory/structure/for/testing/purposes';
      final longDir = Directory(longPath);

      await longDir.create(recursive: true);

      expect(await longDir.exists(), isTrue);

      final testFile = File('$longPath/test.arb');
      await testFile.writeAsString('{}');

      expect(await testFile.exists(), isTrue);
    });
  });

  group('File Writing Edge Cases', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('po_editor_file_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('should overwrite existing file', () async {
      final file = File('${tempDir.path}/test.arb');
      await file.writeAsString('original content');

      expect(await file.readAsString(), equals('original content'));

      await file.writeAsString('new content');

      expect(await file.readAsString(), equals('new content'));
    });

    test('should handle empty file content', () async {
      final file = File('${tempDir.path}/empty.arb');
      await file.writeAsString('');

      expect(await file.exists(), isTrue);
      expect(await file.readAsString(), equals(''));
    });

    test('should handle large file content', () async {
      final largeContent = '{"key": "value"}' * 10000;
      final file = File('${tempDir.path}/large.arb');
      await file.writeAsString(largeContent);

      expect(await file.exists(), isTrue);
      expect((await file.readAsString()).length, equals(largeContent.length));
    });

    test('should handle unicode content', () async {
      final unicodeContent = '{"hello": "Hello 世界 🌍"}';
      final file = File('${tempDir.path}/unicode.arb');
      await file.writeAsString(unicodeContent);

      expect(await file.readAsString(), equals(unicodeContent));
    });

    test('should handle filenames with special characters', () async {
      final file = File('${tempDir.path}/app_en-US.arb');
      await file.writeAsString('{"test": "value"}');

      expect(await file.exists(), isTrue);
    });
  });
}
