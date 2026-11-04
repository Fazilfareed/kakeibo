import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'backup_repository.dart';

final _log = Logger('backup');

/// A folder the user picked through the Storage Access Framework
/// (MainActivity's `kakeibo/backup_folder` channel).
class BackupFolder {
  const BackupFolder();

  static const _channel = MethodChannel('kakeibo/backup_folder');

  /// Lets the user pick a folder; null if they cancelled.
  Future<({String uri, String name})?> pick() async {
    final r = await _channel.invokeMapMethod<String, String>('pick');
    return r == null ? null : (uri: r['uri']!, name: r['name']!);
  }

  Future<bool> hasAccess(String uri) async =>
      await _channel.invokeMethod<bool>('hasAccess', {'uri': uri}) ?? false;

  Future<void> write(String uri, String name, List<int> bytes) => _channel.invokeMethod<void>(
    'write',
    {'uri': uri, 'name': name, 'bytes': Uint8List.fromList(bytes)},
  );

  /// Deletes the oldest files starting with [prefix], keeping [keep].
  Future<int> prune(String uri, String prefix, int keep) async =>
      await _channel.invokeMethod<int>('prune', {'uri': uri, 'prefix': prefix, 'keep': keep}) ?? 0;

  Future<void> release(String uri) => _channel.invokeMethod<void>('release', {'uri': uri});
}

/// What happened when an automatic backup was due.
enum AutoBackupOutcome { notDue, saved, noAccess, failed }

/// FR-73: once a week (checked whenever the app opens) a backup is written to
/// the chosen folder, keeping the newest [keep]. There is no background job.
class AutoBackup {
  AutoBackup(this._backup, this._folder, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final BackupRepository _backup;
  final BackupFolder _folder;
  final DateTime Function() _now;

  static bool _running = false;

  static const every = Duration(days: 7);
  static const keep = 8;
  static const prefix = 'kakeibo-auto-';

  static const keyEnabled = 'auto_backup_enabled';
  static const keyFolderUri = 'backup_folder_uri';
  static const keyFolderName = 'backup_folder_name';
  static const keyError = 'auto_backup_error';

  /// When the last backup of any kind was made, or null.
  static DateTime? lastBackup(Map<String, String> settings) =>
      DateTime.tryParse(settings[BackupRepository.lastBackupKey] ?? '');

  static bool isDue(Map<String, String> settings, DateTime now) {
    if (settings[keyEnabled] != 'true' || settings[keyFolderUri] == null) return false;
    final last = lastBackup(settings);
    return last == null || now.difference(last) >= every;
  }

  /// FR-73 banner: warn when the last backup is over 14 days old, or when
  /// there's never been one and the data is at least 14 days old.
  static bool isStale(Map<String, String> settings, DateTime now, {DateTime? firstUse}) {
    final last = lastBackup(settings);
    final since = last ?? firstUse;
    return since != null && now.difference(since) > const Duration(days: 14);
  }

  /// Runs the backup if due. Returns the settings to store (last backup time
  /// or an error flag), or an empty map when nothing changed.
  Future<({AutoBackupOutcome outcome, Map<String, String> settings})> runIfDue(
    Map<String, String> settings,
  ) async {
    final now = _now();
    // One backup at a time: start-up, resume and "turn on" can overlap.
    if (_running || !isDue(settings, now)) {
      return (outcome: AutoBackupOutcome.notDue, settings: const <String, String>{});
    }
    final uri = settings[keyFolderUri]!;
    _running = true;
    try {
      if (!await _folder.hasAccess(uri)) {
        return (outcome: AutoBackupOutcome.noAccess, settings: {keyError: 'no_access'});
      }
      final name = BackupRepository.fileName(now, prefix);
      await _folder.write(uri, name, utf8.encode(await _backup.encode()));
      await _folder.prune(uri, prefix, keep);
      _log.info('Automatic backup saved: $name');
      return (
        outcome: AutoBackupOutcome.saved,
        settings: {BackupRepository.lastBackupKey: now.toUtc().toIso8601String(), keyError: ''},
      );
    } on Object catch (e, st) {
      _log.severe('Automatic backup failed', e, st);
      return (outcome: AutoBackupOutcome.failed, settings: {keyError: 'failed'});
    } finally {
      _running = false;
    }
  }
}
