import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/features/activity/domain/activity_models.dart';
import 'package:rikit/features/activity/infrastructure/sqlite_activity_repository.dart';
import 'package:rikit/shared/persistence/app_database.dart';

void main() {
  late AppDatabase database;
  late SqliteActivityRepository repository;

  setUp(() {
    database = AppDatabase.inMemory();
    repository = SqliteActivityRepository(database);
  });
  tearDown(() => database.dispose());

  test('aggregates runs and bytes by UTC day, tool, and outcome', () {
    for (var index = 0; index < 2; index++) {
      repository.record(
        timestamp: DateTime.utc(2026, 7, 25, index),
        tool: 'JSON Formatter',
        outcome: ToolRunOutcome.succeeded,
        inputBytes: 10,
        outputBytes: 20,
      );
    }
    repository.record(
      timestamp: DateTime.utc(2026, 7, 25, 3),
      tool: 'JSON Formatter',
      outcome: ToolRunOutcome.validationFailed,
      inputBytes: 5,
      outputBytes: 0,
    );

    final summary = repository.summary(
      from: DateTime.utc(2026, 7, 25),
      through: DateTime.utc(2026, 7, 25),
    );

    expect(summary.days, hasLength(2));
    expect(summary.runs, 3);
    expect(summary.successes, 2);
    expect(summary.bytesProcessed, 65);
    expect(summary.activeTools, 1);
  });

  test('filters summaries by inclusive date range', () {
    for (final day in [1, 10, 20]) {
      repository.record(
        timestamp: DateTime.utc(2026, 7, day),
        tool: 'JSON Formatter',
        outcome: ToolRunOutcome.succeeded,
        inputBytes: day,
        outputBytes: 0,
      );
    }

    final summary = repository.summary(
      from: DateTime.utc(2026, 7, 5),
      through: DateTime.utc(2026, 7, 15),
    );

    expect(summary.runs, 1);
    expect(summary.bytesProcessed, 10);
  });

  test('removes daily aggregates older than one year', () {
    repository.record(
      timestamp: DateTime.utc(2025, 1, 1),
      tool: 'JSON Formatter',
      outcome: ToolRunOutcome.succeeded,
      inputBytes: 1,
      outputBytes: 1,
    );
    repository.record(
      timestamp: DateTime.utc(2026, 7, 25),
      tool: 'JSON Formatter',
      outcome: ToolRunOutcome.succeeded,
      inputBytes: 1,
      outputBytes: 1,
    );

    repository.cleanUp(now: DateTime.utc(2026, 7, 25));

    final summary = repository.summary(
      from: DateTime.utc(2020),
      through: DateTime.utc(2030),
    );
    expect(summary.runs, 1);
    expect(summary.days.single.day, DateTime.utc(2026, 7, 25));
  });
}
