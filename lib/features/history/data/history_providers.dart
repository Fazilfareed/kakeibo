import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database_provider.dart';
import 'history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(appDatabaseProvider)),
);

/// Every month, newest first (the current one included).
final historyMonthsProvider = StreamProvider<List<MonthRecord>>(
  (ref) => ref.watch(historyRepositoryProvider).watchMonths(),
);
