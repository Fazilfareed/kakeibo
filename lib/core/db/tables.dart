import 'package:drift/drift.dart';

// Schema from PRD §11. Money columns are integer cents; dates are local
// `yyyy-MM-dd` text; timestamps are ISO-8601 UTC text.

/// The four Kakeibo pillars: 1 Needs, 2 Wants, 3 Culture, 4 Unexpected.
class Pillars extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  /// Custom ARGB colour; null means "use the theme's pillar colour".
  IntColumn get color => integer().nullable()();
  TextColumn get icon => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Periods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get startDate => text()();
  TextColumn get endDate => text()();
  IntColumn get savingsGoal => integer().withDefault(const Constant(0))();

  /// `amount` or `percent`.
  TextColumn get savingsGoalType => text().withDefault(const Constant('amount'))();

  /// Basis points (2000 = 20%), used when [savingsGoalType] is `percent`.
  IntColumn get savingsGoalPct => integer().nullable()();
  BoolColumn get savingsSetAside => boolean().withDefault(const Constant(false))();
  BoolColumn get isPartial => boolean().withDefault(const Constant(false))();

  /// `planning`, `active` or `closed`.
  TextColumn get status => text().withDefault(const Constant('planning'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}

@TableIndex(name: 'incomes_period', columns: {#periodId})
class Incomes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get periodId => integer().references(Periods, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();
  IntColumn get amount => integer()();
  TextColumn get date => text()();

  /// True when entered in the plan; false for extra income logged mid-month.
  BoolColumn get isPlanned => boolean().withDefault(const Constant(true))();
}

@TableIndex(name: 'fixed_costs_period', columns: {#periodId})
class FixedCosts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get periodId => integer().references(Periods, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();
  IntColumn get amount => integer()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(true))();
}

class PillarBudgets extends Table {
  IntColumn get periodId => integer().references(Periods, #id, onDelete: KeyAction.cascade)();
  IntColumn get pillarId => integer().references(Pillars, #id, onDelete: KeyAction.restrict)();
  IntColumn get plannedAmount => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {periodId, pillarId};
}

class PaymentMethods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer()();
}

@TableIndex(name: 'expenses_period_date', columns: {#periodId, #date})
@TableIndex(name: 'expenses_period_pillar', columns: {#periodId, #pillarId})
@TableIndex(name: 'expenses_deleted', columns: {#deletedAt})
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get periodId => integer().references(Periods, #id, onDelete: KeyAction.cascade)();
  IntColumn get pillarId => integer().references(Pillars, #id, onDelete: KeyAction.restrict)();

  /// `expense` or `refund` (refunds count as negative spend).
  TextColumn get type => text().withDefault(const Constant('expense'))();
  // Drift's check-constraint idiom refers to the column itself.
  // ignore: recursive_getters
  IntColumn get amount => integer().check(amount.isBiggerThanValue(0))();
  TextColumn get note => text().nullable()();
  TextColumn get date => text()();

  /// `worth`, `neutral`, `regret` or null.
  TextColumn get mood => text().nullable()();
  IntColumn get paymentMethodId =>
      integer().nullable().references(PaymentMethods, #id, onDelete: KeyAction.setNull)();
  IntColumn get refundOfId =>
      integer().nullable().references(Expenses, #id, onDelete: KeyAction.setNull)();
  TextColumn get splitGroupId => text().nullable()();
  BoolColumn get isLumpSum => boolean().withDefault(const Constant(false))();
  TextColumn get deletedAt => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}

class PlanChanges extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get periodId => integer().references(Periods, #id, onDelete: KeyAction.cascade)();
  TextColumn get field => text()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  TextColumn get changedAt => text()();
}

class Reflections extends Table {
  IntColumn get periodId => integer().references(Periods, #id, onDelete: KeyAction.cascade)();
  IntColumn get savedAmount => integer()();
  BoolColumn get goalMet => boolean()();
  TextColumn get answerQ1 => text().nullable()();
  TextColumn get answerQ2 => text().nullable()();
  TextColumn get answerQ3 => text().nullable()();
  TextColumn get answerQ4 => text().nullable()();

  /// `yes`, `partly` or `no`.
  TextColumn get prevImprovementKept => text().nullable()();
  TextColumn get improvement => text().nullable()();
  TextColumn get completedAt => text().nullable()();
  IntColumn get editedAfterClose => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {periodId};
}

class WeeklyCheckins extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get periodId => integer().references(Periods, #id, onDelete: KeyAction.cascade)();
  TextColumn get weekStart => text()();
  TextColumn get note => text().nullable()();
}

/// Key-value app settings (PRD §11.2).
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
