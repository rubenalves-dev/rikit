import 'package:flutter/material.dart';
import 'package:rikit/features/design_system/domain/color_row.dart';
import 'package:rikit/features/design_system/domain/color_token.dart';
import 'package:rikit/features/design_system/domain/component_models.dart';
import 'package:rikit/features/design_system/domain/dimension.dart';
import 'package:rikit/features/design_system/domain/global_tokens.dart';
import 'package:rikit/features/design_system/domain/typography_settings.dart';

class DesignSystemState {
  final GlobalTokens globalTokens;
  final List<ColorRow> colorRows;
  final TypographySettings typography;
  final List<DesignComponent> components;

  const DesignSystemState({
    required this.globalTokens,
    required this.colorRows,
    required this.typography,
    required this.components,
  });

  DesignSystemState copyWith({
    GlobalTokens? globalTokens,
    List<ColorRow>? colorRows,
    TypographySettings? typography,
    List<DesignComponent>? components,
  }) {
    return DesignSystemState(
      globalTokens: globalTokens ?? this.globalTokens,
      colorRows: colorRows ?? this.colorRows,
      typography: typography ?? this.typography,
      components: components ?? this.components,
    );
  }

  Map<String, dynamic> toJson() => {
    'globalTokens': globalTokens.toJson(),
    'colorRows': colorRows.map((e) => e.toJson()).toList(),
    'typography': typography.toJson(),
    'components': components.map((e) => e.toJson()).toList(),
  };

