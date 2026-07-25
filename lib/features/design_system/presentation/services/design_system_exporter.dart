import 'dart:convert';
import 'package:rikit/features/design_system/domain/color_token.dart';
import 'package:rikit/features/design_system/domain/design_system_state.dart';
import 'package:rikit/features/design_system/domain/dimension.dart';

class DesignSystemExporter {
  const DesignSystemExporter();

  String exportToCSS(DesignSystemState state, String name) {
    final buffer = StringBuffer();
    final slug = name.toLowerCase().replaceAll(RegExp(r'\s+'), '-');
    buffer.writeln('/* Design System: $name */');
    buffer.writeln(':root {');

    // 1. Spacing scales
    buffer.writeln('  /* Spacing Scale */');
    for (final token in state.globalTokens.spacingScale) {
      buffer.writeln(
        '  --$slug-spacing-${token.key}: ${_formatDimension(token.value)};',
      );
    }
    buffer.writeln();

    // 2. Radius scales
    buffer.writeln('  /* Border Radii Scale */');
    for (final token in state.globalTokens.borderRadiusScale) {
      buffer.writeln(
        '  --$slug-radius-${token.key}: ${_formatDimension(token.value)};',
      );
    }
    buffer.writeln();

    // 3. Color scales
    buffer.writeln('  /* Color Row Shades */');
    for (final row in state.colorRows) {
      buffer.writeln('  /* ${row.name} */');
      for (final entry in row.shades.entries) {
        buffer.writeln(
          '  --$slug-${row.name}-${entry.key}: ${colorToHex(entry.value)};',
        );
      }
      buffer.writeln('  --$slug-on-${row.name}: ${colorToHex(row.onColor)};');
      buffer.writeln();
    }

    // 4. Typography Styles
    buffer.writeln('  /* Typography */');
    buffer.writeln('  --$slug-font-h1: "${state.typography.h1.fontFamily}";');
    buffer.writeln(
      '  --$slug-font-h1-size: ${_formatDimension(state.typography.h1.fontSize)};',
    );
    buffer.writeln(
      '  --$slug-font-body: "${state.typography.bodyNormal.fontFamily}";',
    );
    buffer.writeln(
      '  --$slug-font-body-size: ${_formatDimension(state.typography.bodyNormal.fontSize)};',
    );

    buffer.writeln('}');
    return buffer.toString();
  }

  String exportToJSON(DesignSystemState state) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(state.toJson());
  }

  String exportToYAML(DesignSystemState state, String name) {
    final buffer = StringBuffer();
    buffer.writeln('design_system:');
    buffer.writeln('  name: "$name"');
    buffer.writeln('  spacing_scale:');
    for (final token in state.globalTokens.spacingScale) {
      buffer.writeln('    ${token.key}: "${_formatDimension(token.value)}"');
    }
    buffer.writeln('  radius_scale:');
    for (final token in state.globalTokens.borderRadiusScale) {
      buffer.writeln('    ${token.key}: "${_formatDimension(token.value)}"');
    }
    buffer.writeln('  colors:');
    for (final row in state.colorRows) {
      buffer.writeln('    ${row.name}:');
      for (final entry in row.shades.entries) {
        buffer.writeln('      sh_${entry.key}: "${colorToHex(entry.value)}"');
      }
      buffer.writeln('      on_color: "${colorToHex(row.onColor)}"');
    }
    return buffer.toString();
  }

  String exportToTXT(
    DesignSystemState state,
    String name,
    String version,
    String author,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('=========================================');
    buffer.writeln('DESIGN SYSTEM MANIFEST: $name');
    buffer.writeln('Version: $version');
    buffer.writeln('Author: $author');
    buffer.writeln('=========================================');
    buffer.writeln();
    buffer.writeln('--- SPACING SCALE ---');
    for (final token in state.globalTokens.spacingScale) {
      buffer.writeln(
        '${token.key.padRight(8)} : ${_formatDimension(token.value)}',
      );
    }
    buffer.writeln();
    buffer.writeln('--- BORDER RADII ---');
    for (final token in state.globalTokens.borderRadiusScale) {
      buffer.writeln(
        '${token.key.padRight(8)} : ${_formatDimension(token.value)}',
      );
    }
    buffer.writeln();
    buffer.writeln('--- COLOR SCHEMES ---');
    for (final row in state.colorRows) {
      buffer.writeln(
        '${row.name.toUpperCase().padRight(12)} (Base: ${colorToHex(row.baseColor)}, On-Color: ${colorToHex(row.onColor)})',
      );
      buffer.write('  Shades: ');
      buffer.writeln(row.shades.keys.join(', '));
    }
    return buffer.toString();
  }

  String _formatDimension(Dimension dim) {
    if (dim.unit == DimensionUnit.none) {
      return dim.value.toString();
    }
    return '${dim.value}${dim.unit.name}';
  }
}
