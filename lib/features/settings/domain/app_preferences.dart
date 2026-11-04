import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/currency_format.dart';
import '../../../core/money/money_formatter.dart';
import '../data/settings_repository.dart';

const String themeKey = 'theme';

ThemeMode themeModeFromSetting(String? value) => switch (value) {
  'light' => ThemeMode.light,
  'dark' => ThemeMode.dark,
  _ => ThemeMode.system,
};

/// Theme mode chosen in Settings (system by default).
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider).value;
  return themeModeFromSetting(settings?[themeKey]);
});

/// The user's currency display format (FR-109).
final currencyFormatProvider = Provider<CurrencyFormat>((ref) {
  final settings = ref.watch(settingsProvider).value;
  return settings == null ? const CurrencyFormat() : CurrencyFormat.fromSettings(settings);
});

/// The one formatter every money widget uses.
final moneyFormatterProvider = Provider<MoneyFormatter>(
  (ref) => MoneyFormatter(ref.watch(currencyFormatProvider)),
);
