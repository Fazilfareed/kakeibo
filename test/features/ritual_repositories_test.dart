import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/db/app_database.dart';
import 'package:kakeibo/features/checkin/data/checkin_repository.dart';
import 'package:kakeibo/features/checkin/domain/week_math.dart';
import 'package:kakeibo/features/expenses/data/expense_repository.dart';
import 'package:kakeibo/features/periods/data/period_repository.dart';
import 'package:kakeibo/features/periods/domain/period_math.dart';
import 'package:kakeibo/features/reflection/data/reflection_repository.dart';
import 'package:kakeibo/features/reflection/domain/reflection_summary.dart';

void main() {
  late AppDatabase db;
  late PeriodRepository periods;
  late ExpenseRepository expenses;
  late ReflectionRepository reflections;
  late CheckinRepository checkins;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    periods = PeriodRepository(db);
    expenses = ExpenseRepository(db);
    reflections = ReflectionRepository(db);
    checkins = CheckinRepository(db);
  });
  tearDown(() => db.close());

  /// November planned: income 150,000, rent 40,000, goal 20,000, Rs 22,500 per pillar.
  Future<Period> plannedNovember() async {
    final nov = await periods.ensureCurrentPeriod(now: DateTime(2026, 11, 3));
    await periods.savePlan(
      nov.id,
      const PlanDraft(
        incomes: [(label: 'Salary', amount: 15000000)],
        fixedCosts: [(label: 'Rent', amount: 4000000, recurring: true)],
        savingsGoal: 2000000,
        budgets: {1: 2250000, 2: 2250000, 3: 2250000, 4: 2250000},
      ),
    );
    return nov;
  }

  ExpenseDraft spend(int pillar, int amount, {Mood? mood, String date = '2026-11-10'}) =>
      ExpenseDraft(pillarId: pillar, amount: amount, date: date, mood: mood);

  group('reflection', () {
    test('a closed month is pending until its reflection is completed', () async {
      final nov = await plannedNovember();
      expect(await reflections.watchPending().first, isNull);

      await periods.ensureCurrentPeriod(now: DateTime(2026, 12, 2));
      expect((await reflections.watchPending().first)?.id, nov.id);

      await reflections.saveDraft(ReflectionDraft(periodId: nov.id, answer1: 'Nearly'));
      expect((await reflections.watchPending().first)?.id, nov.id, reason: 'a draft is not done');

      await reflections.complete(ReflectionDraft(periodId: nov.id, improvement: 'Cook more'));
      expect(await reflections.watchPending().first, isNull);
    });

    test('summary: savings, goal, mood lists and the biggest overshoot', () async {
      final nov = await plannedNovember();
      await expenses.add(spend(1, 2000000));
      await expenses.add(spend(2, 2400000, mood: Mood.regret)); // Wants 2,000 over
      await expenses.add(spend(2, 50000, mood: Mood.worth));
      await expenses.add(spend(4, 3000000)); // Unexpected 7,500 over
      await expenses.add(spend(4, 100000, mood: Mood.regret));

      final s = await reflections.load(nov.id);
      expect(s.spent, 7550000);
      expect(s.savedAmount, 15000000 - 4000000 - 7550000); // 34,500
      expect(s.goalMet, isTrue);
      expect(s.regrets.map((e) => e.amount), [2400000, 100000]);
      expect(s.worthIt.single.amount, 50000);
      expect(s.biggestOvershoot, (pillarId: 4, overBy: 850000));
      expect(s.isFirstReflection, isTrue);
    });

    test('a missed goal says by how much and suggests a smaller one', () async {
      final nov = await plannedNovember();
      await expenses.add(spend(1, 9750000)); // saved 12,500 of 20,000
      final s = await reflections.load(nov.id);
      expect(s.goalMet, isFalse);
      expect(s.missedBy, 750000);
      expect(s.suggestedGoal, 1200000);
      expect(s.biggestOvershoot, (pillarId: 1, overBy: 7500000));
    });

    test('completing shows the improvement next month; a draft does not', () async {
      final nov = await plannedNovember();
      final dec = await periods.ensureCurrentPeriod(now: DateTime(2026, 12, 2));

      await reflections.saveDraft(ReflectionDraft(periodId: nov.id, improvement: 'Cook more'));
      expect(await periods.watchImprovementFor(dec).first, isNull);

      await reflections.complete(
        ReflectionDraft(
          periodId: nov.id,
          answer1: 'Yes',
          improvementKept: ImprovementKept.partly,
          improvement: ' Cook more ',
        ),
      );
      expect(await periods.watchImprovementFor(dec).first, 'Cook more');

      final row = await db.select(db.reflections).getSingle();
      expect(row.answerQ1, 'Yes');
      expect(row.prevImprovementKept, 'partly');
      expect(row.completedAt, isNotNull);

      final decSummary = await reflections.load(dec.id);
      expect(decSummary.previousImprovement, 'Cook more');
      expect(decSummary.isFirstReflection, isFalse);
    });

    test('after completion the totals are frozen and edits are tracked (FR-58)', () async {
      final nov = await plannedNovember();
      final id = await expenses.add(spend(1, 1000000));
      await periods.ensureCurrentPeriod(now: DateTime(2026, 12, 2));
      await reflections.complete(ReflectionDraft(periodId: nov.id));
      final frozen = (await reflections.load(nov.id)).savedAmount;

      await expenses.add(spend(2, 50000));
      await expenses.softDelete(id);
      final s = await reflections.load(nov.id);
      expect(s.savedAmount, frozen);
      expect(s.saved!.editedAfterClose, 50000 - 1000000);

      await expenses.restore(id);
      expect((await reflections.load(nov.id)).saved!.editedAfterClose, 50000);
    });
  });

  group('WeekMath', () {
    final nov = DateRange(DateTime(2026, 11, 1), DateTime(2026, 11, 30));

    test('Monday weeks are clipped to the period', () {
      // 1 Nov 2026 is a Sunday.
      expect(
        WeekMath.weekContaining(DateTime(2026, 11, 1), DateTime.monday, nov),
        DateRange(DateTime(2026, 11, 1), DateTime(2026, 11, 1)),
      );
      expect(
        WeekMath.weekContaining(DateTime(2026, 11, 4), DateTime.monday, nov),
        DateRange(DateTime(2026, 11, 2), DateTime(2026, 11, 8)),
      );
      expect(
        WeekMath.weekContaining(DateTime(2026, 11, 30), DateTime.monday, nov),
        DateRange(DateTime(2026, 11, 30), DateTime(2026, 11, 30)),
      );
    });

    test('Sunday weeks and the previous week', () {
      final week = WeekMath.weekContaining(DateTime(2026, 11, 4), DateTime.sunday, nov);
      expect(week, DateRange(DateTime(2026, 11, 1), DateTime(2026, 11, 7)));
      expect(WeekMath.previous(week, DateTime.sunday, nov), isNull);
      final later = WeekMath.weekContaining(DateTime(2026, 11, 12), DateTime.sunday, nov);
      expect(WeekMath.previous(later, DateTime.sunday, nov), week);
    });
  });

  test('check-ins: one per week, the note is replaced, the week is totalled', () async {
    final nov = await plannedNovember();
    final week = DateRange(DateTime(2026, 11, 2), DateTime(2026, 11, 8));
    expect(await checkins.watchWeek(nov.id, week.start).first, isNull);

    await checkins.save(nov.id, week.start, ' Watch food delivery ');
    await checkins.save(nov.id, week.start, 'On track');
    final rows = await db.select(db.weeklyCheckins).get();
    expect(rows.single.note, 'On track');
    expect(rows.single.weekStart, '2026-11-02');

    await expenses.add(spend(1, 10000, date: '2026-11-01'));
    await expenses.add(spend(1, 20000, date: '2026-11-03'));
    await expenses.add(spend(2, 5000, date: '2026-11-08'));
    expect(await checkins.watchWeekTotals(nov.id, week).first, {1: 20000, 2: 5000});
  });
}
