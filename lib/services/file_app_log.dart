import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:galitrack/core/app_log.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// [AppLog] that appends to a small text file in app-private storage.
///
/// Writes are synchronous so an entry survives even if the app is killed
/// right after. Once the file passes [_maxBytes], the oldest half is
/// dropped. In debug builds every entry is also printed to the console.
final class FileAppLog implements AppLog {
  FileAppLog._(this._file, this._clock);

  static const int _maxBytes = 256 * 1024;

  /// Null when app storage was unavailable; then only the console is used.
  final File? _file;
  final Clock _clock;

  /// Opens the log. Never throws, because it runs before the error handlers
  /// exist.
  static Future<FileAppLog> open({Clock clock = const Clock()}) async {
    try {
      final directory = await getApplicationSupportDirectory();
      return FileAppLog._(
        File(p.join(directory.path, 'diagnostics.log')),
        clock,
      );
    } on Exception catch (error) {
      debugPrint('Diagnostics log unavailable: $error');
      return FileAppLog._(null, clock);
    }
  }

  @override
  void error(String code, Object error, StackTrace stackTrace) {
    _append('ERROR $code: $error\n$stackTrace');
  }

  @override
  void info(String event) => _append('INFO $event');

  void _append(String entry) {
    final line = '${_clock.now().toUtc().toIso8601String()} $entry\n';
    if (kDebugMode) debugPrint(line);
    final file = _file;
    if (file == null) return;
    try {
      _trimIfFull(file);
      file.writeAsStringSync(line, mode: FileMode.append, flush: true);
    } on FileSystemException catch (failure) {
      // Logging must never crash the app; the console is the last resort.
      debugPrint('Diagnostics log write failed: $failure');
    }
  }

  void _trimIfFull(File file) {
    if (!file.existsSync() || file.lengthSync() < _maxBytes) return;
    final text = file.readAsStringSync();
    file.writeAsStringSync(text.substring(text.length ~/ 2), flush: true);
  }
}
