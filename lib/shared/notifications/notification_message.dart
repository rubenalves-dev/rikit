import 'package:rikit/shared/logging/domain/log_entry.dart';

final class NotificationMessage {
  const NotificationMessage({
    required this.id,
    required this.severity,
    required this.title,
    required this.body,
  });

  final int id;
  final LogSeverity severity;
  final String title;
  final String body;
}
