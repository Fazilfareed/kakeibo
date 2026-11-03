import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
