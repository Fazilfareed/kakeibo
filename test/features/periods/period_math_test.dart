import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/features/periods/domain/period_math.dart';
import 'package:kakeibo/features/periods/domain/period_summary.dart';

void main() {
  group('PeriodMath.rangeContaining', () {
    test('start day 1 gives the calendar month', () {
      final r = PeriodMath.rangeContaining(DateTime(2026, 11, 3), 1);
      expect(r, DateRange(DateTime(2026, 11, 1), DateTime(2026, 11, 30)));
      expect(r.totalDays, 30);
    });

    test('salary day 25: before the 25th belongs to last month', () {
      expect(
        PeriodMath.rangeContaining(DateTime(2026, 11, 3), 25),
        DateRange(DateTime(2026, 10, 25), DateTime(2026, 11, 24)),
      );
      expect(
        PeriodMath.rangeContaining(DateTime(2026, 11, 25), 25),
        DateRange(DateTime(2026, 11, 25), DateTime(2026, 12, 24)),
      );
    });

    test('start day 28 across February in a leap year', () {
      final r = PeriodMath.rangeContaining(DateTime(2028, 2, 28), 28);
      expect(r, DateRange(DateTime(2028, 2, 28), DateTime(2028, 3, 27)));
      expect(r.totalDays, 29);
    });

    test('year boundary', () {
      expect(
        PeriodMath.rangeContaining(DateTime(2027, 1, 2), 5),
        DateRange(DateTime(2026, 12, 5), DateTime(2027, 1, 4)),
      );
    });

    test('start day is clamped to 1–28', () {
      expect(PeriodMath.rangeContaining(DateTime(2026, 11, 30), 31).start, DateTime(2026, 11, 28));
    });
  });

  test('next period starts the day after the previous one ends', () {
    final nov = DateRange(DateTime(2026, 11, 1), DateTime(2026, 11, 30));
    final dec = PeriodMath.next(nov);
    expect(dec, DateRange(DateTime(2026, 12, 1), DateTime(2026, 12, 31)));
    expect(PeriodMath.next(dec).start, DateTime(2027, 1, 1));
  });

  group('PeriodSummary', () {
    final range = DateRange(DateTime(2026, 11, 1), DateTime(2026, 11, 30));

    PeriodSummary summary({int spent = 0, DateTime? today}) => PeriodSummary(
      income: 15000000,
      fixed: 5000000,
      savingsGoal: 2000000,
      spentByPillar: {1: spent},
      plannedByPillar: {1: 5000000, 2: 2000000},
      range: range,
      today: today ?? DateTime(2026, 11, 11),
    );

    test('spendable, remaining and daily allowance', () {
      final s = summary(spent: 1000000);
      expect(s.spendable, 8000000);
      expect(s.remaining, 7000000);
      expect(s.daysLeft, 20);
      expect(s.dailyAllowance, 350000);
      expect(s.unassigned, 1000000);
      expect(s.savingsProtected, 1);
    });

    test('daily allowance rounds down to whole cents', () {
      final s = summary(spent: 1, today: DateTime(2026, 11, 28));
      expect(s.daysLeft, 3);
      expect(s.dailyAllowance, (8000000 - 1) ~/ 3);
    });

    test('overspending never gives a negative allowance and eats savings', () {
      final s = summary(spent: 8500000);
      expect(s.remaining, -500000);
      expect(s.overspend, 500000);
      expect(s.dailyAllowance, 0);
      expect(s.savingsProtected, closeTo(0.75, 1e-9));
      expect(s.actualSavings, 1500000);
      // The ring follows what is left of the goal, not a pace projection.
      expect(s.savingsProgress, closeTo(0.75, 1e-9));
    });

    test('projection appears after day 3 and extrapolates the pace', () {
      // Day 3: too early, ring shows how much of the goal is still safe.
      final early = summary(spent: 300000, today: DateTime(2026, 11, 3));
      expect(early.hasProjection, isFalse);
      expect(early.savingsProgress, 1);

      // Day 10, Rs 30,000 spent: pace Rs 90,000 for 30 days.
      final s = summary(spent: 3000000, today: DateTime(2026, 11, 10));
      expect(s.daysElapsed, 10);
      expect(s.hasProjection, isTrue);
      expect(s.projectedSpend, 9000000);
      expect(s.projectedSavings, 1000000);
      expect(s.savingsProgress, 0.5);
    });

    test('projection on pace for the goal clamps at 100%', () {
      final s = summary(spent: 1000000, today: DateTime(2026, 11, 15));
      expect(s.projectedSavings, 8000000);
      expect(s.savingsProgress, 1);
    });

    test('a pace that overshoots income projects no savings', () {
      final s = summary(spent: 6000000, today: DateTime(2026, 11, 5));
      expect(s.projectedSavings, lessThan(0));
      expect(s.savingsProgress, 0);
    });

    test('last day still has one day left', () {
      expect(summary(today: DateTime(2026, 11, 30)).daysLeft, 1);
      expect(summary(today: DateTime(2026, 12, 2)).daysLeft, 1);
    });
  });
}
