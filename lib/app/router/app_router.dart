import 'package:go_router/go_router.dart';
import 'package:rikit/app/app/app_dependencies.dart';
import 'package:rikit/app/router/app_routes.dart';
import 'package:rikit/features/home/presentation/views/home_page.dart';
import 'package:rikit/features/json/presentation/views/json_tool_page.dart';
import 'package:rikit/shared/logging/presentation/log_settings_page.dart';
import 'package:rikit/shared/logging/presentation/logs_page.dart';
import 'package:rikit/shared/presentation/app_shell.dart';

GoRouter createAppRouter(AppDependencies dependencies) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(
          currentLocation: state.uri.path,
          notifications: dependencies.notifications,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: AppRoutes.jsonFormatter,
            pageBuilder: (context, state) => NoTransitionPage(
              child: JsonToolPage(controller: dependencies.jsonToolController),
            ),
          ),
          GoRoute(
            path: AppRoutes.logs,
            pageBuilder: (context, state) => NoTransitionPage(
              child: LogsPage(repository: dependencies.logRepository),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => NoTransitionPage(
              child: LogSettingsPage(
                repository: dependencies.logRepository,
                notifications: dependencies.notifications,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
