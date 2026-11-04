import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../periods/data/period_providers.dart';
import '../../periods/domain/period_math.dart';
import '../../settings/data/settings_repository.dart';
import '../domain/week_math.dart';
import 'checkin_repository.dart';

final checkinRepositoryProvider = Provider<CheckinRepository>(
  (ref) => CheckinRepository(ref.watch(appDatabaseProvider)),
);

/// First day of the week, 1 = Monday … 7 = Sunday (FR-42).
final weekStartDayProvider = Provider<int>((ref) {
  final value = int.tryParse(ref.watch(settingsProvider).value?['week_start_day'] ?? '');
  return (value == null || value < 1 || value > 7) ? DateTime.monday : value;
});

/// This week, clipped to the current period; null while loading.
final currentWeekProvider = Provider<DateRange?>((ref) {
  final summary = ref.watch(currentSummaryProvider);
  if (summary == null) return null;
  return WeekMath.weekContaining(summary.today, ref.watch(weekStartDayProvider), summary.range);
});

/// This week's check-in, or null if not done yet.
final currentCheckinProvider = StreamProvider<WeeklyCheckin?>((ref) {
  final period = ref.watch(currentPeriodProvider).value;
  final week = ref.watch(currentWeekProvider);
  if (period == null || week == null) return Stream.value(null);
  return ref.watch(checkinRepositoryProvider).watchWeek(period.id, week.start);
});

/// Net spend per pillar this week.
final currentWeekTotalsProvider = StreamProvider<Map<int, int>>((ref) {
  final period = ref.watch(currentPeriodProvider).value;
  final week = ref.watch(currentWeekProvider);
  if (period == null || week == null) return Stream.value(const {});
  return ref.watch(checkinRepositoryProvider).watchWeekTotals(period.id, week);
});
