// IO (mobile/desktop) implementation of LoggingService
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

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

  late File _logFile;
  bool _initialized = false;
  final int _maxLogFileSize = 5 * 1024 * 1024; // 5MB
  final int _maxLogFiles = 3;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      _logFile = File('${logDir.path}/grevo_${_getCurrentDateString()}.log');
      _initialized = true;
      await _rotateLogsIfNeeded();
      await info('LoggingService', 'Logging service initialized');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize logging service: $e');
      }
    }
  }

  Future<void> debug(String tag, String message, [Object? error, StackTrace? stackTrace]) async {
    await _log(LogLevel.debug, tag, message, error, stackTrace);
  }

  Future<void> info(String tag, String message, [Object? error, StackTrace? stackTrace]) async {
    await _log(LogLevel.info, tag, message, error, stackTrace);
  }

  Future<void> warning(String tag, String message, [Object? error, StackTrace? stackTrace]) async {
    await _log(LogLevel.warning, tag, message, error, stackTrace);
  }

  Future<void> error(String tag, String message, [Object? error, StackTrace? stackTrace]) async {
    await _log(LogLevel.error, tag, message, error, stackTrace);
  }

  Future<void> fatal(String tag, String message, [Object? error, StackTrace? stackTrace]) async {
    await _log(LogLevel.fatal, tag, message, error, stackTrace);
  }

  Future<void> _log(LogLevel level, String tag, String message, [Object? error, StackTrace? stackTrace]) async {
    if (!_initialized) {
      await initialize();
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelString = level.name.toUpperCase().padRight(7);

    String logMessage = '[$timestamp] [$levelString] [$tag] $message';

    if (error != null) {
      logMessage += '\nError: $error';
    }

    if (stackTrace != null) {
      logMessage += '\nStack trace: $stackTrace';
    }

    logMessage += '\n';

    // Always print to console in debug mode
    if (kDebugMode) {
      if (level == LogLevel.error || level == LogLevel.fatal) {
        debugPrint('🔴 $logMessage');
      } else if (level == LogLevel.warning) {
        debugPrint('🟡 $logMessage');
      } else if (level == LogLevel.info) {
        debugPrint('🔵 $logMessage');
      } else {
        debugPrint('⚪ $logMessage');
      }
    }

    // Write to file
    try {
      await _logFile.writeAsString(logMessage, mode: FileMode.append);
      await _rotateLogsIfNeeded();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to write to log file: $e');
      }
    }
  }

  Future<void> _rotateLogsIfNeeded() async {
    try {
      if (!await _logFile.exists()) return;

      final fileSize = await _logFile.length();
      if (fileSize > _maxLogFileSize) {
        await _rotateLogs();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to rotate logs: $e');
      }
    }
  }

  Future<void> _rotateLogs() async {
    try {
      final directory = _logFile.parent;
      final baseName = 'grevo_${_getCurrentDateString()}';

      for (int i = _maxLogFiles - 1; i >= 1; i--) {
        final oldFile = File('${directory.path}/${baseName}_$i.log');
        final newFile = File('${directory.path}/${baseName}_${i + 1}.log');
        if (await oldFile.exists()) {
          if (i == _maxLogFiles - 1) {
            await oldFile.delete();
          } else {
            await oldFile.rename(newFile.path);
          }
        }
      }

      await _logFile.rename('${directory.path}/${baseName}_1.log');
      _logFile = File('${directory.path}/$baseName.log');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to rotate log files: $e');
      }
    }
  }

  String _getCurrentDateString() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  Future<List<String>> getLogFiles() async {
    try {
      if (!_initialized) await initialize();
      final directory = _logFile.parent;
      final files = await directory.list().toList();
      return files
          .where((file) => file is File && file.path.endsWith('.log'))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get log files: $e');
      }
      return [];
    }
  }

  Future<String?> getLogContent([String? filePath]) async {
    try {
      final file = filePath != null ? File(filePath) : _logFile;
      if (!await file.exists()) {
        return null;
      }
      return await file.readAsString();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to read log file: $e');
      }
      return null;
    }
  }

  Future<void> clearLogs() async {
    try {
      if (!_initialized) await initialize();
      final directory = _logFile.parent;
      final files = await directory.list().toList();
      for (final file in files) {
        if (file is File && file.path.endsWith('.log')) {
          await file.delete();
        }
      }
      _logFile = File('${directory.path}/grevo_${_getCurrentDateString()}.log');
      await info('LoggingService', 'All log files cleared');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to clear logs: $e');
      }
    }
  }

  Future<int> getLogFileSize() async {
    try {
      if (await _logFile.exists()) {
        return await _logFile.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getTotalLogSize() async {
    try {
      if (!_initialized) await initialize();
      final directory = _logFile.parent;
      final files = await directory.list().toList();
      int totalSize = 0;
      for (final file in files) {
        if (file is File && file.path.endsWith('.log')) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}

final _logger = LoggingService.instance;
Future<void> logDebug(String tag, String message, [Object? error, StackTrace? stackTrace]) => _logger.debug(tag, message, error, stackTrace);
Future<void> logInfo(String tag, String message, [Object? error, StackTrace? stackTrace]) => _logger.info(tag, message, error, stackTrace);
Future<void> logWarning(String tag, String message, [Object? error, StackTrace? stackTrace]) => _logger.warning(tag, message, error, stackTrace);
Future<void> logError(String tag, String message, [Object? error, StackTrace? stackTrace]) => _logger.error(tag, message, error, stackTrace);
Future<void> logFatal(String tag, String message, [Object? error, StackTrace? stackTrace]) => _logger.fatal(tag, message, error, stackTrace);
