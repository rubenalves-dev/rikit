enum LogSeverity {
  information('Information'),
  warning('Warnings'),
  error('Errors'),
  debug('Debug');

  const LogSeverity(this.label);
  final String label;
}

final class LogEntry {
  const LogEntry({
    required this.id,
    required this.timestamp,
    required this.severity,
    required this.tool,
    required this.eventName,
    required this.message,
    this.stackTrace,
  });

  final int id;
  final DateTime timestamp;
  final LogSeverity severity;
  final String tool;
  final String eventName;
  final String message;
  final String? stackTrace;
}
