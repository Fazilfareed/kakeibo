import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/periods/data/period_providers.dart';
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
    onResume: () => ref.invalidate(ledgerBootstrapProvider),
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
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
    return MaterialApp.router(
      title: 'Kakeibo',
      debugShowCheckedModeBanner: false,
      theme: _light,
      darkTheme: _dark,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: _router,
    );
  }
}
