import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/app/app/app_dependencies.dart';
import 'package:rikit/app/rikit_app.dart';

void main() {
  testWidgets('uses the expanded sidebar on a wide desktop', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(RikitApp(dependencies: AppDependencies.create()));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const ValueKey('app-sidebar'))).width,
      236,
    );
    expect(find.text('SYSTEM'), findsOneWidget);
  });

  testWidgets('uses a compact sidebar on a narrow desktop', (tester) async {
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(RikitApp(dependencies: AppDependencies.create()));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byKey(const ValueKey('app-sidebar'))).width, 76);
    expect(find.text('SYSTEM'), findsNothing);
  });

  testWidgets('navigates to shared system destinations', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(RikitApp(dependencies: AppDependencies.create()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav-Logs')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Sanitized application events and diagnostics will appear here.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('nav-Settings')));
    await tester.pumpAndSettle();
    expect(
      find.text('Tune persistence, retention, and application preferences.'),
      findsOneWidget,
    );
  });

  testWidgets('matches the desktop shell golden', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(RikitApp(dependencies: AppDependencies.create()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/desktop_shell.png'),
    );
  });
}
