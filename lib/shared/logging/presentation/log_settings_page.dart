import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rikit/shared/logging/domain/log_entry.dart';
import 'package:rikit/shared/logging/domain/log_repository.dart';
import 'package:rikit/shared/logging/domain/log_retention.dart';
import 'package:rikit/shared/notifications/notification_controller.dart';
import 'package:rikit/shared/presentation/page_header.dart';

class LogSettingsPage extends StatefulWidget {
  const LogSettingsPage({
    required this.repository,
    required this.notifications,
    super.key,
  });
  final LogRepository repository;
  final NotificationController notifications;

  @override
  State<LogSettingsPage> createState() => _LogSettingsPageState();
}

class _LogSettingsPageState extends State<LogSettingsPage> {
  late LogRetentionSettings settings = widget.repository.loadRetention();

  @override
  Widget build(BuildContext context) {
    final severities = [
      LogSeverity.error,
      LogSeverity.warning,
      LogSeverity.information,
      if (kDebugMode) LogSeverity.debug,
    ];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              eyebrow: 'System',
              title: 'Settings',
              description:
                  'Control local diagnostic retention. Payload data is never logged.',
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log retention',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Type-specific values override the global default.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    _RetentionRow(
                      label: 'Global default',
                      value: settings.global,
                      allowGlobal: false,
                      onChanged: (value) {
                        if (value != null) {
                          _save(settings.copyWith(global: value));
                        }
                      },
                    ),
                    const Divider(),
                    for (final severity in severities)
                      _RetentionRow(
                        label: severity.label,
                        value: settings.overrides[severity.name],
                        allowGlobal: true,
                        onChanged: (value) {
                          final overrides = {...settings.overrides};
                          value == null
                              ? overrides.remove(severity.name)
                              : overrides[severity.name] = value;
                          _save(settings.copyWith(overrides: overrides));
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save(LogRetentionSettings value) {
    widget.repository.saveRetention(value);
    widget.repository.cleanUp(now: DateTime.now().toUtc());
    setState(() => settings = value);
    widget.notifications.show(
      severity: LogSeverity.information,
      title: 'Settings saved',
      body: 'Log retention was updated on this device.',
    );
  }
}

class _RetentionRow extends StatelessWidget {
  const _RetentionRow({
    required this.label,
    required this.value,
    required this.allowGlobal,
    required this.onChanged,
  });
  final String label;
  final LogRetention? value;
  final bool allowGlobal;
  final ValueChanged<LogRetention?> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        DropdownButton<LogRetention?>(
          value: value,
          onChanged: onChanged,
          items: [
            if (allowGlobal)
              const DropdownMenuItem(value: null, child: Text('Use global')),
            for (final retention in LogRetention.values)
              DropdownMenuItem(value: retention, child: Text(retention.label)),
          ],
        ),
      ],
    ),
  );
}
