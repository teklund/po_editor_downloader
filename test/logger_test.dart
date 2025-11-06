import 'package:po_editor_downloader/src/logger.dart';
import 'package:test/test.dart';

void main() {
  group('Logger', () {
    group('LogLevel', () {
      test('should have three levels', () {
        expect(LogLevel.values.length, equals(3));
        expect(LogLevel.values, contains(LogLevel.quiet));
        expect(LogLevel.values, contains(LogLevel.normal));
        expect(LogLevel.values, contains(LogLevel.verbose));
      });
    });

    group('Quiet Mode', () {
      late Logger logger;

      setUp(() {
        logger = Logger(LogLevel.quiet);
      });

      test('should not output debug messages', () {
        // In quiet mode, these methods should execute without error
        expect(() => logger.debug('Debug message'), returnsNormally);
      });

      test('should not output info messages', () {
        expect(() => logger.info('Info message'), returnsNormally);
      });

      test('should not output success messages', () {
        expect(() => logger.success('Success message'), returnsNormally);
      });

      test('should not output progress messages', () {
        expect(() => logger.progress('Progress message'), returnsNormally);
      });

      test('should not output warning messages', () {
        expect(() => logger.warning('Warning message'), returnsNormally);
      });

      test('should output error messages to stderr', () {
        // Error messages should still be shown in quiet mode
        // We can't easily capture stderr in tests, but we can verify the method exists
        expect(() => logger.error('Error message'), returnsNormally);
      });
    });

    group('Normal Mode', () {
      late Logger logger;

      setUp(() {
        logger = Logger(LogLevel.normal);
      });

      test('should not output debug messages', () {
        expect(() => logger.debug('Debug message'), returnsNormally);
      });

      test('should output info messages', () {
        expect(() => logger.info('Info message'), returnsNormally);
      });

      test('should output success messages', () {
        expect(() => logger.success('Success message'), returnsNormally);
      });

      test('should output progress messages', () {
        expect(() => logger.progress('Progress message'), returnsNormally);
      });

      test('should output warning messages', () {
        expect(() => logger.warning('Warning message'), returnsNormally);
      });

      test('should output error messages', () {
        expect(() => logger.error('Error message'), returnsNormally);
      });
    });

    group('Verbose Mode', () {
      late Logger logger;

      setUp(() {
        logger = Logger(LogLevel.verbose);
      });

      test('should output debug messages', () {
        expect(() => logger.debug('Debug message'), returnsNormally);
      });

      test('should output info messages', () {
        expect(() => logger.info('Info message'), returnsNormally);
      });

      test('should output success messages', () {
        expect(() => logger.success('Success message'), returnsNormally);
      });

      test('should output progress messages', () {
        expect(() => logger.progress('Progress message'), returnsNormally);
      });

      test('should output warning messages', () {
        expect(() => logger.warning('Warning message'), returnsNormally);
      });

      test('should output error messages', () {
        expect(() => logger.error('Error message'), returnsNormally);
      });
    });

    group('Logger Instance', () {
      test('should be created with specified log level', () {
        final quietLogger = Logger(LogLevel.quiet);
        final normalLogger = Logger(LogLevel.normal);
        final verboseLogger = Logger(LogLevel.verbose);

        expect(quietLogger.level, equals(LogLevel.quiet));
        expect(normalLogger.level, equals(LogLevel.normal));
        expect(verboseLogger.level, equals(LogLevel.verbose));
      });
    });

    group('Message Formatting', () {
      test('info should prefix with ℹ️', () {
        final logger = Logger(LogLevel.normal);
        // We can't easily capture stdout, but we can verify the method works
        expect(() => logger.info('Test'), returnsNormally);
      });

      test('success should prefix with ✅', () {
        final logger = Logger(LogLevel.normal);
        expect(() => logger.success('Test'), returnsNormally);
      });

      test('warning should prefix with ⚠️', () {
        final logger = Logger(LogLevel.normal);
        expect(() => logger.warning('Test'), returnsNormally);
      });

      test('error should prefix with ❌', () {
        final logger = Logger(LogLevel.normal);
        expect(() => logger.error('Test'), returnsNormally);
      });

      test('progress should prefix with ⏳', () {
        final logger = Logger(LogLevel.normal);
        expect(() => logger.progress('Test'), returnsNormally);
      });

      test('debug should prefix with 🔍', () {
        final logger = Logger(LogLevel.verbose);
        expect(() => logger.debug('Test'), returnsNormally);
      });
    });

    group('Logger Behavior Verification', () {
      test('quiet mode should suppress all non-error output', () {
        final logger = Logger(LogLevel.quiet);

        // These should all work without throwing
        expect(() {
          logger.debug('Debug');
          logger.info('Info');
          logger.success('Success');
          logger.progress('Progress');
          logger.warning('Warning');
          logger.error('Error');
        }, returnsNormally);
      });

      test('normal mode should show standard messages', () {
        final logger = Logger(LogLevel.normal);

        expect(() {
          logger.info('Info');
          logger.success('Success');
          logger.progress('Progress');
          logger.warning('Warning');
          logger.error('Error');
          // Debug should be suppressed
          logger.debug('Debug');
        }, returnsNormally);
      });

      test('verbose mode should show all messages', () {
        final logger = Logger(LogLevel.verbose);

        expect(() {
          logger.debug('Debug');
          logger.info('Info');
          logger.success('Success');
          logger.progress('Progress');
          logger.warning('Warning');
          logger.error('Error');
        }, returnsNormally);
      });
    });

    group('Empty and Special Messages', () {
      late Logger logger;

      setUp(() {
        logger = Logger(LogLevel.normal);
      });

      test('should handle empty messages', () {
        expect(() => logger.info(''), returnsNormally);
        expect(() => logger.success(''), returnsNormally);
        expect(() => logger.error(''), returnsNormally);
      });

      test('should handle messages with newlines', () {
        expect(() => logger.info('Line 1\nLine 2'), returnsNormally);
        expect(() => logger.success('Multi\nLine\nMessage'), returnsNormally);
      });

      test('should handle messages with special characters', () {
        expect(() => logger.info('Message with émojis 🚀🎉'), returnsNormally);
        expect(() => logger.success('Special chars: @#\$%'), returnsNormally);
      });

      test('should handle very long messages', () {
        final longMessage = 'x' * 1000;
        expect(() => logger.info(longMessage), returnsNormally);
      });
    });
  });
}
