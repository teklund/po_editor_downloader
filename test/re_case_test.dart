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

    test('toPascalCase()', () {
      expect(ReCase('hello world').toPascalCase(), 'HelloWorld');
      expect(ReCase('snake_case').toPascalCase(), 'SnakeCase');
      expect(ReCase('kebab-case').toPascalCase(), 'KebabCase');
      expect(ReCase('camelCase').toPascalCase(), 'CamelCase');
      expect(ReCase('PascalCase').toPascalCase(), 'PascalCase');
      expect(ReCase('UPPERCASE').toPascalCase(), 'Uppercase');
      expect(ReCase('lowercase').toPascalCase(), 'Lowercase');
      expect(ReCase('').toPascalCase(), '');
    });

    test('toSnakeCase()', () {
      expect(ReCase('hello world').toSnakeCase(), 'hello_world');
      expect(ReCase('camelCase').toSnakeCase(), 'camel_case');
      expect(ReCase('PascalCase').toSnakeCase(), 'pascal_case');
      expect(ReCase('kebab-case').toSnakeCase(), 'kebab_case');
      expect(ReCase('UPPERCASE').toSnakeCase(), 'uppercase');
      expect(ReCase('snake_case').toSnakeCase(), 'snake_case');
      expect(ReCase('').toSnakeCase(), '');
    });

    test('toConstantCase()', () {
      expect(ReCase('hello world').toConstantCase(), 'HELLO_WORLD');
      expect(ReCase('camelCase').toConstantCase(), 'CAMEL_CASE');
      expect(ReCase('PascalCase').toConstantCase(), 'PASCAL_CASE');
      expect(ReCase('snake_case').toConstantCase(), 'SNAKE_CASE');
      expect(ReCase('kebab-case').toConstantCase(), 'KEBAB_CASE');
      expect(ReCase('').toConstantCase(), '');
    });

    test('toKebabCase()', () {
      expect(ReCase('hello world').toKebabCase(), 'hello-world');
      expect(ReCase('camelCase').toKebabCase(), 'camel-case');
      expect(ReCase('PascalCase').toKebabCase(), 'pascal-case');
      expect(ReCase('snake_case').toKebabCase(), 'snake-case');
      expect(ReCase('UPPERCASE').toKebabCase(), 'uppercase');
      expect(ReCase('').toKebabCase(), '');
    });

    test('toDotCase()', () {
      expect(ReCase('hello world').toDotCase(), 'hello.world');
      expect(ReCase('camelCase').toDotCase(), 'camel.case');
      expect(ReCase('PascalCase').toDotCase(), 'pascal.case');
      expect(ReCase('snake_case').toDotCase(), 'snake.case');
      expect(ReCase('').toDotCase(), '');
    });

    test('toTitleCase()', () {
      expect(ReCase('hello world').toTitleCase(), 'Hello World');
      expect(ReCase('camelCase').toTitleCase(), 'Camel Case');
      expect(ReCase('snake_case').toTitleCase(), 'Snake Case');
      expect(ReCase('kebab-case').toTitleCase(), 'Kebab Case');
      expect(ReCase('').toTitleCase(), '');
    });

    test('toPathCase()', () {
      expect(ReCase('hello world').toPathCase(), 'hello/world');
      expect(ReCase('camelCase').toPathCase(), 'camel/case');
      expect(ReCase('PascalCase').toPathCase(), 'pascal/case');
      expect(ReCase('snake_case').toPathCase(), 'snake/case');
      expect(ReCase('').toPathCase(), '');
    });

    group('detectConvention()', () {
      test('detects camelCase', () {
        expect(ReCase('helloWorld').detectConvention(),
            NamingConvention.camelCase);
        expect(ReCase('myVariableName').detectConvention(),
            NamingConvention.camelCase);
        expect(
            ReCase('lowercase').detectConvention(), NamingConvention.camelCase);
      });

      test('detects PascalCase', () {
        expect(ReCase('HelloWorld').detectConvention(),
            NamingConvention.pascalCase);
        expect(ReCase('MyClassName').detectConvention(),
            NamingConvention.pascalCase);
      });

      test('detects snake_case', () {
        expect(ReCase('hello_world').detectConvention(),
            NamingConvention.snakeCase);
        expect(ReCase('my_variable_name').detectConvention(),
            NamingConvention.snakeCase);
      });

      test('detects CONSTANT_CASE', () {
        expect(ReCase('HELLO_WORLD').detectConvention(),
            NamingConvention.constantCase);
        expect(ReCase('MY_CONSTANT').detectConvention(),
            NamingConvention.constantCase);
      });

      test('detects kebab-case', () {
        expect(ReCase('hello-world').detectConvention(),
            NamingConvention.kebabCase);
        expect(ReCase('my-component-name').detectConvention(),
            NamingConvention.kebabCase);
      });

      test('detects dot.case', () {
        expect(
            ReCase('hello.world').detectConvention(), NamingConvention.dotCase);
        expect(ReCase('com.example.app').detectConvention(),
            NamingConvention.dotCase);
      });

      test('detects Title Case', () {
        expect(ReCase('Hello World').detectConvention(),
            NamingConvention.titleCase);
        expect(ReCase('My Title Case').detectConvention(),
            NamingConvention.titleCase);
      });

      test('detects path/case', () {
        expect(ReCase('hello/world').detectConvention(),
            NamingConvention.pathCase);
        expect(ReCase('my/path/case').detectConvention(),
            NamingConvention.pathCase);
      });

      test('returns null for empty string', () {
        expect(ReCase('').detectConvention(), isNull);
        expect(ReCase('   ').detectConvention(), isNull);
      });
    });

    group('convertTo()', () {
      test('converts to all conventions via enum', () {
        final rc = ReCase('hello_world');
        expect(rc.convertTo(NamingConvention.camelCase), 'helloWorld');
        expect(rc.convertTo(NamingConvention.pascalCase), 'HelloWorld');
        expect(rc.convertTo(NamingConvention.snakeCase), 'hello_world');
        expect(rc.convertTo(NamingConvention.constantCase), 'HELLO_WORLD');
        expect(rc.convertTo(NamingConvention.kebabCase), 'hello-world');
        expect(rc.convertTo(NamingConvention.dotCase), 'hello.world');
        expect(rc.convertTo(NamingConvention.titleCase), 'Hello World');
        expect(rc.convertTo(NamingConvention.pathCase), 'hello/world');
      });

      test('detect then convert roundtrips', () {
        // Detect a convention, convert to another, detect again
        final original = ReCase('myVariableName');
        expect(original.detectConvention(), NamingConvention.camelCase);

        final asSnake = original.convertTo(NamingConvention.snakeCase);
        expect(asSnake, 'my_variable_name');
        expect(ReCase(asSnake).detectConvention(), NamingConvention.snakeCase);

        final asKebab = original.convertTo(NamingConvention.kebabCase);
        expect(asKebab, 'my-variable-name');
        expect(ReCase(asKebab).detectConvention(), NamingConvention.kebabCase);

        final asConstant = original.convertTo(NamingConvention.constantCase);
        expect(asConstant, 'MY_VARIABLE_NAME');
        expect(ReCase(asConstant).detectConvention(),
            NamingConvention.constantCase);

        final asPascal = original.convertTo(NamingConvention.pascalCase);
        expect(asPascal, 'MyVariableName');
        expect(
            ReCase(asPascal).detectConvention(), NamingConvention.pascalCase);
      });
    });

    group('sanitization', () {
      test('strips special characters and treats them as word boundaries', () {
        expect(ReCase('hello@world').toCamelCase(), 'helloWorld');
        expect(ReCase('hello#world').toSnakeCase(), 'hello_world');
        expect(ReCase('foo\$bar').toKebabCase(), 'foo-bar');
        expect(ReCase('test&value').toPascalCase(), 'TestValue');
        expect(ReCase('a(b)c').toDotCase(), 'a.b.c');
        expect(ReCase('key=value').toConstantCase(), 'KEY_VALUE');
        expect(ReCase('hello!world?').toTitleCase(), 'Hello World');
        expect(ReCase('path%to%file').toPathCase(), 'path/to/file');
      });

      test('strips multiple consecutive special characters', () {
        expect(ReCase('hello@@##world').toCamelCase(), 'helloWorld');
        expect(ReCase('a!!!b').toSnakeCase(), 'a_b');
      });

      test('strips leading and trailing special characters', () {
        expect(ReCase('@hello').toCamelCase(), 'hello');
        expect(ReCase('hello!').toSnakeCase(), 'hello');
        expect(ReCase('!@#hello!@#world!@#').toKebabCase(), 'hello-world');
      });

      test('handles mixed special characters and valid separators', () {
        expect(ReCase('hello_@world').toCamelCase(), 'helloWorld');
        expect(ReCase('hello-!-world').toSnakeCase(), 'hello_world');
        expect(ReCase('foo.#.bar').toKebabCase(), 'foo-bar');
      });

      test('preserves digits during sanitization', () {
        expect(ReCase('item1@value2').toCamelCase(), 'item1Value2');
        expect(ReCase('test#123').toSnakeCase(), 'test_123');
        expect(ReCase('v2!beta').toKebabCase(), 'v2-beta');
      });

      test('handles string of only special characters', () {
        expect(ReCase('@#\$%').toCamelCase(), '');
        expect(ReCase('!!!').toSnakeCase(), '');
      });
    });
  });

  group('NamingConvention', () {
    test('isDartCompatible returns true for valid Dart identifiers', () {
      expect(NamingConvention.camelCase.isDartCompatible, isTrue);
      expect(NamingConvention.pascalCase.isDartCompatible, isTrue);
      expect(NamingConvention.snakeCase.isDartCompatible, isTrue);
      expect(NamingConvention.constantCase.isDartCompatible, isTrue);
    });

    test('isDartCompatible returns false for invalid Dart identifiers', () {
      expect(NamingConvention.kebabCase.isDartCompatible, isFalse);
      expect(NamingConvention.dotCase.isDartCompatible, isFalse);
      expect(NamingConvention.titleCase.isDartCompatible, isFalse);
      expect(NamingConvention.pathCase.isDartCompatible, isFalse);
    });
  });
}
