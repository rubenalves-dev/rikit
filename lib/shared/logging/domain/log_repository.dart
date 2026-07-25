import 'package:rikit/shared/logging/domain/log_entry.dart';
import 'package:rikit/shared/logging/domain/log_retention.dart';

abstract interface class LogRepository {
  void add({
    required DateTime timestamp,
    required LogSeverity severity,
    required String tool,
    required String eventName,
    required String message,
    String? stackTrace,
  });

  List<LogEntry> list({
    LogSeverity? severity,
    String? tool,
    String? eventName,
    int limit = 500,
  });

  List<String> listTools();
  List<String> listEventNames();
  LogRetentionSettings loadRetention();
  void saveRetention(LogRetentionSettings settings);
  void cleanUp({required DateTime now});
  void clear();
}
