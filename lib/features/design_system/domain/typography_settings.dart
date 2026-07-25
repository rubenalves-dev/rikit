import 'package:rikit/features/design_system/domain/dimension.dart';

class TextStyleSpec {
  final String fontFamily;
  final Dimension fontSize;
  final Dimension letterSpacing;

  const TextStyleSpec({
    required this.fontFamily,
    required this.fontSize,
    required this.letterSpacing,
  });

  TextStyleSpec copyWith({
    String? fontFamily,
    Dimension? fontSize,
    Dimension? letterSpacing,
  }) {
    return TextStyleSpec(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      letterSpacing: letterSpacing ?? this.letterSpacing,
    );
  }

  Map<String, dynamic> toJson() => {
    'fontFamily': fontFamily,
    'fontSize': fontSize.toJson(),
    'letterSpacing': letterSpacing.toJson(),
  };

  factory TextStyleSpec.fromJson(Map<String, dynamic> json) {
    return TextStyleSpec(
      fontFamily: json['fontFamily'] as String,
      fontSize: Dimension.fromJson(json['fontSize'] as Map<String, dynamic>),
      letterSpacing: Dimension.fromJson(
        json['letterSpacing'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextStyleSpec &&
          runtimeType == other.runtimeType &&
          fontFamily == other.fontFamily &&
          fontSize == other.fontSize &&
          letterSpacing == other.letterSpacing;

  @override
  int get hashCode =>
      fontFamily.hashCode ^ fontSize.hashCode ^ letterSpacing.hashCode;
}

class TypographySettings {
  final TextStyleSpec h1;
  final TextStyleSpec h2;
  final TextStyleSpec h3;

  final TextStyleSpec bodyNormal;
  final TextStyleSpec bodySmall;

  final TextStyleSpec infoNormal;
  final TextStyleSpec infoSmall;

  final bool groupHeadings;
  final bool groupBodies;
  final bool groupInfos;

  const TypographySettings({
    required this.h1,
    required this.h2,
    required this.h3,
    required this.bodyNormal,
    required this.bodySmall,
    required this.infoNormal,
    required this.infoSmall,
    this.groupHeadings = true,
    this.groupBodies = true,
    this.groupInfos = true,
  });

  Map<String, dynamic> toJson() => {
    'h1': h1.toJson(),
    'h2': h2.toJson(),
    'h3': h3.toJson(),
    'bodyNormal': bodyNormal.toJson(),
    'bodySmall': bodySmall.toJson(),
    'infoNormal': infoNormal.toJson(),
    'infoSmall': infoSmall.toJson(),
    'groupHeadings': groupHeadings,
    'groupBodies': groupBodies,
    'groupInfos': groupInfos,
  };

  factory TypographySettings.fromJson(Map<String, dynamic> json) {
    return TypographySettings(
      h1: TextStyleSpec.fromJson(json['h1'] as Map<String, dynamic>),
      h2: TextStyleSpec.fromJson(json['h2'] as Map<String, dynamic>),
      h3: TextStyleSpec.fromJson(json['h3'] as Map<String, dynamic>),
      bodyNormal: TextStyleSpec.fromJson(
        json['bodyNormal'] as Map<String, dynamic>,
      ),
      bodySmall: TextStyleSpec.fromJson(
        json['bodySmall'] as Map<String, dynamic>,
      ),
      infoNormal: TextStyleSpec.fromJson(
        json['infoNormal'] as Map<String, dynamic>,
      ),
      infoSmall: TextStyleSpec.fromJson(
        json['infoSmall'] as Map<String, dynamic>,
      ),
      groupHeadings: json['groupHeadings'] as bool? ?? true,
      groupBodies: json['groupBodies'] as bool? ?? true,
      groupInfos: json['groupInfos'] as bool? ?? true,
    );
  }

  TypographySettings copyWith({
    TextStyleSpec? h1,
    TextStyleSpec? h2,
    TextStyleSpec? h3,
    TextStyleSpec? bodyNormal,
    TextStyleSpec? bodySmall,
    TextStyleSpec? infoNormal,
    TextStyleSpec? infoSmall,
    bool? groupHeadings,
    bool? groupBodies,
    bool? groupInfos,
  }) {
    return TypographySettings(
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      bodyNormal: bodyNormal ?? this.bodyNormal,
      bodySmall: bodySmall ?? this.bodySmall,
      infoNormal: infoNormal ?? this.infoNormal,
      infoSmall: infoSmall ?? this.infoSmall,
      groupHeadings: groupHeadings ?? this.groupHeadings,
      groupBodies: groupBodies ?? this.groupBodies,
      groupInfos: groupInfos ?? this.groupInfos,
    );
  }
}
