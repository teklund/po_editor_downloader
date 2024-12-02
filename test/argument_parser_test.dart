import 'package:po_editor_downloader/po_editor_downloader.dart';
import 'package:test/test.dart';

void main() {
  group('ArgumentValueParser', () {
    test('should return the value of the option if found', () {
      final args = ['--input=data.txt', '--output=results.txt'];
      expect(ArgumentValueParser.parse('output', args), 'results.txt');
    });

    test('should return null if the option is not found', () {
      final args = ['--input=data.txt'];
      expect(ArgumentValueParser.parse('output', args), null);
    });

    test('should handle options with spaces in the value', () {
      final args = ['--message="Hello world"'];
      expect(ArgumentValueParser.parse('message', args), 'Hello world');
    });

    test('should handle options with trailing spaces', () {
      final args = ['--path= /home/user/  '];
      expect(ArgumentValueParser.parse('path', args), '/home/user/');
    });
    test('should handle tags with no quotes', () {
      final args = ['--tags=name-of-tag'];
      expect(ArgumentValueParser.parse('tags', args), 'name-of-tag');
    });

    test('should handle tags with single quotes', () {
      final args = ['--tags="name-of-tag"'];
      expect(ArgumentValueParser.parse('tags', args), 'name-of-tag');
    });

    test('should handle tags with multiple values in single quotes', () {
      final args = ['--tags="name-of-tag,name-of-another-tag"'];
      expect(ArgumentValueParser.parse('tags', args),
          'name-of-tag,name-of-another-tag');
    });
  });
}
