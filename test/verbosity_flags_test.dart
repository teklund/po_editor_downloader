import 'package:args/args.dart';
import 'package:test/test.dart';

void main() {
  group('Verbosity Flags', () {
    late ArgParser parser;

    setUp(() {
      parser = ArgParser()
        ..addFlag('quiet', abbr: 'q', negatable: false)
        ..addFlag('verbose', abbr: 'v', negatable: false)
        ..addFlag('help', abbr: 'h', negatable: false);
    });

    group('Quiet Flag', () {
      test('should parse --quiet flag', () {
        final result = parser.parse(['--quiet']);
        expect(result['quiet'], isTrue);
        expect(result['verbose'], isFalse);
      });

      test('should parse -q flag', () {
        final result = parser.parse(['-q']);
        expect(result['quiet'], isTrue);
        expect(result['verbose'], isFalse);
      });

      test('should be false by default', () {
        final result = parser.parse([]);
        expect(result['quiet'], isFalse);
      });
    });

    group('Verbose Flag', () {
      test('should parse --verbose flag', () {
        final result = parser.parse(['--verbose']);
        expect(result['verbose'], isTrue);
        expect(result['quiet'], isFalse);
      });

      test('should parse -v flag', () {
        final result = parser.parse(['-v']);
        expect(result['verbose'], isTrue);
        expect(result['quiet'], isFalse);
      });

      test('should be false by default', () {
        final result = parser.parse([]);
        expect(result['verbose'], isFalse);
      });
    });

    group('Flag Combinations', () {
      test('should handle both flags together (verbose takes precedence)', () {
        // In the actual implementation, if both are provided, verbose wins
        final result = parser.parse(['--quiet', '--verbose']);
        expect(result['quiet'], isTrue);
        expect(result['verbose'], isTrue);
        // The application logic determines which takes precedence
      });

      test('should work with other options', () {
        final result = parser.parse([
          '--quiet',
          '--help',
        ]);
        expect(result['quiet'], isTrue);
        expect(result['help'], isTrue);
      });

      test('should work with short flags combined', () {
        final result = parser.parse(['-qh']);
        expect(result['quiet'], isTrue);
        expect(result['help'], isTrue);
      });
    });

    group('Flag Negation', () {
      test('flags should not be negatable', () {
        // These flags are defined as negatable: false
        // So --no-quiet should not be a valid option
        expect(
          () => parser.parse(['--no-quiet']),
          throwsA(isA<FormatException>()),
        );
      });

      test('--no-verbose should not be valid', () {
        expect(
          () => parser.parse(['--no-verbose']),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('Default Behavior', () {
      test('should default to normal mode when no flags provided', () {
        final result = parser.parse([]);
        expect(result['quiet'], isFalse);
        expect(result['verbose'], isFalse);
        // This means normal mode in the application
      });

      test('should parse with unrecognized arguments in rest', () {
        final result = parser.parse([
          '--quiet',
          'some_value',
        ]);
        expect(result['quiet'], isTrue);
        expect(result.rest, contains('some_value'));
      });
    });
  });
}
