import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:rikit/features/activity/domain/activity_repository.dart';
import 'package:rikit/features/activity/infrastructure/sqlite_activity_repository.dart';
import 'package:rikit/features/json/application/format_json.dart';
import 'package:rikit/features/json/domain/json_formatter.dart';
import 'package:rikit/features/json/domain/json_input_policy.dart';
import 'package:rikit/features/json/infrastructure/dart_json_formatter.dart';
import 'package:rikit/features/json/presentation/controllers/json_tool_controller.dart';
import 'package:rikit/features/design_system/presentation/controllers/design_system_controller.dart';
import 'package:rikit/shared/logging/application/application_logger.dart';
import 'package:rikit/shared/logging/domain/log_repository.dart';
import 'package:rikit/shared/logging/infrastructure/sqlite_log_repository.dart';
import 'package:rikit/shared/notifications/notification_controller.dart';
import 'package:rikit/shared/persistence/app_database.dart';

class AppDependencies {
  final JsonFormatter jsonFormatter;
  final FormatJson formatJson;
  final AppDatabase database;
  final LogRepository logRepository;
  final ApplicationLogger logger;
  final NotificationController notifications;
  final JsonToolController jsonToolController;
  final DesignSystemController designSystemController;
  final ActivityRepository activityRepository;

  const AppDependencies._({
    required this.jsonFormatter,
    required this.formatJson,
    required this.database,
    required this.logRepository,
    required this.logger,
    required this.notifications,
    required this.jsonToolController,
    required this.designSystemController,
    required this.activityRepository,
  });

  static Future<AppDependencies> create() async {
    final directory = await getApplicationSupportDirectory();
    return _withDatabase(
      AppDatabase.open(path.join(directory.path, 'rikit.db')),
    );
  }

  factory AppDependencies.forTest() => _withDatabase(AppDatabase.inMemory());

  static AppDependencies _withDatabase(AppDatabase database) {
    final JsonFormatter jsonFormatter = DartJsonFormatter();

    final FormatJson formatJson = FormatJson(
      formatter: jsonFormatter,
      inputPolicy: const JsonInputPolicy(maxInputBytes: 2 * 1024 * 1024),
      maximumOutputBytes: 2 * 1024 * 1024,
    );
    final logRepository = SqliteLogRepository(database);
    logRepository.cleanUp(now: DateTime.now().toUtc());
    final activityRepository = SqliteActivityRepository(database);
    activityRepository.cleanUp(now: DateTime.now().toUtc());
    final notifications = NotificationController();
    final logger = ApplicationLogger(
      repository: logRepository,
      isDevelopment: kDebugMode,
    );
    final designSystemController = DesignSystemController();

    return AppDependencies._(
      jsonFormatter: jsonFormatter,
      formatJson: formatJson,
      database: database,
      logRepository: logRepository,
      logger: logger,
      notifications: notifications,
      activityRepository: activityRepository,
      designSystemController: designSystemController,
      jsonToolController: JsonToolController(
        formatJson: formatJson,
        logger: logger,
        notifications: notifications,
        activityRepository: activityRepository,
      ),
    );
  }

  void dispose() {
    jsonToolController.dispose();
    designSystemController.dispose();
    notifications.dispose();
    database.dispose();
  }
}
