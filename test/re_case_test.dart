import 'package:po_editor_downloader/po_editor_downloader.dart';
import 'package:test/test.dart';

void main() {
  group('ReCase', () {
    test('toCamelCase()', () {
      expect(ReCase('hello world').toCamelCase(), 'helloWorld');
      expect(ReCase('snake_case').toCamelCase(), 'snakeCase');
      expect(ReCase('kebab-case').toCamelCase(), 'kebabCase');
      expect(ReCase('Title Case').toCamelCase(), 'titleCase');
      expect(ReCase('camelCase').toCamelCase(), 'camelCase');
      expect(ReCase('PascalCase').toCamelCase(), 'pascalCase');
      expect(ReCase('UPPERCASE').toCamelCase(), 'uppercase');
      expect(ReCase('lowercase').toCamelCase(), 'lowercase');
      expect(ReCase('').toCamelCase(), '');
      expect(ReCase(' multiple   spaces').toCamelCase(), 'multipleSpaces');
      expect(ReCase('leading space').toCamelCase(), 'leadingSpace');
      expect(ReCase('trailing space ').toCamelCase(), 'trailingSpace');
      expect(ReCase('internal  multiple   spaces').toCamelCase(),
          'internalMultipleSpaces');
      expect(ReCase('space age').toCamelCase(), 'spaceAge');
      expect(ReCase('  space age  ').toCamelCase(), 'spaceAge');
      expect(ReCase('hyphen-delimited').toCamelCase(), 'hyphenDelimited');
      expect(ReCase('snake_case_longer').toCamelCase(), 'snakeCaseLonger');
      expect(ReCase('dot.case').toCamelCase(), 'dotCase');
      expect(ReCase('path/case').toCamelCase(), 'pathCase');
      expect(ReCase('Mix1').toCamelCase(), 'mix1');
      expect(ReCase('').toCamelCase(), '');
    });
  });
}
