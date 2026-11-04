import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/app/app.dart';
import 'package:kakeibo/core/date/local_date.dart';
import 'package:kakeibo/core/db/app_database.dart';
import 'package:kakeibo/core/money/money_text.dart';
import 'package:kakeibo/core/pillars/pillars_provider.dart';
import 'package:kakeibo/features/expenses/data/expense_providers.dart';
import 'package:kakeibo/features/expenses/data/expense_repository.dart';
import 'package:kakeibo/features/periods/data/period_providers.dart';
import 'package:kakeibo/features/periods/domain/period_math.dart';
import 'package:kakeibo/features/periods/domain/period_summary.dart';
import 'package:kakeibo/features/dashboard/presentation/widgets/savings_ring.dart';
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

class _MockExpenses extends Mock implements ExpenseRepository {}

class _FakeDraft extends Fake implements ExpenseDraft {}

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
}) {
  final period = _period(status: status);
  return ProviderScope(
    overrides: [
      ledgerBootstrapProvider.overrideWith((ref) async {}),
      pillarsProvider.overrideWith((ref) => Stream.value(_pillars)),
      settingsProvider.overrideWith((ref) => Stream.value(settings ?? AppDatabase.defaultSettings)),
      currentPeriodProvider.overrideWith((ref) => Stream.value(period)),
      currentSummaryProvider.overrideWithValue(summary ?? _summary()),
      currentImprovementProvider.overrideWith((ref) => Stream.value(improvement)),
      periodExpensesProvider.overrideWith((ref, id) => Stream.value(spends)),
      paymentMethodsProvider.overrideWith((ref) => Stream.value(const <PaymentMethod>[])),
      if (expenses != null) expenseRepositoryProvider.overrideWithValue(expenses),
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
  setUpAll(() => registerFallbackValue(_FakeDraft()));

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
}
