import 'package:po_editor_downloader/po_editor_downloader.dart';
import 'package:test/test.dart';

void main() {
  group('Language', () {
    group('fromJson', () {
      test('should parse valid JSON', () {
        final json = {
          'name': 'English',
          'code': 'en',
          'translations': 150,
          'percentage': 95.5,
          'updated': '2025-11-06 12:30:00',
        };

        final language = Language.fromJson(json);

        expect(language.name, 'English');
        expect(language.code, 'en');
        expect(language.translations, 150);
        expect(language.percentage, 95.5);
        expect(language.updated, '2025-11-06 12:30:00');
      });

      test('should handle integer percentage', () {
        final json = {
          'name': 'Spanish',
          'code': 'es',
          'translations': 100,
          'percentage': 100, // Integer instead of double
          'updated': '2025-11-05 10:00:00',
        };

        final language = Language.fromJson(json);

        expect(language.percentage, 100.0);
      });

      test('should handle zero translations', () {
        final json = {
          'name': 'French',
          'code': 'fr',
          'translations': 0,
          'percentage': 0.0,
          'updated': '2025-11-01 00:00:00',
        };

        final language = Language.fromJson(json);

        expect(language.translations, 0);
        expect(language.percentage, 0.0);
      });

      test('should handle partial completion', () {
        final json = {
          'name': 'German',
          'code': 'de',
          'translations': 50,
          'percentage': 33.33,
          'updated': '2025-11-04 15:45:00',
        };

        final language = Language.fromJson(json);

        expect(language.percentage, 33.33);
      });
    });

    group('toString', () {
      test('should format language information', () {
        final language = Language(
          name: 'English',
          code: 'en',
          translations: 150,
          percentage: 95.5,
          updated: '2025-11-06 12:30:00',
        );

        final string = language.toString();

        expect(string, contains('English'));
        expect(string, contains('en'));
        expect(string, contains('150'));
        expect(string, contains('95.5'));
        expect(string, contains('2025-11-06 12:30:00'));
      });

      test('should handle zero values in string', () {
        final language = Language(
          name: 'French',
          code: 'fr',
          translations: 0,
          percentage: 0.0,
          updated: '2025-11-01',
        );

        final string = language.toString();

        expect(string, contains('0'));
        expect(string, contains('0.0'));
      });
    });

    group('Language constructor', () {
      test('should create language with all fields', () {
        final language = Language(
          name: 'Spanish',
          code: 'es',
          translations: 200,
          percentage: 100.0,
          updated: '2025-11-06',
        );

        expect(language.name, 'Spanish');
        expect(language.code, 'es');
        expect(language.translations, 200);
        expect(language.percentage, 100.0);
        expect(language.updated, '2025-11-06');
      });
    });

    group('Edge cases', () {
      test('should handle language codes with regions', () {
        final json = {
          'name': 'English (US)',
          'code': 'en-US',
          'translations': 150,
          'percentage': 95.5,
          'updated': '2025-11-06',
        };

        final language = Language.fromJson(json);

        expect(language.code, 'en-US');
        expect(language.name, 'English (US)');
      });

      test('should handle very long language names', () {
        final json = {
          'name': 'Portuguese (Brazilian Portuguese)',
          'code': 'pt-BR',
          'translations': 100,
          'percentage': 75.0,
          'updated': '2025-11-06',
        };

        final language = Language.fromJson(json);

        expect(language.name, 'Portuguese (Brazilian Portuguese)');
      });

      test('should handle high precision percentages', () {
        final json = {
          'name': 'Italian',
          'code': 'it',
          'translations': 147,
          'percentage': 98.12345,
          'updated': '2025-11-06',
        };

        final language = Language.fromJson(json);

        expect(language.percentage, 98.12345);
      });

      test('should handle large translation counts', () {
        final json = {
          'name': 'Chinese',
          'code': 'zh',
          'translations': 99999,
          'percentage': 100.0,
          'updated': '2025-11-06',
        };

        final language = Language.fromJson(json);

        expect(language.translations, 99999);
      });
    });
  });
}
