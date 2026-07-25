import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/app/app/app_dependencies.dart';
import 'package:rikit/app/rikit_app.dart';

void main() {
  Future<AppDependencies> pumpJsonPage(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final dependencies = AppDependencies.forTest();
    await tester.pumpWidget(RikitApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-JSON Formatter')));
    await tester.pumpAndSettle();
    return dependencies;
  }

  testWidgets('formats input only after the explicit button is pressed', (
    tester,
  ) async {
    await pumpJsonPage(tester);
    await tester.enterText(find.byKey(const ValueKey('json-input')), '{"a":1}');
    await tester.pump();

    final emptyOutput = tester.widget<TextField>(
      find.byKey(const ValueKey('json-output')),
    );
    expect(emptyOutput.controller!.text, isEmpty);

    await tester.tap(find.byKey(const ValueKey('format-json')));
    await tester.pump();

    expect(find.text('{\n  "a": 1\n}'), findsOneWidget);
  });

  testWidgets('supports the platform formatting keyboard command', (
    tester,
  ) async {
    await pumpJsonPage(tester);
    await tester.enterText(find.byKey(const ValueKey('json-input')), '[1]');
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
    await tester.pump();

    expect(find.text('[\n  1\n]'), findsOneWidget);
  });

  testWidgets('stacks editors on a narrow desktop layout', (tester) async {
    await pumpJsonPage(tester, size: const Size(850, 900));

    final input = tester.getTopLeft(
      find.byKey(const ValueKey('json-input-panel')),
    );
    final output = tester.getTopLeft(
      find.byKey(const ValueKey('json-output-panel')),
    );
    expect(output.dy, greaterThan(input.dy));
  });

  testWidgets('keeps the JSON workspace in memory while navigating', (
    tester,
  ) async {
    await pumpJsonPage(tester);
    await tester.enterText(
      find.byKey(const ValueKey('json-input')),
      '{"session":true}',
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('nav-Home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-JSON Formatter')));
    await tester.pumpAndSettle();

    expect(find.text('{"session":true}'), findsOneWidget);
  });

  testWidgets('shows line gutters and navigates to a duplicate key', (
    tester,
  ) async {
    final dependencies = await pumpJsonPage(tester);
    final input = '{\n"a": 1,\n${List.filled(35, '').join('\n')}"a": 2\n}';
    await tester.enterText(find.byKey(const ValueKey('json-input')), input);
    dependencies.jsonToolController.format();
    await tester.pumpAndSettle();

    expect(dependencies.jsonToolController.view.errorOffset, isNotNull);
    expect(
      find.byKey(const ValueKey('json-line-number-gutter')),
      findsNWidgets(2),
    );
    expect(
      find.byKey(const ValueKey('json-diagnostic-line-highlight')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('notification-action-icon')), findsOne);
    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('json-input')),
    );
    expect(field.focusNode!.hasFocus, isTrue);
    expect(
      field.controller!.selection.textInside(field.controller!.text),
      '"a"',
    );

    field.controller!.selection = const TextSelection.collapsed(offset: 0);
    await tester.tap(find.byKey(const ValueKey('notification-0')));
    await tester.pumpAndSettle();
    expect(
      field.controller!.selection.textInside(field.controller!.text),
      '"a"',
    );

    await tester.tap(find.byKey(const ValueKey('nav-Home')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('notification-action-icon')),
      findsNothing,
    );
  });

  testWidgets('matches the JSON formatter desktop golden', (tester) async {
    await pumpJsonPage(tester);
    await tester.enterText(
      find.byKey(const ValueKey('json-input')),
      '{"rikit":{"fast":true,"private":true}}',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('format-json')));
    await tester.pump();
    expect(find.byKey(const ValueKey('json-output')), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/json_formatter.png'),
    );
  });
}
