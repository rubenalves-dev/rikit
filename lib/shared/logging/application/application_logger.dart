import 'package:rikit/shared/logging/application/log_sanitizer.dart';
import 'package:rikit/shared/logging/domain/log_entry.dart';
import 'package:rikit/shared/logging/domain/log_repository.dart';

final class ApplicationLogger {
  const ApplicationLogger({
    required this.repository,
    required this.isDevelopment,
    this.sanitizer = const LogSanitizer(),
  });

  final LogRepository repository;
  final bool isDevelopment;
  final LogSanitizer sanitizer;

  void record({
    required LogSeverity severity,
    required String tool,
    required String eventName,
    required String message,
    String? stackTrace,
    DateTime? timestamp,
  }) {
    if (severity == LogSeverity.debug && !isDevelopment) return;
    repository.add(
      timestamp: timestamp ?? DateTime.now().toUtc(),
      severity: severity,
      tool: sanitizer.message(tool),
      eventName: sanitizer.message(eventName),
      message: sanitizer.message(message),
      stackTrace: isDevelopment ? sanitizer.stackTrace(stackTrace) : null,
    );
  }
}
