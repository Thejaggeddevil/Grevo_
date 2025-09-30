// Web implementation of LoggingService (console-only)
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  static LoggingService get instance => _instance;

  LoggingService._internal();

  Future<void> initialize() async {
    // No-op for web
    await info('LoggingService', 'Initialized (web, console-only)');
  }

  Future<void> debug(String tag, String message, [Object? error, StackTrace? stackTrace]) async {
    _log(LogLevel.debug, tag, message, error, stackTrace);
  }

  Future<void> info(String tag, String message, [Object? error, StackTrace? stackTrace]) async {
    _log(LogLevel.info, tag, message, error, stackTrace);
  }

  Future<void> warning(String tag, String message, [Object? error, StackTrace? stackTrace]) async {
    _log(LogLevel.warning, tag, message, error, stackTrace);
  }

  Future<void> error(String tag, String message, [Object? error, StackTrace? stackTrace]) async {
    _log(LogLevel.error, tag, message, error, stackTrace);
  }

  Future<void> fatal(String tag, String message, [Object? error, StackTrace? stackTrace]) async {
    _log(LogLevel.fatal, tag, message, error, stackTrace);
  }

  void _log(LogLevel level, String tag, String message, [Object? error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    final levelString = level.name.toUpperCase().padRight(7);
    String logMessage = '[$timestamp] [$levelString] [$tag] $message';
    if (error != null) {
      logMessage += '\nError: $error';
    }
    if (stackTrace != null) {
      logMessage += '\nStack trace: $stackTrace';
    }
    if (kDebugMode) {
      debugPrint(logMessage);
    }
  }

  // Web stubs for parity
  Future<List<String>> getLogFiles() async => [];
  Future<String?> getLogContent([String? filePath]) async => null;
  Future<void> clearLogs() async {}
  Future<int> getLogFileSize() async => 0;
  Future<int> getTotalLogSize() async => 0;
}

final _logger = LoggingService.instance;
Future<void> logDebug(String tag, String message, [Object? error, StackTrace? stackTrace]) => _logger.debug(tag, message, error, stackTrace);
Future<void> logInfo(String tag, String message, [Object? error, StackTrace? stackTrace]) => _logger.info(tag, message, error, stackTrace);
Future<void> logWarning(String tag, String message, [Object? error, StackTrace? stackTrace]) => _logger.warning(tag, message, error, stackTrace);
Future<void> logError(String tag, String message, [Object? error, StackTrace? stackTrace]) => _logger.error(tag, message, error, stackTrace);
Future<void> logFatal(String tag, String message, [Object? error, StackTrace? stackTrace]) => _logger.fatal(tag, message, error, stackTrace);
