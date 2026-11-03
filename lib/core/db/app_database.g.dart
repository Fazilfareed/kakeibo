// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PillarsTable extends Pillars with TableInfo<$PillarsTable, Pillar> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PillarsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color, icon, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pillars';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pillar> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pillar map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pillar(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $PillarsTable createAlias(String alias) {
    return $PillarsTable(attachedDatabase, alias);
  }
}

class Pillar extends DataClass implements Insertable<Pillar> {
  final int id;
  final String name;

  /// Custom ARGB colour; null means "use the theme's pillar colour".
  final int? color;
  final String icon;
  final int sortOrder;
  const Pillar({
    required this.id,
    required this.name,
    this.color,
    required this.icon,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    map['icon'] = Variable<String>(icon);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PillarsCompanion toCompanion(bool nullToAbsent) {
    return PillarsCompanion(
      id: Value(id),
      name: Value(name),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      icon: Value(icon),
      sortOrder: Value(sortOrder),
    );
  }

  factory Pillar.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pillar(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int?>(json['color']),
      icon: serializer.fromJson<String>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int?>(color),
      'icon': serializer.toJson<String>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Pillar copyWith({
    int? id,
    String? name,
    Value<int?> color = const Value.absent(),
    String? icon,
    int? sortOrder,
  }) => Pillar(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color.present ? color.value : this.color,
    icon: icon ?? this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Pillar copyWithCompanion(PillarsCompanion data) {
    return Pillar(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pillar(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, icon, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pillar &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder);
}

class PillarsCompanion extends UpdateCompanion<Pillar> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> color;
  final Value<String> icon;
  final Value<int> sortOrder;
  const PillarsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  PillarsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
    required String icon,
    required int sortOrder,
  }) : name = Value(name),
       icon = Value(icon),
       sortOrder = Value(sortOrder);
  static Insertable<Pillar> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<String>? icon,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  PillarsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? color,
    Value<String>? icon,
    Value<int>? sortOrder,
  }) {
    return PillarsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PillarsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $PeriodsTable extends Periods with TableInfo<$PeriodsTable, Period> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeriodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savingsGoalMeta = const VerificationMeta(
    'savingsGoal',
  );
  @override
  late final GeneratedColumn<int> savingsGoal = GeneratedColumn<int>(
    'savings_goal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _savingsGoalTypeMeta = const VerificationMeta(
    'savingsGoalType',
  );
  @override
  late final GeneratedColumn<String> savingsGoalType = GeneratedColumn<String>(
    'savings_goal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('amount'),
  );
  static const VerificationMeta _savingsGoalPctMeta = const VerificationMeta(
    'savingsGoalPct',
  );
  @override
  late final GeneratedColumn<int> savingsGoalPct = GeneratedColumn<int>(
    'savings_goal_pct',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savingsSetAsideMeta = const VerificationMeta(
    'savingsSetAside',
  );
  @override
  late final GeneratedColumn<bool> savingsSetAside = GeneratedColumn<bool>(
    'savings_set_aside',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("savings_set_aside" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPartialMeta = const VerificationMeta(
    'isPartial',
  );
  @override
  late final GeneratedColumn<bool> isPartial = GeneratedColumn<bool>(
    'is_partial',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_partial" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planning'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startDate,
    endDate,
    savingsGoal,
    savingsGoalType,
    savingsGoalPct,
    savingsSetAside,
    isPartial,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<Period> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('savings_goal')) {
      context.handle(
        _savingsGoalMeta,
        savingsGoal.isAcceptableOrUnknown(
          data['savings_goal']!,
          _savingsGoalMeta,
        ),
      );
    }
    if (data.containsKey('savings_goal_type')) {
      context.handle(
        _savingsGoalTypeMeta,
        savingsGoalType.isAcceptableOrUnknown(
          data['savings_goal_type']!,
          _savingsGoalTypeMeta,
        ),
      );
    }
    if (data.containsKey('savings_goal_pct')) {
      context.handle(
        _savingsGoalPctMeta,
        savingsGoalPct.isAcceptableOrUnknown(
          data['savings_goal_pct']!,
          _savingsGoalPctMeta,
        ),
      );
    }
    if (data.containsKey('savings_set_aside')) {
      context.handle(
        _savingsSetAsideMeta,
        savingsSetAside.isAcceptableOrUnknown(
          data['savings_set_aside']!,
          _savingsSetAsideMeta,
        ),
      );
    }
    if (data.containsKey('is_partial')) {
      context.handle(
        _isPartialMeta,
        isPartial.isAcceptableOrUnknown(data['is_partial']!, _isPartialMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Period map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Period(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      )!,
      savingsGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}savings_goal'],
      )!,
      savingsGoalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}savings_goal_type'],
      )!,
      savingsGoalPct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}savings_goal_pct'],
      ),
      savingsSetAside: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}savings_set_aside'],
      )!,
      isPartial: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_partial'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PeriodsTable createAlias(String alias) {
    return $PeriodsTable(attachedDatabase, alias);
  }
}

class Period extends DataClass implements Insertable<Period> {
  final int id;
  final String startDate;
  final String endDate;
  final int savingsGoal;

  /// `amount` or `percent`.
  final String savingsGoalType;

  /// Basis points (2000 = 20%), used when [savingsGoalType] is `percent`.
  final int? savingsGoalPct;
  final bool savingsSetAside;
  final bool isPartial;

