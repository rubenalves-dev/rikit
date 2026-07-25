import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rikit/shared/logging/domain/log_entry.dart';
import 'package:rikit/shared/logging/domain/log_repository.dart';
import 'package:rikit/shared/presentation/page_header.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({required this.repository, super.key});
  final LogRepository repository;

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  LogSeverity? severity;
  String? tool;
  String? eventName;

  @override
  Widget build(BuildContext context) {
    final entries = widget.repository.list(
      severity: severity,
      tool: tool,
      eventName: eventName,
    );
    final severities = [
      null,
      LogSeverity.error,
      LogSeverity.warning,
      LogSeverity.information,
      if (kDebugMode) LogSeverity.debug,
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              eyebrow: 'System',
              title: 'Logs',
              description:
                  'Sanitized application events. Tool payloads are never stored.',
            ),
            const SizedBox(height: 26),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in severities)
                  ChoiceChip(
                    label: Text(item?.label ?? 'All'),
                    selected: severity == item,
                    onSelected: (_) => setState(() => severity = item),
                  ),
                _Filter(
                  hint: 'All tools',
                  value: tool,
                  values: widget.repository.listTools(),
                  onChanged: (value) => setState(() => tool = value),
                ),
                _Filter(
                  hint: 'All events',
                  value: eventName,
                  values: widget.repository.listEventNames(),
                  onChanged: (value) => setState(() => eventName = value),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Card(
                child: entries.isEmpty
                    ? const Center(child: Text('No matching logs'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: entries.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (_, index) => _LogRow(entries[index]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Filter extends StatelessWidget {
  const _Filter({
    required this.hint,
    required this.value,
    required this.values,
    required this.onChanged,
  });
  final String hint;
  final String? value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButton<String?>(
    value: value,
    hint: Text(hint),
    onChanged: onChanged,
    items: [
      DropdownMenuItem(value: null, child: Text(hint)),
      for (final item in values)
        DropdownMenuItem(value: item, child: Text(item)),
    ],
  );
}

class _LogRow extends StatelessWidget {
  const _LogRow(this.entry);
  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = switch (entry.severity) {
      LogSeverity.error => RikitColors.primary,
      LogSeverity.warning => RikitColors.warning,
      LogSeverity.information => RikitColors.success,
      LogSeverity.debug => Colors.lightBlueAccent,
    };
    final local = entry.timestamp.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.eventName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  entry.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(entry.tool, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 20),
          Text(
            '${local.year}-${two(local.month)}-${two(local.day)} '
            '${two(local.hour)}:${two(local.minute)}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
