import 'package:rikit/shared/logging/domain/log_entry.dart';

typedef NotificationAction = void Function();

final class NotificationMessage {
  const NotificationMessage({
    required this.id,
    required this.severity,
    required this.title,
    required this.body,
    this.action,
    this.actionLabel,
  });

  final int id;
  final LogSeverity severity;
  final String title;
  final String body;
  final NotificationAction? action;
  final String? actionLabel;

  NotificationMessage copyWith({
    NotificationAction? action,
    String? actionLabel,
    bool clearAction = false,
  }) {
    return NotificationMessage(
      id: id,
      severity: severity,
      title: title,
      body: body,
      action: clearAction ? null : action ?? this.action,
      actionLabel: clearAction ? null : actionLabel ?? this.actionLabel,
    );
  }
}
