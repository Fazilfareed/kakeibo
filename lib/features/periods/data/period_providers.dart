import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../expenses/data/expense_providers.dart';
import '../domain/period_summary.dart';
import 'period_repository.dart';

final periodRepositoryProvider = Provider<PeriodRepository>(
  (ref) => PeriodRepository(ref.watch(appDatabaseProvider)),
);

/// Runs on app start and on every resume: creates or rolls over the current
/// period and purges old deleted entries. Invalidate it to run again.
final ledgerBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.watch(periodRepositoryProvider).ensureCurrentPeriod();
  await ref.watch(expenseRepositoryProvider).purgeDeleted();
});

/// The current period (the latest stored one).
final currentPeriodProvider = StreamProvider<Period?>(
  (ref) => ref.watch(periodRepositoryProvider).watchLatest(),
);

final periodPlanProvider = StreamProvider.family<PeriodPlan, int>(
  (ref, periodId) => ref.watch(periodRepositoryProvider).watchPlan(periodId),
);

/// Summary of the current period, or null while loading.
final currentSummaryProvider = Provider<PeriodSummary?>((ref) {
  final period = ref.watch(currentPeriodProvider).value;
  if (period == null) return null;
  final plan = ref.watch(periodPlanProvider(period.id)).value;
  final totals = ref.watch(pillarTotalsProvider(period.id)).value;
  if (plan == null || totals == null) return null;
  return PeriodSummary(
    income: plan.incomeTotal,
    fixed: plan.fixedTotal,
    savingsGoal: plan.period.savingsGoal,
    spentByPillar: totals,
    plannedByPillar: plan.budgets,
    range: plan.range,
    today: DateTime.now(),
  );
});
