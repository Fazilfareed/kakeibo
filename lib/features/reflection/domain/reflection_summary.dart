import '../../../core/db/app_database.dart';

/// Kakeibo's four end-of-month questions (PRD §1.6), with the "why" shown on
/// the first ever reflection (FR-102).
abstract final class ReflectionQuestions {
  static const q1 = 'Did I reach my savings goal? Can I repeat it, or aim higher?';
  static const q2 = 'Which pillar surprised me the most?';
  static const q3 = 'Which purchases do I regret, and which made me genuinely happy?';
  static const q4 = 'What is the ONE thing I will change next month?';

  static const why1 =
      'Saving is the point of Kakeibo. Noticing whether you hit the goal, '
      'and why, helps you set one you can keep.';
  static const why2 =
      'The surprise is where your habits differ from your plan. '
      'That is the most useful thing to learn each month.';
  static const why3 =
      'Spending that brought joy is money well used. '
      'Regrets show what to skip next time, without guilt.';
  static const why4 = 'One small change is easier to keep than many.';
}

/// Whether last month's improvement was kept (FR-57).
enum ImprovementKept {
  yes('Yes'),
  partly('Partly'),
  no('No');

  const ImprovementKept(this.label);
  final String label;

  static ImprovementKept? fromName(String? name) =>
      ImprovementKept.values.where((k) => k.name == name).firstOrNull;
}

/// Everything the reflection wizard shows for one closed period (FR-51–59).
class ReflectionSummary {
  const ReflectionSummary({
    required this.period,
    required this.income,
    required this.fixed,
    required this.spentByPillar,
    required this.plannedByPillar,
    required this.worthIt,
    required this.regrets,
    required this.previousImprovement,
    required this.isFirstReflection,
    this.saved,
  });

  final Period period;
  final int income;
  final int fixed;
  final Map<int, int> spentByPillar;
  final Map<int, int> plannedByPillar;

  /// Expenses tagged "Worth it" / "Regret", largest first (FR-53).
  final List<Expense> worthIt;
  final List<Expense> regrets;

  /// The improvement chosen at the end of the month before (FR-57).
  final String? previousImprovement;
  final bool isFirstReflection;

  /// The stored reflection, a draft or a completed one.
  final Reflection? saved;

  int get savingsGoal => period.savingsGoal;
  int get spent => spentByPillar.values.fold(0, (a, b) => a + b);

  /// What was actually left over (may be negative). A completed reflection
  /// keeps its frozen snapshot (FR-58).
  int get savedAmount => saved?.completedAt != null ? saved!.savedAmount : income - fixed - spent;

  bool get goalMet => savedAmount >= savingsGoal && savedAmount > 0;
  int get missedBy => goalMet ? 0 : savingsGoal - savedAmount;

  /// FR-59: the pillar that went furthest over its budget, if any.
  ({int pillarId, int overBy})? get biggestOvershoot {
    ({int pillarId, int overBy})? best;
    for (final e in plannedByPillar.entries) {
      if (e.value <= 0) continue;
      final over = (spentByPillar[e.key] ?? 0) - e.value;
      if (over > 0 && (best == null || over > best.overBy)) best = (pillarId: e.key, overBy: over);
    }
    return best;
  }

  /// FR-59: a gentler goal when this one was missed: what was actually saved,
  /// rounded down to a whole Rs 1,000. Null when nothing was saved.
  int? get suggestedGoal {
    if (goalMet || savedAmount < 100000) return null;
    return savedAmount ~/ 100000 * 100000;
  }
}

/// What the wizard saves, on every step and on Finish.
class ReflectionDraft {
  const ReflectionDraft({
    required this.periodId,
    this.answer1,
    this.answer2,
    this.answer3,
    this.improvementKept,
    this.improvement,
  });

  final int periodId;
  final String? answer1;
  final String? answer2;
  final String? answer3;
  final ImprovementKept? improvementKept;

  /// Question 4: the one change for next month (FR-54).
  final String? improvement;
}
