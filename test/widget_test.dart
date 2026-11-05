import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/app/app.dart';
import 'package:kakeibo/app/theme/app_theme.dart';
import 'package:kakeibo/core/date/local_date.dart';
import 'package:kakeibo/core/db/app_database.dart';
import 'package:kakeibo/core/money/money_text.dart';
import 'package:kakeibo/core/pillars/pillars_provider.dart';
import 'package:kakeibo/features/backup/data/auto_backup.dart';
import 'package:kakeibo/features/backup/data/backup_providers.dart';
import 'package:kakeibo/features/backup/data/backup_repository.dart';
import 'package:kakeibo/features/checkin/data/checkin_providers.dart';
import 'package:kakeibo/features/checkin/data/checkin_repository.dart';
import 'package:kakeibo/features/expenses/data/expense_providers.dart';
import 'package:kakeibo/features/expenses/data/expense_repository.dart';
import 'package:kakeibo/features/guide/domain/guide_state.dart';
import 'package:kakeibo/features/guide/presentation/guide_widgets.dart';
import 'package:kakeibo/features/history/data/history_providers.dart';
import 'package:kakeibo/features/lock/data/lock_providers.dart';
import 'package:kakeibo/features/lock/data/lock_repository.dart';
import 'package:kakeibo/features/lock/presentation/pin_pad.dart';
import 'package:kakeibo/features/reminders/data/reminder_providers.dart';
import 'package:kakeibo/features/stats/data/stats_providers.dart';
import 'package:kakeibo/features/history/data/history_repository.dart';
import 'package:kakeibo/features/periods/data/period_providers.dart';
import 'package:kakeibo/features/periods/domain/period_math.dart';
import 'package:kakeibo/features/periods/domain/period_summary.dart';
import 'package:kakeibo/features/dashboard/presentation/widgets/savings_ring.dart';
import 'package:kakeibo/features/reflection/data/reflection_providers.dart';
import 'package:kakeibo/features/reflection/data/reflection_repository.dart';
import 'package:kakeibo/features/reflection/domain/reflection_summary.dart';
import 'package:kakeibo/features/settings/data/settings_repository.dart';
import 'package:mocktail/mocktail.dart';

// Widget tests use fake data streams: a real SQLite database does real I/O,
// which never completes inside the widget-test fake-async zone.
const _pillars = [
  Pillar(id: 1, name: 'Needs', icon: 'house', sortOrder: 1),
  Pillar(id: 2, name: 'Wants', icon: 'shopping_bag', sortOrder: 2),
  Pillar(id: 3, name: 'Culture', icon: 'menu_book', sortOrder: 3),
  Pillar(id: 4, name: 'Unexpected', icon: 'bolt', sortOrder: 4),
];

final _guideSeen = {
  GuideKeys.tourDone: 'true',
  GuideKeys.checklistDismissed: 'true',
  GuideKeys.tipsEnabled: 'false',
  for (final s in CoachScreen.values) GuideKeys.coachSeen(s): 'true',
};

class _MockExpenses extends Mock implements ExpenseRepository {}

class _FakeDraft extends Fake implements ExpenseDraft {}

class _MockReflections extends Mock implements ReflectionRepository {}

class _FakeReflectionDraft extends Fake implements ReflectionDraft {}

class _MockCheckins extends Mock implements CheckinRepository {}

class _MockSettings extends Mock implements SettingsRepository {}

class _MockBackup extends Mock implements BackupRepository {}

class _MemorySecrets implements SecretStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];
  @override
  Future<void> write(String key, String value) async => _values[key] = value;
  @override
  Future<void> delete(String key) async => _values.remove(key);
}

Period _period({String status = 'active'}) {
  final today = DateTime.now();
  final range = PeriodMath.rangeContaining(today, 1);
  String d(DateTime x) =>
      '${x.year}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}';
  return Period(
    id: 1,
    startDate: d(range.start),
    endDate: d(range.end),
    savingsGoal: 2000000,
    savingsGoalType: 'amount',
    savingsSetAside: true,
    isPartial: false,
    status: status,
    createdAt: '',
    updatedAt: '',
  );
}

