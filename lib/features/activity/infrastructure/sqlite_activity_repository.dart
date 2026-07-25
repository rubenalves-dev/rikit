import 'package:rikit/features/activity/domain/activity_models.dart';
import 'package:rikit/features/activity/domain/activity_repository.dart';
import 'package:rikit/shared/persistence/app_database.dart';

final class SqliteActivityRepository implements ActivityRepository {
  const SqliteActivityRepository(this.appDatabase);
  final AppDatabase appDatabase;

  @override
  void record({
    required DateTime timestamp,
    required String tool,
    required ToolRunOutcome outcome,
    required int inputBytes,
    required int outputBytes,
  }) {
    final day = _dayKey(timestamp);
    appDatabase.database.execute(
      '''
      INSERT INTO daily_activity(
        day_key, tool, outcome, runs, input_bytes, output_bytes
      ) VALUES (?, ?, ?, 1, ?, ?)
      ON CONFLICT(day_key, tool, outcome) DO UPDATE SET
        runs = runs + 1,
        input_bytes = input_bytes + excluded.input_bytes,
        output_bytes = output_bytes + excluded.output_bytes
      ''',
      [day, tool, outcome.name, inputBytes, outputBytes],
    );
  }

  @override
  ActivitySummary summary({required DateTime from, required DateTime through}) {
    final rows = appDatabase.database.select(
      '''
      SELECT day_key, tool, outcome, runs, input_bytes, output_bytes
      FROM daily_activity
      WHERE day_key >= ? AND day_key <= ?
      ORDER BY day_key ASC, tool ASC, outcome ASC
      ''',
      [_dayKey(from), _dayKey(through)],
    );
    return ActivitySummary([
      for (final row in rows)
        DailyActivity(
          day: DateTime.parse('${row['day_key']}T00:00:00Z'),
          tool: row['tool'] as String,
          outcome: ToolRunOutcome.values.byName(row['outcome'] as String),
          runs: row['runs'] as int,
          inputBytes: row['input_bytes'] as int,
          outputBytes: row['output_bytes'] as int,
        ),
    ]);
  }

  @override
  void cleanUp({required DateTime now}) {
    final cutoff = now.toUtc().subtract(const Duration(days: 365));
    appDatabase.database.execute(
      'DELETE FROM daily_activity WHERE day_key < ?',
      [_dayKey(cutoff)],
    );
  }

  String _dayKey(DateTime value) {
    final utc = value.toUtc();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${utc.year}-${two(utc.month)}-${two(utc.day)}';
  }
}
