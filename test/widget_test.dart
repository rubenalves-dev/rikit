import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/app/app/app_dependencies.dart';
import 'package:rikit/app/rikit_app.dart';

void main() {
  testWidgets('opens the dashboard and navigates to the JSON tool', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(RikitApp(dependencies: AppDependencies.forTest()));
    await tester.pumpAndSettle();

    expect(find.text('Good tools. Zero friction.'), findsOneWidget);
    expect(find.text('JSON Formatter'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('nav-JSON Formatter')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('json-input')), findsOneWidget);
    expect(find.text('Formatted JSON appears here'), findsOneWidget);
  });
}
