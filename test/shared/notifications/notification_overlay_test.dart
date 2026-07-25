import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/shared/logging/domain/log_entry.dart';
import 'package:rikit/shared/notifications/notification_controller.dart';
import 'package:rikit/shared/notifications/notification_overlay.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

void main() {
  testWidgets('shows two newest notifications and expands the older stack', (
    tester,
  ) async {
    final controller = NotificationController(
      dismissAfter: const Duration(minutes: 1),
    );
    for (var index = 0; index < 3; index++) {
      controller.show(
        severity: LogSeverity.error,
        title: 'Error $index',
        body: 'Body $index',
      );
    }
    await tester.pumpWidget(
      MaterialApp(
        theme: RikitTheme.dark(),
        home: Scaffold(body: NotificationOverlay(controller: controller)),
      ),
    );

    expect(find.byKey(const ValueKey('notification-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-0')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('notification-stack')));
    await tester.pump();

    expect(find.byKey(const ValueKey('notification-expanded')), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-0')), findsOneWidget);
  });

  testWidgets('truncates titles to one line and bodies to two lines', (
    tester,
  ) async {
    final controller = NotificationController(
      dismissAfter: const Duration(minutes: 1),
    );
    controller.show(
      severity: LogSeverity.warning,
      title: 'A very long warning title',
      body: 'A body that may be long enough to wrap over several lines.',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: RikitTheme.dark(),
        home: Scaffold(body: NotificationOverlay(controller: controller)),
      ),
    );

    final title = tester.widget<Text>(find.text('A very long warning title'));
    final body = tester.widget<Text>(
      find.text('A body that may be long enough to wrap over several lines.'),
    );
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(body.maxLines, 2);
    expect(body.overflow, TextOverflow.ellipsis);
    controller.dispose();
  });

  testWidgets('auto-dismisses after six-second style timer', (tester) async {
    final controller = NotificationController(
      dismissAfter: const Duration(seconds: 6),
    );
    addTearDown(controller.dispose);
    controller.show(
      severity: LogSeverity.information,
      title: 'Copied',
      body: 'Output copied to clipboard.',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: RikitTheme.dark(),
        home: Scaffold(body: NotificationOverlay(controller: controller)),
      ),
    );

    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Copied'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Copied'), findsNothing);
  });

  testWidgets('actionable card shows a chevron and invokes its action', (
    tester,
  ) async {
    var activations = 0;
    final controller = NotificationController(
      dismissAfter: const Duration(minutes: 1),
    );
    final id = controller.show(
      severity: LogSeverity.error,
      title: 'Invalid JSON',
      body: 'Check line 10, column 4.',
      action: () => activations++,
      actionLabel: 'Go to JSON error',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: RikitTheme.dark(),
        home: Scaffold(body: NotificationOverlay(controller: controller)),
      ),
    );

    expect(find.byKey(const ValueKey('notification-action-icon')), findsOne);
    await tester.tap(find.byKey(ValueKey('notification-$id')));
    expect(activations, 1);

    controller.clearAction(id);
    await tester.pump();
    expect(
      find.byKey(const ValueKey('notification-action-icon')),
      findsNothing,
    );
    controller.dispose();
  });

  testWidgets('matches the expanded notification stack golden', (tester) async {
    tester.view.physicalSize = const Size(420, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = NotificationController(
      dismissAfter: const Duration(minutes: 1),
    );
    for (final severity in [
      LogSeverity.error,
      LogSeverity.warning,
      LogSeverity.information,
    ]) {
      controller.show(
        severity: severity,
        title: '${severity.label} notification',
        body: 'A concise, sanitized diagnostic message for the user.',
      );
    }
    controller.setExpanded(true);
    await tester.pumpWidget(
      MaterialApp(
        theme: RikitTheme.dark(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topRight,
            child: NotificationOverlay(controller: controller),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(NotificationOverlay),
      matchesGoldenFile('goldens/notification_stack.png'),
    );
    controller.dispose();
  });
}