  factory DesignSystemState.fromJson(Map<String, dynamic> json) {
    return DesignSystemState(
      globalTokens: GlobalTokens.fromJson(
        json['globalTokens'] as Map<String, dynamic>,
      ),
      colorRows: (json['colorRows'] as List)
          .map((e) => ColorRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      typography: TypographySettings.fromJson(
        json['typography'] as Map<String, dynamic>,
      ),
      components: (json['components'] as List)
          .map((e) => parseDesignComponent(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DesignSystemPresets {
  static DesignSystemState minimalist() {
    return _buildState(
      primaryColor: const Color(0xFF0F172A), // Slate 900
      secondaryColor: const Color(0xFF64748B), // Slate 500
      accentColor: const Color(0xFF3B82F6), // Blue 500
      baseColor: const Color(0xFFFFFFFF),
      mutedColor: const Color(0xFFF8FAFC),
      destructiveColor: const Color(0xFFEF4444),
      bordersColor: const Color(0xFFE2E8F0),
      ringsColor: const Color(0xFF94A3B8),
      borderRadiusScale: [
        const ScaleToken('sm', Dimension.px(4)),
        const ScaleToken('md', Dimension.px(6)),
        const ScaleToken('lg', Dimension.px(10)),
        const ScaleToken('xl', Dimension.px(16)),
      ],
      spacingScale: [
        const ScaleToken('sm', Dimension.px(6)),
        const ScaleToken('md', Dimension.px(12)),
        const ScaleToken('lg', Dimension.px(18)),
        const ScaleToken('xl', Dimension.px(24)),
      ],
      shadowsScale: [
        const ScaleToken(
          'sm',
          ShadowValue(
            color: ColorToken.static('#0000000D'),
            offsetX: 0,
            offsetY: 1,
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ),
        const ScaleToken(
          'md',
          ShadowValue(
            color: ColorToken.static('#00000012'),
            offsetX: 0,
            offsetY: 4,
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ),
        const ScaleToken(
          'lg',
          ShadowValue(
            color: ColorToken.static('#0000001A'),
            offsetX: 0,
            offsetY: 10,
            blurRadius: 15,
            spreadRadius: -3,
          ),
        ),
        const ScaleToken(
          'xl',
          ShadowValue(
            color: ColorToken.static('#00000026'),
            offsetX: 0,
            offsetY: 20,
            blurRadius: 25,
            spreadRadius: -5,
          ),
        ),
      ],
      fontFamily: 'system-ui',
      h1Size: 32,
      h2Size: 24,
      h3Size: 18,
      bodyNormalSize: 15,
      bodySmallSize: 13,
      infoNormalSize: 11,
      infoSmallSize: 9,
      buttonRadius: const Dimension.px(6),
      buttonPaddingH: const Dimension.px(14),
      buttonPaddingV: const Dimension.px(8),
    );
  }

  static DesignSystemState sharp() {
    return _buildState(
      primaryColor: const Color(0xFF000000), // Black
      secondaryColor: const Color(0xFF3F3F46), // Zinc 700
      accentColor: const Color(0xFFFF5A00), // Orange
      baseColor: const Color(0xFFFFFFFF),
      mutedColor: const Color(0xFFF4F4F5),
      destructiveColor: const Color(0xFFD00000),
      bordersColor: const Color(0xFF000000),
      ringsColor: const Color(0xFF000000),
      borderRadiusScale: [
        const ScaleToken('sm', Dimension.px(0)),
        const ScaleToken('md', Dimension.px(0)),
        const ScaleToken('lg', Dimension.px(0)),
        const ScaleToken('xl', Dimension.px(0)),
      ],
      spacingScale: [
        const ScaleToken('sm', Dimension.px(4)),
        const ScaleToken('md', Dimension.px(8)),
        const ScaleToken('lg', Dimension.px(12)),
        const ScaleToken('xl', Dimension.px(16)),
      ],
      shadowsScale: [
        const ScaleToken(
          'sm',
          ShadowValue(
            color: ColorToken.static('#000000'),
            offsetX: 1,
            offsetY: 1,
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ),
        const ScaleToken(
          'md',
          ShadowValue(
            color: ColorToken.static('#000000'),
            offsetX: 2,
            offsetY: 2,
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ),
        const ScaleToken(
          'lg',
          ShadowValue(
            color: ColorToken.static('#000000'),
            offsetX: 4,
            offsetY: 4,
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ),
        const ScaleToken(
          'xl',
          ShadowValue(
            color: ColorToken.static('#000000'),
            offsetX: 6,
            offsetY: 6,
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ),
      ],
      fontFamily: 'Courier New',
      h1Size: 30,
      h2Size: 22,
      h3Size: 16,
      bodyNormalSize: 14,
      bodySmallSize: 12,
      infoNormalSize: 10,
      infoSmallSize: 8,
      buttonRadius: const Dimension.px(0),
      buttonPaddingH: const Dimension.px(12),
      buttonPaddingV: const Dimension.px(6),
    );
  }

  static DesignSystemState fullRounded() {
    return _buildState(
      primaryColor: const Color(0xFF6366F1), // Indigo 500
      secondaryColor: const Color(0xFFEC4899), // Pink 500
      accentColor: const Color(0xFF10B981), // Emerald 500
      baseColor: const Color(0xFFFFFFFF),
      mutedColor: const Color(0xFFFDF2F8), // Pink muted
      destructiveColor: const Color(0xFFF43F5E), // Rose 500
      bordersColor: const Color(0xFFF0E7F6),
      ringsColor: const Color(0xFFC7D2FE),
      borderRadiusScale: [
        const ScaleToken('sm', Dimension.px(8)),
        const ScaleToken('md', Dimension.px(16)),
        const ScaleToken('lg', Dimension.px(24)),
        const ScaleToken('xl', Dimension.px(9999)),
      ],
      spacingScale: [
        const ScaleToken('sm', Dimension.px(8)),
        const ScaleToken('md', Dimension.px(16)),
        const ScaleToken('lg', Dimension.px(24)),
        const ScaleToken('xl', Dimension.px(32)),
      ],
      shadowsScale: [
        const ScaleToken(
          'sm',
          ShadowValue(
            color: ColorToken.static('#6366F112'),
            offsetX: 0,
            offsetY: 2,
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ),
        const ScaleToken(
          'md',
          ShadowValue(
            color: ColorToken.static('#6366F11F'),
            offsetX: 0,
            offsetY: 6,
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ),
        const ScaleToken(
          'lg',
          ShadowValue(
            color: ColorToken.static('#6366F12B'),
            offsetX: 0,
            offsetY: 12,
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ),
        const ScaleToken(
          'xl',
          ShadowValue(
            color: ColorToken.static('#6366F13D'),
            offsetX: 0,
            offsetY: 20,
            blurRadius: 32,
            spreadRadius: 0,
          ),
        ),
      ],
      fontFamily: 'Avenir',
      h1Size: 34,
      h2Size: 26,
      h3Size: 20,
      bodyNormalSize: 16,
      bodySmallSize: 14,
      infoNormalSize: 12,
      infoSmallSize: 10,
      buttonRadius: const Dimension.px(9999),
      buttonPaddingH: const Dimension.px(18),
      buttonPaddingV: const Dimension.px(10),
    );
  }

  static DesignSystemState compact() {
    return _buildState(
      primaryColor: const Color(0xFF1E293B), // Slate 800
      secondaryColor: const Color(0xFF475569),
      accentColor: const Color(0xFF0EA5E9),
      baseColor: const Color(0xFFFFFFFF),
      mutedColor: const Color(0xFFF8FAFC),
      destructiveColor: const Color(0xFFEF4444),
      bordersColor: const Color(0xFFCBD5E1),
      ringsColor: const Color(0xFF38BDF8),
      borderRadiusScale: [
        const ScaleToken('sm', Dimension.px(2)),
        const ScaleToken('md', Dimension.px(4)),
        const ScaleToken('lg', Dimension.px(6)),
        const ScaleToken('xl', Dimension.px(8)),
      ],
      spacingScale: [
        const ScaleToken('sm', Dimension.px(4)),
        const ScaleToken('md', Dimension.px(8)),
        const ScaleToken('lg', Dimension.px(12)),
        const ScaleToken('xl', Dimension.px(16)),
      ],
      shadowsScale: [
        const ScaleToken(
          'sm',
          ShadowValue(
            color: ColorToken.static('#0000000A'),
            offsetX: 0,
            offsetY: 1,
            blurRadius: 1,
            spreadRadius: 0,
          ),
        ),
        const ScaleToken(
          'md',
          ShadowValue(
            color: ColorToken.static('#0000000F'),
            offsetX: 0,
            offsetY: 2,
            blurRadius: 3,
            spreadRadius: 0,
          ),
        ),
        const ScaleToken(
          'lg',
          ShadowValue(
            color: ColorToken.static('#00000014'),
            offsetX: 0,
            offsetY: 4,
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ),
        const ScaleToken(
          'xl',
          ShadowValue(
            color: ColorToken.static('#0000001F'),
            offsetX: 0,
            offsetY: 8,
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ),
      ],
      fontFamily: 'Arial',
      h1Size: 26,
      h2Size: 20,
      h3Size: 15,
      bodyNormalSize: 13,
      bodySmallSize: 11,
      infoNormalSize: 9,
      infoSmallSize: 7,
      buttonRadius: const Dimension.px(4),
      buttonPaddingH: const Dimension.px(10),
      buttonPaddingV: const Dimension.px(5),
    );
  }

  static DesignSystemState spacious() {
    return _buildState(
      primaryColor: const Color(0xFF1A1A1A),
      secondaryColor: const Color(0xFF757575),
      accentColor: const Color(0xFFFFD700),
      baseColor: const Color(0xFFFFFFFF),
      mutedColor: const Color(0xFFFAFAFA),
      destructiveColor: const Color(0xFFFF3B30),
      bordersColor: const Color(0xFFD1D1D6),
      ringsColor: const Color(0xFFFFD700),
      borderRadiusScale: [
        const ScaleToken('sm', Dimension.px(6)),
        const ScaleToken('md', Dimension.px(10)),
        const ScaleToken('lg', Dimension.px(16)),
        const ScaleToken('xl', Dimension.px(24)),
      ],
      spacingScale: [
        const ScaleToken('sm', Dimension.px(10)),
        const ScaleToken('md', Dimension.px(20)),
        const ScaleToken('lg', Dimension.px(30)),
        const ScaleToken('xl', Dimension.px(40)),
      ],
      shadowsScale: [
        const ScaleToken(
          'sm',
          ShadowValue(
            color: ColorToken.static('#00000008'),
            offsetX: 0,
            offsetY: 3,
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ),
        const ScaleToken(
          'md',
          ShadowValue(
            color: ColorToken.static('#0000000D'),
            offsetX: 0,
            offsetY: 8,
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ),
        const ScaleToken(
          'lg',
          ShadowValue(
            color: ColorToken.static('#00000014'),
            offsetX: 0,
            offsetY: 16,
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ),
        const ScaleToken(
          'xl',
          ShadowValue(
            color: ColorToken.static('#0000001A'),
            offsetX: 0,
            offsetY: 24,
            blurRadius: 40,
            spreadRadius: 0,
          ),
        ),
      ],
      fontFamily: 'Georgia',
      h1Size: 38,
      h2Size: 28,
      h3Size: 22,
      bodyNormalSize: 18,
      bodySmallSize: 15,
      infoNormalSize: 13,
      infoSmallSize: 11,
      buttonRadius: const Dimension.px(8),
      buttonPaddingH: const Dimension.px(20),
      buttonPaddingV: const Dimension.px(12),
    );
  }

  static DesignSystemState _buildState({
    required Color primaryColor,
    required Color secondaryColor,
    required Color accentColor,
    required Color baseColor,
    required Color mutedColor,
    required Color destructiveColor,
    required Color bordersColor,
    required Color ringsColor,
    required List<ScaleToken<Dimension>> borderRadiusScale,
    required List<ScaleToken<Dimension>> spacingScale,
    required List<ScaleToken<ShadowValue>> shadowsScale,
    required String fontFamily,
    required double h1Size,
    required double h2Size,
    required double h3Size,
    required double bodyNormalSize,
    required double bodySmallSize,
    required double infoNormalSize,
    required double infoSmallSize,
    required Dimension buttonRadius,
    required Dimension buttonPaddingH,
    required Dimension buttonPaddingV,
  }) {
    final colorRows = [
      ColorRow.create(
        name: 'primary',
        baseColor: primaryColor,
        isRemovable: false,
      ),
      ColorRow.create(
        name: 'secondary',
        baseColor: secondaryColor,
        isRemovable: false,
      ),
      ColorRow.create(
        name: 'accent',
        baseColor: accentColor,
        isRemovable: false,
      ),
      ColorRow.create(name: 'base', baseColor: baseColor, isRemovable: false),
      ColorRow.create(name: 'muted', baseColor: mutedColor, isRemovable: false),
      ColorRow.create(
        name: 'destructive',
        baseColor: destructiveColor,
        isRemovable: false,
      ),
      ColorRow.create(
        name: 'borders',
        baseColor: bordersColor,
        isRemovable: false,
      ),
      ColorRow.create(name: 'rings', baseColor: ringsColor, isRemovable: false),
    ];

    final globalTokens = GlobalTokens(
      borderRadiusScale: borderRadiusScale,
      spacingScale: spacingScale,
      shadowsScale: shadowsScale,
      defaultBorderRadiusKey: 'md',
      defaultSpacingKey: 'md',
      defaultShadowKey: 'md',
    );

    final typography = TypographySettings(
      h1: TextStyleSpec(
        fontFamily: fontFamily,
        fontSize: Dimension.px(h1Size),
        letterSpacing: const Dimension.px(0),
      ),
      h2: TextStyleSpec(
        fontFamily: fontFamily,
        fontSize: Dimension.px(h2Size),
        letterSpacing: const Dimension.px(0),
      ),
      h3: TextStyleSpec(
        fontFamily: fontFamily,
        fontSize: Dimension.px(h3Size),
        letterSpacing: const Dimension.px(0),
      ),
      bodyNormal: TextStyleSpec(
        fontFamily: fontFamily,
        fontSize: Dimension.px(bodyNormalSize),
        letterSpacing: const Dimension.px(0),
      ),
      bodySmall: TextStyleSpec(
        fontFamily: fontFamily,
        fontSize: Dimension.px(bodySmallSize),
        letterSpacing: const Dimension.px(0),
      ),
      infoNormal: TextStyleSpec(
        fontFamily: fontFamily,
        fontSize: Dimension.px(infoNormalSize),
        letterSpacing: const Dimension.px(0),
      ),
      infoSmall: TextStyleSpec(
        fontFamily: fontFamily,
        fontSize: Dimension.px(infoSmallSize),
        letterSpacing: const Dimension.px(0),
      ),
      groupHeadings: true,
      groupBodies: true,
      groupInfos: true,
    );

    // Initial specs for buttons, dropdowns and forms
    final btnSpec = ButtonStyleSpec(
      paddingHorizontal: buttonPaddingH,
      paddingVertical: buttonPaddingV,
      backgroundColor: const ColorToken.theme('primary-500'),
      foregroundColor: const ColorToken.theme('on-primary'),
      borderColor: const ColorToken.theme('borders'),
      borderWidth: const Dimension.px(1),
      borderRadius: buttonRadius,
      fontSize: Dimension.px(bodyNormalSize - 1),
      textTransform: 'none',
      gap: const Dimension.px(6),
    );

    final dropdownSpec = DropdownStyleSpec(
      triggerButton: btnSpec,
      menuBackground: const ColorToken.theme('base-500'),
      menuBorder: const ColorToken.theme('borders-500'),
      menuBorderRadius: buttonRadius,
      menuPadding: const Dimension.px(4),
      itemPaddingHorizontal: const Dimension.px(10),
      itemPaddingVertical: const Dimension.px(6),
      itemHoverBackground: const ColorToken.theme('muted-500'),
      itemHoverForeground: const ColorToken.theme('primary-500'),
    );

    final inputSpec = TextInputStyleSpec(
      backgroundColor: const ColorToken.theme('base-500'),
      foregroundColor: const ColorToken.theme('primary-500'),
      borderColor: const ColorToken.theme('borders-500'),
      borderWidth: const Dimension.px(1),
      borderRadius: buttonRadius,
      paddingHorizontal: const Dimension.px(12),
      paddingVertical: const Dimension.px(10),
      fontSize: Dimension.px(bodyNormalSize - 1),
      placeholderColor: const ColorToken.theme('secondary-400'),
    );

    final checkSpec = CheckboxStyleSpec(
      size: const Dimension.px(16),
      borderWidth: const Dimension.px(1),
      borderColor: const ColorToken.theme('borders-500'),
      backgroundColorUnchecked: const ColorToken.theme('base-500'),
      backgroundColorChecked: const ColorToken.theme('primary-500'),
      indicatorColor: const ColorToken.theme('on-primary'),
      borderRadius: const Dimension.px(4),
    );

    final sliderSpec = SliderStyleSpec(
      trackHeight: const Dimension.px(6),
      trackColorInactive: const ColorToken.theme('muted-500'),
      trackColorActive: const ColorToken.theme('primary-500'),
      thumbSize: const Dimension.px(16),
      thumbColor: const ColorToken.theme('primary-500'),
    );

    final toggleSpec = ToggleStyleSpec(
      width: const Dimension.px(40),
      height: const Dimension.px(24),
      trackColorOff: const ColorToken.theme('muted-500'),
      trackColorOn: const ColorToken.theme('primary-500'),
      thumbColor: const ColorToken.theme('base-500'),
      thumbSize: const Dimension.px(18),
    );

    final btnComp = ButtonComponent(
      variations: [
        ComponentVariation(
          name: 'Default',
          stateStyles: {
            'idle': btnSpec,
            'hovered': btnSpec.copyWith(
              backgroundColor: const ColorToken.theme('primary-600'),
            ),
            'pressed': btnSpec.copyWith(
              backgroundColor: const ColorToken.theme('primary-700'),
            ),
            'disabled': btnSpec.copyWith(
              backgroundColor: const ColorToken.theme('muted-500'),
              foregroundColor: const ColorToken.theme('secondary-400'),
            ),
          },
        ),
        ComponentVariation(
          name: 'Outline',
          stateStyles: {
            'idle': btnSpec.copyWith(
              backgroundColor: const ColorToken.theme('base-500'),
              foregroundColor: const ColorToken.theme('primary-500'),
            ),
            'hovered': btnSpec.copyWith(
              backgroundColor: const ColorToken.theme('muted-500'),
              foregroundColor: const ColorToken.theme('primary-600'),
            ),
            'pressed': btnSpec.copyWith(
              backgroundColor: const ColorToken.theme('borders-500'),
              foregroundColor: const ColorToken.theme('primary-700'),
            ),
            'disabled': btnSpec.copyWith(
              backgroundColor: const ColorToken.theme('base-500'),
              foregroundColor: const ColorToken.theme('muted-500'),
              borderColor: const ColorToken.theme('muted-500'),
            ),
          },
        ),
      ],
    );

    final dropdownComp = DropdownComponent(
      variations: [
        ComponentVariation(
          name: 'Default',
          stateStyles: {
            'idle': dropdownSpec,
            'hovered': dropdownSpec.copyWith(
              triggerButton: btnSpec.copyWith(
                backgroundColor: const ColorToken.theme('primary-600'),
              ),
            ),
            'pressed': dropdownSpec.copyWith(
              triggerButton: btnSpec.copyWith(
                backgroundColor: const ColorToken.theme('primary-700'),
              ),
            ),
            'disabled': dropdownSpec.copyWith(
              triggerButton: btnSpec.copyWith(
                backgroundColor: const ColorToken.theme('muted-500'),
                foregroundColor: const ColorToken.theme('secondary-400'),
              ),
            ),
          },
        ),
      ],
    );

    final inputComp = TextInputComponent(
      variations: [
        ComponentVariation(
          name: 'Default',
          stateStyles: {
            'idle': inputSpec,
            'hovered': inputSpec.copyWith(
              borderColor: const ColorToken.theme('secondary-500'),
            ),
            'focused': inputSpec.copyWith(
              borderColor: const ColorToken.theme('rings-500'),
            ),
            'disabled': inputSpec.copyWith(
              backgroundColor: const ColorToken.theme('muted-500'),
              foregroundColor: const ColorToken.theme('secondary-400'),
            ),
          },
        ),
      ],
    );

    final textareaComp = TextareaComponent(
      variations: [
        ComponentVariation(
          name: 'Default',
          stateStyles: {
            'idle': inputSpec.copyWith(paddingVertical: const Dimension.px(12)),
            'hovered': inputSpec.copyWith(
              paddingVertical: const Dimension.px(12),
              borderColor: const ColorToken.theme('secondary-500'),
            ),
            'focused': inputSpec.copyWith(
              paddingVertical: const Dimension.px(12),
              borderColor: const ColorToken.theme('rings-500'),
            ),
            'disabled': inputSpec.copyWith(
              paddingVertical: const Dimension.px(12),
              backgroundColor: const ColorToken.theme('muted-500'),
              foregroundColor: const ColorToken.theme('secondary-400'),
            ),
          },
        ),
      ],
    );

    final checkboxComp = CheckboxComponent(
      variations: [
        ComponentVariation(
          name: 'Default',
          stateStyles: {
            'uncheckedIdle': checkSpec,
            'uncheckedHovered': checkSpec.copyWith(
              borderColor: const ColorToken.theme('secondary-500'),
            ),
            'checkedIdle': checkSpec,
            'checkedHovered': checkSpec.copyWith(
              backgroundColorChecked: const ColorToken.theme('primary-600'),
            ),
            'disabled': checkSpec.copyWith(
              backgroundColorChecked: const ColorToken.theme('muted-500'),
              indicatorColor: const ColorToken.theme('secondary-400'),
            ),
          },
        ),
      ],
    );

    final radioComp = RadioComponent(
      variations: [
        ComponentVariation(
          name: 'Default',
          stateStyles: {
            'uncheckedIdle': checkSpec.copyWith(
              borderRadius: const Dimension.px(9999),
            ),
            'uncheckedHovered': checkSpec.copyWith(
              borderRadius: const Dimension.px(9999),
              borderColor: const ColorToken.theme('secondary-500'),
            ),
            'checkedIdle': checkSpec.copyWith(
              borderRadius: const Dimension.px(9999),
            ),
            'checkedHovered': checkSpec.copyWith(
              borderRadius: const Dimension.px(9999),
              backgroundColorChecked: const ColorToken.theme('primary-600'),
            ),
            'disabled': checkSpec.copyWith(
              borderRadius: const Dimension.px(9999),
              backgroundColorChecked: const ColorToken.theme('muted-500'),
              indicatorColor: const ColorToken.theme('secondary-400'),
            ),
          },
        ),
      ],
    );

    final sliderComp = SliderComponent(
      variations: [
        ComponentVariation(
          name: 'Default',
          stateStyles: {
            'idle': sliderSpec,
            'hovered': sliderSpec.copyWith(
              thumbColor: const ColorToken.theme('primary-600'),
            ),
            'dragging': sliderSpec.copyWith(
              thumbColor: const ColorToken.theme('primary-700'),
            ),
            'disabled': sliderSpec.copyWith(
              thumbColor: const ColorToken.theme('secondary-400'),
              trackColorActive: const ColorToken.theme('muted-500'),
            ),
          },
        ),
      ],
    );

    final toggleComp = ToggleComponent(
      variations: [
        ComponentVariation(
          name: 'Default',
          stateStyles: {
            'offIdle': toggleSpec,
            'offHovered': toggleSpec.copyWith(
              trackColorOff: const ColorToken.theme('secondary-400'),
            ),
            'onIdle': toggleSpec,
            'onHovered': toggleSpec.copyWith(
              trackColorOn: const ColorToken.theme('primary-600'),
            ),
            'disabled': toggleSpec.copyWith(
              trackColorOn: const ColorToken.theme('muted-500'),
              trackColorOff: const ColorToken.theme('muted-500'),
              thumbColor: const ColorToken.theme('secondary-400'),
            ),
          },
        ),
      ],
    );

    return DesignSystemState(
      globalTokens: globalTokens,
      colorRows: colorRows,
      typography: typography,
      components: [
        btnComp,
        dropdownComp,
        inputComp,
        textareaComp,
        checkboxComp,
        radioComp,
        sliderComp,
        toggleComp,
      ],
    );
  }
}
