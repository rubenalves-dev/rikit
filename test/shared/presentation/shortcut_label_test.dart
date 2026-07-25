import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/shared/presentation/shortcut_label.dart';

void main() {
  testWidgets('uses macOS shortcut symbols on macOS', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ShortcutLabel.format())),
    );

    expect(find.text('⌘'), findsOneWidget);
    expect(find.text('Enter'), findsOneWidget);
    expect(find.text('Ctrl'), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('uses Ctrl on Windows and consistent keycaps', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ShortcutLabel.format())),
    );

    expect(find.text('Ctrl'), findsOneWidget);
    expect(find.byKey(const ValueKey('shortcut-key-Ctrl')), findsOneWidget);
    expect(find.byKey(const ValueKey('shortcut-key-Enter')), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });
}
