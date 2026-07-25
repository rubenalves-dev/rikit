import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/features/design_system/domain/component_models.dart';
import 'package:rikit/features/design_system/domain/color_token.dart';
import 'package:rikit/features/design_system/domain/design_system_state.dart';
import 'package:rikit/features/design_system/presentation/controllers/design_system_controller.dart';

void main() {
  group('DesignSystemPresets & State', () {
    test('minimalist preset initializes core color rows', () {
      final state = DesignSystemPresets.minimalist();
      expect(state.colorRows.length, 8);
      expect(state.colorRows[0].name, 'primary');
      expect(state.colorRows[0].isRemovable, false);

      // Check some of the default scaling values
      final defaultRadius = state.globalTokens.borderRadiusScale.firstWhere(
        (e) => e.key == state.globalTokens.defaultBorderRadiusKey,
      );
      expect(defaultRadius.value.value, 6.0);
    });

    test('sharp preset has 0px border-radius values', () {
      final state = DesignSystemPresets.sharp();
      for (final token in state.globalTokens.borderRadiusScale) {
        expect(token.value.value, 0.0);
      }
    });
  });

  group('DesignSystemController Operations', () {
    test('changing base color updates shades and contrast automatically', () {
      final controller = DesignSystemController();
      final primaryIndex = controller.state.colorRows.indexWhere(
        (r) => r.name == 'primary',
      );

      // Update primary base color to pure yellow
      controller.updateColorRowBase(primaryIndex, const Color(0xFFFFD700));

      final updatedRow = controller.state.colorRows[primaryIndex];
      expect(updatedRow.baseColor, const Color(0xFFFFD700));
      expect(updatedRow.shades[500], const Color(0xFFFFD700));
      // Yellow should contrast most with Black text
      expect(updatedRow.onColor, Colors.black);
    });

    test('protects core color rows from deletion and renaming', () {
      final controller = DesignSystemController();
      final initialCount = controller.state.colorRows.length;

      // Attempt to delete primary (index 0)
      controller.removeColorRow(0);
      expect(controller.state.colorRows.length, initialCount);

      // Attempt to rename primary (index 0)
      controller.renameColorRow(0, 'super-primary');
      expect(controller.state.colorRows[0].name, 'primary');
    });

    test('supports adding, renaming, and deleting custom colors', () {
      final controller = DesignSystemController();
      final initialCount = controller.state.colorRows.length;

      // Add a custom brand color
      controller.addColorRow('brand-lime', const Color(0xFF00FF00));
      expect(controller.state.colorRows.length, initialCount + 1);
      final customIndex = controller.state.colorRows.indexWhere(
        (r) => r.name == 'brand-lime',
      );
      expect(customIndex, isNot(-1));

      // Rename the custom color
      controller.renameColorRow(customIndex, 'brand-emerald');
      expect(controller.state.colorRows[customIndex].name, 'brand-emerald');

      // Delete the custom color
      controller.removeColorRow(customIndex);
      expect(controller.state.colorRows.length, initialCount);
    });

    test('typography updates propagate to group when flag is active', () {
      final controller = DesignSystemController();
      expect(controller.state.typography.groupHeadings, true);

      // Update H1 font family
      controller.updateTypographyStyle('h1', fontFamily: 'Roboto');
      expect(controller.state.typography.h1.fontFamily, 'Roboto');
      expect(controller.state.typography.h2.fontFamily, 'Roboto');
      expect(controller.state.typography.h3.fontFamily, 'Roboto');

      // Turn off grouping for headings
      controller.toggleGroupHeadings(false);
      controller.updateTypographyStyle('h1', fontFamily: 'Inter');
      expect(controller.state.typography.h1.fontFamily, 'Inter');
      expect(controller.state.typography.h2.fontFamily, 'Roboto'); // Unchanged
    });

    test('supports managing component custom variations', () {
      final controller = DesignSystemController();
      final btn =
          controller.state.components.firstWhere((c) => c.name == 'Button')
              as ButtonComponent;
      final initialVars = btn.variations.length;

      // Add custom ghost variation
      controller.addComponentVariation('Button', 'Ghost');
      final updatedBtn =
          controller.state.components.firstWhere((c) => c.name == 'Button')
              as ButtonComponent;
      expect(updatedBtn.variations.length, initialVars + 1);
      expect(updatedBtn.variations.last.name, 'Ghost');

      // Modify styled properties on custom variation
      final targetIndex = updatedBtn.variations.indexWhere(
        (v) => v.name == 'Ghost',
      );
      final ghostSpec = updatedBtn.variations[targetIndex].stateStyles['idle']!
          .copyWith(
            backgroundColor: const ColorToken.theme('base-500'),
            foregroundColor: const ColorToken.theme('primary-500'),
          );
      controller.updateButtonStyle(targetIndex, 'idle', ghostSpec);

      final modifiedBtn =
          controller.state.components.firstWhere((c) => c.name == 'Button')
              as ButtonComponent;
      expect(
        modifiedBtn
            .variations[targetIndex]
            .stateStyles['idle']!
            .backgroundColor
            .value,
        'base-500',
      );

      // Delete the custom variation
      controller.removeComponentVariation('Button', targetIndex);
      final finalBtn =
          controller.state.components.firstWhere((c) => c.name == 'Button')
              as ButtonComponent;
      expect(finalBtn.variations.length, initialVars);
    });
  });
}
