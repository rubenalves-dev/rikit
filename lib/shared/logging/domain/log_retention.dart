enum LogRetention {
  oneDay('1 day', 1),
  threeDays('3 days', 3),
  fiveDays('5 days', 5),
  oneWeek('1 week', 7),
  twoWeeks('2 weeks', 14),
  oneMonth('1 month', 30),
  never('Never', null);

  const LogRetention(this.label, this.days);
  final String label;
  final int? days;
}

final class LogRetentionSettings {
  const LogRetentionSettings({
    this.global = LogRetention.oneWeek,
    this.overrides = const {},
  });

  final LogRetention global;
  final Map<String, LogRetention> overrides;

  LogRetention forSeverity(String severityName) =>
      overrides[severityName] ?? global;

  LogRetentionSettings copyWith({
    LogRetention? global,
    Map<String, LogRetention>? overrides,
  }) => LogRetentionSettings(
    global: global ?? this.global,
    overrides: overrides ?? this.overrides,
  );
}
