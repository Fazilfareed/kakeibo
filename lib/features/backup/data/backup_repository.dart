import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../../core/date/local_date.dart';
import '../../../core/db/app_database.dart';
import '../../../core/money/money_formatter.dart';

/// Why a backup file was refused (FR-74).
class BackupFormatException implements Exception {
  const BackupFormatException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Backups (PRD §11.4), restore (FR-71, FR-74), CSV export (FR-70, FR-75)
/// and delete-all (FR-72). Restore always replaces everything; it never merges.
class BackupRepository {
  BackupRepository(this._db, {required this.snapshotDir});

  final AppDatabase _db;

  /// Where safety snapshots are kept before a restore or delete-all.
  final Future<Directory> Function() snapshotDir;

  static const appId = 'kakeibo';

  /// Settings key: when the last backup was made (UTC ISO 8601).
  static const lastBackupKey = 'last_backup_at';
  static const keepSnapshots = 3;

  // ---------------------------------------------------------------- backup

  Future<Map<String, Object?>> toJson() async {
    final periods = await (_db.select(_db.periods)..orderBy([(x) => OrderingTerm.asc(x.id)])).get();

    /// All rows of a table as JSON, grouped by period id.
    Map<int, List<Map<String, dynamic>>> byPeriod<T>(
      List<T> rows,
      int Function(T) periodId,
      Map<String, dynamic> Function(T) toJson,
    ) {
      final out = <int, List<Map<String, dynamic>>>{};
      for (final r in rows) {
        (out[periodId(r)] ??= []).add(toJson(r));
      }
      return out;
    }

    final incomes = byPeriod(
      await _db.select(_db.incomes).get(),
      (r) => r.periodId,
      (r) => r.toJson(),
    );
    final fixed = byPeriod(
      await _db.select(_db.fixedCosts).get(),
      (r) => r.periodId,
      (r) => r.toJson(),
    );
    final budgets = byPeriod(
      await _db.select(_db.pillarBudgets).get(),
      (r) => r.periodId,
      (r) => r.toJson(),
    );
    final expenses = byPeriod(
      await _db.select(_db.expenses).get(),
      (r) => r.periodId,
      (r) => r.toJson(),
    );
    final changes = byPeriod(
      await _db.select(_db.planChanges).get(),
      (r) => r.periodId,
      (r) => r.toJson(),
    );
    final checkins = byPeriod(
      await _db.select(_db.weeklyCheckins).get(),
      (r) => r.periodId,
      (r) => r.toJson(),
    );
    final reflections = {
      for (final r in await _db.select(_db.reflections).get()) r.periodId: r.toJson(),
    };

    return {
      'app': appId,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'settings': {for (final s in await _db.select(_db.settings).get()) s.key: s.value},
      'pillars': [for (final r in await _db.select(_db.pillars).get()) r.toJson()],
      'paymentMethods': [for (final r in await _db.select(_db.paymentMethods).get()) r.toJson()],
      'periods': [
        for (final x in periods)
          {
            ...x.toJson(),
            'incomes': incomes[x.id] ?? const [],
            'fixedCosts': fixed[x.id] ?? const [],
            'pillarBudgets': budgets[x.id] ?? const [],
            'expenses': expenses[x.id] ?? const [],
            'planChanges': changes[x.id] ?? const [],
            'reflection': reflections[x.id],
            'checkins': checkins[x.id] ?? const [],
          },
      ],
    };
  }

  Future<String> encode() async => const JsonEncoder.withIndent(' ').convert(await toJson());

  /// Sorts by name in time order: kakeibo-backup-2026-11-04-1747.json.
  static String fileName([DateTime? now, String prefix = 'kakeibo-backup-']) {
    final t = now ?? DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '$prefix${LocalDate.format(t)}-${two(t.hour)}${two(t.minute)}.json';
  }

  // --------------------------------------------------------------- restore

