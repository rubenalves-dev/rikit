final class LogSanitizer {
  const LogSanitizer();

  String message(String value) => _sanitize(value, 240);

  String? stackTrace(String? value) =>
      value == null ? null : _sanitize(value, 4000, keepLines: true);

  String _sanitize(String value, int limit, {bool keepLines = false}) {
    var sanitized = value
        .replaceAll(keepLines ? RegExp(r'\r') : RegExp(r'[\r\n\t]+'), ' ')
        .replaceAllMapped(
          RegExp(
            r'\b(input|output|payload|clipboard|filename)\s*[:=]\s*(?:"[^"]*"|\S+)',
            caseSensitive: false,
          ),
          (match) => '${match.group(1)}=[redacted]',
        )
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
    if (sanitized.length > limit) {
      sanitized = '${sanitized.substring(0, limit - 3)}...';
    }
    return sanitized;
  }
}
