import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/backup/data/backup_providers.dart';
import '../features/lock/presentation/lock_screen.dart';
import '../features/periods/data/period_providers.dart';
import '../features/reminders/data/reminder_providers.dart';
import '../features/settings/domain/app_preferences.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class KakeiboApp extends ConsumerStatefulWidget {
  const KakeiboApp({super.key});

  @override
  ConsumerState<KakeiboApp> createState() => _KakeiboAppState();
}

class _KakeiboAppState extends ConsumerState<KakeiboApp> {
  late final GoRouter _router = buildRouter();
  final _light = buildTheme(Brightness.light);
  final _dark = buildTheme(Brightness.dark);

  // Month rollover runs on start and on every resume (PRD §12.4).
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () {
      ref.invalidate(ledgerBootstrapProvider);
      ref.invalidate(autoBackupRunProvider);
      // A new day or changed system settings: re-check and re-plan.
      ref.invalidate(notificationsAllowedProvider);
      ref.invalidate(currentSummaryProvider);
    },
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
    // Tapping a reminder opens its screen.
    ref.read(notificationServiceProvider).onOpenRoute = (route) {
      if (route == Routes.home) {
        _router.go(route);
      } else {
        _router.push(route);
      }
    };
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(ledgerBootstrapProvider);
    ref.watch(reminderSyncProvider);
    ref.watch(autoBackupRunProvider);
    return MaterialApp.router(
      title: 'Kakeibo',
      debugShowCheckedModeBanner: false,
      theme: _light,
      darkTheme: _dark,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: _router,
      builder: (context, child) => AppLockGate(child: child ?? const SizedBox()),
    );
  }
}
