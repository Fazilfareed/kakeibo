import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../money/currency_format.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Pillars,
    Periods,
    Incomes,
    FixedCosts,
    PillarBudgets,
    PaymentMethods,
    Expenses,
    PlanChanges,
    Reflections,
    WeeklyCheckins,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens `kakeibo.db` in app-private storage on a background isolate.
  factory AppDatabase.open() => AppDatabase(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Default pillars, payment methods and settings for a fresh install.
  Future<void> _seed() async {
    await batch((b) {
      b.insertAll(pillars, const [
        PillarsCompanion(
          id: Value(1),
          name: Value('Needs'),
          icon: Value('houseLine'),
          sortOrder: Value(1),
        ),
        PillarsCompanion(
          id: Value(2),
          name: Value('Wants'),
          icon: Value('shoppingBag'),
          sortOrder: Value(2),
        ),
        PillarsCompanion(
          id: Value(3),
          name: Value('Culture'),
          icon: Value('bookOpen'),
          sortOrder: Value(3),
        ),
        PillarsCompanion(
          id: Value(4),
          name: Value('Unexpected'),
          icon: Value('lightning'),
          sortOrder: Value(4),
        ),
      ]);
      b.insertAll(paymentMethods, const [
        PaymentMethodsCompanion(name: Value('Cash'), icon: Value('money'), sortOrder: Value(1)),
        PaymentMethodsCompanion(
          name: Value('Card'),
          icon: Value('creditCard'),
          sortOrder: Value(2),
        ),
        PaymentMethodsCompanion(
          name: Value('Bank transfer'),
          icon: Value('bank'),
          sortOrder: Value(3),
        ),
        PaymentMethodsCompanion(name: Value('LankaQR'), icon: Value('qrCode'), sortOrder: Value(4)),
      ]);
      b.insertAll(settings, [
        for (final e in defaultSettings.entries)
          SettingsCompanion(key: Value(e.key), value: Value(e.value)),
      ]);
    });
  }

  /// Settings written on first launch (PRD §11.2).
  static final Map<String, String> defaultSettings = {
    'currency_code': CurrencyFormat.currencyCode,
    ...const CurrencyFormat().toSettings(),
    'theme': 'system',
    'month_start_day': '1',
    'week_start_day': '1',
  };
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'kakeibo.db'));
    return NativeDatabase.createInBackground(file);
  });
}
