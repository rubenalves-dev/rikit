import 'package:flutter/material.dart';
import 'package:rikit/shared/logging/domain/log_entry.dart';
import 'package:rikit/shared/notifications/notification_controller.dart';
import 'package:rikit/shared/notifications/notification_message.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class NotificationOverlay extends StatelessWidget {
  const NotificationOverlay({required this.controller, super.key});
  final NotificationController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.messages.isEmpty) return const SizedBox.shrink();
        if (controller.expanded) {
          return _ExpandedNotifications(controller: controller);
        }
        return SizedBox(
          width: 330,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final message in controller.messages.take(2)) ...[
                _NotificationCard(message: message, controller: controller),
                const SizedBox(height: 8),
              ],
              if (controller.messages.length > 2)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: const ValueKey('notification-stack'),
                    onPressed: () => controller.setExpanded(true),
                    icon: const Icon(Icons.layers_rounded, size: 16),
                    label: Text('${controller.messages.length - 2} more'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ExpandedNotifications extends StatelessWidget {
  const _ExpandedNotifications({required this.controller});
  final NotificationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('notification-expanded'),
      width: 360,
      constraints: const BoxConstraints(maxHeight: 520),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: RikitColors.surface.withValues(alpha: .98),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RikitColors.border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Notifications',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Collapse notifications',
                onPressed: () => controller.setExpanded(false),
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ],
          ),
          const Divider(),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: controller.messages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, index) => _NotificationCard(
                message: controller.messages[index],
                controller: controller,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.message, required this.controller});
  final NotificationMessage message;
  final NotificationController controller;

  @override
  Widget build(BuildContext context) {
    final color = switch (message.severity) {
      LogSeverity.error => RikitColors.primary,
      LogSeverity.warning => RikitColors.warning,
      LogSeverity.information => RikitColors.success,
      LogSeverity.debug => Colors.lightBlueAccent,
    };
    final icon = switch (message.severity) {
      LogSeverity.error => Icons.error_outline_rounded,
      LogSeverity.warning => Icons.warning_amber_rounded,
      LogSeverity.information => Icons.check_circle_outline_rounded,
      LogSeverity.debug => Icons.bug_report_outlined,
    };
    return MouseRegion(
      onEnter: (_) => controller.pause(message.id),
      onExit: (_) => controller.resume(message.id),
      child: Container(
        key: ValueKey('notification-${message.id}'),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: RikitColors.surfaceRaised,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: color.withValues(alpha: .35)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 22,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: RikitColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: RikitColors.textMuted,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => controller.remove(message.id),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: RikitColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
