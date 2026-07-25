import 'package:flutter/material.dart';
import 'package:rikit/features/design_system/domain/color_token.dart';

class ColorRow {
  final String name;
  final Color baseColor;
  final bool isRemovable;
  final Map<int, Color> shades;
  final Color onColor;

  ColorRow({
    required this.name,
    required this.baseColor,
    required this.isRemovable,
    required this.shades,
    required this.onColor,
  });

  factory ColorRow.create({
    required String name,
    required Color baseColor,
    bool isRemovable = true,
  }) {
    final shades = _generateShades(baseColor);
    final onColor = _calculateContrastColor(baseColor);
    return ColorRow(
      name: name,
      baseColor: baseColor,
      isRemovable: isRemovable,
      shades: shades,
      onColor: onColor,
    );
  }

  static Map<int, Color> _generateShades(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    final h = hsl.hue;
    final s = hsl.saturation;
    final l = hsl.lightness;

    final Map<int, Color> generated = {};

    // For 50 to 500, linearly interpolate from 0.98 (at 50) to l (at 500)
    // l_shade = 0.98 + ratio * (l - 0.98)
    final Map<int, double> lightRatios = {
      50: 0.0,
      100: 0.2,
      200: 0.4,
      300: 0.6,
      400: 0.8,
      500: 1.0,
    };

    lightRatios.forEach((shade, ratio) {
      final shadeL = (0.98 + ratio * (l - 0.98)).clamp(0.0, 1.0);
      generated[shade] = HSLColor.fromAHSL(1.0, h, s, shadeL).toColor();
    });

    // For 600 to 950, linearly interpolate from l (at 500/ratio=0.0) to 0.08 (at 950/ratio=1.0)
    // l_shade = l + ratio * (0.08 - l)
    final Map<int, double> darkRatios = {
      600: 0.2,
      700: 0.4,
      800: 0.6,
      900: 0.8,
      950: 1.0,
    };

    darkRatios.forEach((shade, ratio) {
      final shadeL = (l + ratio * (0.08 - l)).clamp(0.0, 1.0);
      generated[shade] = HSLColor.fromAHSL(1.0, h, s, shadeL).toColor();
    });

    return generated;
  }

  static Color _calculateContrastColor(Color color) {
    // Relative luminance calculation using standard W3C luminance checks
    // computeLuminance is built into Flutter's Color class and implements the exact WCAG standard
    final luminance = color.computeLuminance();
    return luminance > 0.179 ? Colors.black : Colors.white;
  }

  ColorRow copyWith({
    String? name,
    Color? baseColor,
  }) {
    if (baseColor != null) {
      return ColorRow.create(
        name: name ?? this.name,
        baseColor: baseColor,
        isRemovable: isRemovable,
      );
    }
    return ColorRow(
      name: name ?? this.name,
      baseColor: this.baseColor,
      isRemovable: isRemovable,
      shades: shades,
      onColor: onColor,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'baseColor': colorToHex(baseColor),
        'isRemovable': isRemovable,
      };

  factory ColorRow.fromJson(Map<String, dynamic> json) {
    final base = hexToColor(json['baseColor'] as String);
    return ColorRow.create(
      name: json['name'] as String,
      baseColor: base,
      isRemovable: json['isRemovable'] as bool? ?? true,
    );
  }
}
