import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../db/database_provider.dart';

/// The four pillars in display order.
final pillarsProvider = StreamProvider<List<Pillar>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.pillars)..orderBy([(p) => OrderingTerm.asc(p.sortOrder)])).watch();
});
