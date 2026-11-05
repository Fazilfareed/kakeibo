import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/checkin/presentation/checkin_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/guide/presentation/help_screen.dart';
import '../features/guide/presentation/welcome_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/history/presentation/month_detail_screen.dart';
import '../features/periods/presentation/plan_month_screen.dart';
import '../features/reflection/presentation/reflection_screen.dart';
import '../features/settings/presentation/currency_format_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/stats/presentation/stats_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import 'shell/app_shell.dart';

abstract final class Routes {
  static const home = '/home';
  static const transactions = '/transactions';
  static const history = '/history';
  static const settings = '/settings';
  static const currencyFormat = '/settings/currency';
  static const plan = '/plan';
  static const checkin = '/checkin';
  static const stats = '/stats';
  static const welcome = '/welcome';
  static const replayGuide = '/guide';
  static const help = '/help';
  static String reflect(int periodId) => '/reflect/$periodId';
  static String month(int periodId) => '/history/$periodId';
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
      GoRoute(
        path: Routes.help,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const HelpScreen(),
        routes: [
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootKey,
            builder: (_, state) => HelpArticleScreen(id: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: Routes.welcome,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.replayGuide,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const WelcomeScreen(replay: true),
      ),
      GoRoute(
        path: Routes.stats,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const StatsScreen(),
      ),
      GoRoute(
        path: Routes.checkin,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const CheckinScreen(),
      ),
      GoRoute(
        path: '/reflect/:periodId',
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            ReflectionScreen(periodId: int.parse(state.pathParameters['periodId']!)),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.home, builder: (_, _) => const DashboardScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.transactions, builder: (_, _) => const TransactionsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.history,
                builder: (_, _) => const HistoryScreen(),
                routes: [
                  GoRoute(
                    path: ':periodId',
                    builder: (_, state) =>
                        MonthDetailScreen(periodId: int.parse(state.pathParameters['periodId']!)),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                builder: (_, _) => const SettingsScreen(),
                routes: [
                  GoRoute(path: 'currency', builder: (_, _) => const CurrencyFormatScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
