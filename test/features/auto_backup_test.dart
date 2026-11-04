import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/db/app_database.dart';
import 'package:kakeibo/features/backup/data/auto_backup.dart';
import 'package:kakeibo/features/backup/data/backup_repository.dart';

class _FakeFolder implements BackupFolder {
  bool access = true;
  bool failWrite = false;
  final written = <String, String>{};
  final pruned = <(String, int)>[];

  @override
  Future<bool> hasAccess(String uri) async => access;
  @override
  Future<void> write(String uri, String name, List<int> bytes) async {
    if (failWrite) throw Exception('disk full');
    written[name] = utf8.decode(bytes);
  }

  @override
  Future<int> prune(String uri, String prefix, int keep) async {
    pruned.add((prefix, keep));
    return 0;
  }

  @override
  Future<({String name, String uri})?> pick() async => null;
  @override
  Future<void> release(String uri) async {}
}

void main() {
  late AppDatabase db;
  late _FakeFolder folder;
  late AutoBackup auto;
  final now = DateTime(2026, 11, 20, 8, 5);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    folder = _FakeFolder();
    auto = AutoBackup(
      BackupRepository(db, snapshotDir: () async => Directory.systemTemp),
      folder,
      clock: () => now,
    );
  });
  tearDown(() => db.close());

  Map<String, String> on({DateTime? last}) => {
    AutoBackup.keyEnabled: 'true',
    AutoBackup.keyFolderUri: 'content://tree/Kakeibo',
    if (last != null) BackupRepository.lastBackupKey: last.toUtc().toIso8601String(),
  };

  test('due weekly, only when turned on with a folder', () {
    expect(AutoBackup.isDue(const {}, now), isFalse);
    expect(AutoBackup.isDue(on(), now), isTrue, reason: 'never backed up');
    expect(AutoBackup.isDue(on(last: now.subtract(const Duration(days: 6))), now), isFalse);
    expect(AutoBackup.isDue(on(last: now.subtract(const Duration(days: 7))), now), isTrue);
    expect(AutoBackup.isDue({...on(), AutoBackup.keyEnabled: 'false'}, now), isFalse);
  });

  test('the Home warning appears after 14 days (FR-73)', () {
    final old = now.subtract(const Duration(days: 15));
    expect(AutoBackup.isStale(on(last: old), now), isTrue);
    expect(AutoBackup.isStale(on(last: now.subtract(const Duration(days: 3))), now), isFalse);
    expect(
      AutoBackup.isStale(const {}, now, firstUse: now.subtract(const Duration(days: 4))),
      isFalse,
    );
    expect(AutoBackup.isStale(const {}, now, firstUse: old), isTrue, reason: 'never, used 15 days');
    expect(AutoBackup.isStale(const {}, now), isFalse, reason: 'no data yet');
  });

  test('a due backup is written, older ones pruned, and the time recorded', () async {
    final run = await auto.runIfDue(on());
    expect(run.outcome, AutoBackupOutcome.saved);
    expect(folder.written.keys, ['kakeibo-auto-2026-11-20-0805.json']);
    final json = jsonDecode(folder.written.values.single) as Map<String, dynamic>;
    expect(json['app'], 'kakeibo');
    expect(folder.pruned, [('kakeibo-auto-', 8)]);
    expect(run.settings[BackupRepository.lastBackupKey], now.toUtc().toIso8601String());
    expect(run.settings[AutoBackup.keyError], '');
  });

  test('overlapping runs write one file, not several', () async {
    final runs = await Future.wait([auto.runIfDue(on()), auto.runIfDue(on()), auto.runIfDue(on())]);
    expect(runs.where((r) => r.outcome == AutoBackupOutcome.saved).length, 1);
    expect(folder.written.length, 1);
  });

  test('not due: nothing written', () async {
    final run = await auto.runIfDue(on(last: now.subtract(const Duration(days: 1))));
    expect(run.outcome, AutoBackupOutcome.notDue);
    expect(run.settings, isEmpty);
    expect(folder.written, isEmpty);
  });

  test('a lost folder or a failed write is reported, not thrown', () async {
    folder.access = false;
    final noAccess = await auto.runIfDue(on());
    expect(noAccess.outcome, AutoBackupOutcome.noAccess);
    expect(noAccess.settings[AutoBackup.keyError], 'no_access');

    folder
      ..access = true
      ..failWrite = true;
    final failed = await auto.runIfDue(on());
    expect(failed.outcome, AutoBackupOutcome.failed);
    expect(failed.settings.containsKey(BackupRepository.lastBackupKey), isFalse);
  });
}
