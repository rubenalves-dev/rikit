import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rikit/app/app/app_dependencies.dart';
import 'package:rikit/app/router/app_routes.dart';
import 'package:rikit/features/home/presentation/views/home_page.dart';
import 'package:rikit/features/json/presentation/views/json_tool_page.dart';
import 'package:rikit/shared/presentation/app_shell.dart';
import 'package:rikit/shared/presentation/placeholder_page.dart';

GoRouter createAppRouter(AppDependencies dependencies) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(currentLocation: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: AppRoutes.jsonFormatter,
            pageBuilder: (context, state) => NoTransitionPage(
              child: JsonToolPage(formatJson: dependencies.formatJson),
            ),
          ),
          GoRoute(
            path: AppRoutes.logs,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlaceholderPage(
                title: 'Logs',
                description:
                    'Sanitized application events and diagnostics will appear here.',
                icon: Icons.receipt_long_rounded,
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlaceholderPage(
                title: 'Settings',
                description:
                    'Tune persistence, retention, and application preferences.',
                icon: Icons.tune_rounded,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
