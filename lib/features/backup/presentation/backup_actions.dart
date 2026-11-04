import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/kakeibo_colors.dart';
import '../../../core/date/local_date.dart';
import '../../../core/diagnostics/diagnostics.dart';
import '../../periods/data/period_providers.dart';
import '../../settings/data/settings_repository.dart';
import '../data/auto_backup.dart';
import '../data/backup_providers.dart';
import '../data/backup_repository.dart';

/// When the last backup was made, for the Settings row and FR-73 in M5.
const lastBackupKey = BackupRepository.lastBackupKey;

/// The Data section's actions (FR-70–72, FR-74, FR-75). Each one asks before
/// doing anything that can't be undone, and says what happened afterwards.
abstract final class BackupActions {
  /// FR-70: share every spend as a CSV file.
  static Future<void> exportCsv(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final csv = await ref.read(backupRepositoryProvider).exportCsv();
    final file = await _tempFile(BackupRepository.csvFileName());
    // A byte-order mark lets spreadsheet apps read Sinhala and Tamil notes.
    await file.writeAsString('﻿$csv', encoding: utf8);
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Kakeibo spends',
      ),
    );
    if (result.status == ShareResultStatus.success) {
      messenger.showSnackBar(const SnackBar(content: Text('Spends exported.')));
    }
  }

  /// FR-71/75: warn that the file is not encrypted, then save or share it.
  static Future<void> backUp(BuildContext context, WidgetRef ref) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Back up your data'),
        content: const Text(
          'The backup file is not encrypted. Anyone who opens it can read your spending, '
          'so keep it somewhere private.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, 'share'), child: const Text('Share')),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Save to phone'),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(backupRepositoryProvider);
    final json = await repo.encode();
    final name = BackupRepository.fileName();

    var saved = false;
    if (choice == 'save') {
      final uri = await FilePicker.saveFile(
        fileName: name,
        bytes: utf8.encode(json),
        mimeType: 'application/json',
        dialogTitle: 'Save backup',
      );
      saved = uri != null;
    } else {
      final file = await _tempFile(name);
      await file.writeAsString(json);
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'Kakeibo backup',
        ),
      );
      saved = result.status == ShareResultStatus.success;
    }
    if (!saved) return;
    await ref
        .read(settingsRepositoryProvider)
        .set(lastBackupKey, DateTime.now().toUtc().toIso8601String());
    messenger.showSnackBar(const SnackBar(content: Text('Backup saved.')));
  }

  /// FR-74: pick a file, check it, confirm, then replace everything.
  static Future<void> restore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await FilePicker.pickFile(dialogTitle: 'Choose a Kakeibo backup');
    if (picked == null || !context.mounted) return;
    final repo = ref.read(backupRepositoryProvider);

    final String text;
    final ({int months, int spends, DateTime? exportedAt}) info;
    try {
      text = utf8.decode(await picked.readAsBytes());
      info = repo.inspect(text);
    } on Object catch (e) {
      if (!context.mounted) return;
      await _message(
        context,
        "Can't restore this file",
        e is BackupFormatException ? e.message : "This file isn't a Kakeibo backup.",
      );
      return;
    }
    if (!context.mounted) return;

    final when = info.exportedAt == null
        ? ''
        : ' from ${DateFormat('d MMM yyyy, h:mm a').format(info.exportedAt!.toLocal())}';
    final ok = await _confirm(
      context,
      title: 'Restore this backup?',
      body:
          'The backup$when has ${info.months} ${info.months == 1 ? 'month' : 'months'} and '
          '${info.spends} ${info.spends == 1 ? 'spend' : 'spends'}. It replaces everything on '
          'this phone. A copy of your current data is kept first.',
      action: 'Restore',
    );
    if (!ok) return;
    await repo.restore(text);
    ref.invalidate(ledgerBootstrapProvider);
    messenger.showSnackBar(const SnackBar(content: Text('Backup restored.')));
  }

  /// FR-73: pick a folder, then back up to it now and every week.
  static Future<void> chooseAutoBackupFolder(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final folder = await ref.read(backupFolderProvider).pick();
    if (folder == null) return;
    final settings = ref.read(settingsRepositoryProvider);
    final old = ref.read(settingsProvider).value?[AutoBackup.keyFolderUri];
    if (old != null && old != folder.uri) await ref.read(backupFolderProvider).release(old);
    final values = {
      AutoBackup.keyEnabled: 'true',
      AutoBackup.keyFolderUri: folder.uri,
      AutoBackup.keyFolderName: folder.name,
      AutoBackup.keyError: '',
    };
    await settings.setAll(values);
    // Back up straight away, whatever the last backup's date.
    final run = await ref
        .read(autoBackupProvider)
        .runIfDue({...?ref.read(settingsProvider).value, ...values}..remove(lastBackupKey));
    if (run.settings.isNotEmpty) await settings.setAll(run.settings);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          run.outcome == AutoBackupOutcome.saved
              ? 'Backed up to ${folder.name}. Kakeibo will do this every week.'
              : "Couldn't save to ${folder.name}. Try another folder.",
        ),
      ),
    );
  }

  static Future<void> turnOffAutoBackup(WidgetRef ref) async {
    final uri = ref.read(settingsProvider).value?[AutoBackup.keyFolderUri];
    if (uri != null) await ref.read(backupFolderProvider).release(uri);
    await ref.read(settingsRepositoryProvider).set(AutoBackup.keyEnabled, 'false');
  }

  /// NFR-12: share the local error log, for example to report a problem.
  static Future<void> exportDiagnostics(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final log = await Diagnostics.collect();
    if (log.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('The log is empty.')));
      return;
    }
    final file = await _tempFile('kakeibo-diagnostics-${LocalDate.today()}.txt');
    await file.writeAsString(log);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/plain')],
        subject: 'Kakeibo diagnostics',
      ),
    );
  }

  /// FR-72: two confirmations, then delete everything.
  static Future<void> deleteAll(BuildContext context, WidgetRef ref) async {
    final first = await _confirm(
      context,
      title: 'Delete all data?',
      body: 'Every month, spend, plan, reflection and setting will be removed from this phone.',
      action: 'Continue',
    );
    if (!first || !context.mounted) return;
    final second = await _confirm(
      context,
      title: 'Are you sure?',
      body: "This can't be undone. Back up first if you might want this data again.",
      action: 'Delete everything',
      destructive: true,
    );
    if (!second || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(backupRepositoryProvider).deleteAll();
    ref.invalidate(ledgerBootstrapProvider);
    messenger.showSnackBar(const SnackBar(content: Text('All data deleted.')));
  }

  // ---------------------------------------------------------------------------

  static Future<File> _tempFile(String name) async {
    final dir = await getTemporaryDirectory();
    return File(p.join(dir.path, name));
  }

  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final c = context.colors;
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(backgroundColor: c.over, foregroundColor: c.bg)
                  : null,
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  static Future<void> _message(BuildContext context, String title, String body) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ),
  );

  /// "Last backup: 4 Nov" or "Never backed up", for the Settings row.
  static String lastBackupLabel(String? iso) {
    final t = DateTime.tryParse(iso ?? '');
    if (t == null) return 'Never backed up';
    return 'Last backup ${DateFormat('d MMM yyyy').format(LocalDate.dateOnly(t.toLocal()))}';
  }
}
