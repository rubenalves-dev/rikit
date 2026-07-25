import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/features/design_system/domain/dimension.dart';
import 'package:rikit/features/design_system/domain/color_token.dart';
import 'package:rikit/features/design_system/domain/color_row.dart';
import 'package:rikit/features/design_system/domain/typography_settings.dart';
import 'package:rikit/features/design_system/domain/component_models.dart';

void main() {
  group('Dimension', () {
    test('toString formatting works correctly', () {
      expect(const Dimension(16, DimensionUnit.px).toString(), '16px');
      expect(const Dimension(1.5, DimensionUnit.rem).toString(), '1.5rem');
      expect(const Dimension(100, DimensionUnit.percent).toString(), '100%');
      expect(const Dimension(8, DimensionUnit.none).toString(), '8');
      expect(const Dimension(8.5, DimensionUnit.none).toString(), '8.5');
    });

    test('JSON serialization matches', () {
      const dim = Dimension(2.5, DimensionUnit.em);
      final json = dim.toJson();
      expect(json['value'], 2.5);
      expect(json['unit'], 'em');

      final fromJson = Dimension.fromJson(json);
      expect(fromJson, dim);
    });
  });

  group('ColorToken & Utils', () {
    test('hexToColor parses short and long hex forms', () {
      expect(hexToColor('#FFF'), const Color(0xFFFFFFFF));
      expect(hexToColor('FFF'), const Color(0xFFFFFFFF));
      expect(hexToColor('#FF0000'), const Color(0xFFFF0000));
      expect(hexToColor('00FF00'), const Color(0xFF00FF00));
      expect(hexToColor('#800000FF'), const Color(0x800000FF));
    });

    test('colorToHex converts correctly', () {
      expect(colorToHex(const Color(0xFFFF0000)), '#FF0000');
      expect(colorToHex(const Color(0x8000FF00)), '#8000FF00');
    });

    test('ColorToken handles static and theme references', () {
      const staticToken = ColorToken.static('#FF0000');
      const themeToken = ColorToken.theme('primary-500');

      expect(staticToken.isStatic, true);
      expect(staticToken.isTheme, false);
      expect(staticToken.staticColor, const Color(0xFFFF0000));

      expect(themeToken.isStatic, false);
      expect(themeToken.isTheme, true);
      expect(themeToken.staticColor, null);
    });
  });

  group('ColorRow Scaling & Contrast', () {
    test('generates shades dynamically from 50 to 950', () {
      // Pick a brand primary color, e.g. blue #0066FF
      final baseBlue = hexToColor('#0066FF');
      final row = ColorRow.create(name: 'primary', baseColor: baseBlue);

      expect(row.name, 'primary');
      expect(row.shades.containsKey(50), true);
      expect(row.shades.containsKey(500), true);
      expect(row.shades.containsKey(950), true);

      // 500 should be the exact base color
      expect(row.shades[500], baseBlue);

      // Light shade (50) should be close to white (lightness ~0.98)
      final hsl50 = HSLColor.fromColor(row.shades[50]!);
      expect(hsl50.lightness, closeTo(0.98, 0.01));

      // Dark shade (950) should be close to black (lightness ~0.08)
      final hsl950 = HSLColor.fromColor(row.shades[950]!);
      expect(hsl950.lightness, closeTo(0.08, 0.01));
    });

    test('chooses high-contrast foreground color automatically', () {
      // White base color should select black text
      final whiteRow = ColorRow.create(name: 'base', baseColor: Colors.white);
      expect(whiteRow.onColor, Colors.black);

      // Black base color should select white text
      final blackRow = ColorRow.create(name: 'dark', baseColor: Colors.black);
      expect(blackRow.onColor, Colors.white);
    });
  });

  group('Polymorphic Components', () {
    test('ButtonStyleSpec and ButtonComponent serialize correctly', () {
      final btnStyle = ButtonStyleSpec(
        paddingHorizontal: const Dimension.px(16),
        paddingVertical: const Dimension.px(12),
        backgroundColor: const ColorToken.theme('primary-500'),
        foregroundColor: const ColorToken.theme('on-primary'),
        borderColor: const ColorToken.theme('borders'),
        borderWidth: const Dimension.px(1),
        borderRadius: const Dimension.px(6),
        fontSize: const Dimension.px(14),
        textTransform: 'uppercase',
        gap: const Dimension.px(8),
      );

      final variation = ComponentVariation<ButtonStyleSpec>(
        name: 'Default',
        stateStyles: {
          'idle': btnStyle,
          'hovered': btnStyle.copyWith(backgroundColor: const ColorToken.theme('primary-600')),
        },
      );

      final component = ButtonComponent(variations: [variation]);
      final json = component.toJson();

      expect(json['name'], 'Button');
      expect(json['variations'][0]['name'], 'Default');

      final parsed = parseDesignComponent(json) as ButtonComponent;
      expect(parsed.name, 'Button');
      expect(parsed.variations[0].name, 'Default');
      expect(parsed.variations[0].stateStyles['hovered']!.textTransform, 'uppercase');
      expect(parsed.variations[0].stateStyles['hovered']!.backgroundColor.value, 'primary-600');
    });
  });
}
