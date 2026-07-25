import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/shared/logging/application/application_logger.dart';
import 'package:rikit/shared/logging/domain/log_entry.dart';
import 'package:rikit/shared/logging/infrastructure/sqlite_log_repository.dart';
import 'package:rikit/shared/persistence/app_database.dart';

void main() {
  late AppDatabase database;
  late SqliteLogRepository repository;

  setUp(() {
    database = AppDatabase.inMemory();
    repository = SqliteLogRepository(database);
  });
  tearDown(() => database.dispose());

  test('sanitizes payload-shaped metadata before persistence', () {
    ApplicationLogger(repository: repository, isDevelopment: true).record(
      severity: LogSeverity.error,
      tool: 'JSON Formatter',
      eventName: 'format.failed',
      message: 'Could not parse payload={"secret":true}\nPlease retry.',
      stackTrace: 'input="private" at parser.dart:12',
    );

    final entry = repository.list().single;
    expect(entry.message, isNot(contains('secret')));
    expect(entry.message, contains('payload=[redacted]'));
    expect(entry.stackTrace, isNot(contains('private')));
  });

  test('release logging drops debug entries and all stack traces', () {
    final logger = ApplicationLogger(
      repository: repository,
      isDevelopment: false,
    );
    logger.record(
      severity: LogSeverity.debug,
      tool: 'App',
      eventName: 'debug.event',
      message: 'Debug',
    );
    logger.record(
      severity: LogSeverity.error,
      tool: 'App',
      eventName: 'error.event',
      message: 'Error',
      stackTrace: 'trace',
    );

    expect(repository.list(), hasLength(1));
    expect(repository.list().single.stackTrace, isNull);
  });
}
