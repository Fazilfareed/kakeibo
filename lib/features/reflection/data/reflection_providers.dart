import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../domain/reflection_summary.dart';
import 'reflection_repository.dart';

final reflectionRepositoryProvider = Provider<ReflectionRepository>(
  (ref) => ReflectionRepository(ref.watch(appDatabaseProvider)),
);

/// The closed month still waiting for its reflection (FR-50), or null.
final pendingReflectionProvider = StreamProvider<Period?>(
  (ref) => ref.watch(reflectionRepositoryProvider).watchPending(),
);

/// Loaded once when the wizard opens; the wizard keeps its own answers.
final reflectionSummaryProvider = FutureProvider.autoDispose.family<ReflectionSummary, int>(
  (ref, periodId) => ref.watch(reflectionRepositoryProvider).load(periodId),
);
