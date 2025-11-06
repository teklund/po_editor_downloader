/// Exception thrown when POEditor API returns an error response
class PoEditorApiException implements Exception {
  /// Human-readable error message
  final String message;

  /// HTTP status code from the API response
  final int? statusCode;

  /// Raw response body from the API
  final String? responseBody;

  /// API endpoint that was called
  final String endpoint;

  /// Create a new PoEditorApiException
  PoEditorApiException({
    required this.message,
    this.statusCode,
    this.responseBody,
    required this.endpoint,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('PoEditorApiException: $message');
    buffer.writeln('Endpoint: $endpoint');
    if (statusCode != null) {
      buffer.writeln('Status Code: $statusCode');
    }
    if (responseBody != null && responseBody!.isNotEmpty) {
      buffer.writeln('Response: $responseBody');
    }
    return buffer.toString().trim();
  }
}

/// Exception thrown when network errors occur
class PoEditorNetworkException implements Exception {
  /// Human-readable error message
  final String message;

  /// API endpoint that was called
  final String endpoint;

  /// Original error that caused this exception
  final Object? originalError;

  /// Stack trace from the original error
  final StackTrace? stackTrace;

  /// Create a new PoEditorNetworkException
  PoEditorNetworkException({
    required this.message,
    required this.endpoint,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('PoEditorNetworkException: $message');
    buffer.writeln('Endpoint: $endpoint');
    if (originalError != null) {
      buffer.writeln('Original Error: $originalError');
    }
    return buffer.toString().trim();
  }
}
