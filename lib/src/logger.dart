import 'dart:io';

/// Logging level for output control
enum LogLevel {
  /// Only show errors
  quiet,

  /// Show normal output (info and errors)
  normal,

  /// Show verbose output (debug, info, and errors)
  verbose,
}

/// Simple logger for controlling output verbosity
class Logger {
  /// Current logging level
  final LogLevel level;

  /// Create a logger with the specified level
  const Logger(this.level);

  /// Log debug information (only in verbose mode)
  void debug(String message) {
    if (level == LogLevel.verbose) {
      stdout.writeln('🔍 $message');
    }
  }

  /// Log informational message (normal and verbose modes)
  void info(String message) {
    if (level != LogLevel.quiet) {
      stdout.writeln(message);
    }
  }

  /// Log success message (normal and verbose modes)
  void success(String message) {
    if (level != LogLevel.quiet) {
      stdout.writeln('✅ $message');
    }
  }

  /// Log warning message (normal and verbose modes)
  void warning(String message) {
    if (level != LogLevel.quiet) {
      stdout.writeln('⚠️  $message');
    }
  }

  /// Log error message (always shown)
  void error(String message) {
    stderr.writeln('❌ $message');
  }

  /// Log progress message (normal and verbose modes)
  void progress(String message) {
    if (level != LogLevel.quiet) {
      stdout.writeln('📥 $message');
    }
  }
}
