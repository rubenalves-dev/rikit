import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/features/design_system/domain/design_system_state.dart';
import 'package:rikit/features/design_system/presentation/controllers/design_system_controller.dart';
import 'package:rikit/features/design_system/presentation/views/design_system_page.dart';

void main() {
  Widget buildTestableWidget(DesignSystemController controller) {
    return MaterialApp(
      home: Scaffold(body: DesignSystemPage(controller: controller)),
    );
  }

  Future<void> setupScreenSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets(
    'renders DesignSystemPage with header, preset selector, and tabs',
    (tester) async {
      await setupScreenSize(tester);
      final controller = DesignSystemController();
      await tester.pumpWidget(buildTestableWidget(controller));
      await tester.pump();

      // Verify page header elements exist
      expect(find.text('Design System Creator'), findsOneWidget);
      expect(find.text('Colors'), findsOneWidget);
      expect(find.text('Globals'), findsOneWidget);
      expect(find.text('Typography'), findsOneWidget);

      // Initial tab is Colors. Should display "Color Schemes" heading
      expect(find.text('Color Schemes'), findsOneWidget);
    },
  );

  testWidgets('can navigate tabs to show Globals and Typography editors', (
    tester,
  ) async {
    await setupScreenSize(tester);
    final controller = DesignSystemController();
    await tester.pumpWidget(buildTestableWidget(controller));
    await tester.pump();

    // Tap Globals Tab
    await tester.tap(find.text('Globals'));
    await tester.pumpAndSettle();

    expect(find.text('Global Scales'), findsOneWidget);
    expect(find.text('Border Radii Scale'), findsOneWidget);
    expect(find.text('Spacing Scale'), findsOneWidget);

    // Tap Typography Tab
    await tester.tap(find.text('Typography'));
    await tester.pumpAndSettle();

    expect(find.text('Typography Style Editor'), findsOneWidget);
    expect(find.text('Headings Group (H1, H2, H3)'), findsOneWidget);
  });

  testWidgets('Preset selection updates the design state', (tester) async {
    await setupScreenSize(tester);
    final controller = DesignSystemController();
    await tester.pumpWidget(buildTestableWidget(controller));
    await tester.pump();

    // Find the dropdown button
    final presetDropdown = find.byType(DropdownButton<String>);
    expect(presetDropdown, findsOneWidget);

    // Verify it updates state (minimalist has md radius = 6.0, sharp has md radius = 0.0)
    expect(
      controller.state.globalTokens.borderRadiusScale
          .firstWhere((e) => e.key == 'md')
          .value
          .value,
      6.0,
    );

    // Trigger state change directly via preset applying to simulate dropdown action or simulate tapping dropdown
    controller.applyPreset(DesignSystemPresets.sharp());
    await tester.pumpAndSettle();

    expect(
      controller.state.globalTokens.borderRadiusScale
          .firstWhere((e) => e.key == 'md')
          .value
          .value,
      0.0,
    );
  });
}
