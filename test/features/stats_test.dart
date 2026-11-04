import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/db/app_database.dart';
import 'package:kakeibo/features/history/data/history_repository.dart';
import 'package:kakeibo/features/stats/domain/my_stats.dart';

MonthRecord _month(String start, {int income = 10000000, int spent = 0, bool reflected = false}) {
  return MonthRecord(
    period: Period(
      id: start.hashCode,
      startDate: start,
      endDate: start,
      savingsGoal: 1000000,
      savingsGoalType: 'amount',
      savingsSetAside: false,
      isPartial: false,
      status: 'closed',
      createdAt: '',
      updatedAt: '',
    ),
    income: income,
    fixed: 0,
    spentByPillar: {1: spent},
    reflection: reflected
        ? Reflection(
            periodId: 1,
            savedAmount: income - spent,
            goalMet: true,
            completedAt: 'x',
            editedAfterClose: 0,
          )
        : null,
  );
}

void main() {
  final today = DateTime(2026, 11, 10);

  test('streak counts back from today, or from yesterday before logging today', () {
    final dates = ['2026-11-07', '2026-11-08', '2026-11-08', '2026-11-09'];
    expect(MyStats.compute(spendDates: dates, months: const [], today: today).streak, 3);
    expect(
      MyStats.compute(spendDates: [...dates, '2026-11-10'], months: const [], today: today).streak,
      4,
    );
    expect(
      MyStats.compute(spendDates: ['2026-11-07'], months: const [], today: today).streak,
      0,
      reason: 'two days without logging ends the streak',
    );
  });

  test('best streak, days logged and entries per day', () {
    final s = MyStats.compute(
      spendDates: [
        '2026-11-01',
        '2026-11-02',
        '2026-11-03',
        '2026-11-03',
        '2026-11-06',
        '2026-11-10',
      ],
      months: const [],
      today: today,
    );
    expect(s.bestStreak, 3);
    expect(s.streak, 1);
    expect(s.daysLogged, 5);
    expect(s.daysSinceStart, 10);
    expect(s.loggedShare, 0.5);
    expect(s.entriesPerLoggedDay, 6 / 5);
  });

  test('goals, reflections and savings rates come from closed months', () {
    final months = [
      _month('2026-10-01', spent: 8000000, reflected: true), // saved 20%
      _month('2026-09-01', spent: 9500000), // saved 5%, goal missed
      _month('2026-08-01', income: 0),
    ];
    final s = MyStats.compute(
      spendDates: const [],
      months: months,
      today: today,
      monthLabel: (m) => m.period.startDate.substring(5, 7),
    );
    expect(s.closedMonths, 3);
    expect(s.goalsMet, 1);
    expect(s.reflectionsDone, 1);
    expect(s.savingsRates.map((r) => r.month), ['09', '10'], reason: 'oldest first');
    expect(s.savingsRates.last.rate, closeTo(0.2, 1e-9));
    expect(s.loggedShare, 0);
  });
}
