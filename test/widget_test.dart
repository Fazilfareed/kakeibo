import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/app/app.dart';
import 'package:kakeibo/core/db/app_database.dart';
import 'package:kakeibo/core/pillars/pillars_provider.dart';
import 'package:kakeibo/features/settings/data/settings_repository.dart';

// Widget tests use fake data streams: a real SQLite database does real I/O,
// which never completes inside the widget-test fake-async zone.
const _pillars = [
  Pillar(id: 1, name: 'Needs', icon: 'house', sortOrder: 1),
  Pillar(id: 2, name: 'Wants', icon: 'shopping_bag', sortOrder: 2),
  Pillar(id: 3, name: 'Culture', icon: 'menu_book', sortOrder: 3),
  Pillar(id: 4, name: 'Unexpected', icon: 'bolt', sortOrder: 4),
];

Widget _app({Map<String, String>? settings}) => ProviderScope(
      overrides: [
        pillarsProvider.overrideWith((ref) => Stream.value(_pillars)),
        settingsProvider.overrideWith(
          (ref) => Stream.value(settings ?? AppDatabase.defaultSettings),
        ),
      ],
      child: const KakeiboApp(),
    );

void main() {
  testWidgets('app shell shows dashboard, pillars and switches tabs', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Left to spend'), findsOneWidget);
    for (final p in _pillars) {
      expect(find.text(p.name), findsOneWidget);
    }
    expect(find.byTooltip('Add expense'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Spends'));
    await tester.pumpAndSettle();
    expect(find.text('No expenses yet'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Currency format'), findsOneWidget);
    expect(find.textContaining('Rs 12,500.00'), findsOneWidget);
  });

  testWidgets('settings preview follows the saved symbol format', (tester) async {
    await tester.pumpWidget(_app(settings: {
      ...AppDatabase.defaultSettings,
      'currency_symbol': 'LKR',
      'currency_symbol_position': 'after',
    }));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    expect(find.textContaining('12,500.00 LKR'), findsOneWidget);
  });
}