PeriodSummary _summary({int spentNeeds = 1000000}) {
  final today = DateTime.now();
  return PeriodSummary(
    income: 15000000,
    fixed: 5000000,
    savingsGoal: 2000000,
    spentByPillar: {1: spentNeeds},
    plannedByPillar: const {1: 4000000, 2: 2000000, 3: 1000000, 4: 1000000},
    range: PeriodMath.rangeContaining(today, 1),
    today: today,
  );
}

Expense _expense(int id, int pillarId, int amount, {String? note}) => Expense(
  id: id,
  periodId: 1,
  pillarId: pillarId,
  amount: amount,
  date: LocalDate.today(),
  note: note,
  type: 'expense',
  isLumpSum: false,
  createdAt: '$id',
  updatedAt: '$id',
);

Widget _app({
  Map<String, String>? settings,
  String status = 'active',
  ExpenseRepository? expenses,
  PeriodSummary? summary,
  List<Expense> spends = const [],
  String? improvement,
  Period? pending,
  ReflectionRepository? reflections,
  ReflectionSummary? reflectionSummary,
  CheckinRepository? checkins,
  Map<int, int> weekTotals = const {},
  List<MonthRecord> history = const [],
  BackupRepository? backup,
  LockRepository? lock,
  SettingsRepository? settingsRepo,
}) {
  final period = _period(status: status);
  final defaultSettingsRepo = _MockSettings();
  when(() => defaultSettingsRepo.set(any(), any())).thenAnswer((_) async {});
  return ProviderScope(
    overrides: [
      ledgerBootstrapProvider.overrideWith((ref) async {}),
      pillarsProvider.overrideWith((ref) => Stream.value(_pillars)),
      // The guide counts as seen, so the tour and coach marks stay out of
      // the way; the guide's own tests turn them back on.
      settingsProvider.overrideWith(
        (ref) => Stream.value({..._guideSeen, ...(settings ?? AppDatabase.defaultSettings)}),
      ),
      currentPeriodProvider.overrideWith((ref) => Stream.value(period)),
      currentSummaryProvider.overrideWithValue(summary ?? _summary()),
      currentImprovementProvider.overrideWith((ref) => Stream.value(improvement)),
      periodExpensesProvider.overrideWith((ref, id) => Stream.value(spends)),
      paymentMethodsProvider.overrideWith((ref) => Stream.value(const <PaymentMethod>[])),
      if (expenses != null) expenseRepositoryProvider.overrideWithValue(expenses),
      settingsRepositoryProvider.overrideWithValue(settingsRepo ?? defaultSettingsRepo),
      pendingReflectionProvider.overrideWith((ref) => Stream.value(pending)),
      currentCheckinProvider.overrideWith((ref) => Stream.value(null)),
      currentWeekTotalsProvider.overrideWith((ref) => Stream.value(weekTotals)),
      if (reflections != null) reflectionRepositoryProvider.overrideWithValue(reflections),
      if (reflectionSummary != null)
        reflectionSummaryProvider.overrideWith((ref, id) async => reflectionSummary),
      if (checkins != null) checkinRepositoryProvider.overrideWithValue(checkins),
      historyMonthsProvider.overrideWith((ref) => Stream.value(history)),
      spendDatesProvider.overrideWith((ref) => Stream.value(const <String>[])),
      anyCheckinProvider.overrideWith((ref) => Stream.value(false)),
      reminderSyncProvider.overrideWithValue(null),
      notificationsAllowedProvider.overrideWith((ref) async => true),
      biometricsAvailableProvider.overrideWith((ref) async => false),
      autoBackupRunProvider.overrideWith((ref) async => AutoBackupOutcome.notDue),
      if (lock != null) lockRepositoryProvider.overrideWithValue(lock),
      if (backup != null) backupRepositoryProvider.overrideWithValue(backup),
    ],
    child: const KakeiboApp(),
  );
}

