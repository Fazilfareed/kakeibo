import '../../../core/date/local_date.dart';
import '../../history/data/history_repository.dart';

/// FR-36: habit and savings metrics, computed only from local data.
class MyStats {
  const MyStats({
    required this.streak,
    required this.bestStreak,
    required this.daysLogged,
    required this.daysSinceStart,
    required this.entries,
    required this.closedMonths,
    required this.goalsMet,
    required this.reflectionsDone,
    required this.savingsRates,
  });

  /// Days in a row with at least one spend, ending today (or yesterday, so a
  /// streak isn't "broken" before the day is over).
  final int streak;
  final int bestStreak;

  /// Days with at least one spend, and days since the first one (inclusive).
  final int daysLogged;
  final int daysSinceStart;
  final int entries;

  final int closedMonths;
  final int goalsMet;
  final int reflectionsDone;

  /// Savings rate (saved ÷ income) of each closed month with income, oldest
  /// first, at most 6.
  final List<({String month, double rate})> savingsRates;

  /// Share of days logged since the first spend (0–1).
  double get loggedShare => daysSinceStart == 0 ? 0 : daysLogged / daysSinceStart;

  /// Average entries on the days something was logged.
  double get entriesPerLoggedDay => daysLogged == 0 ? 0 : entries / daysLogged;

  static MyStats compute({
    required List<String> spendDates,
    required List<MonthRecord> months,
    required DateTime today,
    String Function(MonthRecord m)? monthLabel,
  }) {
    final day = LocalDate.dateOnly(today);
    final days = spendDates.map(LocalDate.parse).toSet().toList()..sort();

    var best = 0;
    var run = 0;
    DateTime? previous;
    for (final d in days) {
      run = (previous != null && LocalDate.daysBetween(previous, d) == 1) ? run + 1 : 1;
      if (run > best) best = run;
      previous = d;
    }

    var streak = 0;
    if (days.isNotEmpty) {
      final gap = LocalDate.daysBetween(days.last, day);
      if (gap == 0 || gap == 1) {
        streak = 1;
        for (var i = days.length - 1; i > 0; i--) {
          if (LocalDate.daysBetween(days[i - 1], days[i]) != 1) break;
          streak++;
        }
      }
    }

    final closed = months.where((m) => m.isClosed).toList();
    final withIncome = closed.where((m) => m.income > 0).take(6).toList().reversed;

    return MyStats(
      streak: streak,
      bestStreak: best,
      daysLogged: days.length,
      daysSinceStart: days.isEmpty ? 0 : LocalDate.daysBetween(days.first, day) + 1,
      entries: spendDates.length,
      closedMonths: closed.length,
      goalsMet: closed.where((m) => m.goalMet).length,
      reflectionsDone: closed.where((m) => m.reflectionDone).length,
      savingsRates: [
        for (final m in withIncome)
          (month: monthLabel?.call(m) ?? m.period.startDate, rate: m.savedAmount / m.income),
      ],
    );
  }
}
