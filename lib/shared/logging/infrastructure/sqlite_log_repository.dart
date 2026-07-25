import 'package:rikit/shared/logging/domain/log_entry.dart';
import 'package:rikit/shared/logging/domain/log_repository.dart';
import 'package:rikit/shared/logging/domain/log_retention.dart';
import 'package:rikit/shared/persistence/app_database.dart';

final class SqliteLogRepository implements LogRepository {
  SqliteLogRepository(this.appDatabase, {this.maximumEntries = 50000});

  final AppDatabase appDatabase;
  final int maximumEntries;

  @override
  void add({
    required DateTime timestamp,
    required LogSeverity severity,
    required String tool,
    required String eventName,
    required String message,
    String? stackTrace,
  }) {
    final database = appDatabase.database;
    database.execute(
      'INSERT INTO diagnostic_logs(timestamp_ms,severity,tool,event_name,message,stack_trace) '
      'VALUES (?,?,?,?,?,?)',
      [
        timestamp.toUtc().millisecondsSinceEpoch,
        severity.name,
        tool,
        eventName,
        message,
        stackTrace,
      ],
    );
    database.execute(
      'DELETE FROM diagnostic_logs WHERE id IN '
      '(SELECT id FROM diagnostic_logs ORDER BY timestamp_ms DESC,id DESC '
      'LIMIT -1 OFFSET ?)',
      [maximumEntries],
    );
  }

  @override
  List<LogEntry> list({
    LogSeverity? severity,
    String? tool,
    String? eventName,
    int limit = 500,
  }) {
    final clauses = <String>[];
    final parameters = <Object?>[];
    if (severity != null) {
      clauses.add('severity = ?');
      parameters.add(severity.name);
    }
    if (tool?.isNotEmpty ?? false) {
      clauses.add('tool = ?');
      parameters.add(tool);
    }
    if (eventName?.isNotEmpty ?? false) {
      clauses.add('event_name = ?');
      parameters.add(eventName);
    }
    parameters.add(limit);
    final where = clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}';
    final rows = appDatabase.database.select(
      'SELECT * FROM diagnostic_logs $where '
      'ORDER BY timestamp_ms DESC,id DESC LIMIT ?',
      parameters,
    );
    return [
      for (final row in rows)
        LogEntry(
          id: row['id'] as int,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            row['timestamp_ms'] as int,
            isUtc: true,
          ),
          severity: LogSeverity.values.byName(row['severity'] as String),
          tool: row['tool'] as String,
          eventName: row['event_name'] as String,
          message: row['message'] as String,
          stackTrace: row['stack_trace'] as String?,
        ),
    ];
  }

  @override
  List<String> listTools() => _distinct('tool');

  @override
  List<String> listEventNames() => _distinct('event_name');

  List<String> _distinct(String column) => [
    for (final row in appDatabase.database.select(
      'SELECT DISTINCT $column FROM diagnostic_logs ORDER BY $column',
    ))
      row[column] as String,
  ];

  @override
  LogRetentionSettings loadRetention() {
    final rows = appDatabase.database.select(
      "SELECT key,value FROM preferences WHERE key LIKE 'log_retention.%'",
    );
    var global = LogRetention.oneWeek;
    final overrides = <String, LogRetention>{};
    for (final row in rows) {
      final key = row['key'] as String;
      final value = LogRetention.values.byName(row['value'] as String);
      if (key == 'log_retention.global') {
        global = value;
      } else {
        overrides[key.substring('log_retention.'.length)] = value;
      }
    }
    return LogRetentionSettings(global: global, overrides: overrides);
  }

  @override
  void saveRetention(LogRetentionSettings settings) {
    final database = appDatabase.database;
    database.execute(
      "DELETE FROM preferences WHERE key LIKE 'log_retention.%'",
    );
    database.execute('INSERT INTO preferences(key,value) VALUES (?,?)', [
      'log_retention.global',
      settings.global.name,
    ]);
    for (final entry in settings.overrides.entries) {
      database.execute('INSERT INTO preferences(key,value) VALUES (?,?)', [
        'log_retention.${entry.key}',
        entry.value.name,
      ]);
    }
  }

  @override
  void cleanUp({required DateTime now}) {
    final settings = loadRetention();
    for (final severity in LogSeverity.values) {
      final days = settings.forSeverity(severity.name).days;
      if (days != null) {
        final cutoff = now
            .toUtc()
            .subtract(Duration(days: days))
            .millisecondsSinceEpoch;
        appDatabase.database.execute(
          'DELETE FROM diagnostic_logs WHERE severity = ? AND timestamp_ms < ?',
          [severity.name, cutoff],
        );
      }
    }
  }

  @override
  void clear() => appDatabase.database.execute('DELETE FROM diagnostic_logs');
}
