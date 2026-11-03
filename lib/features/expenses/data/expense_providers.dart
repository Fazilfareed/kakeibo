import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import 'expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => ExpenseRepository(ref.watch(appDatabaseProvider)),
);

final periodExpensesProvider = StreamProvider.family<List<Expense>, int>(
  (ref, periodId) => ref.watch(expenseRepositoryProvider).watchForPeriod(periodId),
);

final pillarTotalsProvider = StreamProvider.family<Map<int, int>, int>(
  (ref, periodId) => ref.watch(expenseRepositoryProvider).watchPillarTotals(periodId),
);

final paymentMethodsProvider = StreamProvider<List<PaymentMethod>>(
  (ref) => ref.watch(expenseRepositoryProvider).watchPaymentMethods(),
);
