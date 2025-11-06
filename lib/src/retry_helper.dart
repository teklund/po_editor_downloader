import 'dart:math';

import 'package:po_editor_downloader/src/po_editor_exceptions.dart';

/// Executes an async operation with retry logic and exponential backoff
///
/// Retries the operation on transient failures (5xx errors, network errors)
/// but immediately fails on client errors (4xx).
Future<T> withRetry<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(seconds: 1),
  void Function(int attempt, Duration delay, Object error)? onRetry,
}) async {
  int attempt = 0;

  while (true) {
    try {
      return await operation();
    } catch (e) {
      attempt++;

      // Check if we've exhausted retries
      if (attempt >= maxRetries) {
        rethrow;
      }

      // Determine if error is retryable
      final isRetryable = _isRetryableError(e);

      if (!isRetryable) {
        rethrow;
      }

      // Calculate exponential backoff delay
      final delay = initialDelay * pow(2, attempt - 1);

      // Call onRetry callback if provided
      if (onRetry != null) {
        onRetry(attempt, delay, e);
      }

      // Wait before retrying
      await Future.delayed(delay);
    }
  }
}

/// Determines if an error is retryable
bool _isRetryableError(Object error) {
  // Retry on network exceptions
  if (error is PoEditorNetworkException) {
    return true;
  }

  // Retry on server errors (5xx)
  if (error is PoEditorApiException) {
    final statusCode = error.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return true;
    }
    // Don't retry client errors (4xx)
    return false;
  }

  // Don't retry unknown errors by default
  return false;
}
