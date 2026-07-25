enum ToolRunOutcome { succeeded, validationFailed, policyRejected }

enum ActivityRange {
  day('Day', 1),
  week('Week', 7),
  month('Month', 30),
  sixMonths('6 months', 183),
  year('1 year', 365);

  const ActivityRange(this.label, this.days);
  final String label;
  final int days;
}

final class DailyActivity {
  const DailyActivity({
    required this.day,
    required this.tool,
    required this.outcome,
    required this.runs,
    required this.inputBytes,
    required this.outputBytes,
  });

  final DateTime day;
  final String tool;
  final ToolRunOutcome outcome;
  final int runs;
  final int inputBytes;
  final int outputBytes;
}

final class ActivitySummary {
  const ActivitySummary(this.days);
  final List<DailyActivity> days;

  int get runs => days.fold(0, (total, item) => total + item.runs);
  int get successes => days
      .where((item) => item.outcome == ToolRunOutcome.succeeded)
      .fold(0, (total, item) => total + item.runs);
  int get bytesProcessed =>
      days.fold(0, (total, item) => total + item.inputBytes + item.outputBytes);
  int get activeTools => days.map((item) => item.tool).toSet().length;
}