  /// Checks the file without touching any data. Returns how many months and
  /// spends it holds, for the confirmation dialog.
  ({int months, int spends, DateTime? exportedAt}) inspect(String text) {
    final json = _parse(text);
    final periods = json['periods'] as List<dynamic>;
    // Deleted spends are kept in the file (for undo) but not counted.
    final spends = periods.fold<int>(
      0,
      (a, p) =>
          a +
          _list((p as Map<String, dynamic>)['expenses'])
              .where((e) => e['deletedAt'] == null)
              .length,
    );
    return (
      months: periods.length,
      spends: spends,
      exportedAt: DateTime.tryParse(json['exportedAt'] as String? ?? ''),
    );
  }

  /// Saves a safety snapshot of the current data, then replaces everything
  /// with the file's contents in one transaction.
  Future<void> restore(String text) async {
    final json = _parse(text);
    await saveSnapshot('before-restore');
    await _db.transaction(() async {
      await _deleteEverything();
      await _db.batch((b) {
        b.insertAll(_db.pillars, [
          for (final r in json['pillars'] as List<dynamic>) Pillar.fromJson(_map(r)),
        ]);
        b.insertAll(_db.paymentMethods, [
          for (final r in json['paymentMethods'] as List<dynamic>? ?? const [])
            PaymentMethod.fromJson(_map(r)),
        ]);
        // The restored file is itself a backup, so it counts as the last one.
        final settings = {..._map(json['settings'])};
        final exportedAt = json['exportedAt'];
        if (exportedAt is String && DateTime.tryParse(exportedAt) != null) {
          settings[lastBackupKey] = exportedAt;
        }
        b.insertAll(_db.settings, [
          for (final e in settings.entries)
            SettingsCompanion.insert(key: e.key, value: '${e.value}'),
        ]);
        final periods = [for (final r in json['periods'] as List<dynamic>) _map(r)];
        b.insertAll(_db.periods, [for (final r in periods) Period.fromJson(r)]);
        for (final r in periods) {
          b.insertAll(_db.incomes, [for (final x in _list(r['incomes'])) Income.fromJson(x)]);
          b.insertAll(_db.fixedCosts, [
            for (final x in _list(r['fixedCosts'])) FixedCost.fromJson(x),
          ]);
          b.insertAll(_db.pillarBudgets, [
            for (final x in _list(r['pillarBudgets'])) PillarBudget.fromJson(x),
          ]);
          b.insertAll(_db.planChanges, [
            for (final x in _list(r['planChanges'])) PlanChange.fromJson(x),
          ]);
          if (r['reflection'] != null) {
            b.insert(_db.reflections, Reflection.fromJson(_map(r['reflection'])));
          }
          b.insertAll(_db.weeklyCheckins, [
            for (final x in _list(r['checkins'])) WeeklyCheckin.fromJson(x),
          ]);
        }
        // Refunds point at earlier expenses, so insert in id order.
        final expenses = [
          for (final r in periods)
            for (final x in _list(r['expenses'])) Expense.fromJson(x),
        ]..sort((a, b) => a.id.compareTo(b.id));
        b.insertAll(_db.expenses, expenses);
      });
    });
  }

  Map<String, dynamic> _parse(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const BackupFormatException("This file isn't a Kakeibo backup.");
    }
    if (decoded is! Map<String, dynamic> || decoded['app'] != appId) {
      throw const BackupFormatException("This file isn't a Kakeibo backup.");
    }
    final version = decoded['schemaVersion'];
    if (version is! int) {
      throw const BackupFormatException('This backup is damaged: it has no version.');
    }
    if (version > _db.schemaVersion) {
      throw const BackupFormatException(
        'This backup was made by a newer version of Kakeibo. Update the app, then try again.',
      );
    }
    if (decoded['periods'] is! List || decoded['pillars'] is! List || decoded['settings'] is! Map) {
      throw const BackupFormatException('This backup is damaged and some data is missing.');
    }
    return decoded;
  }

