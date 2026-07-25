import 'package:flutter/material.dart';
import 'package:rikit/features/design_system/domain/color_token.dart';
import 'package:rikit/features/design_system/domain/design_system_state.dart';

Color resolveColorToken(ColorToken token, DesignSystemState state) {
  if (token.type == 'static') {
    return token.staticColor ?? Colors.transparent;
  }

  final parts = token.value.split('-');

  // Check for "on-[color]" pattern (e.g. on-primary)
  if (parts.length == 2 && parts[0] == 'on') {
    final rowName = parts[1];
    final row = state.colorRows.firstWhere(
      (r) => r.name.toLowerCase() == rowName.toLowerCase(),
      orElse: () => state.colorRows.first,
    );
    return row.onColor;
  }

  // Check for "[color]-[shade]" pattern (e.g. primary-500)
  if (parts.length == 2) {
    final rowName = parts[0];
    final shade = int.tryParse(parts[1]) ?? 500;
    final row = state.colorRows.firstWhere(
      (r) => r.name.toLowerCase() == rowName.toLowerCase(),
      orElse: () => state.colorRows.first,
    );
    return row.shades[shade] ?? row.baseColor;
  }

  // Fallback to name match (e.g. primary)
  final row = state.colorRows.firstWhere(
    (r) => r.name.toLowerCase() == token.value.toLowerCase(),
    orElse: () => state.colorRows.first,
  );
  return row.baseColor;
}
