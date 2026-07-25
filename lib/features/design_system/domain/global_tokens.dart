import 'package:rikit/features/design_system/domain/color_token.dart';
import 'package:rikit/features/design_system/domain/dimension.dart';

class ShadowValue {
  final ColorToken color;
  final double offsetX;
  final double offsetY;
  final double blurRadius;
  final double spreadRadius;

  const ShadowValue({
    required this.color,
    required this.offsetX,
    required this.offsetY,
    required this.blurRadius,
    required this.spreadRadius,
  });

  const ShadowValue.none()
      : color = const ColorToken.static('#00000000'),
        offsetX = 0.0,
        offsetY = 0.0,
        blurRadius = 0.0,
        spreadRadius = 0.0;

  Map<String, dynamic> toJson() => {
        'color': color.toJson(),
        'offsetX': offsetX,
        'offsetY': offsetY,
        'blurRadius': blurRadius,
        'spreadRadius': spreadRadius,
      };

  factory ShadowValue.fromJson(Map<String, dynamic> json) {
    return ShadowValue(
      color: ColorToken.fromJson(json['color'] as Map<String, dynamic>),
      offsetX: (json['offsetX'] as num).toDouble(),
      offsetY: (json['offsetY'] as num).toDouble(),
      blurRadius: (json['blurRadius'] as num).toDouble(),
      spreadRadius: (json['spreadRadius'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    // Returns e.g. "0px 2px 4px 0px #000000"
    return '${offsetX}px ${offsetY}px ${blurRadius}px ${spreadRadius}px ${color.value}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShadowValue &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          offsetX == other.offsetX &&
          offsetY == other.offsetY &&
          blurRadius == other.blurRadius &&
          spreadRadius == other.spreadRadius;

  @override
  int get hashCode =>
      color.hashCode ^
      offsetX.hashCode ^
      offsetY.hashCode ^
      blurRadius.hashCode ^
      spreadRadius.hashCode;
}

class ScaleToken<T> {
  final String key;
  final T value;

  const ScaleToken(this.key, this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScaleToken &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          value == other.value;

  @override
  int get hashCode => key.hashCode ^ value.hashCode;
}

class GlobalTokens {
  final List<ScaleToken<Dimension>> borderRadiusScale;
  final List<ScaleToken<Dimension>> spacingScale;
  final List<ScaleToken<ShadowValue>> shadowsScale;
  
  // Nominated keys for default fallback references
  final String defaultBorderRadiusKey;
  final String defaultSpacingKey;
  final String defaultShadowKey;

  const GlobalTokens({
    required this.borderRadiusScale,
    required this.spacingScale,
    required this.shadowsScale,
    required this.defaultBorderRadiusKey,
    required this.defaultSpacingKey,
    required this.defaultShadowKey,
  });

  Map<String, dynamic> toJson() => {
        'borderRadiusScale': borderRadiusScale
            .map((e) => {'key': e.key, 'value': e.value.toJson()})
            .toList(),
        'spacingScale': spacingScale
            .map((e) => {'key': e.key, 'value': e.value.toJson()})
            .toList(),
        'shadowsScale': shadowsScale
            .map((e) => {'key': e.key, 'value': e.value.toJson()})
            .toList(),
        'defaultBorderRadiusKey': defaultBorderRadiusKey,
        'defaultSpacingKey': defaultSpacingKey,
        'defaultShadowKey': defaultShadowKey,
      };

  factory GlobalTokens.fromJson(Map<String, dynamic> json) {
    final brList = (json['borderRadiusScale'] as List)
        .map((e) => ScaleToken(
            e['key'] as String, Dimension.fromJson(e['value'] as Map<String, dynamic>)))
        .toList();
    final spList = (json['spacingScale'] as List)
        .map((e) => ScaleToken(
            e['key'] as String, Dimension.fromJson(e['value'] as Map<String, dynamic>)))
        .toList();
    final sdList = (json['shadowsScale'] as List)
        .map((e) => ScaleToken(
            e['key'] as String, ShadowValue.fromJson(e['value'] as Map<String, dynamic>)))
        .toList();

    return GlobalTokens(
      borderRadiusScale: brList,
      spacingScale: spList,
      shadowsScale: sdList,
      defaultBorderRadiusKey: json['defaultBorderRadiusKey'] as String? ?? 'md',
      defaultSpacingKey: json['defaultSpacingKey'] as String? ?? 'md',
      defaultShadowKey: json['defaultShadowKey'] as String? ?? 'md',
    );
  }

  GlobalTokens copyWith({
    List<ScaleToken<Dimension>>? borderRadiusScale,
    List<ScaleToken<Dimension>>? spacingScale,
    List<ScaleToken<ShadowValue>>? shadowsScale,
    String? defaultBorderRadiusKey,
    String? defaultSpacingKey,
    String? defaultShadowKey,
  }) {
    return GlobalTokens(
      borderRadiusScale: borderRadiusScale ?? this.borderRadiusScale,
      spacingScale: spacingScale ?? this.spacingScale,
      shadowsScale: shadowsScale ?? this.shadowsScale,
      defaultBorderRadiusKey: defaultBorderRadiusKey ?? this.defaultBorderRadiusKey,
      defaultSpacingKey: defaultSpacingKey ?? this.defaultSpacingKey,
      defaultShadowKey: defaultShadowKey ?? this.defaultShadowKey,
    );
  }
}
