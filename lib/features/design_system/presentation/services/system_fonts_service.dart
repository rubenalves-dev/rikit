import 'dart:io';
import 'package:flutter/foundation.dart';

class SystemFontsService {
  const SystemFontsService();

  static const List<String> fallbackFonts = [
    'SF Pro',
    'Inter',
    'Avenir',
    'Avenir Next',
    'Arial',
    'Helvetica',
    'Georgia',
    'Courier New',
    'Times New Roman',
    'Verdana',
    'Trebuchet MS',
    'Impact',
    'Monospace',
    'Serif',
    'Sans-Serif',
  ];

  Future<List<String>> loadSystemFonts() async {
    // Under Flutter widget tests, return fallback immediately to prevent hanging Process.run
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return fallbackFonts;
    }

    try {
      if (Platform.isMacOS) {
        final result = await Process.run('osascript', [
          '-e',
          'use framework "AppKit"\nreturn (current application\'s NSFontManager\'s sharedFontManager\'s availableFontFamilies) as list',
        ]);
        if (result.exitCode == 0) {
          final output = result.stdout.toString().trim();
          final fonts = output
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          if (fonts.isNotEmpty) {
            return fonts;
          }
        }
      } else if (Platform.isWindows) {
        final result = await Process.run('powershell', [
          '-Command',
          '[System.Drawing.Text.InstalledFontCollection]::new().Families | Select-Object -ExpandProperty Name',
        ]);
        if (result.exitCode == 0) {
          final output = result.stdout.toString().trim();
          final fonts = output
              .split(RegExp(r'\r?\n'))
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          if (fonts.isNotEmpty) {
            return fonts;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load system fonts dynamically: $e');
    }

    return fallbackFonts;
  }
}
