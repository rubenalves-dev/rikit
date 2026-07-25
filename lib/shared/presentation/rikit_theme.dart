import 'package:flutter/material.dart';

abstract final class RikitColors {
  static const background = Color(0xFF08090B);
  static const surface = Color(0xFF101216);
  static const surfaceRaised = Color(0xFF17191F);
  static const surfaceHover = Color(0xFF1D2027);
  static const border = Color(0xFF292C34);
  static const borderSubtle = Color(0xFF1E2127);
  static const primary = Color(0xFFFF4D5E);
  static const primaryMuted = Color(0xFF6A2730);
  static const text = Color(0xFFF5F5F7);
  static const textMuted = Color(0xFF9297A3);
  static const success = Color(0xFF57D99A);
  static const warning = Color(0xFFFFC760);
}

abstract final class RikitTheme {
  static ThemeData dark() {
    final colorScheme = const ColorScheme.dark(
      primary: RikitColors.primary,
      onPrimary: Colors.white,
      surface: RikitColors.surface,
      onSurface: RikitColors.text,
      error: RikitColors.primary,
      outline: RikitColors.border,
    );
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: RikitColors.background,
      fontFamily: 'Inter',
      visualDensity: VisualDensity.compact,
      splashFactory: InkSparkle.splashFactory,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: RikitColors.text,
          fontSize: 34,
          height: 1.1,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.1,
        ),
        headlineSmall: TextStyle(
          color: RikitColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          color: RikitColors.text,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: RikitColors.textMuted,
          fontSize: 13,
          height: 1.45,
        ),
        labelMedium: TextStyle(
          color: RikitColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      dividerColor: RikitColors.borderSubtle,
      cardTheme: const CardThemeData(
        color: RikitColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: RikitColors.borderSubtle),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: RikitColors.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: RikitColors.border),
        ),
        textStyle: const TextStyle(color: RikitColors.text, fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RikitColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: RikitColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: RikitColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: RikitColors.primary),
        ),
      ),
    );
  }
}
