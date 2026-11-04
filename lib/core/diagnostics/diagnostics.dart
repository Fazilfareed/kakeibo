import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// NFR-12: a local, rotating diagnostics log (1 MB × 3 files). Nothing leaves
/// the phone unless the user exports it from Settings.
abstract final class Diagnostics {
  static const defaultMaxBytes = 1024 * 1024;
  static int maxBytes = defaultMaxBytes;
  static const files = 3;
  static const _name = 'kakeibo.log';

  static Directory? _dir;

  /// Starts logging and installs the global error handlers.
  static Future<void> init({Directory? dir, int maxBytes = defaultMaxBytes}) async {
    Diagnostics.maxBytes = maxBytes;
    _dir = dir ?? Directory(p.join((await getApplicationSupportDirectory()).path, 'logs'));
    await _dir!.create(recursive: true);

    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen(_write);

    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      Logger('flutter').severe(details.exceptionAsString(), details.exception, details.stack);
      previous?.call(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      Logger('platform').severe('Uncaught error', error, stack);
      return true;
    };
    Logger('app').info('Started');
  }

  static File _file(int n) => File(p.join(_dir!.path, n == 0 ? _name : '$_name.$n'));

  static void _write(LogRecord r) {
    if (kDebugMode) debugPrint('[${r.loggerName}] ${r.message}');
    if (_dir == null) return;
    final buf = StringBuffer(
      '${r.time.toUtc().toIso8601String()} ${r.level.name} ${r.loggerName}: ',
    )..write(r.message);
    if (r.error != null) buf.write(' | ${r.error}');
    if (r.stackTrace != null) buf.write('\n${r.stackTrace}');
    try {
      final f = _file(0);
      if (f.existsSync() && f.lengthSync() > maxBytes) _rotate();
      f.writeAsStringSync('$buf\n', mode: FileMode.append, flush: true);
    } on FileSystemException {
      // Logging must never break the app.
    }
  }

  /// kakeibo.log → .1 → .2; the oldest is dropped.
  static void _rotate() {
    final oldest = _file(files - 1);
    if (oldest.existsSync()) oldest.deleteSync();
    for (var n = files - 2; n >= 0; n--) {
      final f = _file(n);
      if (f.existsSync()) f.renameSync(_file(n + 1).path);
    }
  }

  /// All log files joined oldest first, for "Export diagnostics".
  static Future<String> collect() async {
    if (_dir == null) return '';
    final out = StringBuffer();
    for (var n = files - 1; n >= 0; n--) {
      try {
        out.write(await _file(n).readAsString());
      } on FileSystemException {
        // Not written yet, or just rotated away.
      }
    }
    return out.toString();
  }
}