  static Map<String, dynamic> _map(Object? o) => Map<String, dynamic>.from(o! as Map);
  static List<Map<String, dynamic>> _list(Object? o) => [
    for (final x in (o as List<dynamic>? ?? const [])) _map(x),
  ];

  // ------------------------------------------------------------ delete all

  /// FR-72: removes everything, then puts back the default pillars, payment
  /// methods and settings. A safety snapshot is kept first.
  Future<void> deleteAll() async {
    await saveSnapshot('before-delete');
    await _db.transaction(() async {
      await _deleteEverything();
      await _db.seedDefaults();
    });
  }

  Future<void> _deleteEverything() async {
    // Children first; pillars and payment methods are restricted.
    for (final table in <TableInfo<Table, dynamic>>[
      _db.expenses,
      _db.planChanges,
      _db.reflections,
      _db.weeklyCheckins,
      _db.pillarBudgets,
      _db.incomes,
      _db.fixedCosts,
      _db.periods,
      _db.paymentMethods,
      _db.pillars,
      _db.settings,
    ]) {
      await _db.delete(table).go();
    }
  }

  // ------------------------------------------------------------- snapshots

  /// Writes the current data to app-private storage, keeping the newest
  /// [keepSnapshots] files. Returns the file.
  Future<File> saveSnapshot(String reason) async {
    final dir = Directory(p.join((await snapshotDir()).path, 'snapshots'));
    await dir.create(recursive: true);
    final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
    final file = File(p.join(dir.path, '$reason-$stamp.json'));
    await file.writeAsString(await encode());
    final old = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json')).toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    for (final f in old.skip(keepSnapshots)) {
      await f.delete();
    }
    return file;
  }

  // ------------------------------------------------------------------- CSV

  /// FR-70: every visible spend, oldest first.
  Future<String> exportCsv() async {
    final pillars = {for (final x in await _db.select(_db.pillars).get()) x.id: x.name};
    final methods = {for (final x in await _db.select(_db.paymentMethods).get()) x.id: x.name};
    final expenses =
        await (_db.select(_db.expenses)
              ..where((e) => e.deletedAt.isNull())
              ..orderBy([(e) => OrderingTerm.asc(e.date), (e) => OrderingTerm.asc(e.id)]))
            .get();
    final out = StringBuffer()
      ..writeln(
        ['Date', 'Pillar', 'Amount (LKR)', 'Type', 'Note', 'Mood', 'Payment method'].join(','),
      );
    for (final e in expenses) {
      final signed = e.type == 'refund' ? -e.amount : e.amount;
      out.writeln(
        [
          e.date,
          pillars[e.pillarId] ?? '',
          _plainAmount(signed),
          e.type,
          e.note ?? '',
          e.mood ?? '',
          methods[e.paymentMethodId] ?? '',
        ].map(csvCell).join(','),
      );
    }
    return out.toString();
  }

  /// Amounts in the CSV are plain numbers ("1850.00"), so spreadsheets can sum
  /// them; the user's symbol format is for the screen only.
  static String _plainAmount(int cents) {
    final sign = cents < 0 ? '-' : '';
    final abs = cents.abs();
    final minor = (abs % MoneyFormatter.minorPerMajor).toString().padLeft(2, '0');
    return '$sign${abs ~/ MoneyFormatter.minorPerMajor}.$minor';
  }

  /// FR-75: quotes cells that need it, and stops text that starts with
  /// = + - @ (or a tab / carriage return) being run as a spreadsheet formula.
  /// Numbers such as "-150.00" stay numbers.
  static String csvCell(String value) {
    var v = value;
    final isNumber = RegExp(r'^-?\d+(\.\d+)?$').hasMatch(v);
    if (!isNumber && v.isNotEmpty && '=+-@\t\r'.contains(v[0])) v = "'$v";
    if (v.contains(RegExp('[",\n\r]')) || v != v.trim()) {
      v = '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  static String csvFileName([DateTime? now]) =>
      'kakeibo-spends-${LocalDate.format(now ?? DateTime.now())}.csv';
}