  /// `planning`, `active` or `closed`.
  final String status;
  final String createdAt;
  final String updatedAt;
  const Period({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.savingsGoal,
    required this.savingsGoalType,
    this.savingsGoalPct,
    required this.savingsSetAside,
    required this.isPartial,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_date'] = Variable<String>(startDate);
    map['end_date'] = Variable<String>(endDate);
    map['savings_goal'] = Variable<int>(savingsGoal);
    map['savings_goal_type'] = Variable<String>(savingsGoalType);
    if (!nullToAbsent || savingsGoalPct != null) {
      map['savings_goal_pct'] = Variable<int>(savingsGoalPct);
    }
    map['savings_set_aside'] = Variable<bool>(savingsSetAside);
    map['is_partial'] = Variable<bool>(isPartial);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  PeriodsCompanion toCompanion(bool nullToAbsent) {
    return PeriodsCompanion(
      id: Value(id),
      startDate: Value(startDate),
      endDate: Value(endDate),
      savingsGoal: Value(savingsGoal),
      savingsGoalType: Value(savingsGoalType),
      savingsGoalPct: savingsGoalPct == null && nullToAbsent
          ? const Value.absent()
          : Value(savingsGoalPct),
      savingsSetAside: Value(savingsSetAside),
      isPartial: Value(isPartial),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Period.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Period(
      id: serializer.fromJson<int>(json['id']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String>(json['endDate']),
      savingsGoal: serializer.fromJson<int>(json['savingsGoal']),
      savingsGoalType: serializer.fromJson<String>(json['savingsGoalType']),
      savingsGoalPct: serializer.fromJson<int?>(json['savingsGoalPct']),
      savingsSetAside: serializer.fromJson<bool>(json['savingsSetAside']),
      isPartial: serializer.fromJson<bool>(json['isPartial']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String>(endDate),
      'savingsGoal': serializer.toJson<int>(savingsGoal),
      'savingsGoalType': serializer.toJson<String>(savingsGoalType),
      'savingsGoalPct': serializer.toJson<int?>(savingsGoalPct),
      'savingsSetAside': serializer.toJson<bool>(savingsSetAside),
      'isPartial': serializer.toJson<bool>(isPartial),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Period copyWith({
    int? id,
    String? startDate,
    String? endDate,
    int? savingsGoal,
    String? savingsGoalType,
    Value<int?> savingsGoalPct = const Value.absent(),
    bool? savingsSetAside,
    bool? isPartial,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) => Period(
    id: id ?? this.id,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    savingsGoal: savingsGoal ?? this.savingsGoal,
    savingsGoalType: savingsGoalType ?? this.savingsGoalType,
    savingsGoalPct: savingsGoalPct.present
        ? savingsGoalPct.value
        : this.savingsGoalPct,
    savingsSetAside: savingsSetAside ?? this.savingsSetAside,
    isPartial: isPartial ?? this.isPartial,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Period copyWithCompanion(PeriodsCompanion data) {
    return Period(
      id: data.id.present ? data.id.value : this.id,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      savingsGoal: data.savingsGoal.present
          ? data.savingsGoal.value
          : this.savingsGoal,
      savingsGoalType: data.savingsGoalType.present
          ? data.savingsGoalType.value
          : this.savingsGoalType,
      savingsGoalPct: data.savingsGoalPct.present
          ? data.savingsGoalPct.value
          : this.savingsGoalPct,
      savingsSetAside: data.savingsSetAside.present
          ? data.savingsSetAside.value
          : this.savingsSetAside,
      isPartial: data.isPartial.present ? data.isPartial.value : this.isPartial,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Period(')
          ..write('id: $id, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('savingsGoal: $savingsGoal, ')
          ..write('savingsGoalType: $savingsGoalType, ')
          ..write('savingsGoalPct: $savingsGoalPct, ')
          ..write('savingsSetAside: $savingsSetAside, ')
          ..write('isPartial: $isPartial, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startDate,
    endDate,
    savingsGoal,
    savingsGoalType,
    savingsGoalPct,
    savingsSetAside,
    isPartial,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Period &&
          other.id == this.id &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.savingsGoal == this.savingsGoal &&
          other.savingsGoalType == this.savingsGoalType &&
          other.savingsGoalPct == this.savingsGoalPct &&
          other.savingsSetAside == this.savingsSetAside &&
          other.isPartial == this.isPartial &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PeriodsCompanion extends UpdateCompanion<Period> {
  final Value<int> id;
  final Value<String> startDate;
  final Value<String> endDate;
  final Value<int> savingsGoal;
  final Value<String> savingsGoalType;
  final Value<int?> savingsGoalPct;
  final Value<bool> savingsSetAside;
  final Value<bool> isPartial;
  final Value<String> status;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const PeriodsCompanion({
    this.id = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.savingsGoal = const Value.absent(),
    this.savingsGoalType = const Value.absent(),
    this.savingsGoalPct = const Value.absent(),
    this.savingsSetAside = const Value.absent(),
    this.isPartial = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PeriodsCompanion.insert({
    this.id = const Value.absent(),
    required String startDate,
    required String endDate,
    this.savingsGoal = const Value.absent(),
    this.savingsGoalType = const Value.absent(),
    this.savingsGoalPct = const Value.absent(),
    this.savingsSetAside = const Value.absent(),
    this.isPartial = const Value.absent(),
    this.status = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : startDate = Value(startDate),
       endDate = Value(endDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Period> custom({
    Expression<int>? id,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<int>? savingsGoal,
    Expression<String>? savingsGoalType,
    Expression<int>? savingsGoalPct,
    Expression<bool>? savingsSetAside,
    Expression<bool>? isPartial,
    Expression<String>? status,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (savingsGoal != null) 'savings_goal': savingsGoal,
      if (savingsGoalType != null) 'savings_goal_type': savingsGoalType,
      if (savingsGoalPct != null) 'savings_goal_pct': savingsGoalPct,
      if (savingsSetAside != null) 'savings_set_aside': savingsSetAside,
      if (isPartial != null) 'is_partial': isPartial,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PeriodsCompanion copyWith({
    Value<int>? id,
    Value<String>? startDate,
    Value<String>? endDate,
    Value<int>? savingsGoal,
    Value<String>? savingsGoalType,
    Value<int?>? savingsGoalPct,
    Value<bool>? savingsSetAside,
    Value<bool>? isPartial,
    Value<String>? status,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return PeriodsCompanion(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      savingsGoalType: savingsGoalType ?? this.savingsGoalType,
      savingsGoalPct: savingsGoalPct ?? this.savingsGoalPct,
      savingsSetAside: savingsSetAside ?? this.savingsSetAside,
      isPartial: isPartial ?? this.isPartial,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (savingsGoal.present) {
      map['savings_goal'] = Variable<int>(savingsGoal.value);
    }
    if (savingsGoalType.present) {
      map['savings_goal_type'] = Variable<String>(savingsGoalType.value);
    }
    if (savingsGoalPct.present) {
      map['savings_goal_pct'] = Variable<int>(savingsGoalPct.value);
    }
    if (savingsSetAside.present) {
      map['savings_set_aside'] = Variable<bool>(savingsSetAside.value);
    }
    if (isPartial.present) {
      map['is_partial'] = Variable<bool>(isPartial.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeriodsCompanion(')
          ..write('id: $id, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('savingsGoal: $savingsGoal, ')
          ..write('savingsGoalType: $savingsGoalType, ')
          ..write('savingsGoalPct: $savingsGoalPct, ')
          ..write('savingsSetAside: $savingsSetAside, ')
          ..write('isPartial: $isPartial, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $IncomesTable extends Incomes with TableInfo<$IncomesTable, Income> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _periodIdMeta = const VerificationMeta(
    'periodId',
  );
  @override
  late final GeneratedColumn<int> periodId = GeneratedColumn<int>(
    'period_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES periods (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPlannedMeta = const VerificationMeta(
    'isPlanned',
  );
  @override
  late final GeneratedColumn<bool> isPlanned = GeneratedColumn<bool>(
    'is_planned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_planned" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    periodId,
    label,
    amount,
    date,
    isPlanned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incomes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Income> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period_id')) {
      context.handle(
        _periodIdMeta,
        periodId.isAcceptableOrUnknown(data['period_id']!, _periodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_periodIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_planned')) {
      context.handle(
        _isPlannedMeta,
        isPlanned.isAcceptableOrUnknown(data['is_planned']!, _isPlannedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Income map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Income(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      periodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      isPlanned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_planned'],
      )!,
    );
  }

  @override
  $IncomesTable createAlias(String alias) {
    return $IncomesTable(attachedDatabase, alias);
  }
}

class Income extends DataClass implements Insertable<Income> {
  final int id;
  final int periodId;
  final String label;
  final int amount;
  final String date;

  /// True when entered in the plan; false for extra income logged mid-month.
  final bool isPlanned;
  const Income({
    required this.id,
    required this.periodId,
    required this.label,
    required this.amount,
    required this.date,
    required this.isPlanned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['period_id'] = Variable<int>(periodId);
    map['label'] = Variable<String>(label);
    map['amount'] = Variable<int>(amount);
    map['date'] = Variable<String>(date);
    map['is_planned'] = Variable<bool>(isPlanned);
    return map;
  }

  IncomesCompanion toCompanion(bool nullToAbsent) {
    return IncomesCompanion(
      id: Value(id),
      periodId: Value(periodId),
      label: Value(label),
      amount: Value(amount),
      date: Value(date),
      isPlanned: Value(isPlanned),
    );
  }

  factory Income.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Income(
      id: serializer.fromJson<int>(json['id']),
      periodId: serializer.fromJson<int>(json['periodId']),
      label: serializer.fromJson<String>(json['label']),
      amount: serializer.fromJson<int>(json['amount']),
      date: serializer.fromJson<String>(json['date']),
      isPlanned: serializer.fromJson<bool>(json['isPlanned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'periodId': serializer.toJson<int>(periodId),
      'label': serializer.toJson<String>(label),
      'amount': serializer.toJson<int>(amount),
      'date': serializer.toJson<String>(date),
      'isPlanned': serializer.toJson<bool>(isPlanned),
    };
  }

  Income copyWith({
    int? id,
    int? periodId,
    String? label,
    int? amount,
    String? date,
    bool? isPlanned,
  }) => Income(
    id: id ?? this.id,
    periodId: periodId ?? this.periodId,
    label: label ?? this.label,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    isPlanned: isPlanned ?? this.isPlanned,
  );
  Income copyWithCompanion(IncomesCompanion data) {
    return Income(
      id: data.id.present ? data.id.value : this.id,
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
      label: data.label.present ? data.label.value : this.label,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      isPlanned: data.isPlanned.present ? data.isPlanned.value : this.isPlanned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Income(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('label: $label, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('isPlanned: $isPlanned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, periodId, label, amount, date, isPlanned);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Income &&
          other.id == this.id &&
          other.periodId == this.periodId &&
          other.label == this.label &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.isPlanned == this.isPlanned);
}

class IncomesCompanion extends UpdateCompanion<Income> {
  final Value<int> id;
  final Value<int> periodId;
  final Value<String> label;
  final Value<int> amount;
  final Value<String> date;
  final Value<bool> isPlanned;
  const IncomesCompanion({
    this.id = const Value.absent(),
    this.periodId = const Value.absent(),
    this.label = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.isPlanned = const Value.absent(),
  });
  IncomesCompanion.insert({
    this.id = const Value.absent(),
    required int periodId,
    required String label,
    required int amount,
    required String date,
    this.isPlanned = const Value.absent(),
  }) : periodId = Value(periodId),
       label = Value(label),
       amount = Value(amount),
       date = Value(date);
  static Insertable<Income> custom({
    Expression<int>? id,
    Expression<int>? periodId,
    Expression<String>? label,
    Expression<int>? amount,
    Expression<String>? date,
    Expression<bool>? isPlanned,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (periodId != null) 'period_id': periodId,
      if (label != null) 'label': label,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (isPlanned != null) 'is_planned': isPlanned,
    });
  }

  IncomesCompanion copyWith({
    Value<int>? id,
    Value<int>? periodId,
    Value<String>? label,
    Value<int>? amount,
    Value<String>? date,
    Value<bool>? isPlanned,
  }) {
    return IncomesCompanion(
      id: id ?? this.id,
      periodId: periodId ?? this.periodId,
      label: label ?? this.label,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isPlanned: isPlanned ?? this.isPlanned,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (periodId.present) {
      map['period_id'] = Variable<int>(periodId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (isPlanned.present) {
      map['is_planned'] = Variable<bool>(isPlanned.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomesCompanion(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('label: $label, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('isPlanned: $isPlanned')
          ..write(')'))
        .toString();
  }
}

class $FixedCostsTable extends FixedCosts
    with TableInfo<$FixedCostsTable, FixedCost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FixedCostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _periodIdMeta = const VerificationMeta(
    'periodId',
  );
  @override
  late final GeneratedColumn<int> periodId = GeneratedColumn<int>(
    'period_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES periods (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    periodId,
    label,
    amount,
    isRecurring,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fixed_costs';
  @override
  VerificationContext validateIntegrity(
    Insertable<FixedCost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period_id')) {
      context.handle(
        _periodIdMeta,
        periodId.isAcceptableOrUnknown(data['period_id']!, _periodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_periodIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FixedCost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FixedCost(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      periodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      isRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring'],
      )!,
    );
  }

  @override
  $FixedCostsTable createAlias(String alias) {
    return $FixedCostsTable(attachedDatabase, alias);
  }
}

class FixedCost extends DataClass implements Insertable<FixedCost> {
  final int id;
  final int periodId;
  final String label;
  final int amount;
  final bool isRecurring;
  const FixedCost({
    required this.id,
    required this.periodId,
    required this.label,
    required this.amount,
    required this.isRecurring,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['period_id'] = Variable<int>(periodId);
    map['label'] = Variable<String>(label);
    map['amount'] = Variable<int>(amount);
    map['is_recurring'] = Variable<bool>(isRecurring);
    return map;
  }

  FixedCostsCompanion toCompanion(bool nullToAbsent) {
    return FixedCostsCompanion(
      id: Value(id),
      periodId: Value(periodId),
      label: Value(label),
      amount: Value(amount),
      isRecurring: Value(isRecurring),
    );
  }

  factory FixedCost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FixedCost(
      id: serializer.fromJson<int>(json['id']),
      periodId: serializer.fromJson<int>(json['periodId']),
      label: serializer.fromJson<String>(json['label']),
      amount: serializer.fromJson<int>(json['amount']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'periodId': serializer.toJson<int>(periodId),
      'label': serializer.toJson<String>(label),
      'amount': serializer.toJson<int>(amount),
      'isRecurring': serializer.toJson<bool>(isRecurring),
    };
  }

  FixedCost copyWith({
    int? id,
    int? periodId,
    String? label,
    int? amount,
    bool? isRecurring,
  }) => FixedCost(
    id: id ?? this.id,
    periodId: periodId ?? this.periodId,
    label: label ?? this.label,
    amount: amount ?? this.amount,
    isRecurring: isRecurring ?? this.isRecurring,
  );
  FixedCost copyWithCompanion(FixedCostsCompanion data) {
    return FixedCost(
      id: data.id.present ? data.id.value : this.id,
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
      label: data.label.present ? data.label.value : this.label,
      amount: data.amount.present ? data.amount.value : this.amount,
      isRecurring: data.isRecurring.present
          ? data.isRecurring.value
          : this.isRecurring,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FixedCost(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('label: $label, ')
          ..write('amount: $amount, ')
          ..write('isRecurring: $isRecurring')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, periodId, label, amount, isRecurring);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FixedCost &&
          other.id == this.id &&
          other.periodId == this.periodId &&
          other.label == this.label &&
          other.amount == this.amount &&
          other.isRecurring == this.isRecurring);
}

class FixedCostsCompanion extends UpdateCompanion<FixedCost> {
  final Value<int> id;
  final Value<int> periodId;
  final Value<String> label;
  final Value<int> amount;
  final Value<bool> isRecurring;
  const FixedCostsCompanion({
    this.id = const Value.absent(),
    this.periodId = const Value.absent(),
    this.label = const Value.absent(),
    this.amount = const Value.absent(),
    this.isRecurring = const Value.absent(),
  });
  FixedCostsCompanion.insert({
    this.id = const Value.absent(),
    required int periodId,
    required String label,
    required int amount,
    this.isRecurring = const Value.absent(),
  }) : periodId = Value(periodId),
       label = Value(label),
       amount = Value(amount);
  static Insertable<FixedCost> custom({
    Expression<int>? id,
    Expression<int>? periodId,
    Expression<String>? label,
    Expression<int>? amount,
    Expression<bool>? isRecurring,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (periodId != null) 'period_id': periodId,
      if (label != null) 'label': label,
      if (amount != null) 'amount': amount,
      if (isRecurring != null) 'is_recurring': isRecurring,
    });
  }

  FixedCostsCompanion copyWith({
    Value<int>? id,
    Value<int>? periodId,
    Value<String>? label,
    Value<int>? amount,
    Value<bool>? isRecurring,
  }) {
    return FixedCostsCompanion(
      id: id ?? this.id,
      periodId: periodId ?? this.periodId,
      label: label ?? this.label,
      amount: amount ?? this.amount,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (periodId.present) {
      map['period_id'] = Variable<int>(periodId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FixedCostsCompanion(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('label: $label, ')
          ..write('amount: $amount, ')
          ..write('isRecurring: $isRecurring')
          ..write(')'))
        .toString();
  }
}

class $PillarBudgetsTable extends PillarBudgets
    with TableInfo<$PillarBudgetsTable, PillarBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PillarBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _periodIdMeta = const VerificationMeta(
    'periodId',
  );
  @override
  late final GeneratedColumn<int> periodId = GeneratedColumn<int>(
    'period_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES periods (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pillarIdMeta = const VerificationMeta(
    'pillarId',
  );
  @override
  late final GeneratedColumn<int> pillarId = GeneratedColumn<int>(
    'pillar_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pillars (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _plannedAmountMeta = const VerificationMeta(
    'plannedAmount',
  );
  @override
  late final GeneratedColumn<int> plannedAmount = GeneratedColumn<int>(
    'planned_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [periodId, pillarId, plannedAmount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pillar_budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<PillarBudget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('period_id')) {
      context.handle(
        _periodIdMeta,
        periodId.isAcceptableOrUnknown(data['period_id']!, _periodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_periodIdMeta);
    }
    if (data.containsKey('pillar_id')) {
      context.handle(
        _pillarIdMeta,
        pillarId.isAcceptableOrUnknown(data['pillar_id']!, _pillarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pillarIdMeta);
    }
    if (data.containsKey('planned_amount')) {
      context.handle(
        _plannedAmountMeta,
        plannedAmount.isAcceptableOrUnknown(
          data['planned_amount']!,
          _plannedAmountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {periodId, pillarId};
  @override
  PillarBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PillarBudget(
      periodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_id'],
      )!,
      pillarId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pillar_id'],
      )!,
      plannedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_amount'],
      )!,
    );
  }

  @override
  $PillarBudgetsTable createAlias(String alias) {
    return $PillarBudgetsTable(attachedDatabase, alias);
  }
}

class PillarBudget extends DataClass implements Insertable<PillarBudget> {
  final int periodId;
  final int pillarId;
  final int plannedAmount;
  const PillarBudget({
    required this.periodId,
    required this.pillarId,
    required this.plannedAmount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['period_id'] = Variable<int>(periodId);
    map['pillar_id'] = Variable<int>(pillarId);
    map['planned_amount'] = Variable<int>(plannedAmount);
    return map;
  }

  PillarBudgetsCompanion toCompanion(bool nullToAbsent) {
    return PillarBudgetsCompanion(
      periodId: Value(periodId),
      pillarId: Value(pillarId),
      plannedAmount: Value(plannedAmount),
    );
  }

  factory PillarBudget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PillarBudget(
      periodId: serializer.fromJson<int>(json['periodId']),
      pillarId: serializer.fromJson<int>(json['pillarId']),
      plannedAmount: serializer.fromJson<int>(json['plannedAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'periodId': serializer.toJson<int>(periodId),
      'pillarId': serializer.toJson<int>(pillarId),
      'plannedAmount': serializer.toJson<int>(plannedAmount),
    };
  }

  PillarBudget copyWith({int? periodId, int? pillarId, int? plannedAmount}) =>
      PillarBudget(
        periodId: periodId ?? this.periodId,
        pillarId: pillarId ?? this.pillarId,
        plannedAmount: plannedAmount ?? this.plannedAmount,
      );
  PillarBudget copyWithCompanion(PillarBudgetsCompanion data) {
    return PillarBudget(
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
      pillarId: data.pillarId.present ? data.pillarId.value : this.pillarId,
      plannedAmount: data.plannedAmount.present
          ? data.plannedAmount.value
          : this.plannedAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PillarBudget(')
          ..write('periodId: $periodId, ')
          ..write('pillarId: $pillarId, ')
          ..write('plannedAmount: $plannedAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(periodId, pillarId, plannedAmount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PillarBudget &&
          other.periodId == this.periodId &&
          other.pillarId == this.pillarId &&
          other.plannedAmount == this.plannedAmount);
}

class PillarBudgetsCompanion extends UpdateCompanion<PillarBudget> {
  final Value<int> periodId;
  final Value<int> pillarId;
  final Value<int> plannedAmount;
  final Value<int> rowid;
  const PillarBudgetsCompanion({
    this.periodId = const Value.absent(),
    this.pillarId = const Value.absent(),
    this.plannedAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PillarBudgetsCompanion.insert({
    required int periodId,
    required int pillarId,
    this.plannedAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : periodId = Value(periodId),
       pillarId = Value(pillarId);
  static Insertable<PillarBudget> custom({
    Expression<int>? periodId,
    Expression<int>? pillarId,
    Expression<int>? plannedAmount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (periodId != null) 'period_id': periodId,
      if (pillarId != null) 'pillar_id': pillarId,
      if (plannedAmount != null) 'planned_amount': plannedAmount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PillarBudgetsCompanion copyWith({
    Value<int>? periodId,
    Value<int>? pillarId,
    Value<int>? plannedAmount,
    Value<int>? rowid,
  }) {
    return PillarBudgetsCompanion(
      periodId: periodId ?? this.periodId,
      pillarId: pillarId ?? this.pillarId,
      plannedAmount: plannedAmount ?? this.plannedAmount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (periodId.present) {
      map['period_id'] = Variable<int>(periodId.value);
    }
    if (pillarId.present) {
      map['pillar_id'] = Variable<int>(pillarId.value);
    }
    if (plannedAmount.present) {
      map['planned_amount'] = Variable<int>(plannedAmount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PillarBudgetsCompanion(')
          ..write('periodId: $periodId, ')
          ..write('pillarId: $pillarId, ')
          ..write('plannedAmount: $plannedAmount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentMethodsTable extends PaymentMethods
    with TableInfo<$PaymentMethodsTable, PaymentMethod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentMethodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, icon, isHidden, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_methods';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentMethod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentMethod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentMethod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $PaymentMethodsTable createAlias(String alias) {
    return $PaymentMethodsTable(attachedDatabase, alias);
  }
}

class PaymentMethod extends DataClass implements Insertable<PaymentMethod> {
  final int id;
  final String name;
  final String icon;
  final bool isHidden;
  final int sortOrder;
  const PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.isHidden,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['is_hidden'] = Variable<bool>(isHidden);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PaymentMethodsCompanion toCompanion(bool nullToAbsent) {
    return PaymentMethodsCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      isHidden: Value(isHidden),
      sortOrder: Value(sortOrder),
    );
  }

  factory PaymentMethod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentMethod(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'isHidden': serializer.toJson<bool>(isHidden),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  PaymentMethod copyWith({
    int? id,
    String? name,
    String? icon,
    bool? isHidden,
    int? sortOrder,
  }) => PaymentMethod(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    isHidden: isHidden ?? this.isHidden,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  PaymentMethod copyWithCompanion(PaymentMethodsCompanion data) {
    return PaymentMethod(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentMethod(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('isHidden: $isHidden, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, icon, isHidden, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentMethod &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.isHidden == this.isHidden &&
          other.sortOrder == this.sortOrder);
}

class PaymentMethodsCompanion extends UpdateCompanion<PaymentMethod> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<bool> isHidden;
  final Value<int> sortOrder;
  const PaymentMethodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  PaymentMethodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String icon,
    this.isHidden = const Value.absent(),
    required int sortOrder,
  }) : name = Value(name),
       icon = Value(icon),
       sortOrder = Value(sortOrder);
  static Insertable<PaymentMethod> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<bool>? isHidden,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (isHidden != null) 'is_hidden': isHidden,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  PaymentMethodsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<bool>? isHidden,
    Value<int>? sortOrder,
  }) {
    return PaymentMethodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isHidden: isHidden ?? this.isHidden,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentMethodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('isHidden: $isHidden, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _periodIdMeta = const VerificationMeta(
    'periodId',
  );
  @override
  late final GeneratedColumn<int> periodId = GeneratedColumn<int>(
    'period_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES periods (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pillarIdMeta = const VerificationMeta(
    'pillarId',
  );
  @override
  late final GeneratedColumn<int> pillarId = GeneratedColumn<int>(
    'pillar_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pillars (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('expense'),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    check: () => ComparableExpr(amount).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentMethodIdMeta = const VerificationMeta(
    'paymentMethodId',
  );
  @override
  late final GeneratedColumn<int> paymentMethodId = GeneratedColumn<int>(
    'payment_method_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES payment_methods (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _refundOfIdMeta = const VerificationMeta(
    'refundOfId',
  );
  @override
  late final GeneratedColumn<int> refundOfId = GeneratedColumn<int>(
    'refund_of_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES expenses (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _splitGroupIdMeta = const VerificationMeta(
    'splitGroupId',
  );
  @override
  late final GeneratedColumn<String> splitGroupId = GeneratedColumn<String>(
    'split_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isLumpSumMeta = const VerificationMeta(
    'isLumpSum',
  );
  @override
  late final GeneratedColumn<bool> isLumpSum = GeneratedColumn<bool>(
    'is_lump_sum',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_lump_sum" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    periodId,
    pillarId,
    type,
    amount,
    note,
    date,
    mood,
    paymentMethodId,
    refundOfId,
    splitGroupId,
    isLumpSum,
    deletedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period_id')) {
      context.handle(
        _periodIdMeta,
        periodId.isAcceptableOrUnknown(data['period_id']!, _periodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_periodIdMeta);
    }
    if (data.containsKey('pillar_id')) {
      context.handle(
        _pillarIdMeta,
        pillarId.isAcceptableOrUnknown(data['pillar_id']!, _pillarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pillarIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('payment_method_id')) {
      context.handle(
        _paymentMethodIdMeta,
        paymentMethodId.isAcceptableOrUnknown(
          data['payment_method_id']!,
          _paymentMethodIdMeta,
        ),
      );
    }
    if (data.containsKey('refund_of_id')) {
      context.handle(
        _refundOfIdMeta,
        refundOfId.isAcceptableOrUnknown(
          data['refund_of_id']!,
          _refundOfIdMeta,
        ),
      );
    }
    if (data.containsKey('split_group_id')) {
      context.handle(
        _splitGroupIdMeta,
        splitGroupId.isAcceptableOrUnknown(
          data['split_group_id']!,
          _splitGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('is_lump_sum')) {
      context.handle(
        _isLumpSumMeta,
        isLumpSum.isAcceptableOrUnknown(data['is_lump_sum']!, _isLumpSumMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      periodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_id'],
      )!,
      pillarId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pillar_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      ),
      paymentMethodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_method_id'],
      ),
      refundOfId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refund_of_id'],
      ),
      splitGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}split_group_id'],
      ),
      isLumpSum: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_lump_sum'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;
  final int periodId;
  final int pillarId;

  /// `expense` or `refund` (refunds count as negative spend).
  final String type;
  final int amount;
  final String? note;
  final String date;

  /// `worth`, `neutral`, `regret` or null.
  final String? mood;
  final int? paymentMethodId;
  final int? refundOfId;
  final String? splitGroupId;
  final bool isLumpSum;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;
  const Expense({
    required this.id,
    required this.periodId,
    required this.pillarId,
    required this.type,
    required this.amount,
    this.note,
    required this.date,
    this.mood,
    this.paymentMethodId,
    this.refundOfId,
    this.splitGroupId,
    required this.isLumpSum,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['period_id'] = Variable<int>(periodId);
    map['pillar_id'] = Variable<int>(pillarId);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    if (!nullToAbsent || paymentMethodId != null) {
      map['payment_method_id'] = Variable<int>(paymentMethodId);
    }
    if (!nullToAbsent || refundOfId != null) {
      map['refund_of_id'] = Variable<int>(refundOfId);
    }
    if (!nullToAbsent || splitGroupId != null) {
      map['split_group_id'] = Variable<String>(splitGroupId);
    }
    map['is_lump_sum'] = Variable<bool>(isLumpSum);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      periodId: Value(periodId),
      pillarId: Value(pillarId),
      type: Value(type),
      amount: Value(amount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      date: Value(date),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      paymentMethodId: paymentMethodId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethodId),
      refundOfId: refundOfId == null && nullToAbsent
          ? const Value.absent()
          : Value(refundOfId),
      splitGroupId: splitGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(splitGroupId),
      isLumpSum: Value(isLumpSum),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      periodId: serializer.fromJson<int>(json['periodId']),
      pillarId: serializer.fromJson<int>(json['pillarId']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<int>(json['amount']),
      note: serializer.fromJson<String?>(json['note']),
      date: serializer.fromJson<String>(json['date']),
      mood: serializer.fromJson<String?>(json['mood']),
      paymentMethodId: serializer.fromJson<int?>(json['paymentMethodId']),
      refundOfId: serializer.fromJson<int?>(json['refundOfId']),
      splitGroupId: serializer.fromJson<String?>(json['splitGroupId']),
      isLumpSum: serializer.fromJson<bool>(json['isLumpSum']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'periodId': serializer.toJson<int>(periodId),
      'pillarId': serializer.toJson<int>(pillarId),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<int>(amount),
      'note': serializer.toJson<String?>(note),
      'date': serializer.toJson<String>(date),
      'mood': serializer.toJson<String?>(mood),
      'paymentMethodId': serializer.toJson<int?>(paymentMethodId),
      'refundOfId': serializer.toJson<int?>(refundOfId),
      'splitGroupId': serializer.toJson<String?>(splitGroupId),
      'isLumpSum': serializer.toJson<bool>(isLumpSum),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Expense copyWith({
    int? id,
    int? periodId,
    int? pillarId,
    String? type,
    int? amount,
    Value<String?> note = const Value.absent(),
    String? date,
    Value<String?> mood = const Value.absent(),
    Value<int?> paymentMethodId = const Value.absent(),
    Value<int?> refundOfId = const Value.absent(),
    Value<String?> splitGroupId = const Value.absent(),
    bool? isLumpSum,
    Value<String?> deletedAt = const Value.absent(),
    String? createdAt,
    String? updatedAt,
  }) => Expense(
    id: id ?? this.id,
    periodId: periodId ?? this.periodId,
    pillarId: pillarId ?? this.pillarId,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    note: note.present ? note.value : this.note,
    date: date ?? this.date,
    mood: mood.present ? mood.value : this.mood,
    paymentMethodId: paymentMethodId.present
        ? paymentMethodId.value
        : this.paymentMethodId,
    refundOfId: refundOfId.present ? refundOfId.value : this.refundOfId,
    splitGroupId: splitGroupId.present ? splitGroupId.value : this.splitGroupId,
    isLumpSum: isLumpSum ?? this.isLumpSum,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
      pillarId: data.pillarId.present ? data.pillarId.value : this.pillarId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
      date: data.date.present ? data.date.value : this.date,
      mood: data.mood.present ? data.mood.value : this.mood,
      paymentMethodId: data.paymentMethodId.present
          ? data.paymentMethodId.value
          : this.paymentMethodId,
      refundOfId: data.refundOfId.present
          ? data.refundOfId.value
          : this.refundOfId,
      splitGroupId: data.splitGroupId.present
          ? data.splitGroupId.value
          : this.splitGroupId,
      isLumpSum: data.isLumpSum.present ? data.isLumpSum.value : this.isLumpSum,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('pillarId: $pillarId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('mood: $mood, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('refundOfId: $refundOfId, ')
          ..write('splitGroupId: $splitGroupId, ')
          ..write('isLumpSum: $isLumpSum, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    periodId,
    pillarId,
    type,
    amount,
    note,
    date,
    mood,
    paymentMethodId,
    refundOfId,
    splitGroupId,
    isLumpSum,
    deletedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.periodId == this.periodId &&
          other.pillarId == this.pillarId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.date == this.date &&
          other.mood == this.mood &&
          other.paymentMethodId == this.paymentMethodId &&
          other.refundOfId == this.refundOfId &&
          other.splitGroupId == this.splitGroupId &&
          other.isLumpSum == this.isLumpSum &&
          other.deletedAt == this.deletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<int> periodId;
  final Value<int> pillarId;
  final Value<String> type;
  final Value<int> amount;
  final Value<String?> note;
  final Value<String> date;
  final Value<String?> mood;
  final Value<int?> paymentMethodId;
  final Value<int?> refundOfId;
  final Value<String?> splitGroupId;
  final Value<bool> isLumpSum;
  final Value<String?> deletedAt;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.periodId = const Value.absent(),
    this.pillarId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
    this.mood = const Value.absent(),
    this.paymentMethodId = const Value.absent(),
    this.refundOfId = const Value.absent(),
    this.splitGroupId = const Value.absent(),
    this.isLumpSum = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required int periodId,
    required int pillarId,
    this.type = const Value.absent(),
    required int amount,
    this.note = const Value.absent(),
    required String date,
    this.mood = const Value.absent(),
    this.paymentMethodId = const Value.absent(),
    this.refundOfId = const Value.absent(),
    this.splitGroupId = const Value.absent(),
    this.isLumpSum = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : periodId = Value(periodId),
       pillarId = Value(pillarId),
       amount = Value(amount),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<int>? periodId,
    Expression<int>? pillarId,
    Expression<String>? type,
    Expression<int>? amount,
    Expression<String>? note,
    Expression<String>? date,
    Expression<String>? mood,
    Expression<int>? paymentMethodId,
    Expression<int>? refundOfId,
    Expression<String>? splitGroupId,
    Expression<bool>? isLumpSum,
    Expression<String>? deletedAt,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (periodId != null) 'period_id': periodId,
      if (pillarId != null) 'pillar_id': pillarId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
      if (mood != null) 'mood': mood,
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      if (refundOfId != null) 'refund_of_id': refundOfId,
      if (splitGroupId != null) 'split_group_id': splitGroupId,
      if (isLumpSum != null) 'is_lump_sum': isLumpSum,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ExpensesCompanion copyWith({
    Value<int>? id,
    Value<int>? periodId,
    Value<int>? pillarId,
    Value<String>? type,
    Value<int>? amount,
    Value<String?>? note,
    Value<String>? date,
    Value<String?>? mood,
    Value<int?>? paymentMethodId,
    Value<int?>? refundOfId,
    Value<String?>? splitGroupId,
    Value<bool>? isLumpSum,
    Value<String?>? deletedAt,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      periodId: periodId ?? this.periodId,
      pillarId: pillarId ?? this.pillarId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      refundOfId: refundOfId ?? this.refundOfId,
      splitGroupId: splitGroupId ?? this.splitGroupId,
      isLumpSum: isLumpSum ?? this.isLumpSum,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (periodId.present) {
      map['period_id'] = Variable<int>(periodId.value);
    }
    if (pillarId.present) {
      map['pillar_id'] = Variable<int>(pillarId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (paymentMethodId.present) {
      map['payment_method_id'] = Variable<int>(paymentMethodId.value);
    }
    if (refundOfId.present) {
      map['refund_of_id'] = Variable<int>(refundOfId.value);
    }
    if (splitGroupId.present) {
      map['split_group_id'] = Variable<String>(splitGroupId.value);
    }
    if (isLumpSum.present) {
      map['is_lump_sum'] = Variable<bool>(isLumpSum.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('pillarId: $pillarId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('mood: $mood, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('refundOfId: $refundOfId, ')
          ..write('splitGroupId: $splitGroupId, ')
          ..write('isLumpSum: $isLumpSum, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PlanChangesTable extends PlanChanges
    with TableInfo<$PlanChangesTable, PlanChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _periodIdMeta = const VerificationMeta(
    'periodId',
  );
  @override
  late final GeneratedColumn<int> periodId = GeneratedColumn<int>(
    'period_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES periods (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oldValueMeta = const VerificationMeta(
    'oldValue',
  );
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
    'old_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newValueMeta = const VerificationMeta(
    'newValue',
  );
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
    'new_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<String> changedAt = GeneratedColumn<String>(
    'changed_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    periodId,
    field,
    oldValue,
    newValue,
    changedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period_id')) {
      context.handle(
        _periodIdMeta,
        periodId.isAcceptableOrUnknown(data['period_id']!, _periodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_periodIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('old_value')) {
      context.handle(
        _oldValueMeta,
        oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta),
      );
    }
    if (data.containsKey('new_value')) {
      context.handle(
        _newValueMeta,
        newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta),
      );
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_changedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanChange(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      periodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      oldValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_value'],
      ),
      newValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_value'],
      ),
      changedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}changed_at'],
      )!,
    );
  }

  @override
  $PlanChangesTable createAlias(String alias) {
    return $PlanChangesTable(attachedDatabase, alias);
  }
}

class PlanChange extends DataClass implements Insertable<PlanChange> {
  final int id;
  final int periodId;
  final String field;
  final String? oldValue;
  final String? newValue;
  final String changedAt;
  const PlanChange({
    required this.id,
    required this.periodId,
    required this.field,
    this.oldValue,
    this.newValue,
    required this.changedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['period_id'] = Variable<int>(periodId);
    map['field'] = Variable<String>(field);
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<String>(oldValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<String>(newValue);
    }
    map['changed_at'] = Variable<String>(changedAt);
    return map;
  }

  PlanChangesCompanion toCompanion(bool nullToAbsent) {
    return PlanChangesCompanion(
      id: Value(id),
      periodId: Value(periodId),
      field: Value(field),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      changedAt: Value(changedAt),
    );
  }

  factory PlanChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanChange(
      id: serializer.fromJson<int>(json['id']),
      periodId: serializer.fromJson<int>(json['periodId']),
      field: serializer.fromJson<String>(json['field']),
      oldValue: serializer.fromJson<String?>(json['oldValue']),
      newValue: serializer.fromJson<String?>(json['newValue']),
      changedAt: serializer.fromJson<String>(json['changedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'periodId': serializer.toJson<int>(periodId),
      'field': serializer.toJson<String>(field),
      'oldValue': serializer.toJson<String?>(oldValue),
      'newValue': serializer.toJson<String?>(newValue),
      'changedAt': serializer.toJson<String>(changedAt),
    };
  }

  PlanChange copyWith({
    int? id,
    int? periodId,
    String? field,
    Value<String?> oldValue = const Value.absent(),
    Value<String?> newValue = const Value.absent(),
    String? changedAt,
  }) => PlanChange(
    id: id ?? this.id,
    periodId: periodId ?? this.periodId,
    field: field ?? this.field,
    oldValue: oldValue.present ? oldValue.value : this.oldValue,
    newValue: newValue.present ? newValue.value : this.newValue,
    changedAt: changedAt ?? this.changedAt,
  );
  PlanChange copyWithCompanion(PlanChangesCompanion data) {
    return PlanChange(
      id: data.id.present ? data.id.value : this.id,
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
      field: data.field.present ? data.field.value : this.field,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanChange(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('field: $field, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, periodId, field, oldValue, newValue, changedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanChange &&
          other.id == this.id &&
          other.periodId == this.periodId &&
          other.field == this.field &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.changedAt == this.changedAt);
}

class PlanChangesCompanion extends UpdateCompanion<PlanChange> {
  final Value<int> id;
  final Value<int> periodId;
  final Value<String> field;
  final Value<String?> oldValue;
  final Value<String?> newValue;
  final Value<String> changedAt;
  const PlanChangesCompanion({
    this.id = const Value.absent(),
    this.periodId = const Value.absent(),
    this.field = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.changedAt = const Value.absent(),
  });
  PlanChangesCompanion.insert({
    this.id = const Value.absent(),
    required int periodId,
    required String field,
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    required String changedAt,
  }) : periodId = Value(periodId),
       field = Value(field),
       changedAt = Value(changedAt);
  static Insertable<PlanChange> custom({
    Expression<int>? id,
    Expression<int>? periodId,
    Expression<String>? field,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<String>? changedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (periodId != null) 'period_id': periodId,
      if (field != null) 'field': field,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (changedAt != null) 'changed_at': changedAt,
    });
  }

  PlanChangesCompanion copyWith({
    Value<int>? id,
    Value<int>? periodId,
    Value<String>? field,
    Value<String?>? oldValue,
    Value<String?>? newValue,
    Value<String>? changedAt,
  }) {
    return PlanChangesCompanion(
      id: id ?? this.id,
      periodId: periodId ?? this.periodId,
      field: field ?? this.field,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      changedAt: changedAt ?? this.changedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (periodId.present) {
      map['period_id'] = Variable<int>(periodId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (oldValue.present) {
      map['old_value'] = Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<String>(changedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanChangesCompanion(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('field: $field, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }
}

class $ReflectionsTable extends Reflections
    with TableInfo<$ReflectionsTable, Reflection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReflectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _periodIdMeta = const VerificationMeta(
    'periodId',
  );
  @override
  late final GeneratedColumn<int> periodId = GeneratedColumn<int>(
    'period_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES periods (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _savedAmountMeta = const VerificationMeta(
    'savedAmount',
  );
  @override
  late final GeneratedColumn<int> savedAmount = GeneratedColumn<int>(
    'saved_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalMetMeta = const VerificationMeta(
    'goalMet',
  );
  @override
  late final GeneratedColumn<bool> goalMet = GeneratedColumn<bool>(
    'goal_met',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("goal_met" IN (0, 1))',
    ),
  );
  static const VerificationMeta _answerQ1Meta = const VerificationMeta(
    'answerQ1',
  );
  @override
  late final GeneratedColumn<String> answerQ1 = GeneratedColumn<String>(
    'answer_q1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answerQ2Meta = const VerificationMeta(
    'answerQ2',
  );
  @override
  late final GeneratedColumn<String> answerQ2 = GeneratedColumn<String>(
    'answer_q2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answerQ3Meta = const VerificationMeta(
    'answerQ3',
  );
  @override
  late final GeneratedColumn<String> answerQ3 = GeneratedColumn<String>(
    'answer_q3',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answerQ4Meta = const VerificationMeta(
    'answerQ4',
  );
  @override
  late final GeneratedColumn<String> answerQ4 = GeneratedColumn<String>(
    'answer_q4',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prevImprovementKeptMeta =
      const VerificationMeta('prevImprovementKept');
  @override
  late final GeneratedColumn<String> prevImprovementKept =
      GeneratedColumn<String>(
        'prev_improvement_kept',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _improvementMeta = const VerificationMeta(
    'improvement',
  );
  @override
  late final GeneratedColumn<String> improvement = GeneratedColumn<String>(
    'improvement',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<String> completedAt = GeneratedColumn<String>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _editedAfterCloseMeta = const VerificationMeta(
    'editedAfterClose',
  );
  @override
  late final GeneratedColumn<int> editedAfterClose = GeneratedColumn<int>(
    'edited_after_close',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    periodId,
    savedAmount,
    goalMet,
    answerQ1,
    answerQ2,
    answerQ3,
    answerQ4,
    prevImprovementKept,
    improvement,
    completedAt,
    editedAfterClose,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reflections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reflection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('period_id')) {
      context.handle(
        _periodIdMeta,
        periodId.isAcceptableOrUnknown(data['period_id']!, _periodIdMeta),
      );
    }
    if (data.containsKey('saved_amount')) {
      context.handle(
        _savedAmountMeta,
        savedAmount.isAcceptableOrUnknown(
          data['saved_amount']!,
          _savedAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_savedAmountMeta);
    }
    if (data.containsKey('goal_met')) {
      context.handle(
        _goalMetMeta,
        goalMet.isAcceptableOrUnknown(data['goal_met']!, _goalMetMeta),
      );
    } else if (isInserting) {
      context.missing(_goalMetMeta);
    }
    if (data.containsKey('answer_q1')) {
      context.handle(
        _answerQ1Meta,
        answerQ1.isAcceptableOrUnknown(data['answer_q1']!, _answerQ1Meta),
      );
    }
    if (data.containsKey('answer_q2')) {
      context.handle(
        _answerQ2Meta,
        answerQ2.isAcceptableOrUnknown(data['answer_q2']!, _answerQ2Meta),
      );
    }
    if (data.containsKey('answer_q3')) {
      context.handle(
        _answerQ3Meta,
        answerQ3.isAcceptableOrUnknown(data['answer_q3']!, _answerQ3Meta),
      );
    }
    if (data.containsKey('answer_q4')) {
      context.handle(
        _answerQ4Meta,
        answerQ4.isAcceptableOrUnknown(data['answer_q4']!, _answerQ4Meta),
      );
    }
    if (data.containsKey('prev_improvement_kept')) {
      context.handle(
        _prevImprovementKeptMeta,
        prevImprovementKept.isAcceptableOrUnknown(
          data['prev_improvement_kept']!,
          _prevImprovementKeptMeta,
        ),
      );
    }
    if (data.containsKey('improvement')) {
      context.handle(
        _improvementMeta,
        improvement.isAcceptableOrUnknown(
          data['improvement']!,
          _improvementMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('edited_after_close')) {
      context.handle(
        _editedAfterCloseMeta,
        editedAfterClose.isAcceptableOrUnknown(
          data['edited_after_close']!,
          _editedAfterCloseMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {periodId};
  @override
  Reflection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reflection(
      periodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_id'],
      )!,
      savedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_amount'],
      )!,
      goalMet: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}goal_met'],
      )!,
      answerQ1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer_q1'],
      ),
      answerQ2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer_q2'],
      ),
      answerQ3: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer_q3'],
      ),
      answerQ4: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer_q4'],
      ),
      prevImprovementKept: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prev_improvement_kept'],
      ),
      improvement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}improvement'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_at'],
      ),
      editedAfterClose: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edited_after_close'],
      )!,
    );
  }

  @override
  $ReflectionsTable createAlias(String alias) {
    return $ReflectionsTable(attachedDatabase, alias);
  }
}

class Reflection extends DataClass implements Insertable<Reflection> {
  final int periodId;
  final int savedAmount;
  final bool goalMet;
  final String? answerQ1;
  final String? answerQ2;
  final String? answerQ3;
  final String? answerQ4;

  /// `yes`, `partly` or `no`.
  final String? prevImprovementKept;
  final String? improvement;
  final String? completedAt;
  final int editedAfterClose;
  const Reflection({
    required this.periodId,
    required this.savedAmount,
    required this.goalMet,
    this.answerQ1,
    this.answerQ2,
    this.answerQ3,
    this.answerQ4,
    this.prevImprovementKept,
    this.improvement,
    this.completedAt,
    required this.editedAfterClose,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['period_id'] = Variable<int>(periodId);
    map['saved_amount'] = Variable<int>(savedAmount);
    map['goal_met'] = Variable<bool>(goalMet);
    if (!nullToAbsent || answerQ1 != null) {
      map['answer_q1'] = Variable<String>(answerQ1);
    }
    if (!nullToAbsent || answerQ2 != null) {
      map['answer_q2'] = Variable<String>(answerQ2);
    }
    if (!nullToAbsent || answerQ3 != null) {
      map['answer_q3'] = Variable<String>(answerQ3);
    }
    if (!nullToAbsent || answerQ4 != null) {
      map['answer_q4'] = Variable<String>(answerQ4);
    }
    if (!nullToAbsent || prevImprovementKept != null) {
      map['prev_improvement_kept'] = Variable<String>(prevImprovementKept);
    }
    if (!nullToAbsent || improvement != null) {
      map['improvement'] = Variable<String>(improvement);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<String>(completedAt);
    }
    map['edited_after_close'] = Variable<int>(editedAfterClose);
    return map;
  }

  ReflectionsCompanion toCompanion(bool nullToAbsent) {
    return ReflectionsCompanion(
      periodId: Value(periodId),
      savedAmount: Value(savedAmount),
      goalMet: Value(goalMet),
      answerQ1: answerQ1 == null && nullToAbsent
          ? const Value.absent()
          : Value(answerQ1),
      answerQ2: answerQ2 == null && nullToAbsent
          ? const Value.absent()
          : Value(answerQ2),
      answerQ3: answerQ3 == null && nullToAbsent
          ? const Value.absent()
          : Value(answerQ3),
      answerQ4: answerQ4 == null && nullToAbsent
          ? const Value.absent()
          : Value(answerQ4),
      prevImprovementKept: prevImprovementKept == null && nullToAbsent
          ? const Value.absent()
          : Value(prevImprovementKept),
      improvement: improvement == null && nullToAbsent
          ? const Value.absent()
          : Value(improvement),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      editedAfterClose: Value(editedAfterClose),
    );
  }

  factory Reflection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reflection(
      periodId: serializer.fromJson<int>(json['periodId']),
      savedAmount: serializer.fromJson<int>(json['savedAmount']),
      goalMet: serializer.fromJson<bool>(json['goalMet']),
      answerQ1: serializer.fromJson<String?>(json['answerQ1']),
      answerQ2: serializer.fromJson<String?>(json['answerQ2']),
      answerQ3: serializer.fromJson<String?>(json['answerQ3']),
      answerQ4: serializer.fromJson<String?>(json['answerQ4']),
      prevImprovementKept: serializer.fromJson<String?>(
        json['prevImprovementKept'],
      ),
      improvement: serializer.fromJson<String?>(json['improvement']),
      completedAt: serializer.fromJson<String?>(json['completedAt']),
      editedAfterClose: serializer.fromJson<int>(json['editedAfterClose']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'periodId': serializer.toJson<int>(periodId),
      'savedAmount': serializer.toJson<int>(savedAmount),
      'goalMet': serializer.toJson<bool>(goalMet),
      'answerQ1': serializer.toJson<String?>(answerQ1),
      'answerQ2': serializer.toJson<String?>(answerQ2),
      'answerQ3': serializer.toJson<String?>(answerQ3),
      'answerQ4': serializer.toJson<String?>(answerQ4),
      'prevImprovementKept': serializer.toJson<String?>(prevImprovementKept),
      'improvement': serializer.toJson<String?>(improvement),
      'completedAt': serializer.toJson<String?>(completedAt),
      'editedAfterClose': serializer.toJson<int>(editedAfterClose),
    };
  }

  Reflection copyWith({
    int? periodId,
    int? savedAmount,
    bool? goalMet,
    Value<String?> answerQ1 = const Value.absent(),
    Value<String?> answerQ2 = const Value.absent(),
    Value<String?> answerQ3 = const Value.absent(),
    Value<String?> answerQ4 = const Value.absent(),
    Value<String?> prevImprovementKept = const Value.absent(),
    Value<String?> improvement = const Value.absent(),
    Value<String?> completedAt = const Value.absent(),
    int? editedAfterClose,
  }) => Reflection(
    periodId: periodId ?? this.periodId,
    savedAmount: savedAmount ?? this.savedAmount,
    goalMet: goalMet ?? this.goalMet,
    answerQ1: answerQ1.present ? answerQ1.value : this.answerQ1,
    answerQ2: answerQ2.present ? answerQ2.value : this.answerQ2,
    answerQ3: answerQ3.present ? answerQ3.value : this.answerQ3,
    answerQ4: answerQ4.present ? answerQ4.value : this.answerQ4,
    prevImprovementKept: prevImprovementKept.present
        ? prevImprovementKept.value
        : this.prevImprovementKept,
    improvement: improvement.present ? improvement.value : this.improvement,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    editedAfterClose: editedAfterClose ?? this.editedAfterClose,
  );
  Reflection copyWithCompanion(ReflectionsCompanion data) {
    return Reflection(
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
      savedAmount: data.savedAmount.present
          ? data.savedAmount.value
          : this.savedAmount,
      goalMet: data.goalMet.present ? data.goalMet.value : this.goalMet,
      answerQ1: data.answerQ1.present ? data.answerQ1.value : this.answerQ1,
      answerQ2: data.answerQ2.present ? data.answerQ2.value : this.answerQ2,
      answerQ3: data.answerQ3.present ? data.answerQ3.value : this.answerQ3,
      answerQ4: data.answerQ4.present ? data.answerQ4.value : this.answerQ4,
      prevImprovementKept: data.prevImprovementKept.present
          ? data.prevImprovementKept.value
          : this.prevImprovementKept,
      improvement: data.improvement.present
          ? data.improvement.value
          : this.improvement,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      editedAfterClose: data.editedAfterClose.present
          ? data.editedAfterClose.value
          : this.editedAfterClose,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reflection(')
          ..write('periodId: $periodId, ')
          ..write('savedAmount: $savedAmount, ')
          ..write('goalMet: $goalMet, ')
          ..write('answerQ1: $answerQ1, ')
          ..write('answerQ2: $answerQ2, ')
          ..write('answerQ3: $answerQ3, ')
          ..write('answerQ4: $answerQ4, ')
          ..write('prevImprovementKept: $prevImprovementKept, ')
          ..write('improvement: $improvement, ')
          ..write('completedAt: $completedAt, ')
          ..write('editedAfterClose: $editedAfterClose')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    periodId,
    savedAmount,
    goalMet,
    answerQ1,
    answerQ2,
    answerQ3,
    answerQ4,
    prevImprovementKept,
    improvement,
    completedAt,
    editedAfterClose,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reflection &&
          other.periodId == this.periodId &&
          other.savedAmount == this.savedAmount &&
          other.goalMet == this.goalMet &&
          other.answerQ1 == this.answerQ1 &&
          other.answerQ2 == this.answerQ2 &&
          other.answerQ3 == this.answerQ3 &&
          other.answerQ4 == this.answerQ4 &&
          other.prevImprovementKept == this.prevImprovementKept &&
          other.improvement == this.improvement &&
          other.completedAt == this.completedAt &&
          other.editedAfterClose == this.editedAfterClose);
}

class ReflectionsCompanion extends UpdateCompanion<Reflection> {
  final Value<int> periodId;
  final Value<int> savedAmount;
  final Value<bool> goalMet;
  final Value<String?> answerQ1;
  final Value<String?> answerQ2;
  final Value<String?> answerQ3;
  final Value<String?> answerQ4;
  final Value<String?> prevImprovementKept;
  final Value<String?> improvement;
  final Value<String?> completedAt;
  final Value<int> editedAfterClose;
  const ReflectionsCompanion({
    this.periodId = const Value.absent(),
    this.savedAmount = const Value.absent(),
    this.goalMet = const Value.absent(),
    this.answerQ1 = const Value.absent(),
    this.answerQ2 = const Value.absent(),
    this.answerQ3 = const Value.absent(),
    this.answerQ4 = const Value.absent(),
    this.prevImprovementKept = const Value.absent(),
    this.improvement = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.editedAfterClose = const Value.absent(),
  });
  ReflectionsCompanion.insert({
    this.periodId = const Value.absent(),
    required int savedAmount,
    required bool goalMet,
    this.answerQ1 = const Value.absent(),
    this.answerQ2 = const Value.absent(),
    this.answerQ3 = const Value.absent(),
    this.answerQ4 = const Value.absent(),
    this.prevImprovementKept = const Value.absent(),
    this.improvement = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.editedAfterClose = const Value.absent(),
  }) : savedAmount = Value(savedAmount),
       goalMet = Value(goalMet);
  static Insertable<Reflection> custom({
    Expression<int>? periodId,
    Expression<int>? savedAmount,
    Expression<bool>? goalMet,
    Expression<String>? answerQ1,
    Expression<String>? answerQ2,
    Expression<String>? answerQ3,
    Expression<String>? answerQ4,
    Expression<String>? prevImprovementKept,
    Expression<String>? improvement,
    Expression<String>? completedAt,
    Expression<int>? editedAfterClose,
  }) {
    return RawValuesInsertable({
      if (periodId != null) 'period_id': periodId,
      if (savedAmount != null) 'saved_amount': savedAmount,
      if (goalMet != null) 'goal_met': goalMet,
      if (answerQ1 != null) 'answer_q1': answerQ1,
      if (answerQ2 != null) 'answer_q2': answerQ2,
      if (answerQ3 != null) 'answer_q3': answerQ3,
      if (answerQ4 != null) 'answer_q4': answerQ4,
      if (prevImprovementKept != null)
        'prev_improvement_kept': prevImprovementKept,
      if (improvement != null) 'improvement': improvement,
      if (completedAt != null) 'completed_at': completedAt,
      if (editedAfterClose != null) 'edited_after_close': editedAfterClose,
    });
  }

  ReflectionsCompanion copyWith({
    Value<int>? periodId,
    Value<int>? savedAmount,
    Value<bool>? goalMet,
    Value<String?>? answerQ1,
    Value<String?>? answerQ2,
    Value<String?>? answerQ3,
    Value<String?>? answerQ4,
    Value<String?>? prevImprovementKept,
    Value<String?>? improvement,
    Value<String?>? completedAt,
    Value<int>? editedAfterClose,
  }) {
    return ReflectionsCompanion(
      periodId: periodId ?? this.periodId,
      savedAmount: savedAmount ?? this.savedAmount,
      goalMet: goalMet ?? this.goalMet,
      answerQ1: answerQ1 ?? this.answerQ1,
      answerQ2: answerQ2 ?? this.answerQ2,
      answerQ3: answerQ3 ?? this.answerQ3,
      answerQ4: answerQ4 ?? this.answerQ4,
      prevImprovementKept: prevImprovementKept ?? this.prevImprovementKept,
      improvement: improvement ?? this.improvement,
      completedAt: completedAt ?? this.completedAt,
      editedAfterClose: editedAfterClose ?? this.editedAfterClose,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (periodId.present) {
      map['period_id'] = Variable<int>(periodId.value);
    }
    if (savedAmount.present) {
      map['saved_amount'] = Variable<int>(savedAmount.value);
    }
    if (goalMet.present) {
      map['goal_met'] = Variable<bool>(goalMet.value);
    }
    if (answerQ1.present) {
      map['answer_q1'] = Variable<String>(answerQ1.value);
    }
    if (answerQ2.present) {
      map['answer_q2'] = Variable<String>(answerQ2.value);
    }
    if (answerQ3.present) {
      map['answer_q3'] = Variable<String>(answerQ3.value);
    }
    if (answerQ4.present) {
      map['answer_q4'] = Variable<String>(answerQ4.value);
    }
    if (prevImprovementKept.present) {
      map['prev_improvement_kept'] = Variable<String>(
        prevImprovementKept.value,
      );
    }
    if (improvement.present) {
      map['improvement'] = Variable<String>(improvement.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<String>(completedAt.value);
    }
    if (editedAfterClose.present) {
      map['edited_after_close'] = Variable<int>(editedAfterClose.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionsCompanion(')
          ..write('periodId: $periodId, ')
          ..write('savedAmount: $savedAmount, ')
          ..write('goalMet: $goalMet, ')
          ..write('answerQ1: $answerQ1, ')
          ..write('answerQ2: $answerQ2, ')
          ..write('answerQ3: $answerQ3, ')
          ..write('answerQ4: $answerQ4, ')
          ..write('prevImprovementKept: $prevImprovementKept, ')
          ..write('improvement: $improvement, ')
          ..write('completedAt: $completedAt, ')
          ..write('editedAfterClose: $editedAfterClose')
          ..write(')'))
        .toString();
  }
}

class $WeeklyCheckinsTable extends WeeklyCheckins
    with TableInfo<$WeeklyCheckinsTable, WeeklyCheckin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyCheckinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _periodIdMeta = const VerificationMeta(
    'periodId',
  );
  @override
  late final GeneratedColumn<int> periodId = GeneratedColumn<int>(
    'period_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES periods (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<String> weekStart = GeneratedColumn<String>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, periodId, weekStart, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_checkins';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeeklyCheckin> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period_id')) {
      context.handle(
        _periodIdMeta,
        periodId.isAcceptableOrUnknown(data['period_id']!, _periodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_periodIdMeta);
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeeklyCheckin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyCheckin(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      periodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_id'],
      )!,
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_start'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $WeeklyCheckinsTable createAlias(String alias) {
    return $WeeklyCheckinsTable(attachedDatabase, alias);
  }
}

class WeeklyCheckin extends DataClass implements Insertable<WeeklyCheckin> {
  final int id;
  final int periodId;
  final String weekStart;
  final String? note;
  const WeeklyCheckin({
    required this.id,
    required this.periodId,
    required this.weekStart,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['period_id'] = Variable<int>(periodId);
    map['week_start'] = Variable<String>(weekStart);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  WeeklyCheckinsCompanion toCompanion(bool nullToAbsent) {
    return WeeklyCheckinsCompanion(
      id: Value(id),
      periodId: Value(periodId),
      weekStart: Value(weekStart),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory WeeklyCheckin.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyCheckin(
      id: serializer.fromJson<int>(json['id']),
      periodId: serializer.fromJson<int>(json['periodId']),
      weekStart: serializer.fromJson<String>(json['weekStart']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'periodId': serializer.toJson<int>(periodId),
      'weekStart': serializer.toJson<String>(weekStart),
      'note': serializer.toJson<String?>(note),
    };
  }

  WeeklyCheckin copyWith({
    int? id,
    int? periodId,
    String? weekStart,
    Value<String?> note = const Value.absent(),
  }) => WeeklyCheckin(
    id: id ?? this.id,
    periodId: periodId ?? this.periodId,
    weekStart: weekStart ?? this.weekStart,
    note: note.present ? note.value : this.note,
  );
  WeeklyCheckin copyWithCompanion(WeeklyCheckinsCompanion data) {
    return WeeklyCheckin(
      id: data.id.present ? data.id.value : this.id,
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyCheckin(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('weekStart: $weekStart, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, periodId, weekStart, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyCheckin &&
          other.id == this.id &&
          other.periodId == this.periodId &&
          other.weekStart == this.weekStart &&
          other.note == this.note);
}

class WeeklyCheckinsCompanion extends UpdateCompanion<WeeklyCheckin> {
  final Value<int> id;
  final Value<int> periodId;
  final Value<String> weekStart;
  final Value<String?> note;
  const WeeklyCheckinsCompanion({
    this.id = const Value.absent(),
    this.periodId = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.note = const Value.absent(),
  });
  WeeklyCheckinsCompanion.insert({
    this.id = const Value.absent(),
    required int periodId,
    required String weekStart,
    this.note = const Value.absent(),
  }) : periodId = Value(periodId),
       weekStart = Value(weekStart);
  static Insertable<WeeklyCheckin> custom({
    Expression<int>? id,
    Expression<int>? periodId,
    Expression<String>? weekStart,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (periodId != null) 'period_id': periodId,
      if (weekStart != null) 'week_start': weekStart,
      if (note != null) 'note': note,
    });
  }

  WeeklyCheckinsCompanion copyWith({
    Value<int>? id,
    Value<int>? periodId,
    Value<String>? weekStart,
    Value<String?>? note,
  }) {
    return WeeklyCheckinsCompanion(
      id: id ?? this.id,
      periodId: periodId ?? this.periodId,
      weekStart: weekStart ?? this.weekStart,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (periodId.present) {
      map['period_id'] = Variable<int>(periodId.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<String>(weekStart.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyCheckinsCompanion(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('weekStart: $weekStart, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PillarsTable pillars = $PillarsTable(this);
  late final $PeriodsTable periods = $PeriodsTable(this);
  late final $IncomesTable incomes = $IncomesTable(this);
  late final $FixedCostsTable fixedCosts = $FixedCostsTable(this);
  late final $PillarBudgetsTable pillarBudgets = $PillarBudgetsTable(this);
  late final $PaymentMethodsTable paymentMethods = $PaymentMethodsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $PlanChangesTable planChanges = $PlanChangesTable(this);
  late final $ReflectionsTable reflections = $ReflectionsTable(this);
  late final $WeeklyCheckinsTable weeklyCheckins = $WeeklyCheckinsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final Index incomesPeriod = Index(
    'incomes_period',
    'CREATE INDEX incomes_period ON incomes (period_id)',
  );
  late final Index fixedCostsPeriod = Index(
    'fixed_costs_period',
    'CREATE INDEX fixed_costs_period ON fixed_costs (period_id)',
  );
  late final Index expensesPeriodDate = Index(
    'expenses_period_date',
    'CREATE INDEX expenses_period_date ON expenses (period_id, date)',
  );
  late final Index expensesPeriodPillar = Index(
    'expenses_period_pillar',
    'CREATE INDEX expenses_period_pillar ON expenses (period_id, pillar_id)',
  );
  late final Index expensesDeleted = Index(
    'expenses_deleted',
    'CREATE INDEX expenses_deleted ON expenses (deleted_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pillars,
    periods,
    incomes,
    fixedCosts,
    pillarBudgets,
    paymentMethods,
    expenses,
    planChanges,
    reflections,
    weeklyCheckins,
    settings,
    incomesPeriod,
    fixedCostsPeriod,
    expensesPeriodDate,
    expensesPeriodPillar,
    expensesDeleted,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'periods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('incomes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'periods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('fixed_costs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'periods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pillar_budgets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'periods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expenses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'payment_methods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expenses', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'expenses',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expenses', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'periods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plan_changes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'periods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reflections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'periods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('weekly_checkins', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PillarsTableCreateCompanionBuilder = PillarsCompanion Function({
  Value<int> id,
  required String name,
  Value<int?> color,
  required String icon,
  required int sortOrder,
});
typedef $$PillarsTableUpdateCompanionBuilder = PillarsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int?> color,
  Value<String> icon,
  Value<int> sortOrder,
});

final class $$PillarsTableReferences
    extends BaseReferences<_$AppDatabase, $PillarsTable, Pillar> {
  $$PillarsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PillarBudgetsTable, List<PillarBudget>>
  _pillarBudgetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pillarBudgets,
    aliasName: 'pillars__id__pillar_budgets__pillar_id',
  );

  $$PillarBudgetsTableProcessedTableManager get pillarBudgetsRefs {
    final manager = $$PillarBudgetsTableTableManager(
      $_db,
      $_db.pillarBudgets,
    ).filter((f) => f.pillarId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pillarBudgetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'pillars__id__expenses__pillar_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.pillarId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PillarsTableFilterComposer
    extends Composer<_$AppDatabase, $PillarsTable> {
  $$PillarsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pillarBudgetsRefs(
    Expression<bool> Function($$PillarBudgetsTableFilterComposer f) f,
  ) {
    final $$PillarBudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pillarBudgets,
      getReferencedColumn: (t) => t.pillarId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PillarBudgetsTableFilterComposer(
            $db: $db,
            $table: $db.pillarBudgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.pillarId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PillarsTableOrderingComposer
    extends Composer<_$AppDatabase, $PillarsTable> {
  $$PillarsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PillarsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PillarsTable> {
  $$PillarsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> pillarBudgetsRefs<T extends Object>(
    Expression<T> Function($$PillarBudgetsTableAnnotationComposer a) f,
  ) {
    final $$PillarBudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pillarBudgets,
      getReferencedColumn: (t) => t.pillarId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PillarBudgetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pillarBudgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.pillarId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PillarsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PillarsTable,
          Pillar,
          $$PillarsTableFilterComposer,
          $$PillarsTableOrderingComposer,
          $$PillarsTableAnnotationComposer,
          $$PillarsTableCreateCompanionBuilder,
          $$PillarsTableUpdateCompanionBuilder,
          (Pillar, $$PillarsTableReferences),
          Pillar,
          PrefetchHooks Function({bool pillarBudgetsRefs, bool expensesRefs})
        > {
  $$PillarsTableTableManager(_$AppDatabase db, $PillarsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PillarsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PillarsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PillarsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => PillarsCompanion(
                id: id,
                name: name,
                color: color,
                icon: icon,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> color = const Value.absent(),
                required String icon,
                required int sortOrder,
              }) => PillarsCompanion.insert(
                id: id,
                name: name,
                color: color,
                icon: icon,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PillarsTable, Pillar>(table),
                  $$PillarsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({pillarBudgetsRefs = false, expensesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pillarBudgetsRefs) db.pillarBudgets,
                    if (expensesRefs) db.expenses,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pillarBudgetsRefs)
                        await $_getPrefetchedDataByColumns<
                          Pillar,
                          $PillarsTable,
                          PillarBudget,
                          $PillarBudgetsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PillarsTableReferences
                              ._pillarBudgetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PillarsTableReferences(
                                db,
                                table,
                                p0,
                              ).pillarBudgetsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pillar_id',
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedDataByColumns<
                          Pillar,
                          $PillarsTable,
                          Expense,
                          $ExpensesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PillarsTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PillarsTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pillar_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PillarsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PillarsTable,
      Pillar,
      $$PillarsTableFilterComposer,
      $$PillarsTableOrderingComposer,
      $$PillarsTableAnnotationComposer,
      $$PillarsTableCreateCompanionBuilder,
      $$PillarsTableUpdateCompanionBuilder,
      (Pillar, $$PillarsTableReferences),
      Pillar,
      PrefetchHooks Function({bool pillarBudgetsRefs, bool expensesRefs})
    >;
typedef $$PeriodsTableCreateCompanionBuilder = PeriodsCompanion Function({
  Value<int> id,
  required String startDate,
  required String endDate,
  Value<int> savingsGoal,
  Value<String> savingsGoalType,
  Value<int?> savingsGoalPct,
  Value<bool> savingsSetAside,
  Value<bool> isPartial,
  Value<String> status,
  required String createdAt,
  required String updatedAt,
});
typedef $$PeriodsTableUpdateCompanionBuilder = PeriodsCompanion Function({
  Value<int> id,
  Value<String> startDate,
  Value<String> endDate,
  Value<int> savingsGoal,
  Value<String> savingsGoalType,
  Value<int?> savingsGoalPct,
  Value<bool> savingsSetAside,
  Value<bool> isPartial,
  Value<String> status,
  Value<String> createdAt,
  Value<String> updatedAt,
});

final class $$PeriodsTableReferences
    extends BaseReferences<_$AppDatabase, $PeriodsTable, Period> {
  $$PeriodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$IncomesTable, List<Income>> _incomesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.incomes,
    aliasName: 'periods__id__incomes__period_id',
  );

  $$IncomesTableProcessedTableManager get incomesRefs {
    final manager = $$IncomesTableTableManager(
      $_db,
      $_db.incomes,
    ).filter((f) => f.periodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_incomesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FixedCostsTable, List<FixedCost>>
  _fixedCostsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fixedCosts,
    aliasName: 'periods__id__fixed_costs__period_id',
  );

  $$FixedCostsTableProcessedTableManager get fixedCostsRefs {
    final manager = $$FixedCostsTableTableManager(
      $_db,
      $_db.fixedCosts,
    ).filter((f) => f.periodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_fixedCostsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PillarBudgetsTable, List<PillarBudget>>
  _pillarBudgetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pillarBudgets,
    aliasName: 'periods__id__pillar_budgets__period_id',
  );

  $$PillarBudgetsTableProcessedTableManager get pillarBudgetsRefs {
    final manager = $$PillarBudgetsTableTableManager(
      $_db,
      $_db.pillarBudgets,
    ).filter((f) => f.periodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pillarBudgetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'periods__id__expenses__period_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.periodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlanChangesTable, List<PlanChange>>
  _planChangesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planChanges,
    aliasName: 'periods__id__plan_changes__period_id',
  );

  $$PlanChangesTableProcessedTableManager get planChangesRefs {
    final manager = $$PlanChangesTableTableManager(
      $_db,
      $_db.planChanges,
    ).filter((f) => f.periodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planChangesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReflectionsTable, List<Reflection>>
  _reflectionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reflections,
    aliasName: 'periods__id__reflections__period_id',
  );

  $$ReflectionsTableProcessedTableManager get reflectionsRefs {
    final manager = $$ReflectionsTableTableManager(
      $_db,
      $_db.reflections,
    ).filter((f) => f.periodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reflectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WeeklyCheckinsTable, List<WeeklyCheckin>>
  _weeklyCheckinsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.weeklyCheckins,
    aliasName: 'periods__id__weekly_checkins__period_id',
  );

  $$WeeklyCheckinsTableProcessedTableManager get weeklyCheckinsRefs {
    final manager = $$WeeklyCheckinsTableTableManager(
      $_db,
      $_db.weeklyCheckins,
    ).filter((f) => f.periodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_weeklyCheckinsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PeriodsTableFilterComposer
    extends Composer<_$AppDatabase, $PeriodsTable> {
  $$PeriodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savingsGoal => $composableBuilder(
    column: $table.savingsGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get savingsGoalType => $composableBuilder(
    column: $table.savingsGoalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savingsGoalPct => $composableBuilder(
    column: $table.savingsGoalPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get savingsSetAside => $composableBuilder(
    column: $table.savingsSetAside,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPartial => $composableBuilder(
    column: $table.isPartial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> incomesRefs(
    Expression<bool> Function($$IncomesTableFilterComposer f) f,
  ) {
    final $$IncomesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableFilterComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> fixedCostsRefs(
    Expression<bool> Function($$FixedCostsTableFilterComposer f) f,
  ) {
    final $$FixedCostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fixedCosts,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixedCostsTableFilterComposer(
            $db: $db,
            $table: $db.fixedCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pillarBudgetsRefs(
    Expression<bool> Function($$PillarBudgetsTableFilterComposer f) f,
  ) {
    final $$PillarBudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pillarBudgets,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PillarBudgetsTableFilterComposer(
            $db: $db,
            $table: $db.pillarBudgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> planChangesRefs(
    Expression<bool> Function($$PlanChangesTableFilterComposer f) f,
  ) {
    final $$PlanChangesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planChanges,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanChangesTableFilterComposer(
            $db: $db,
            $table: $db.planChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reflectionsRefs(
    Expression<bool> Function($$ReflectionsTableFilterComposer f) f,
  ) {
    final $$ReflectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reflections,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReflectionsTableFilterComposer(
            $db: $db,
            $table: $db.reflections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> weeklyCheckinsRefs(
    Expression<bool> Function($$WeeklyCheckinsTableFilterComposer f) f,
  ) {
    final $$WeeklyCheckinsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weeklyCheckins,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeeklyCheckinsTableFilterComposer(
            $db: $db,
            $table: $db.weeklyCheckins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PeriodsTableOrderingComposer
    extends Composer<_$AppDatabase, $PeriodsTable> {
  $$PeriodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savingsGoal => $composableBuilder(
    column: $table.savingsGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get savingsGoalType => $composableBuilder(
    column: $table.savingsGoalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savingsGoalPct => $composableBuilder(
    column: $table.savingsGoalPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get savingsSetAside => $composableBuilder(
    column: $table.savingsSetAside,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPartial => $composableBuilder(
    column: $table.isPartial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeriodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeriodsTable> {
  $$PeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get savingsGoal => $composableBuilder(
    column: $table.savingsGoal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get savingsGoalType => $composableBuilder(
    column: $table.savingsGoalType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get savingsGoalPct => $composableBuilder(
    column: $table.savingsGoalPct,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get savingsSetAside => $composableBuilder(
    column: $table.savingsSetAside,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPartial =>
      $composableBuilder(column: $table.isPartial, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> incomesRefs<T extends Object>(
    Expression<T> Function($$IncomesTableAnnotationComposer a) f,
  ) {
    final $$IncomesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableAnnotationComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> fixedCostsRefs<T extends Object>(
    Expression<T> Function($$FixedCostsTableAnnotationComposer a) f,
  ) {
    final $$FixedCostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fixedCosts,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixedCostsTableAnnotationComposer(
            $db: $db,
            $table: $db.fixedCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pillarBudgetsRefs<T extends Object>(
    Expression<T> Function($$PillarBudgetsTableAnnotationComposer a) f,
  ) {
    final $$PillarBudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pillarBudgets,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PillarBudgetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pillarBudgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> planChangesRefs<T extends Object>(
    Expression<T> Function($$PlanChangesTableAnnotationComposer a) f,
  ) {
    final $$PlanChangesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planChanges,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanChangesTableAnnotationComposer(
            $db: $db,
            $table: $db.planChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reflectionsRefs<T extends Object>(
    Expression<T> Function($$ReflectionsTableAnnotationComposer a) f,
  ) {
    final $$ReflectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reflections,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReflectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.reflections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> weeklyCheckinsRefs<T extends Object>(
    Expression<T> Function($$WeeklyCheckinsTableAnnotationComposer a) f,
  ) {
    final $$WeeklyCheckinsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weeklyCheckins,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeeklyCheckinsTableAnnotationComposer(
            $db: $db,
            $table: $db.weeklyCheckins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PeriodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeriodsTable,
          Period,
          $$PeriodsTableFilterComposer,
          $$PeriodsTableOrderingComposer,
          $$PeriodsTableAnnotationComposer,
          $$PeriodsTableCreateCompanionBuilder,
          $$PeriodsTableUpdateCompanionBuilder,
          (Period, $$PeriodsTableReferences),
          Period,
          PrefetchHooks Function({
            bool incomesRefs,
            bool fixedCostsRefs,
            bool pillarBudgetsRefs,
            bool expensesRefs,
            bool planChangesRefs,
            bool reflectionsRefs,
            bool weeklyCheckinsRefs,
          })
        > {
  $$PeriodsTableTableManager(_$AppDatabase db, $PeriodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeriodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeriodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeriodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String> endDate = const Value.absent(),
                Value<int> savingsGoal = const Value.absent(),
                Value<String> savingsGoalType = const Value.absent(),
                Value<int?> savingsGoalPct = const Value.absent(),
                Value<bool> savingsSetAside = const Value.absent(),
                Value<bool> isPartial = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => PeriodsCompanion(
                id: id,
                startDate: startDate,
                endDate: endDate,
                savingsGoal: savingsGoal,
                savingsGoalType: savingsGoalType,
                savingsGoalPct: savingsGoalPct,
                savingsSetAside: savingsSetAside,
                isPartial: isPartial,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String startDate,
                required String endDate,
                Value<int> savingsGoal = const Value.absent(),
                Value<String> savingsGoalType = const Value.absent(),
                Value<int?> savingsGoalPct = const Value.absent(),
                Value<bool> savingsSetAside = const Value.absent(),
                Value<bool> isPartial = const Value.absent(),
                Value<String> status = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => PeriodsCompanion.insert(
                id: id,
                startDate: startDate,
                endDate: endDate,
                savingsGoal: savingsGoal,
                savingsGoalType: savingsGoalType,
                savingsGoalPct: savingsGoalPct,
                savingsSetAside: savingsSetAside,
                isPartial: isPartial,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PeriodsTable, Period>(table),
                  $$PeriodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                incomesRefs = false,
                fixedCostsRefs = false,
                pillarBudgetsRefs = false,
                expensesRefs = false,
                planChangesRefs = false,
                reflectionsRefs = false,
                weeklyCheckinsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (incomesRefs) db.incomes,
                    if (fixedCostsRefs) db.fixedCosts,
                    if (pillarBudgetsRefs) db.pillarBudgets,
                    if (expensesRefs) db.expenses,
                    if (planChangesRefs) db.planChanges,
                    if (reflectionsRefs) db.reflections,
                    if (weeklyCheckinsRefs) db.weeklyCheckins,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (incomesRefs)
                        await $_getPrefetchedDataByColumns<
                          Period,
                          $PeriodsTable,
                          Income,
                          $IncomesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeriodsTableReferences
                              ._incomesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeriodsTableReferences(
                                db,
                                table,
                                p0,
                              ).incomesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'period_id',
                          typedResults: items,
                        ),
                      if (fixedCostsRefs)
                        await $_getPrefetchedDataByColumns<
                          Period,
                          $PeriodsTable,
                          FixedCost,
                          $FixedCostsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeriodsTableReferences
                              ._fixedCostsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeriodsTableReferences(
                                db,
                                table,
                                p0,
                              ).fixedCostsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'period_id',
                          typedResults: items,
                        ),
                      if (pillarBudgetsRefs)
                        await $_getPrefetchedDataByColumns<
                          Period,
                          $PeriodsTable,
                          PillarBudget,
                          $PillarBudgetsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeriodsTableReferences
                              ._pillarBudgetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeriodsTableReferences(
                                db,
                                table,
                                p0,
                              ).pillarBudgetsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'period_id',
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedDataByColumns<
                          Period,
                          $PeriodsTable,
                          Expense,
                          $ExpensesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeriodsTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeriodsTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'period_id',
                          typedResults: items,
                        ),
                      if (planChangesRefs)
                        await $_getPrefetchedDataByColumns<
                          Period,
                          $PeriodsTable,
                          PlanChange,
                          $PlanChangesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeriodsTableReferences
                              ._planChangesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeriodsTableReferences(
                                db,
                                table,
                                p0,
                              ).planChangesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'period_id',
                          typedResults: items,
                        ),
                      if (reflectionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Period,
                          $PeriodsTable,
                          Reflection,
                          $ReflectionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeriodsTableReferences
                              ._reflectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeriodsTableReferences(
                                db,
                                table,
                                p0,
                              ).reflectionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'period_id',
                          typedResults: items,
                        ),
                      if (weeklyCheckinsRefs)
                        await $_getPrefetchedDataByColumns<
                          Period,
                          $PeriodsTable,
                          WeeklyCheckin,
                          $WeeklyCheckinsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PeriodsTableReferences
                              ._weeklyCheckinsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeriodsTableReferences(
                                db,
                                table,
                                p0,
                              ).weeklyCheckinsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'period_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeriodsTable,
      Period,
      $$PeriodsTableFilterComposer,
      $$PeriodsTableOrderingComposer,
      $$PeriodsTableAnnotationComposer,
      $$PeriodsTableCreateCompanionBuilder,
      $$PeriodsTableUpdateCompanionBuilder,
      (Period, $$PeriodsTableReferences),
      Period,
      PrefetchHooks Function({
        bool incomesRefs,
        bool fixedCostsRefs,
        bool pillarBudgetsRefs,
        bool expensesRefs,
        bool planChangesRefs,
        bool reflectionsRefs,
        bool weeklyCheckinsRefs,
      })
    >;
typedef $$IncomesTableCreateCompanionBuilder = IncomesCompanion Function({
  Value<int> id,
  required int periodId,
  required String label,
  required int amount,
  required String date,
  Value<bool> isPlanned,
});
typedef $$IncomesTableUpdateCompanionBuilder = IncomesCompanion Function({
  Value<int> id,
  Value<int> periodId,
  Value<String> label,
  Value<int> amount,
  Value<String> date,
  Value<bool> isPlanned,
});

final class $$IncomesTableReferences
    extends BaseReferences<_$AppDatabase, $IncomesTable, Income> {
  $$IncomesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeriodsTable _periodIdTable(_$AppDatabase db) =>
      db.periods.createAlias('incomes__period_id__periods__id');

  $$PeriodsTableProcessedTableManager get periodId {
    final $_column = $_itemColumn<int>('period_id')!;

    final manager = $$PeriodsTableTableManager(
      $_db,
      $_db.periods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_periodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IncomesTableFilterComposer
    extends Composer<_$AppDatabase, $IncomesTable> {
  $$IncomesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPlanned => $composableBuilder(
    column: $table.isPlanned,
    builder: (column) => ColumnFilters(column),
  );

  $$PeriodsTableFilterComposer get periodId {
    final $$PeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableFilterComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomesTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomesTable> {
  $$IncomesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlanned => $composableBuilder(
    column: $table.isPlanned,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeriodsTableOrderingComposer get periodId {
    final $$PeriodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableOrderingComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomesTable> {
  $$IncomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isPlanned =>
      $composableBuilder(column: $table.isPlanned, builder: (column) => column);

  $$PeriodsTableAnnotationComposer get periodId {
    final $$PeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncomesTable,
          Income,
          $$IncomesTableFilterComposer,
          $$IncomesTableOrderingComposer,
          $$IncomesTableAnnotationComposer,
          $$IncomesTableCreateCompanionBuilder,
          $$IncomesTableUpdateCompanionBuilder,
          (Income, $$IncomesTableReferences),
          Income,
          PrefetchHooks Function({bool periodId})
        > {
  $$IncomesTableTableManager(_$AppDatabase db, $IncomesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> periodId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<bool> isPlanned = const Value.absent(),
              }) => IncomesCompanion(
                id: id,
                periodId: periodId,
                label: label,
                amount: amount,
                date: date,
                isPlanned: isPlanned,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int periodId,
                required String label,
                required int amount,
                required String date,
                Value<bool> isPlanned = const Value.absent(),
              }) => IncomesCompanion.insert(
                id: id,
                periodId: periodId,
                label: label,
                amount: amount,
                date: date,
                isPlanned: isPlanned,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IncomesTable, Income>(table),
                  $$IncomesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({periodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (periodId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.periodId,
                        referencedTable: $$IncomesTableReferences
                            ._periodIdTable(db),
                        referencedColumn: $$IncomesTableReferences
                            ._periodIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IncomesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncomesTable,
      Income,
      $$IncomesTableFilterComposer,
      $$IncomesTableOrderingComposer,
      $$IncomesTableAnnotationComposer,
      $$IncomesTableCreateCompanionBuilder,
      $$IncomesTableUpdateCompanionBuilder,
      (Income, $$IncomesTableReferences),
      Income,
      PrefetchHooks Function({bool periodId})
    >;
typedef $$FixedCostsTableCreateCompanionBuilder = FixedCostsCompanion Function({
  Value<int> id,
  required int periodId,
  required String label,
  required int amount,
  Value<bool> isRecurring,
});
typedef $$FixedCostsTableUpdateCompanionBuilder = FixedCostsCompanion Function({
  Value<int> id,
  Value<int> periodId,
  Value<String> label,
  Value<int> amount,
  Value<bool> isRecurring,
});

final class $$FixedCostsTableReferences
    extends BaseReferences<_$AppDatabase, $FixedCostsTable, FixedCost> {
  $$FixedCostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeriodsTable _periodIdTable(_$AppDatabase db) =>
      db.periods.createAlias('fixed_costs__period_id__periods__id');

  $$PeriodsTableProcessedTableManager get periodId {
    final $_column = $_itemColumn<int>('period_id')!;

    final manager = $$PeriodsTableTableManager(
      $_db,
      $_db.periods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_periodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FixedCostsTableFilterComposer
    extends Composer<_$AppDatabase, $FixedCostsTable> {
  $$FixedCostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnFilters(column),
  );

  $$PeriodsTableFilterComposer get periodId {
    final $$PeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableFilterComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixedCostsTableOrderingComposer
    extends Composer<_$AppDatabase, $FixedCostsTable> {
  $$FixedCostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeriodsTableOrderingComposer get periodId {
    final $$PeriodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableOrderingComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixedCostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FixedCostsTable> {
  $$FixedCostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => column,
  );

  $$PeriodsTableAnnotationComposer get periodId {
    final $$PeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixedCostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FixedCostsTable,
          FixedCost,
          $$FixedCostsTableFilterComposer,
          $$FixedCostsTableOrderingComposer,
          $$FixedCostsTableAnnotationComposer,
          $$FixedCostsTableCreateCompanionBuilder,
          $$FixedCostsTableUpdateCompanionBuilder,
          (FixedCost, $$FixedCostsTableReferences),
          FixedCost,
          PrefetchHooks Function({bool periodId})
        > {
  $$FixedCostsTableTableManager(_$AppDatabase db, $FixedCostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FixedCostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FixedCostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FixedCostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> periodId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
              }) => FixedCostsCompanion(
                id: id,
                periodId: periodId,
                label: label,
                amount: amount,
                isRecurring: isRecurring,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int periodId,
                required String label,
                required int amount,
                Value<bool> isRecurring = const Value.absent(),
              }) => FixedCostsCompanion.insert(
                id: id,
                periodId: periodId,
                label: label,
                amount: amount,
                isRecurring: isRecurring,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FixedCostsTable, FixedCost>(table),
                  $$FixedCostsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({periodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (periodId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.periodId,
                        referencedTable: $$FixedCostsTableReferences
                            ._periodIdTable(db),
                        referencedColumn: $$FixedCostsTableReferences
                            ._periodIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FixedCostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FixedCostsTable,
      FixedCost,
      $$FixedCostsTableFilterComposer,
      $$FixedCostsTableOrderingComposer,
      $$FixedCostsTableAnnotationComposer,
      $$FixedCostsTableCreateCompanionBuilder,
      $$FixedCostsTableUpdateCompanionBuilder,
      (FixedCost, $$FixedCostsTableReferences),
      FixedCost,
      PrefetchHooks Function({bool periodId})
    >;
typedef $$PillarBudgetsTableCreateCompanionBuilder =
    PillarBudgetsCompanion Function({
      required int periodId,
      required int pillarId,
      Value<int> plannedAmount,
      Value<int> rowid,
    });
typedef $$PillarBudgetsTableUpdateCompanionBuilder =
    PillarBudgetsCompanion Function({
      Value<int> periodId,
      Value<int> pillarId,
      Value<int> plannedAmount,
      Value<int> rowid,
    });

final class $$PillarBudgetsTableReferences
    extends BaseReferences<_$AppDatabase, $PillarBudgetsTable, PillarBudget> {
  $$PillarBudgetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PeriodsTable _periodIdTable(_$AppDatabase db) =>
      db.periods.createAlias('pillar_budgets__period_id__periods__id');

  $$PeriodsTableProcessedTableManager get periodId {
    final $_column = $_itemColumn<int>('period_id')!;

    final manager = $$PeriodsTableTableManager(
      $_db,
      $_db.periods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_periodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PillarsTable _pillarIdTable(_$AppDatabase db) =>
      db.pillars.createAlias('pillar_budgets__pillar_id__pillars__id');

  $$PillarsTableProcessedTableManager get pillarId {
    final $_column = $_itemColumn<int>('pillar_id')!;

    final manager = $$PillarsTableTableManager(
      $_db,
      $_db.pillars,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pillarIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PillarBudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $PillarBudgetsTable> {
  $$PillarBudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get plannedAmount => $composableBuilder(
    column: $table.plannedAmount,
    builder: (column) => ColumnFilters(column),
  );

  $$PeriodsTableFilterComposer get periodId {
    final $$PeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableFilterComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PillarsTableFilterComposer get pillarId {
    final $$PillarsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pillarId,
      referencedTable: $db.pillars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PillarsTableFilterComposer(
            $db: $db,
            $table: $db.pillars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PillarBudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $PillarBudgetsTable> {
  $$PillarBudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get plannedAmount => $composableBuilder(
    column: $table.plannedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeriodsTableOrderingComposer get periodId {
    final $$PeriodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableOrderingComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PillarsTableOrderingComposer get pillarId {
    final $$PillarsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pillarId,
      referencedTable: $db.pillars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PillarsTableOrderingComposer(
            $db: $db,
            $table: $db.pillars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PillarBudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PillarBudgetsTable> {
  $$PillarBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get plannedAmount => $composableBuilder(
    column: $table.plannedAmount,
    builder: (column) => column,
  );

  $$PeriodsTableAnnotationComposer get periodId {
    final $$PeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PillarsTableAnnotationComposer get pillarId {
    final $$PillarsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pillarId,
      referencedTable: $db.pillars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PillarsTableAnnotationComposer(
            $db: $db,
            $table: $db.pillars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PillarBudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PillarBudgetsTable,
          PillarBudget,
          $$PillarBudgetsTableFilterComposer,
          $$PillarBudgetsTableOrderingComposer,
          $$PillarBudgetsTableAnnotationComposer,
          $$PillarBudgetsTableCreateCompanionBuilder,
          $$PillarBudgetsTableUpdateCompanionBuilder,
          (PillarBudget, $$PillarBudgetsTableReferences),
          PillarBudget,
          PrefetchHooks Function({bool periodId, bool pillarId})
        > {
  $$PillarBudgetsTableTableManager(_$AppDatabase db, $PillarBudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PillarBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PillarBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PillarBudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> periodId = const Value.absent(),
                Value<int> pillarId = const Value.absent(),
                Value<int> plannedAmount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PillarBudgetsCompanion(
                periodId: periodId,
                pillarId: pillarId,
                plannedAmount: plannedAmount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int periodId,
                required int pillarId,
                Value<int> plannedAmount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PillarBudgetsCompanion.insert(
                periodId: periodId,
                pillarId: pillarId,
                plannedAmount: plannedAmount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PillarBudgetsTable, PillarBudget>(table),
                  $$PillarBudgetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({periodId = false, pillarId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (periodId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.periodId,
                        referencedTable: $$PillarBudgetsTableReferences
                            ._periodIdTable(db),
                        referencedColumn: $$PillarBudgetsTableReferences
                            ._periodIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (pillarId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pillarId,
                        referencedTable: $$PillarBudgetsTableReferences
                            ._pillarIdTable(db),
                        referencedColumn: $$PillarBudgetsTableReferences
                            ._pillarIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PillarBudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PillarBudgetsTable,
      PillarBudget,
      $$PillarBudgetsTableFilterComposer,
      $$PillarBudgetsTableOrderingComposer,
      $$PillarBudgetsTableAnnotationComposer,
      $$PillarBudgetsTableCreateCompanionBuilder,
      $$PillarBudgetsTableUpdateCompanionBuilder,
      (PillarBudget, $$PillarBudgetsTableReferences),
      PillarBudget,
      PrefetchHooks Function({bool periodId, bool pillarId})
    >;
typedef $$PaymentMethodsTableCreateCompanionBuilder =
    PaymentMethodsCompanion Function({
      Value<int> id,
      required String name,
      required String icon,
      Value<bool> isHidden,
      required int sortOrder,
    });
typedef $$PaymentMethodsTableUpdateCompanionBuilder =
    PaymentMethodsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> icon,
      Value<bool> isHidden,
      Value<int> sortOrder,
    });

final class $$PaymentMethodsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentMethodsTable, PaymentMethod> {
  $$PaymentMethodsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'payment_methods__id__expenses__payment_method_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.paymentMethodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PaymentMethodsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.paymentMethodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentMethodsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentMethodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.paymentMethodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentMethodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentMethodsTable,
          PaymentMethod,
          $$PaymentMethodsTableFilterComposer,
          $$PaymentMethodsTableOrderingComposer,
          $$PaymentMethodsTableAnnotationComposer,
          $$PaymentMethodsTableCreateCompanionBuilder,
          $$PaymentMethodsTableUpdateCompanionBuilder,
          (PaymentMethod, $$PaymentMethodsTableReferences),
          PaymentMethod,
          PrefetchHooks Function({bool expensesRefs})
        > {
  $$PaymentMethodsTableTableManager(
    _$AppDatabase db,
    $PaymentMethodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentMethodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentMethodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentMethodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => PaymentMethodsCompanion(
                id: id,
                name: name,
                icon: icon,
                isHidden: isHidden,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String icon,
                Value<bool> isHidden = const Value.absent(),
                required int sortOrder,
              }) => PaymentMethodsCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                isHidden: isHidden,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentMethodsTable, PaymentMethod>(table),
                  $$PaymentMethodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (expensesRefs) db.expenses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedDataByColumns<
                      PaymentMethod,
                      $PaymentMethodsTable,
                      Expense,
                      $ExpensesTable
                    >(
                      currentTable: table,
                      referencedTable: $$PaymentMethodsTableReferences
                          ._expensesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PaymentMethodsTableReferences(
                            db,
                            table,
                            p0,
                          ).expensesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'payment_method_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PaymentMethodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentMethodsTable,
      PaymentMethod,
      $$PaymentMethodsTableFilterComposer,
      $$PaymentMethodsTableOrderingComposer,
      $$PaymentMethodsTableAnnotationComposer,
      $$PaymentMethodsTableCreateCompanionBuilder,
      $$PaymentMethodsTableUpdateCompanionBuilder,
      (PaymentMethod, $$PaymentMethodsTableReferences),
      PaymentMethod,
      PrefetchHooks Function({bool expensesRefs})
    >;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  required int periodId,
  required int pillarId,
  Value<String> type,
  required int amount,
  Value<String?> note,
  required String date,
  Value<String?> mood,
  Value<int?> paymentMethodId,
  Value<int?> refundOfId,
  Value<String?> splitGroupId,
  Value<bool> isLumpSum,
  Value<String?> deletedAt,
  required String createdAt,
  required String updatedAt,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<int> periodId,
  Value<int> pillarId,
  Value<String> type,
  Value<int> amount,
  Value<String?> note,
  Value<String> date,
  Value<String?> mood,
  Value<int?> paymentMethodId,
  Value<int?> refundOfId,
  Value<String?> splitGroupId,
  Value<bool> isLumpSum,
  Value<String?> deletedAt,
  Value<String> createdAt,
  Value<String> updatedAt,
});

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeriodsTable _periodIdTable(_$AppDatabase db) =>
      db.periods.createAlias('expenses__period_id__periods__id');

  $$PeriodsTableProcessedTableManager get periodId {
    final $_column = $_itemColumn<int>('period_id')!;

    final manager = $$PeriodsTableTableManager(
      $_db,
      $_db.periods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_periodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PillarsTable _pillarIdTable(_$AppDatabase db) =>
      db.pillars.createAlias('expenses__pillar_id__pillars__id');

  $$PillarsTableProcessedTableManager get pillarId {
    final $_column = $_itemColumn<int>('pillar_id')!;

    final manager = $$PillarsTableTableManager(
      $_db,
      $_db.pillars,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pillarIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PaymentMethodsTable _paymentMethodIdTable(_$AppDatabase db) => db
      .paymentMethods
      .createAlias('expenses__payment_method_id__payment_methods__id');

  $$PaymentMethodsTableProcessedTableManager? get paymentMethodId {
    final $_column = $_itemColumn<int>('payment_method_id');
    if ($_column == null) return null;
    final manager = $$PaymentMethodsTableTableManager(
      $_db,
      $_db.paymentMethods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentMethodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExpensesTable _refundOfIdTable(_$AppDatabase db) =>
      db.expenses.createAlias('expenses__refund_of_id__expenses__id');

  $$ExpensesTableProcessedTableManager? get refundOfId {
    final $_column = $_itemColumn<int>('refund_of_id');
    if ($_column == null) return null;
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_refundOfIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get splitGroupId => $composableBuilder(
    column: $table.splitGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLumpSum => $composableBuilder(
    column: $table.isLumpSum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PeriodsTableFilterComposer get periodId {
    final $$PeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableFilterComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PillarsTableFilterComposer get pillarId {
    final $$PillarsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pillarId,
      referencedTable: $db.pillars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PillarsTableFilterComposer(
            $db: $db,
            $table: $db.pillars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentMethodsTableFilterComposer get paymentMethodId {
    final $$PaymentMethodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableFilterComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpensesTableFilterComposer get refundOfId {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refundOfId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get splitGroupId => $composableBuilder(
    column: $table.splitGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLumpSum => $composableBuilder(
    column: $table.isLumpSum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeriodsTableOrderingComposer get periodId {
    final $$PeriodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableOrderingComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PillarsTableOrderingComposer get pillarId {
    final $$PillarsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pillarId,
      referencedTable: $db.pillars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PillarsTableOrderingComposer(
            $db: $db,
            $table: $db.pillars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentMethodsTableOrderingComposer get paymentMethodId {
    final $$PaymentMethodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableOrderingComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpensesTableOrderingComposer get refundOfId {
    final $$ExpensesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refundOfId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableOrderingComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get splitGroupId => $composableBuilder(
    column: $table.splitGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLumpSum =>
      $composableBuilder(column: $table.isLumpSum, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PeriodsTableAnnotationComposer get periodId {
    final $$PeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PillarsTableAnnotationComposer get pillarId {
    final $$PillarsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pillarId,
      referencedTable: $db.pillars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PillarsTableAnnotationComposer(
            $db: $db,
            $table: $db.pillars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentMethodsTableAnnotationComposer get paymentMethodId {
    final $$PaymentMethodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpensesTableAnnotationComposer get refundOfId {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refundOfId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({
            bool periodId,
            bool pillarId,
            bool paymentMethodId,
            bool refundOfId,
          })
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> periodId = const Value.absent(),
                Value<int> pillarId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<int?> paymentMethodId = const Value.absent(),
                Value<int?> refundOfId = const Value.absent(),
                Value<String?> splitGroupId = const Value.absent(),
                Value<bool> isLumpSum = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                periodId: periodId,
                pillarId: pillarId,
                type: type,
                amount: amount,
                note: note,
                date: date,
                mood: mood,
                paymentMethodId: paymentMethodId,
                refundOfId: refundOfId,
                splitGroupId: splitGroupId,
                isLumpSum: isLumpSum,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int periodId,
                required int pillarId,
                Value<String> type = const Value.absent(),
                required int amount,
                Value<String?> note = const Value.absent(),
                required String date,
                Value<String?> mood = const Value.absent(),
                Value<int?> paymentMethodId = const Value.absent(),
                Value<int?> refundOfId = const Value.absent(),
                Value<String?> splitGroupId = const Value.absent(),
                Value<bool> isLumpSum = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => ExpensesCompanion.insert(
                id: id,
                periodId: periodId,
                pillarId: pillarId,
                type: type,
                amount: amount,
                note: note,
                date: date,
                mood: mood,
                paymentMethodId: paymentMethodId,
                refundOfId: refundOfId,
                splitGroupId: splitGroupId,
                isLumpSum: isLumpSum,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTable, Expense>(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                periodId = false,
                pillarId = false,
                paymentMethodId = false,
                refundOfId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (periodId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.periodId,
                            referencedTable: $$ExpensesTableReferences
                                ._periodIdTable(db),
                            referencedColumn: $$ExpensesTableReferences
                                ._periodIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (pillarId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.pillarId,
                            referencedTable: $$ExpensesTableReferences
                                ._pillarIdTable(db),
                            referencedColumn: $$ExpensesTableReferences
                                ._pillarIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (paymentMethodId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.paymentMethodId,
                            referencedTable: $$ExpensesTableReferences
                                ._paymentMethodIdTable(db),
                            referencedColumn: $$ExpensesTableReferences
                                ._paymentMethodIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (refundOfId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.refundOfId,
                            referencedTable: $$ExpensesTableReferences
                                ._refundOfIdTable(db),
                            referencedColumn: $$ExpensesTableReferences
                                ._refundOfIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({
        bool periodId,
        bool pillarId,
        bool paymentMethodId,
        bool refundOfId,
      })
    >;
typedef $$PlanChangesTableCreateCompanionBuilder =
    PlanChangesCompanion Function({
      Value<int> id,
      required int periodId,
      required String field,
      Value<String?> oldValue,
      Value<String?> newValue,
      required String changedAt,
    });
typedef $$PlanChangesTableUpdateCompanionBuilder =
    PlanChangesCompanion Function({
      Value<int> id,
      Value<int> periodId,
      Value<String> field,
      Value<String?> oldValue,
      Value<String?> newValue,
      Value<String> changedAt,
    });

final class $$PlanChangesTableReferences
    extends BaseReferences<_$AppDatabase, $PlanChangesTable, PlanChange> {
  $$PlanChangesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeriodsTable _periodIdTable(_$AppDatabase db) =>
      db.periods.createAlias('plan_changes__period_id__periods__id');

  $$PeriodsTableProcessedTableManager get periodId {
    final $_column = $_itemColumn<int>('period_id')!;

    final manager = $$PeriodsTableTableManager(
      $_db,
      $_db.periods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_periodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlanChangesTableFilterComposer
    extends Composer<_$AppDatabase, $PlanChangesTable> {
  $$PlanChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PeriodsTableFilterComposer get periodId {
    final $$PeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableFilterComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanChangesTable> {
  $$PlanChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeriodsTableOrderingComposer get periodId {
    final $$PeriodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableOrderingComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanChangesTable> {
  $$PlanChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  GeneratedColumn<String> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  $$PeriodsTableAnnotationComposer get periodId {
    final $$PeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanChangesTable,
          PlanChange,
          $$PlanChangesTableFilterComposer,
          $$PlanChangesTableOrderingComposer,
          $$PlanChangesTableAnnotationComposer,
          $$PlanChangesTableCreateCompanionBuilder,
          $$PlanChangesTableUpdateCompanionBuilder,
          (PlanChange, $$PlanChangesTableReferences),
          PlanChange,
          PrefetchHooks Function({bool periodId})
        > {
  $$PlanChangesTableTableManager(_$AppDatabase db, $PlanChangesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> periodId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<String> changedAt = const Value.absent(),
              }) => PlanChangesCompanion(
                id: id,
                periodId: periodId,
                field: field,
                oldValue: oldValue,
                newValue: newValue,
                changedAt: changedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int periodId,
                required String field,
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                required String changedAt,
              }) => PlanChangesCompanion.insert(
                id: id,
                periodId: periodId,
                field: field,
                oldValue: oldValue,
                newValue: newValue,
                changedAt: changedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanChangesTable, PlanChange>(table),
                  $$PlanChangesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({periodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (periodId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.periodId,
                        referencedTable: $$PlanChangesTableReferences
                            ._periodIdTable(db),
                        referencedColumn: $$PlanChangesTableReferences
                            ._periodIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlanChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanChangesTable,
      PlanChange,
      $$PlanChangesTableFilterComposer,
      $$PlanChangesTableOrderingComposer,
      $$PlanChangesTableAnnotationComposer,
      $$PlanChangesTableCreateCompanionBuilder,
      $$PlanChangesTableUpdateCompanionBuilder,
      (PlanChange, $$PlanChangesTableReferences),
      PlanChange,
      PrefetchHooks Function({bool periodId})
    >;
typedef $$ReflectionsTableCreateCompanionBuilder =
    ReflectionsCompanion Function({
      Value<int> periodId,
      required int savedAmount,
      required bool goalMet,
      Value<String?> answerQ1,
      Value<String?> answerQ2,
      Value<String?> answerQ3,
      Value<String?> answerQ4,
      Value<String?> prevImprovementKept,
      Value<String?> improvement,
      Value<String?> completedAt,
      Value<int> editedAfterClose,
    });
typedef $$ReflectionsTableUpdateCompanionBuilder =
    ReflectionsCompanion Function({
      Value<int> periodId,
      Value<int> savedAmount,
      Value<bool> goalMet,
      Value<String?> answerQ1,
      Value<String?> answerQ2,
      Value<String?> answerQ3,
      Value<String?> answerQ4,
      Value<String?> prevImprovementKept,
      Value<String?> improvement,
      Value<String?> completedAt,
      Value<int> editedAfterClose,
    });

final class $$ReflectionsTableReferences
    extends BaseReferences<_$AppDatabase, $ReflectionsTable, Reflection> {
  $$ReflectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeriodsTable _periodIdTable(_$AppDatabase db) =>
      db.periods.createAlias('reflections__period_id__periods__id');

  $$PeriodsTableProcessedTableManager get periodId {
    final $_column = $_itemColumn<int>('period_id')!;

    final manager = $$PeriodsTableTableManager(
      $_db,
      $_db.periods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_periodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReflectionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReflectionsTable> {
  $$ReflectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get savedAmount => $composableBuilder(
    column: $table.savedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get goalMet => $composableBuilder(
    column: $table.goalMet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answerQ1 => $composableBuilder(
    column: $table.answerQ1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answerQ2 => $composableBuilder(
    column: $table.answerQ2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answerQ3 => $composableBuilder(
    column: $table.answerQ3,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answerQ4 => $composableBuilder(
    column: $table.answerQ4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prevImprovementKept => $composableBuilder(
    column: $table.prevImprovementKept,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get improvement => $composableBuilder(
    column: $table.improvement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get editedAfterClose => $composableBuilder(
    column: $table.editedAfterClose,
    builder: (column) => ColumnFilters(column),
  );

  $$PeriodsTableFilterComposer get periodId {
    final $$PeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableFilterComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReflectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReflectionsTable> {
  $$ReflectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get savedAmount => $composableBuilder(
    column: $table.savedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get goalMet => $composableBuilder(
    column: $table.goalMet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerQ1 => $composableBuilder(
    column: $table.answerQ1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerQ2 => $composableBuilder(
    column: $table.answerQ2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerQ3 => $composableBuilder(
    column: $table.answerQ3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerQ4 => $composableBuilder(
    column: $table.answerQ4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prevImprovementKept => $composableBuilder(
    column: $table.prevImprovementKept,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get improvement => $composableBuilder(
    column: $table.improvement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get editedAfterClose => $composableBuilder(
    column: $table.editedAfterClose,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeriodsTableOrderingComposer get periodId {
    final $$PeriodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableOrderingComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReflectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReflectionsTable> {
  $$ReflectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get savedAmount => $composableBuilder(
    column: $table.savedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get goalMet =>
      $composableBuilder(column: $table.goalMet, builder: (column) => column);

  GeneratedColumn<String> get answerQ1 =>
      $composableBuilder(column: $table.answerQ1, builder: (column) => column);

  GeneratedColumn<String> get answerQ2 =>
      $composableBuilder(column: $table.answerQ2, builder: (column) => column);

  GeneratedColumn<String> get answerQ3 =>
      $composableBuilder(column: $table.answerQ3, builder: (column) => column);

  GeneratedColumn<String> get answerQ4 =>
      $composableBuilder(column: $table.answerQ4, builder: (column) => column);

  GeneratedColumn<String> get prevImprovementKept => $composableBuilder(
    column: $table.prevImprovementKept,
    builder: (column) => column,
  );

  GeneratedColumn<String> get improvement => $composableBuilder(
    column: $table.improvement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get editedAfterClose => $composableBuilder(
    column: $table.editedAfterClose,
    builder: (column) => column,
  );

  $$PeriodsTableAnnotationComposer get periodId {
    final $$PeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReflectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReflectionsTable,
          Reflection,
          $$ReflectionsTableFilterComposer,
          $$ReflectionsTableOrderingComposer,
          $$ReflectionsTableAnnotationComposer,
          $$ReflectionsTableCreateCompanionBuilder,
          $$ReflectionsTableUpdateCompanionBuilder,
          (Reflection, $$ReflectionsTableReferences),
          Reflection,
          PrefetchHooks Function({bool periodId})
        > {
  $$ReflectionsTableTableManager(_$AppDatabase db, $ReflectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReflectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReflectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReflectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> periodId = const Value.absent(),
                Value<int> savedAmount = const Value.absent(),
                Value<bool> goalMet = const Value.absent(),
                Value<String?> answerQ1 = const Value.absent(),
                Value<String?> answerQ2 = const Value.absent(),
                Value<String?> answerQ3 = const Value.absent(),
                Value<String?> answerQ4 = const Value.absent(),
                Value<String?> prevImprovementKept = const Value.absent(),
                Value<String?> improvement = const Value.absent(),
                Value<String?> completedAt = const Value.absent(),
                Value<int> editedAfterClose = const Value.absent(),
              }) => ReflectionsCompanion(
                periodId: periodId,
                savedAmount: savedAmount,
                goalMet: goalMet,
                answerQ1: answerQ1,
                answerQ2: answerQ2,
                answerQ3: answerQ3,
                answerQ4: answerQ4,
                prevImprovementKept: prevImprovementKept,
                improvement: improvement,
                completedAt: completedAt,
                editedAfterClose: editedAfterClose,
              ),
          createCompanionCallback:
              ({
                Value<int> periodId = const Value.absent(),
                required int savedAmount,
                required bool goalMet,
                Value<String?> answerQ1 = const Value.absent(),
                Value<String?> answerQ2 = const Value.absent(),
                Value<String?> answerQ3 = const Value.absent(),
                Value<String?> answerQ4 = const Value.absent(),
                Value<String?> prevImprovementKept = const Value.absent(),
                Value<String?> improvement = const Value.absent(),
                Value<String?> completedAt = const Value.absent(),
                Value<int> editedAfterClose = const Value.absent(),
              }) => ReflectionsCompanion.insert(
                periodId: periodId,
                savedAmount: savedAmount,
                goalMet: goalMet,
                answerQ1: answerQ1,
                answerQ2: answerQ2,
                answerQ3: answerQ3,
                answerQ4: answerQ4,
                prevImprovementKept: prevImprovementKept,
                improvement: improvement,
                completedAt: completedAt,
                editedAfterClose: editedAfterClose,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReflectionsTable, Reflection>(table),
                  $$ReflectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({periodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (periodId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.periodId,
                        referencedTable: $$ReflectionsTableReferences
                            ._periodIdTable(db),
                        referencedColumn: $$ReflectionsTableReferences
                            ._periodIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReflectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReflectionsTable,
      Reflection,
      $$ReflectionsTableFilterComposer,
      $$ReflectionsTableOrderingComposer,
      $$ReflectionsTableAnnotationComposer,
      $$ReflectionsTableCreateCompanionBuilder,
      $$ReflectionsTableUpdateCompanionBuilder,
      (Reflection, $$ReflectionsTableReferences),
      Reflection,
      PrefetchHooks Function({bool periodId})
    >;
typedef $$WeeklyCheckinsTableCreateCompanionBuilder =
    WeeklyCheckinsCompanion Function({
      Value<int> id,
      required int periodId,
      required String weekStart,
      Value<String?> note,
    });
typedef $$WeeklyCheckinsTableUpdateCompanionBuilder =
    WeeklyCheckinsCompanion Function({
      Value<int> id,
      Value<int> periodId,
      Value<String> weekStart,
      Value<String?> note,
    });

final class $$WeeklyCheckinsTableReferences
    extends BaseReferences<_$AppDatabase, $WeeklyCheckinsTable, WeeklyCheckin> {
  $$WeeklyCheckinsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PeriodsTable _periodIdTable(_$AppDatabase db) =>
      db.periods.createAlias('weekly_checkins__period_id__periods__id');

  $$PeriodsTableProcessedTableManager get periodId {
    final $_column = $_itemColumn<int>('period_id')!;

    final manager = $$PeriodsTableTableManager(
      $_db,
      $_db.periods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_periodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WeeklyCheckinsTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklyCheckinsTable> {
  $$WeeklyCheckinsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$PeriodsTableFilterComposer get periodId {
    final $$PeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableFilterComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeeklyCheckinsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklyCheckinsTable> {
  $$WeeklyCheckinsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeriodsTableOrderingComposer get periodId {
    final $$PeriodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableOrderingComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeeklyCheckinsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklyCheckinsTable> {
  $$WeeklyCheckinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$PeriodsTableAnnotationComposer get periodId {
    final $$PeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.periods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.periods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeeklyCheckinsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeeklyCheckinsTable,
          WeeklyCheckin,
          $$WeeklyCheckinsTableFilterComposer,
          $$WeeklyCheckinsTableOrderingComposer,
          $$WeeklyCheckinsTableAnnotationComposer,
          $$WeeklyCheckinsTableCreateCompanionBuilder,
          $$WeeklyCheckinsTableUpdateCompanionBuilder,
          (WeeklyCheckin, $$WeeklyCheckinsTableReferences),
          WeeklyCheckin,
          PrefetchHooks Function({bool periodId})
        > {
  $$WeeklyCheckinsTableTableManager(
    _$AppDatabase db,
    $WeeklyCheckinsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyCheckinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyCheckinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyCheckinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> periodId = const Value.absent(),
                Value<String> weekStart = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => WeeklyCheckinsCompanion(
                id: id,
                periodId: periodId,
                weekStart: weekStart,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int periodId,
                required String weekStart,
                Value<String?> note = const Value.absent(),
              }) => WeeklyCheckinsCompanion.insert(
                id: id,
                periodId: periodId,
                weekStart: weekStart,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeeklyCheckinsTable, WeeklyCheckin>(table),
                  $$WeeklyCheckinsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({periodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (periodId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.periodId,
                        referencedTable: $$WeeklyCheckinsTableReferences
                            ._periodIdTable(db),
                        referencedColumn: $$WeeklyCheckinsTableReferences
                            ._periodIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WeeklyCheckinsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeeklyCheckinsTable,
      WeeklyCheckin,
      $$WeeklyCheckinsTableFilterComposer,
      $$WeeklyCheckinsTableOrderingComposer,
      $$WeeklyCheckinsTableAnnotationComposer,
      $$WeeklyCheckinsTableCreateCompanionBuilder,
      $$WeeklyCheckinsTableUpdateCompanionBuilder,
      (WeeklyCheckin, $$WeeklyCheckinsTableReferences),
      WeeklyCheckin,
      PrefetchHooks Function({bool periodId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PillarsTableTableManager get pillars =>
      $$PillarsTableTableManager(_db, _db.pillars);
  $$PeriodsTableTableManager get periods =>
      $$PeriodsTableTableManager(_db, _db.periods);
  $$IncomesTableTableManager get incomes =>
      $$IncomesTableTableManager(_db, _db.incomes);
  $$FixedCostsTableTableManager get fixedCosts =>
      $$FixedCostsTableTableManager(_db, _db.fixedCosts);
  $$PillarBudgetsTableTableManager get pillarBudgets =>
      $$PillarBudgetsTableTableManager(_db, _db.pillarBudgets);
  $$PaymentMethodsTableTableManager get paymentMethods =>
      $$PaymentMethodsTableTableManager(_db, _db.paymentMethods);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$PlanChangesTableTableManager get planChanges =>
      $$PlanChangesTableTableManager(_db, _db.planChanges);
  $$ReflectionsTableTableManager get reflections =>
      $$ReflectionsTableTableManager(_db, _db.reflections);
  $$WeeklyCheckinsTableTableManager get weeklyCheckins =>
      $$WeeklyCheckinsTableTableManager(_db, _db.weeklyCheckins);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
