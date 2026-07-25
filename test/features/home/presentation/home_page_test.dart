import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/app/app/app_dependencies.dart';
import 'package:rikit/app/rikit_app.dart';
import 'package:rikit/features/activity/domain/activity_models.dart';

void main() {
  testWidgets('shows live privacy-safe aggregate metrics and chart', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final dependencies = AppDependencies.forTest();
    for (var index = 0; index < 3; index++) {
      dependencies.activityRepository.record(
        timestamp: DateTime.now().toUtc(),
        tool: 'JSON Formatter',
        outcome: index == 2
            ? ToolRunOutcome.validationFailed
            : ToolRunOutcome.succeeded,
        inputBytes: 10,
        outputBytes: index == 2 ? 0 : 20,
      );
    }

    await tester.pumpWidget(RikitApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const ValueKey('metric-Tool runs'))).data,
      '3',
    );
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('metric-Successful'))).data,
      '2',
    );
    expect(find.byKey(const ValueKey('activity-chart')), findsOneWidget);
  });

  testWidgets('offers all agreed dashboard ranges', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(RikitApp(dependencies: AppDependencies.forTest()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('activity-range')));
    await tester.pumpAndSettle();

    for (final range in ActivityRange.values) {
      expect(find.text(range.label), findsWidgets);
    }
  });
}
