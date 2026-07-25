import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/shared/logging/domain/log_entry.dart';
import 'package:rikit/shared/logging/domain/log_retention.dart';
import 'package:rikit/shared/logging/infrastructure/sqlite_log_repository.dart';
import 'package:rikit/shared/persistence/app_database.dart';

void main() {
  late AppDatabase database;
  late SqliteLogRepository repository;

  setUp(() {
    database = AppDatabase.inMemory();
    repository = SqliteLogRepository(database, maximumEntries: 3);
  });
  tearDown(() => database.dispose());

  void add(
    LogSeverity severity, {
    String tool = 'JSON Formatter',
    String event = 'format.failed',
    DateTime? at,
  }) {
    repository.add(
      timestamp: at ?? DateTime.utc(2026, 7, 25),
      severity: severity,
      tool: tool,
      eventName: event,
      message: 'Safe diagnostic metadata.',
    );
  }

  test('persists and filters logs by severity, tool, and event', () {
    add(LogSeverity.error);
    add(LogSeverity.warning, tool: 'Other', event: 'other.warning');

    expect(repository.list(), hasLength(2));
    expect(repository.list(severity: LogSeverity.error), hasLength(1));
    expect(repository.list(tool: 'Other').single.eventName, 'other.warning');
    expect(
      repository.list(eventName: 'format.failed').single.tool,
      'JSON Formatter',
    );
    expect(repository.listTools(), ['JSON Formatter', 'Other']);
  });

  test('defaults retention to one week and persists overrides', () {
    expect(repository.loadRetention().global, LogRetention.oneWeek);

    repository.saveRetention(
      const LogRetentionSettings(
        global: LogRetention.oneDay,
        overrides: {'error': LogRetention.oneWeek},
      ),
    );

    final loaded = repository.loadRetention();
    expect(loaded.forSeverity('warning'), LogRetention.oneDay);
    expect(loaded.forSeverity('error'), LogRetention.oneWeek);
  });

  test('cleans each severity using its effective retention', () {
    add(LogSeverity.error, at: DateTime.utc(2026, 7, 20));
    add(LogSeverity.warning, at: DateTime.utc(2026, 7, 20));
    repository.saveRetention(
      const LogRetentionSettings(
        global: LogRetention.oneDay,
        overrides: {'error': LogRetention.oneWeek},
      ),
    );

    repository.cleanUp(now: DateTime.utc(2026, 7, 25));

    expect(repository.list(severity: LogSeverity.error), hasLength(1));
    expect(repository.list(severity: LogSeverity.warning), isEmpty);
  });

  test('never disables time cleanup but the hard entry cap still applies', () {
    repository.saveRetention(
      const LogRetentionSettings(global: LogRetention.never),
    );
    for (var index = 0; index < 5; index++) {
      add(
        LogSeverity.information,
        event: 'event.$index',
        at: DateTime.utc(2020, 1, index + 1),
      );
    }

    repository.cleanUp(now: DateTime.utc(2026, 7, 25));

    expect(repository.list(), hasLength(3));
    expect(repository.list().first.eventName, 'event.4');
  });
}
