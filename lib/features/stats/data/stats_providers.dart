import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/date/local_date.dart';
import '../../../core/db/database_provider.dart';
import '../../history/data/history_providers.dart';
import '../domain/my_stats.dart';

/// The date of every visible spend (refunds excluded), for streaks.
final spendDatesProvider = StreamProvider<List<String>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final q = db.selectOnly(db.expenses)
    ..addColumns([db.expenses.date])
    ..where(db.expenses.deletedAt.isNull() & db.expenses.type.equals('expense'));
  return q.watch().map((rows) => [for (final r in rows) r.read(db.expenses.date)!]);
});

/// FR-36: My stats, or null while loading.
final myStatsProvider = Provider<MyStats?>((ref) {
  final dates = ref.watch(spendDatesProvider).value;
  final months = ref.watch(historyMonthsProvider).value;
  if (dates == null || months == null) return null;
  return MyStats.compute(
    spendDates: dates,
    months: months,
    today: DateTime.now(),
    monthLabel: (m) => DateFormat('MMM').format(LocalDate.parse(m.period.startDate)),
  );
});
