import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';

/// Reads and writes the key-value `settings` table.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Stream<Map<String, String>> watchAll() {
    return _db.select(_db.settings).watch().map((rows) => {for (final r in rows) r.key: r.value});
  }

  Future<void> setAll(Map<String, String> values) {
    return _db.batch((b) {
      b.insertAllOnConflictUpdate(_db.settings, [
        for (final e in values.entries) SettingsCompanion(key: Value(e.key), value: Value(e.value)),
      ]);
    });
  }

  Future<void> set(String key, String value) => setAll({key: value});
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(appDatabaseProvider)),
);

/// All settings as a live map.
final settingsProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(settingsRepositoryProvider).watchAll(),
);
