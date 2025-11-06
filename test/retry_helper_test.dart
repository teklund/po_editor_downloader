import 'package:po_editor_downloader/src/po_editor_exceptions.dart';
import 'package:po_editor_downloader/src/retry_helper.dart';
import 'package:test/test.dart';

void main() {
  group('Retry Helper', () {
    test('should succeed on first try when no error occurs', () async {
      var callCount = 0;
      final result = await withRetry(() async {
        callCount++;
        return 'success';
      });

      expect(result, equals('success'));
      expect(callCount, equals(1));
    });

    test('should retry on PoEditorNetworkException', () async {
      var callCount = 0;
      final result = await withRetry(
        () async {
          callCount++;
          if (callCount < 3) {
            throw PoEditorNetworkException(
              message: 'Network error',
              endpoint: '/test',
            );
          }
          return 'success';
        },
        maxRetries: 3,
        initialDelay: Duration(milliseconds: 10),
      );

      expect(result, equals('success'));
      expect(callCount, equals(3));
    });

    test('should retry on 5xx API errors', () async {
      var callCount = 0;
      final result = await withRetry(
        () async {
          callCount++;
          if (callCount < 2) {
            throw PoEditorApiException(
              message: 'Server error',
              statusCode: 500,
              endpoint: '/test',
            );
          }
          return 'success';
        },
        maxRetries: 3,
        initialDelay: Duration(milliseconds: 10),
      );

      expect(result, equals('success'));
      expect(callCount, equals(2));
    });

    test('should NOT retry on 4xx API errors', () async {
      var callCount = 0;

      expect(
        () => withRetry(
          () async {
            callCount++;
            throw PoEditorApiException(
              message: 'Client error',
              statusCode: 400,
              endpoint: '/test',
            );
          },
          maxRetries: 3,
          initialDelay: Duration(milliseconds: 10),
        ),
        throwsA(isA<PoEditorApiException>()),
      );

      await Future.delayed(Duration(milliseconds: 50));
      expect(callCount, equals(1)); // Should not retry
    });

    test('should NOT retry on 401 Unauthorized', () async {
      var callCount = 0;

      expect(
        () => withRetry(
          () async {
            callCount++;
            throw PoEditorApiException(
              message: 'Unauthorized',
              statusCode: 401,
              endpoint: '/test',
            );
          },
          maxRetries: 3,
          initialDelay: Duration(milliseconds: 10),
        ),
        throwsA(isA<PoEditorApiException>()),
      );

      await Future.delayed(Duration(milliseconds: 50));
      expect(callCount, equals(1));
    });

    test('should NOT retry on 404 Not Found', () async {
      var callCount = 0;

      expect(
        () => withRetry(
          () async {
            callCount++;
            throw PoEditorApiException(
              message: 'Not found',
              statusCode: 404,
              endpoint: '/test',
            );
          },
          maxRetries: 3,
          initialDelay: Duration(milliseconds: 10),
        ),
        throwsA(isA<PoEditorApiException>()),
      );

      await Future.delayed(Duration(milliseconds: 50));
      expect(callCount, equals(1));
    });

    test('should throw after max retries exceeded', () async {
      var callCount = 0;

      expect(
        () => withRetry(
          () async {
            callCount++;
            throw PoEditorNetworkException(
              message: 'Network error',
              endpoint: '/test',
            );
          },
          maxRetries: 3,
          initialDelay: Duration(milliseconds: 10),
        ),
        throwsA(isA<PoEditorNetworkException>()),
      );

      await Future.delayed(Duration(milliseconds: 200));
      expect(callCount, equals(3)); // Tried 3 times
    });

    test('should use exponential backoff', () async {
      final delays = <Duration>[];
      final startTime = DateTime.now();

      try {
        await withRetry(
          () async {
            throw PoEditorNetworkException(
              message: 'Network error',
              endpoint: '/test',
            );
          },
          maxRetries: 3,
          initialDelay: Duration(milliseconds: 100),
          onRetry: (attempt, delay, error) {
            delays.add(delay);
          },
        );
      } catch (e) {
        // Expected to fail
      }

      final endTime = DateTime.now();
      final totalDuration = endTime.difference(startTime);

      // Verify exponential backoff: 100ms, 200ms
      expect(delays.length, equals(2));
      expect(delays[0].inMilliseconds, equals(100));
      expect(delays[1].inMilliseconds, equals(200));

      // Verify actual delays occurred (should be at least 300ms total)
      expect(totalDuration.inMilliseconds, greaterThanOrEqualTo(280));
    });

    test('should call onRetry callback with correct parameters', () async {
      var callCount = 0;
      final retryInfo = <Map<String, dynamic>>[];

      await withRetry(
        () async {
          callCount++;
          if (callCount < 3) {
            throw PoEditorNetworkException(
              message: 'Network error',
              endpoint: '/test',
            );
          }
          return 'success';
        },
        maxRetries: 3,
        initialDelay: Duration(milliseconds: 10),
        onRetry: (attempt, delay, error) {
          retryInfo.add({
            'attempt': attempt,
            'delay': delay,
            'error': error,
          });
        },
      );

      expect(retryInfo.length, equals(2));
      expect(retryInfo[0]['attempt'], equals(1));
      expect(retryInfo[1]['attempt'], equals(2));
      expect(retryInfo[0]['error'], isA<PoEditorNetworkException>());
      expect(retryInfo[1]['error'], isA<PoEditorNetworkException>());
    });

    test('should retry on 503 Service Unavailable', () async {
      var callCount = 0;
      final result = await withRetry(
        () async {
          callCount++;
          if (callCount < 2) {
            throw PoEditorApiException(
              message: 'Service unavailable',
              statusCode: 503,
              endpoint: '/test',
            );
          }
          return 'success';
        },
        maxRetries: 3,
        initialDelay: Duration(milliseconds: 10),
      );

      expect(result, equals('success'));
      expect(callCount, equals(2));
    });

    test('should NOT retry on unknown exceptions', () async {
      var callCount = 0;

      expect(
        () => withRetry(
          () async {
            callCount++;
            throw Exception('Unknown error');
          },
          maxRetries: 3,
          initialDelay: Duration(milliseconds: 10),
        ),
        throwsException,
      );

      await Future.delayed(Duration(milliseconds: 50));
      expect(callCount, equals(1)); // Should not retry unknown exceptions
    });

    test('should work with custom maxRetries', () async {
      var callCount = 0;

      expect(
        () => withRetry(
          () async {
            callCount++;
            throw PoEditorNetworkException(
              message: 'Network error',
              endpoint: '/test',
            );
          },
          maxRetries: 5,
          initialDelay: Duration(milliseconds: 10),
        ),
        throwsA(isA<PoEditorNetworkException>()),
      );

      await Future.delayed(Duration(milliseconds: 500));
      expect(callCount, equals(5));
    });

    test('should work with custom initialDelay', () async {
      final delays = <Duration>[];

      try {
        await withRetry(
          () async {
            throw PoEditorNetworkException(
              message: 'Network error',
              endpoint: '/test',
            );
          },
          maxRetries: 2,
          initialDelay: Duration(milliseconds: 50),
          onRetry: (attempt, delay, error) {
            delays.add(delay);
          },
        );
      } catch (e) {
        // Expected to fail
      }

      expect(delays.length, equals(1));
      expect(delays[0].inMilliseconds, equals(50));
    });
  });
}
