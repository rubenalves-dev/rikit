import 'package:flutter/material.dart';

String colorToHex(Color color) {
  final aVal = (color.a * 255).round().clamp(0, 255);
  final rVal = (color.r * 255).round().clamp(0, 255);
  final gVal = (color.g * 255).round().clamp(0, 255);
  final bVal = (color.b * 255).round().clamp(0, 255);

  final a = aVal.toRadixString(16).padLeft(2, '0');
  final r = rVal.toRadixString(16).padLeft(2, '0');
  final g = gVal.toRadixString(16).padLeft(2, '0');
  final b = bVal.toRadixString(16).padLeft(2, '0');

  // Return #RRGGBB by default (drop alpha if 255)
  if (aVal == 255) {
    return '#$r$g$b'.toUpperCase();
  }
  return '#$a$r$g$b'.toUpperCase();
}

Color hexToColor(String hex) {
  var cleanHex = hex.replaceAll('#', '').trim();
  if (cleanHex.length == 3) {
    final r = cleanHex[0];
    final g = cleanHex[1];
    final b = cleanHex[2];
    cleanHex = 'FF$r$r$g$g$b$b';
  } else if (cleanHex.length == 6) {
    cleanHex = 'FF$cleanHex';
  } else if (cleanHex.length == 8) {
    // Already has alpha
  } else {
    return Colors.black; // Fallback
  }
  return Color(int.parse(cleanHex, radix: 16));
}

class ColorToken {
  final String type; // 'theme' or 'static'
  final String value; // e.g. 'primary-500', or '#FFFFFF'

  const ColorToken.theme(this.value) : type = 'theme';
  const ColorToken.static(this.value) : type = 'static';

  bool get isTheme => type == 'theme';
  bool get isStatic => type == 'static';

  Color? get staticColor {
    if (!isStatic) return null;
    return hexToColor(value);
  }

  Map<String, dynamic> toJson() => {'type': type, 'value': value};

  factory ColorToken.fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'theme') {
      return ColorToken.theme(json['value'] as String);
    } else {
      return ColorToken.static(json['value'] as String);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorToken &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          value == other.value;

  @override
  int get hashCode => type.hashCode ^ value.hashCode;

  @override
  String toString() => '$type($value)';
}
