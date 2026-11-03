import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/periods/presentation/plan_month_screen.dart';
import '../features/settings/presentation/currency_format_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import 'shell/app_shell.dart';

abstract final class Routes {
  static const home = '/home';
  static const transactions = '/transactions';
  static const history = '/history';
  static const settings = '/settings';
  static const currencyFormat = '/settings/currency';
  static const plan = '/plan';
}

final _rootKey = GlobalKey<NavigatorState>();

GoRouter buildRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.home,
    routes: [
      // Full-screen pages cover the bottom bar.
      GoRoute(
        path: Routes.plan,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const PlanMonthScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.home, builder: (_, _) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.transactions, builder: (_, _) => const TransactionsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.history, builder: (_, _) => const HistoryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.settings,
              builder: (_, _) => const SettingsScreen(),
              routes: [
                GoRoute(path: 'currency', builder: (_, _) => const CurrencyFormatScreen()),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
}
