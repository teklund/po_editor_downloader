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

    group('acronym and mixed convention handling', () {
      test('preserves acronyms when splitting words', () {
        expect(ReCase('HTMLParser').toCamelCase(), 'htmlParser');
        expect(ReCase('XMLHttpRequest').toCamelCase(), 'xmlHttpRequest');
        expect(ReCase('getHTTPResponse').toCamelCase(), 'getHttpResponse');
        expect(ReCase('IOStream').toCamelCase(), 'ioStream');
      });

      test('handles messy POEditor keys with mixed conventions', () {
        // Uppercase words with separators
        expect(ReCase('ERROR_404_notFound').toCamelCase(), 'error404NotFound');
        expect(ReCase('API_KEY_value').toCamelCase(), 'apiKeyValue');

        // All-caps segments mixed with lowercase
        expect(ReCase('HTTP_ERROR').toCamelCase(), 'httpError');
        expect(ReCase('btnOK').toCamelCase(), 'btnOk');
      });

      test('converts acronyms across all conventions', () {
        expect(ReCase('HTMLParser').toSnakeCase(), 'html_parser');
        expect(ReCase('HTMLParser').toKebabCase(), 'html-parser');
        expect(ReCase('HTMLParser').toConstantCase(), 'HTML_PARSER');
        expect(ReCase('HTMLParser').toPascalCase(), 'HtmlParser');
        expect(ReCase('HTMLParser').toTitleCase(), 'Html Parser');
      });

      test('handles all-caps words without separators', () {
        expect(ReCase('ALLCAPS').toCamelCase(), 'allcaps');
        expect(ReCase('ALLCAPS').toSnakeCase(), 'allcaps');
        expect(ReCase('USA').toCamelCase(), 'usa');
      });

      test('handles two-letter acronyms', () {
        expect(ReCase('IOError').toCamelCase(), 'ioError');
        expect(ReCase('getIO').toCamelCase(), 'getIo');
        expect(ReCase('IOError').toSnakeCase(), 'io_error');
        expect(ReCase('UIView').toCamelCase(), 'uiView');
      });

      test('handles consecutive acronyms', () {
        // Consecutive all-caps acronyms without separator are ambiguous;
        // the algorithm treats them as one block until it sees a
        // lowercase transition.
        expect(ReCase('XMLHTTPRequest').toCamelCase(), 'xmlhttpRequest');
        expect(ReCase('XMLHTTPRequest').toSnakeCase(), 'xmlhttp_request');
        expect(
            ReCase('getXMLHTTPResponse').toCamelCase(), 'getXmlhttpResponse');
        // Use separators for unambiguous consecutive acronyms
        expect(ReCase('XML_HTTP_Request').toCamelCase(), 'xmlHttpRequest');
      });

      test('handles acronym at end of string', () {
        expect(ReCase('parseHTML').toCamelCase(), 'parseHtml');
        expect(ReCase('parseHTML').toSnakeCase(), 'parse_html');
        expect(ReCase('isUSA').toCamelCase(), 'isUsa');
      });

      test('handles acronym at start followed by lowercase', () {
        // "APIkey" is ambiguous — "AP" + "Ikey" is the best split
        // without a dictionary. Use "API_key" for clarity.
        expect(ReCase('APIkey').toCamelCase(), 'apIkey');
        expect(ReCase('API_key').toCamelCase(), 'apiKey');
        expect(ReCase('HTTPSConnection').toCamelCase(), 'httpsConnection');
      });

      test('handles mixed CONSTANT_CASE with camelCase segments', () {
        expect(ReCase('ERROR_notFound').toCamelCase(), 'errorNotFound');
        expect(ReCase('OK_btnSubmit').toCamelCase(), 'okBtnSubmit');
        expect(ReCase('SUCCESS_myValue').toSnakeCase(), 'success_my_value');
      });
    });

    group('digit edge cases', () {
      test('digits at start of word', () {
        expect(ReCase('123abc').toCamelCase(), '123abc');
        expect(ReCase('1st_place').toCamelCase(), '1stPlace');
        expect(ReCase('2ndPlace').toCamelCase(), '2ndPlace');
      });

      test('digit-only segments separated by boundaries', () {
        expect(ReCase('error_404').toCamelCase(), 'error404');
        expect(ReCase('error404').toCamelCase(), 'error404');
        expect(ReCase('http_200_ok').toCamelCase(), 'http200Ok');
        expect(ReCase('item123value').toCamelCase(), 'item123value');
      });

      test('digits between words', () {
        expect(ReCase('v2beta').toCamelCase(), 'v2beta');
        expect(ReCase('log4j').toCamelCase(), 'log4j');
        expect(ReCase('mp3Player').toCamelCase(), 'mp3Player');
        expect(ReCase('mp3Player').toSnakeCase(), 'mp3_player');
        expect(ReCase('i18n').toCamelCase(), 'i18n');
        expect(ReCase('l10n').toCamelCase(), 'l10n');
      });

      test('digits with separators', () {
        expect(ReCase('error_404_not_found').toCamelCase(), 'error404NotFound');
        expect(ReCase('v2-beta-1').toCamelCase(), 'v2Beta1');
        expect(ReCase('level.3.boss').toCamelCase(), 'level3Boss');
      });

      test('digits only', () {
        expect(ReCase('123').toCamelCase(), '123');
        expect(ReCase('123').toSnakeCase(), '123');
        expect(ReCase('1_2_3').toCamelCase(), '123');
      });

      test('digits followed by uppercase', () {
        expect(ReCase('error404NotFound').toCamelCase(), 'error404NotFound');
        expect(ReCase('get3DModel').toCamelCase(), 'get3DModel');
      });
    });

    group('single character and short strings', () {
      test('single lowercase letter', () {
        expect(ReCase('a').toCamelCase(), 'a');
        expect(ReCase('a').toPascalCase(), 'A');
        expect(ReCase('a').toSnakeCase(), 'a');
        expect(ReCase('a').toConstantCase(), 'A');
      });

      test('single uppercase letter', () {
        expect(ReCase('A').toCamelCase(), 'a');
        expect(ReCase('A').toPascalCase(), 'A');
        expect(ReCase('A').toSnakeCase(), 'a');
        expect(ReCase('A').toConstantCase(), 'A');
      });

      test('two characters', () {
        expect(ReCase('ok').toCamelCase(), 'ok');
        expect(ReCase('OK').toCamelCase(), 'ok');
        expect(ReCase('Ok').toCamelCase(), 'ok');
        expect(ReCase('oK').toCamelCase(), 'oK');
        expect(ReCase('oK').toSnakeCase(), 'o_k');
      });

      test('single digit', () {
        expect(ReCase('1').toCamelCase(), '1');
        expect(ReCase('1').toSnakeCase(), '1');
      });
    });

    group('whitespace edge cases', () {
      test('tabs and mixed whitespace', () {
        expect(ReCase('hello\tworld').toCamelCase(), 'helloWorld');
        expect(ReCase('hello\nworld').toCamelCase(), 'helloWorld');
        expect(ReCase('hello\r\nworld').toCamelCase(), 'helloWorld');
      });

      test('only whitespace', () {
        expect(ReCase(' ').toCamelCase(), '');
        expect(ReCase('\t').toCamelCase(), '');
        expect(ReCase('\n').toCamelCase(), '');
      });
    });

    group('realistic POEditor keys', () {
      test('typical translation key formats', () {
        expect(ReCase('btn_submit').toCamelCase(), 'btnSubmit');
        expect(ReCase('error.network.timeout').toCamelCase(),
            'errorNetworkTimeout');
        expect(ReCase('LABEL_USERNAME').toCamelCase(), 'labelUsername');
        expect(ReCase('screen/login/title').toCamelCase(), 'screenLoginTitle');
        expect(ReCase('dialog-confirm-delete').toCamelCase(),
            'dialogConfirmDelete');
      });

      test('keys with pluralization hints', () {
        expect(ReCase('item_count_one').toCamelCase(), 'itemCountOne');
        expect(ReCase('item_count_other').toCamelCase(), 'itemCountOther');
        expect(ReCase('items_zero').toCamelCase(), 'itemsZero');
      });

      test('keys with platform prefixes', () {
        expect(ReCase('ios_permission_camera').toCamelCase(),
            'iosPermissionCamera');
        expect(ReCase('android_notification_title').toCamelCase(),
            'androidNotificationTitle');
        expect(ReCase('web_cookie_consent').toCamelCase(), 'webCookieConsent');
      });

      test('keys with version or feature flags', () {
        expect(ReCase('feature_v2_onboarding').toCamelCase(),
            'featureV2Onboarding');
        expect(ReCase('new_ui_banner_text').toCamelCase(), 'newUiBannerText');
      });

      test('messy real-world mixed keys', () {
        // Someone typed it manually with inconsistent style
        expect(ReCase('loginScreen_title').toCamelCase(), 'loginScreenTitle');
        expect(ReCase('ERROR_MSG_not_found').toCamelCase(), 'errorMsgNotFound');
        expect(
            ReCase('UserProfile_EDIT_btn').toCamelCase(), 'userProfileEditBtn');
      });
    });

    group('cross-convention roundtrip stability', () {
      // none is excluded from roundtrip tests since it preserves
      // the original text without conversion.
      final convertibleConventions = NamingConvention.values
          .where((c) => c != NamingConvention.none)
          .toList();

      test('snake_case roundtrips through all conventions', () {
        const original = 'hello_world';
        for (final convention in convertibleConventions) {
          final converted = ReCase(original).convertTo(convention);
          final backToSnake = ReCase(converted).toSnakeCase();
          expect(backToSnake, 'hello_world',
              reason:
                  'Roundtrip via ${convention.name} failed: $original → $converted → $backToSnake');
        }
      });

      test('camelCase roundtrips through all conventions', () {
        const original = 'helloWorld';
        for (final convention in convertibleConventions) {
          final converted = ReCase(original).convertTo(convention);
          final backToCamel = ReCase(converted).toCamelCase();
          expect(backToCamel, 'helloWorld',
              reason:
                  'Roundtrip via ${convention.name} failed: $original → $converted → $backToCamel');
        }
      });

      test('multi-word roundtrips through all conventions', () {
        const original = 'my_long_variable_name';
        for (final convention in convertibleConventions) {
          final converted = ReCase(original).convertTo(convention);
          final backToSnake = ReCase(converted).toSnakeCase();
          expect(backToSnake, 'my_long_variable_name',
              reason:
                  'Roundtrip via ${convention.name} failed: $original → $converted → $backToSnake');
        }
      });
    });

    group('unicode and non-ASCII', () {
      test('non-ASCII characters act as word boundaries', () {
        // Accented chars are stripped and split words
        expect(ReCase('héllo_wörld').toCamelCase(), 'hLloWRld');
        expect(ReCase('café').toCamelCase(), 'caf');
      });

      test('handles emoji as word boundary', () {
        expect(ReCase('hello😀world').toCamelCase(), 'helloWorld');
      });

      test('use ASCII equivalents for predictable results', () {
        expect(ReCase('hello_world').toCamelCase(), 'helloWorld');
        expect(ReCase('cafe').toCamelCase(), 'cafe');
      });
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

      test('returns null for digits-only strings', () {
        expect(ReCase('123').detectConvention(), isNull);
        expect(ReCase('42').detectConvention(), isNull);
      });

      test('detects single all-caps word as CONSTANT_CASE', () {
        expect(ReCase('ALLCAPS').detectConvention(),
            NamingConvention.constantCase);
        expect(
            ReCase('HTTP').detectConvention(), NamingConvention.constantCase);
      });

      test('returns null for ambiguous separator+case combinations', () {
        // Underscore with mixed case
        expect(ReCase('Hello_World').detectConvention(), isNull);
        expect(ReCase('mixed_Case').detectConvention(), isNull);
        // Dash with mixed case
        expect(ReCase('Hello-World').detectConvention(), isNull);
        // Dot with mixed case
        expect(ReCase('Com.Example').detectConvention(), isNull);
        // Slash with mixed case
        expect(ReCase('Hello/World').detectConvention(), isNull);
        // Space but not title case
        expect(ReCase('hello world').detectConvention(), isNull);
        expect(ReCase('Hello world').detectConvention(), isNull);
      });
    });

    group('convertTo()', () {
      test('converts to all conventions via enum', () {
        final rc = ReCase('hello_world');
        expect(rc.convertTo(NamingConvention.none), 'hello_world');
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

    group('convertTo() with none', () {
      test('none returns original text unchanged', () {
        expect(ReCase('hello_world').convertTo(NamingConvention.none),
            'hello_world');
        expect(ReCase('helloWorld').convertTo(NamingConvention.none),
            'helloWorld');
        expect(ReCase('HELLO_WORLD').convertTo(NamingConvention.none),
            'HELLO_WORLD');
        expect(ReCase('Mixed-Case_key').convertTo(NamingConvention.none),
            'Mixed-Case_key');
        expect(ReCase('').convertTo(NamingConvention.none), '');
        expect(ReCase('  spaced  ').convertTo(NamingConvention.none),
            '  spaced  ');
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
      expect(NamingConvention.none.isDartCompatible, isTrue);
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
