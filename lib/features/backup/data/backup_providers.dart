import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/db/database_provider.dart';
import '../../settings/data/settings_repository.dart';
import 'auto_backup.dart';
import 'backup_repository.dart';

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => BackupRepository(
    ref.watch(appDatabaseProvider),
    snapshotDir: getApplicationDocumentsDirectory,
  ),
);

final backupFolderProvider = Provider<BackupFolder>((ref) => const BackupFolder());

final autoBackupProvider = Provider<AutoBackup>(
  (ref) => AutoBackup(ref.watch(backupRepositoryProvider), ref.watch(backupFolderProvider)),
);

/// FR-73: checked on start and on every resume (the app root invalidates it).
/// It reads settings once rather than watching them, so saving settings
/// doesn't start another backup.
final autoBackupRunProvider = FutureProvider<AutoBackupOutcome>((ref) async {
  final settings = await ref.read(settingsProvider.future);
  final run = await ref.read(autoBackupProvider).runIfDue(settings);
  if (run.settings.isNotEmpty) await ref.read(settingsRepositoryProvider).setAll(run.settings);
  return run.outcome;
});
