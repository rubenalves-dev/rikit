import 'package:sqlite3/sqlite3.dart';

final class AppDatabase {
  AppDatabase._(this.database) {
    _migrate();
  }

  factory AppDatabase.open(String path) => AppDatabase._(sqlite3.open(path));
  factory AppDatabase.inMemory() => AppDatabase._(sqlite3.openInMemory());

  final Database database;

  void _migrate() {
    database.execute('PRAGMA foreign_keys = ON;');
    database.execute('''
      CREATE TABLE IF NOT EXISTS diagnostic_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp_ms INTEGER NOT NULL,
        severity TEXT NOT NULL,
        tool TEXT NOT NULL,
        event_name TEXT NOT NULL,
        message TEXT NOT NULL,
        stack_trace TEXT
      );
      CREATE INDEX IF NOT EXISTS idx_logs_timestamp
        ON diagnostic_logs(timestamp_ms DESC);
      CREATE INDEX IF NOT EXISTS idx_logs_filters
        ON diagnostic_logs(severity, tool, event_name);
      CREATE TABLE IF NOT EXISTS preferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');
  }

  void dispose() => database.close();
}