/// Phone-sized test screen (about the size of the Infinix X6812).
void _phoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeDraft());
    registerFallbackValue(_FakeReflectionDraft());
    registerFallbackValue(DateTime(2000));
  });

  testWidgets('dashboard shows what is left and the pillars', (tester) async {
    _phoneScreen(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Left to spend'), findsOneWidget);
    // Spendable 80,000 − spent 10,000 = 70,000 left.
    expect(find.byWidgetPredicate((w) => w is MoneyText && w.cents == 7000000), findsOneWidget);
    for (final p in _pillars) {
      expect(find.text(p.name), findsOneWidget);
    }
    await tester.scrollUntilVisible(find.text('Edit plan'), 200);
    expect(find.text('Edit plan'), findsOneWidget);
  });

  testWidgets('unplanned month shows the plan prompt', (tester) async {
    _phoneScreen(tester);
    await tester.pumpWidget(_app(status: 'planning'));
    await tester.pumpAndSettle();
    expect(find.text('Plan'), findsOneWidget);
  });

  testWidgets('tabs switch and the settings preview follows the symbol format', (tester) async {
    _phoneScreen(tester);
    await tester.pumpWidget(
      _app(
        settings: {
          ...AppDatabase.defaultSettings,
          'currency_symbol': 'LKR',
          'currency_symbol_position': 'after',
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Spends'));
    await tester.pumpAndSettle();
    expect(find.text('No expenses yet'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    expect(find.textContaining('12,500.00 LKR'), findsOneWidget);
  });

  testWidgets('quick add: amount, pillar, save in three taps', (tester) async {
    _phoneScreen(tester);
    final repo = _MockExpenses();
    when(() => repo.recentNotes()).thenAnswer((_) async => ['Groceries']);
    when(() => repo.add(any())).thenAnswer((_) async => 7);

    await tester.pumpWidget(_app(expenses: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add expense'));
    // The caret blinks forever, so wait a fixed time instead of settling.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Choose a pillar'), findsOneWidget);

    for (final k in ['2', '4', '0']) {
      await tester.tap(find.text(k).last);
    }
    await tester.tap(find.bySemanticsLabel('Needs').last);
    await tester.pump();
    expect(find.text('Save'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final saved = verify(() => repo.add(captureAny())).captured.single as ExpenseDraft;
    expect(saved.amount, 24000);
    expect(saved.pillarId, 1);
    expect(find.text('Saved Rs 240.00 to Needs'), findsOneWidget);
  });

  testWidgets('dashboard shows the savings ring, saved stamp and recent spends', (tester) async {
    _phoneScreen(tester);
    await tester.pumpWidget(
      _app(
        spends: [
          _expense(2, 2, 18000, note: 'Lunch'),
          _expense(1, 1, 4000, note: 'Bus'),
        ],
        improvement: 'No food delivery',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SavingsRing), findsOneWidget);
    expect(find.text('saved'), findsOneWidget);
    expect(find.text('No food delivery'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Bus'), 200);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text(' · 2 entries'), findsOneWidget);
  });

  testWidgets('overspend shows how far over and the reduced savings (FR-35)', (tester) async {
    _phoneScreen(tester);
    // Spendable 80,000; spent 81,500 → over by 1,500, savings 18,500.
    await tester.pumpWidget(_app(summary: _summary(spentNeeds: 8150000)));
    await tester.pumpAndSettle();

    expect(find.text('Over this month'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is MoneyText && w.cents == 150000), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is MoneyText && w.cents == 1850000), findsWidgets);
    expect(find.text(' a day keeps you on track'), findsNothing);
    // Needs: 81,500 spent of 40,000 planned.
    expect(find.text('+Rs 41,500 over'), findsOneWidget);
    expect(find.text('saved'), findsNothing);
  });

  testWidgets('tapping a pillar bar opens its spends', (tester) async {
    _phoneScreen(tester);
    await tester.pumpWidget(_app(spends: [_expense(1, 1, 4000, note: 'Bus')]));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel(RegExp(r'^Wants, ')));
    await tester.pumpAndSettle();
    expect(find.text('Spends'), findsWidgets);
    expect(find.text('Nothing in this pillar'), findsOneWidget);
  });

  testWidgets('adding a note closes the dialog without crashing', (tester) async {
    _phoneScreen(tester);
    final repo = _MockExpenses();
    when(() => repo.recentNotes()).thenAnswer((_) async => const <String>[]);
    await tester.pumpWidget(_app(expenses: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add expense'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Add note'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField), 'Lunch');
    await tester.tap(find.text('Done'));
    // Run the dialog's exit animation to the end.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.takeException(), isNull);
    expect(find.text('Lunch'), findsOneWidget);
  });

  group('M3 ritual', () {
    const october = Period(
      id: 9,
      startDate: '2026-10-01',
      endDate: '2026-10-31',
      savingsGoal: 1500000,
      savingsGoalType: 'amount',
      savingsSetAside: true,
      isPartial: false,
      status: 'closed',
      createdAt: '',
      updatedAt: '',
    );
    Expense tagged(int id, int pillar, int amount, String note, String mood) => Expense(
      id: id,
      periodId: 9,
      pillarId: pillar,
      amount: amount,
      date: '2026-10-10',
      note: note,
      mood: mood,
      type: 'expense',
      isLumpSum: false,
      createdAt: '',
      updatedAt: '',
    );
    final octoberSummary = ReflectionSummary(
      period: october,
      income: 12000000,
      fixed: 4000000,
      spentByPillar: const {1: 3250000, 2: 1350000, 3: 780000, 4: 1620000},
      plannedByPillar: const {1: 3000000, 2: 1500000, 3: 1000000, 4: 1000000},
      worthIt: [tagged(1, 3, 600000, 'Concert ticket', 'worth')],
      regrets: [tagged(2, 2, 850000, 'New shoes', 'regret')],
      previousImprovement: 'No food delivery',
      isFirstReflection: true,
    );

    /// The text fields' caret blinks for ever, so pump a fixed time.
    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    testWidgets('a finished month opens its reflection; Finish saves every answer', (tester) async {
      _phoneScreen(tester);
      final repo = _MockReflections();
      when(() => repo.saveDraft(any())).thenAnswer((_) async {});
      when(() => repo.complete(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        _app(pending: october, reflections: repo, reflectionSummary: octoberSummary),
      );
      await settle(tester);

      // FR-50: opened by itself, starting with the month in numbers (FR-51, FR-59).
      expect(find.text('Reflect on October'), findsOneWidget);
      expect(find.text('You saved'), findsOneWidget);
      expect(find.text('Rs 5,000 short of your Rs 15,000 goal.'), findsOneWidget);
      expect(find.textContaining('Unexpected went Rs 6,200 over its plan.'), findsOneWidget);
      expect(find.textContaining('try a goal of Rs 10,000'), findsOneWidget);
      // Costs show a plain minus, not the red negative style.
      expect(find.text('− '), findsNWidgets(2));

      await tester.tap(find.text('Next'));
      await settle(tester);
      expect(find.text(ReflectionQuestions.q1), findsOneWidget);
      expect(find.text(ReflectionQuestions.why1), findsOneWidget, reason: 'first reflection');
      await tester.enterText(find.byType(TextField), 'Missed it by a little');

      await tester.tap(find.text('Next'));
      await settle(tester);
      await tester.tap(find.text('Next'));
      await settle(tester);
      // FR-53: tagged spends.
      expect(find.text(ReflectionQuestions.q3), findsOneWidget);
      expect(find.text('New shoes'), findsOneWidget);
      expect(find.text('Concert ticket'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await settle(tester);
      // FR-57: last month's improvement first.
      expect(find.text('“No food delivery”'), findsOneWidget);
      await tester.tap(find.text('Partly'));
      await tester.pump();

      await tester.tap(find.text('Next'));
      await settle(tester);
      expect(find.text(ReflectionQuestions.q4), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Cook at home on weekdays');
      await tester.tap(find.text('Finish'));
      await settle(tester);

      final draft = verify(() => repo.complete(captureAny())).captured.single as ReflectionDraft;
      expect(draft.periodId, 9);
      expect(draft.answer1, 'Missed it by a little');
      expect(draft.improvementKept, ImprovementKept.partly);
      expect(draft.improvement, 'Cook at home on weekdays');
      verify(() => repo.saveDraft(any())).called(greaterThanOrEqualTo(4));
      expect(find.text('Reflection saved. Your improvement is on Home.'), findsOneWidget);
    });

    testWidgets('once opened, a pending reflection waits as a Home card', (tester) async {
      _phoneScreen(tester);
      await tester.pumpWidget(
        _app(
          pending: october,
          reflectionSummary: octoberSummary,
          settings: {...AppDatabase.defaultSettings, 'reflection_prompted_period': '9'},
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Reflect on October'), findsNothing);
      expect(find.text('October has ended. Take five quiet minutes to reflect.'), findsOneWidget);

      await tester.tap(find.text('Reflect'));
      await settle(tester);
      expect(find.text('Reflect on October'), findsOneWidget);
    });

    testWidgets('weekly check-in shows the week by pillar and saves the note', (tester) async {
      _phoneScreen(tester);
      final repo = _MockCheckins();
      when(() => repo.save(any(), any(), any())).thenAnswer((_) async {});
      await tester.pumpWidget(_app(checkins: repo, weekTotals: const {1: 240000, 2: 60000}));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Weekly check-in'), 200);
      await tester.tap(find.text('Weekly check-in'));
      await tester.pumpAndSettle();
      expect(find.text('This week you spent'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is MoneyText && w.cents == 300000), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Watch eating out');
      await tester.tap(find.text('Save check-in'));
      await settle(tester);
      final args = verify(() => repo.save(1, captureAny(), 'Watch eating out')).captured;
      expect(args.single, isA<DateTime>());
      expect(find.text('Check-in saved. See you next week.'), findsOneWidget);
    });
  });

  group('M4 insights', () {
    Period month(int id, String start, String end, {String status = 'closed'}) => Period(
      id: id,
      startDate: start,
      endDate: end,
      savingsGoal: 1500000,
      savingsGoalType: 'amount',
      savingsSetAside: true,
      isPartial: false,
      status: status,
      createdAt: '',
      updatedAt: '',
    );
    Reflection done(int periodId, int saved) => Reflection(
      periodId: periodId,
      savedAmount: saved,
      goalMet: saved >= 1500000,
      answerQ1: 'Missed it by a little',
      improvement: 'Cook at home',
      completedAt: '2026-11-01T00:00:00Z',
      editedAfterClose: 25000,
    );
    final records = [
      MonthRecord(
        period: month(3, '2026-11-01', '2026-11-30', status: 'active'),
        income: 15000000,
        fixed: 4000000,
        spentByPillar: const {1: 100000},
        reflection: null,
      ),
      MonthRecord(
        period: month(2, '2026-10-01', '2026-10-31'),
        income: 12000000,
        fixed: 4000000,
        spentByPillar: const {1: 3250000, 2: 1350000, 3: 780000, 4: 1620000},
        reflection: done(2, 1000000),
      ),
      MonthRecord(
        period: month(1, '2026-09-01', '2026-09-30'),
        income: 12000000,
        fixed: 4000000,
        spentByPillar: const {1: 5000000},
        reflection: null,
      ),
    ];

    testWidgets('History shows lifetime savings, charts and month cards', (tester) async {
      _phoneScreen(tester);
      await tester.pumpWidget(_app(history: records));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('History'));
      await tester.pumpAndSettle();

      // FR-63: October 10,000 (frozen) + September 30,000; November is still open.
      expect(find.text('Saved so far'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is MoneyText && w.cents == 4000000), findsOneWidget);
      expect(find.text('2 months · goal met in 1 of 2'), findsOneWidget);
      expect(find.text('Savings by month'), findsOneWidget);
      expect(find.text('Spending by pillar'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('September 2026'), 300);
      expect(find.text('October 2026'), findsOneWidget);
      expect(find.text('Rs 5,000 short'), findsOneWidget);
      expect(find.text('Goal met'), findsOneWidget);
      expect(find.text('Reflection waiting'), findsOneWidget);
    });

    testWidgets('a month shows its totals, edits after close and the answers', (tester) async {
      _phoneScreen(tester);
      final summary = ReflectionSummary(
        period: month(2, '2026-10-01', '2026-10-31'),
        income: 12000000,
        fixed: 4000000,
        spentByPillar: const {1: 3250000, 2: 1350000, 3: 780000, 4: 1645000},
        plannedByPillar: const {1: 3000000, 2: 1500000, 3: 1000000, 4: 1000000},
        worthIt: const [],
        regrets: const [],
        previousImprovement: null,
        isFirstReflection: false,
        saved: done(2, 1000000),
      );
      await tester.pumpWidget(_app(history: records, reflectionSummary: summary));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('History'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('October 2026'), 300);
      await tester.ensureVisible(find.text('October 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('October 2026'));
      await tester.pumpAndSettle();

      expect(find.text('Rs 5,000 short of the Rs 15,000 goal.'), findsOneWidget);
      expect(find.textContaining('Edited after close: +Rs 250 of spending'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Cook at home'), 300);
      expect(find.text('Missed it by a little'), findsOneWidget);
    });

    testWidgets('delete all data asks twice before deleting', (tester) async {
      _phoneScreen(tester);
      final repo = _MockBackup();
      when(() => repo.deleteAll()).thenAnswer((_) async {});
      await tester.pumpWidget(_app(backup: repo));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Settings'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Delete all data'), 300);
      await tester.ensureVisible(find.text('Delete all data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete all data'));
      await tester.pumpAndSettle();

      expect(find.text('Delete all data?'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure?'), findsOneWidget);
      verifyNever(() => repo.deleteAll());

      await tester.tap(find.text('Delete everything'));
      await tester.pumpAndSettle();
      verify(() => repo.deleteAll()).called(1);
      expect(find.text('All data deleted.'), findsOneWidget);
    });

    testWidgets('cancelling the second question deletes nothing', (tester) async {
      _phoneScreen(tester);
      final repo = _MockBackup();
      await tester.pumpWidget(_app(backup: repo));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Settings'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Delete all data'), 300);
      await tester.ensureVisible(find.text('Delete all data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete all data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      verifyNever(() => repo.deleteAll());
    });
  });

  group('M5 app lock', () {
    LockRepository lockRepo() => LockRepository(
      _MemorySecrets(),
      hasher: (secret, salt) async => '$salt:$secret'.hashCode.toString(),
    );

    Future<void> enter(WidgetTester tester, String pin) async {
      for (final d in pin.split('')) {
        await tester.tap(find.bySemanticsLabel(d).last);
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('a locked app hides Home until the right PIN', (tester) async {
      _phoneScreen(tester);
      final lock = lockRepo();
      await lock.setPin('2580');
      await tester.pumpWidget(
        _app(lock: lock, settings: {...AppDatabase.defaultSettings, 'lock_enabled': 'true'}),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kakeibo is locked'), findsOneWidget);
      expect(find.text('Left to spend'), findsNothing, reason: 'Home is not shown or read out');

      await enter(tester, '1111');
      expect(find.text('Wrong PIN. 4 tries left.'), findsOneWidget);

      await enter(tester, '2580');
      await tester.pumpAndSettle();
      expect(find.text('Kakeibo is locked'), findsNothing);
      expect(find.text('Left to spend'), findsOneWidget);
    });

    testWidgets('forgot PIN: the recovery code leads to a new PIN', (tester) async {
      _phoneScreen(tester);
      final lock = lockRepo();
      final code = await lock.setPin('2580');
      await tester.pumpWidget(
        _app(lock: lock, settings: {...AppDatabase.defaultSettings, 'lock_enabled': 'true'}),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Forgot PIN?'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.enterText(find.byType(TextField), code.toLowerCase());
      await tester.tap(find.text('Continue'));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Choose a PIN'), findsOneWidget);
    });

    testWidgets('turning the lock on walks through PIN and recovery code', (tester) async {
      _phoneScreen(tester);
      final lock = lockRepo();
      await tester.pumpWidget(_app(lock: lock));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Settings'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('App lock'), 300);
      await tester.ensureVisible(find.text('App lock'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('App lock'));
      await tester.pumpAndSettle();

      expect(find.text('Choose a PIN'), findsOneWidget);
      await enter(tester, '1234');
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('Type it again'), findsOneWidget);
      await enter(tester, '1235');
      expect(find.text('The PINs didn’t match. Choose your PIN again.'), findsOneWidget);

      await enter(tester, '1234');
      await tester.tap(find.text('Next'));
      await tester.pump();
      await enter(tester, '1234');
      await tester.pumpAndSettle();
      expect(find.text('Your recovery code'), findsOneWidget);
      final code = tester.widget<SelectableText>(find.byType(SelectableText)).data!;

      await tester.tap(find.text('I’ve written it down'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.enterText(find.byType(TextField), 'WRONG-CODE-0000');
      await tester.tap(find.text('Confirm'));
      await tester.pump();
      expect(find.textContaining('doesn’t match'), findsOneWidget);

      await tester.enterText(find.byType(TextField), code);
      await tester.tap(find.text('Confirm'));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('App lock is on.'), findsOneWidget);
      expect(await lock.checkPin('1234'), isA<Unlocked>());
    });
  });

  testWidgets('screen readers can activate tabs, pillar tiles, bars and PIN keys', (tester) async {
    _phoneScreen(tester);
    final handle = tester.ensureSemantics();
    final repo = _MockExpenses();
    when(() => repo.recentNotes()).thenAnswer((_) async => const <String>[]);
    await tester.pumpWidget(_app(expenses: repo));
    await tester.pumpAndSettle();

    for (final tab in ['Home', 'Spends', 'History', 'Settings']) {
      expect(
        tester.getSemantics(find.bySemanticsLabel(tab).first),
        isSemantics(hasTapAction: true),
      );
    }
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp(r'^Needs, ')).first),
      isSemantics(hasTapAction: true),
    );

    await tester.tap(find.byTooltip('Add expense'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Wants').last),
      isSemantics(hasTapAction: true),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(Brightness.light),
        home: Scaffold(
          body: PinPad(onDigit: (_) {}, onBackspace: () {}),
        ),
      ),
    );
    expect(tester.getSemantics(find.bySemanticsLabel('7')), isSemantics(hasTapAction: true));
    expect(tester.getSemantics(find.bySemanticsLabel('Delete')), isSemantics(hasTapAction: true));
    handle.dispose();
  });

  group('M5b guide', () {
    testWidgets('first run: tour, Skip, setup steps, then the tour is marked done', (tester) async {
      _phoneScreen(tester);
      final settingsRepo = _MockSettings();
      when(() => settingsRepo.set(any(), any())).thenAnswer((_) async {});
      await tester.pumpWidget(
        _app(
          settingsRepo: settingsRepo,
          settings: {...AppDatabase.defaultSettings, GuideKeys.tourDone: 'false'},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('What is Kakeibo?'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Four questions'), findsOneWidget);
      expect(find.bySemanticsLabel('Card 2 of 5'), findsOneWidget);

      // Skip still leads to the required setup (FR-91).
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.text('A few settings'), findsOneWidget);
      expect(find.textContaining('Rs 12,500.00'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Gentle reminders'), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.text('Lock with a PIN?'), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      verify(() => settingsRepo.set(GuideKeys.tourDone, 'true')).called(1);
      verifyNever(() => settingsRepo.set('reminders_on', any()));
    });

    testWidgets('Getting started checklist and tip of the day on Home', (tester) async {
      _phoneScreen(tester);
      await tester.pumpWidget(
        _app(
          settings: {
            ...AppDatabase.defaultSettings,
            GuideKeys.checklistDismissed: 'false',
            GuideKeys.tipsEnabled: 'true',
            'reminders_on': 'true',
          },
          history: [
            MonthRecord(
              period: _period(),
              income: 0,
              fixed: 0,
              spentByPillar: const {},
              reflection: null,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Getting started'), 200);
      expect(find.text('2 of 5'), findsOneWidget, reason: 'planned and reminders on');
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Plan your month, done',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Log your first expense, not done yet',
        ),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(find.text('Kakeibo tip'), 200);
      expect(find.text('Hide tips'), findsOneWidget);
    });

    testWidgets('(?) explains the daily allowance', (tester) async {
      _phoneScreen(tester);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('What is a day keeps you on track?'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Daily allowance = left to spend'), findsOneWidget);
    });

    testWidgets('Help Center search finds the refund answer', (tester) async {
      _phoneScreen(tester);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Settings'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Help Center'), 300);
      await tester.ensureVisible(find.text('Help Center'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Help Center'));
      await tester.pumpAndSettle();
      expect(find.text('Kakeibo basics'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'refund');
      await tester.pump();
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Kakeibo basics'), findsNothing);
      expect(find.text('Questions'), findsOneWidget);
      await tester.tap(find.text('Questions'));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('I started mid-month', findRichText: true), findsOneWidget);
    });
  });
}
