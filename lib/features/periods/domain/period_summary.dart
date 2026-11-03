import '../../../core/date/local_date.dart';
import 'period_math.dart';

/// Totals for one period, computed with integer cents only (PRD §12.2).
class PeriodSummary {
  const PeriodSummary({
    required this.income,
    required this.fixed,
    required this.savingsGoal,
    required this.spentByPillar,
    required this.plannedByPillar,
    required this.range,
    required this.today,
  });

  final int income;
  final int fixed;
  final int savingsGoal;

  /// Net spend per pillar id (expenses minus refunds).
  final Map<int, int> spentByPillar;
  final Map<int, int> plannedByPillar;
  final DateRange range;
  final DateTime today;

  int get spendable => income - fixed - savingsGoal;
  int get spent => spentByPillar.values.fold(0, (a, b) => a + b);
  int get remaining => spendable - spent;
  int get actualSavings => income - fixed - spent;
  int get overspend => remaining < 0 ? -remaining : 0;

  int get plannedTotal => plannedByPillar.values.fold(0, (a, b) => a + b);

  /// Spendable money not yet assigned to any pillar (negative = over-assigned).
  int get unassigned => spendable - plannedTotal;

  /// Days left including today; at least 1.
  int get daysLeft {
    final left = LocalDate.daysBetween(LocalDate.dateOnly(today), range.end) + 1;
    return left < 1 ? 1 : left;
  }

  /// What can be spent per day to stay on track; never negative.
  int get dailyAllowance => remaining <= 0 ? 0 : remaining ~/ daysLeft;

  /// Fraction of the savings goal still safe (0–1). It stays at 1 until
  /// overspending starts eating into the savings.
  double get savingsProtected {
    if (savingsGoal <= 0) return 0;
    if (overspend == 0) return 1;
    return ((savingsGoal - overspend) / savingsGoal).clamp(0.0, 1.0);
  }
}
