import 'package:rikit/features/design_system/domain/color_token.dart';
import 'package:rikit/features/design_system/domain/dimension.dart';

// Polymorphic base for style specs
abstract class ComponentStyleSpec {
  Map<String, dynamic> toJson();
}

class ComponentVariation<T extends ComponentStyleSpec> {
  final String name;
  final Map<String, T>
  stateStyles; // maps state key (e.g. 'idle', 'hovered') to specific style

  ComponentVariation({required this.name, required this.stateStyles});

  ComponentVariation<T> copyWith({String? name, Map<String, T>? stateStyles}) {
    return ComponentVariation<T>(
      name: name ?? this.name,
      stateStyles: stateStyles ?? Map<String, T>.from(this.stateStyles),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'stateStyles': stateStyles.map((key, val) => MapEntry(key, val.toJson())),
  };
}

abstract class DesignComponent {
  String get name;
  List<ComponentVariation> get variations;

  Map<String, dynamic> toJson();
}

// 1. Button Style Spec
class ButtonStyleSpec implements ComponentStyleSpec {
  final Dimension paddingHorizontal;
  final Dimension paddingVertical;
  final ColorToken backgroundColor;
  final ColorToken foregroundColor;
  final ColorToken borderColor;
  final Dimension borderWidth;
  final Dimension borderRadius;
  final Dimension fontSize;
  final String textTransform; // 'none', 'uppercase', 'lowercase', 'capitalize'
  final Dimension gap;

  const ButtonStyleSpec({
    required this.paddingHorizontal,
    required this.paddingVertical,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.fontSize,
    required this.textTransform,
    required this.gap,
  });

  ButtonStyleSpec copyWith({
    Dimension? paddingHorizontal,
    Dimension? paddingVertical,
    ColorToken? backgroundColor,
    ColorToken? foregroundColor,
    ColorToken? borderColor,
    Dimension? borderWidth,
    Dimension? borderRadius,
    Dimension? fontSize,
    String? textTransform,
    Dimension? gap,
  }) {
    return ButtonStyleSpec(
      paddingHorizontal: paddingHorizontal ?? this.paddingHorizontal,
      paddingVertical: paddingVertical ?? this.paddingVertical,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      fontSize: fontSize ?? this.fontSize,
      textTransform: textTransform ?? this.textTransform,
      gap: gap ?? this.gap,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'paddingHorizontal': paddingHorizontal.toJson(),
    'paddingVertical': paddingVertical.toJson(),
    'backgroundColor': backgroundColor.toJson(),
    'foregroundColor': foregroundColor.toJson(),
    'borderColor': borderColor.toJson(),
    'borderWidth': borderWidth.toJson(),
    'borderRadius': borderRadius.toJson(),
    'fontSize': fontSize.toJson(),
    'textTransform': textTransform,
    'gap': gap.toJson(),
  };

  factory ButtonStyleSpec.fromJson(Map<String, dynamic> json) {
    return ButtonStyleSpec(
      paddingHorizontal: Dimension.fromJson(
        json['paddingHorizontal'] as Map<String, dynamic>,
      ),
      paddingVertical: Dimension.fromJson(
        json['paddingVertical'] as Map<String, dynamic>,
      ),
      backgroundColor: ColorToken.fromJson(
        json['backgroundColor'] as Map<String, dynamic>,
      ),
      foregroundColor: ColorToken.fromJson(
        json['foregroundColor'] as Map<String, dynamic>,
      ),
      borderColor: ColorToken.fromJson(
        json['borderColor'] as Map<String, dynamic>,
      ),
      borderWidth: Dimension.fromJson(
        json['borderWidth'] as Map<String, dynamic>,
      ),
      borderRadius: Dimension.fromJson(
        json['borderRadius'] as Map<String, dynamic>,
      ),
      fontSize: Dimension.fromJson(json['fontSize'] as Map<String, dynamic>),
      textTransform: json['textTransform'] as String? ?? 'none',
      gap: Dimension.fromJson(json['gap'] as Map<String, dynamic>),
    );
  }
}

class ButtonComponent extends DesignComponent {
  @override
  final String name = 'Button';
  @override
  final List<ComponentVariation<ButtonStyleSpec>> variations;

  ButtonComponent({required this.variations});

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'variations': variations.map((v) => v.toJson()).toList(),
  };

  factory ButtonComponent.fromJson(Map<String, dynamic> json) {
    final list = (json['variations'] as List)
        .map(
          (v) => ComponentVariation<ButtonStyleSpec>(
            name: v['name'] as String,
            stateStyles: (v['stateStyles'] as Map<String, dynamic>).map(
              (k, val) => MapEntry(
                k,
                ButtonStyleSpec.fromJson(val as Map<String, dynamic>),
              ),
            ),
          ),
        )
        .toList();
    return ButtonComponent(variations: list);
  }
}

// 2. Dropdown Style Spec
class DropdownStyleSpec implements ComponentStyleSpec {
  final ButtonStyleSpec triggerButton;
  final ColorToken menuBackground;
  final ColorToken menuBorder;
  final Dimension menuBorderRadius;
  final Dimension menuPadding;
  final Dimension itemPaddingHorizontal;
  final Dimension itemPaddingVertical;
  final ColorToken itemHoverBackground;
  final ColorToken itemHoverForeground;

  const DropdownStyleSpec({
    required this.triggerButton,
    required this.menuBackground,
    required this.menuBorder,
    required this.menuBorderRadius,
    required this.menuPadding,
    required this.itemPaddingHorizontal,
    required this.itemPaddingVertical,
    required this.itemHoverBackground,
    required this.itemHoverForeground,
  });

  DropdownStyleSpec copyWith({
    ButtonStyleSpec? triggerButton,
    ColorToken? menuBackground,
    ColorToken? menuBorder,
    Dimension? menuBorderRadius,
    Dimension? menuPadding,
    Dimension? itemPaddingHorizontal,
    Dimension? itemPaddingVertical,
    ColorToken? itemHoverBackground,
    ColorToken? itemHoverForeground,
  }) {
    return DropdownStyleSpec(
      triggerButton: triggerButton ?? this.triggerButton,
      menuBackground: menuBackground ?? this.menuBackground,
      menuBorder: menuBorder ?? this.menuBorder,
      menuBorderRadius: menuBorderRadius ?? this.menuBorderRadius,
      menuPadding: menuPadding ?? this.menuPadding,
      itemPaddingHorizontal:
          itemPaddingHorizontal ?? this.itemPaddingHorizontal,
      itemPaddingVertical: itemPaddingVertical ?? this.itemPaddingVertical,
      itemHoverBackground: itemHoverBackground ?? this.itemHoverBackground,
      itemHoverForeground: itemHoverForeground ?? this.itemHoverForeground,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'triggerButton': triggerButton.toJson(),
    'menuBackground': menuBackground.toJson(),
    'menuBorder': menuBorder.toJson(),
    'menuBorderRadius': menuBorderRadius.toJson(),
    'menuPadding': menuPadding.toJson(),
    'itemPaddingHorizontal': itemPaddingHorizontal.toJson(),
    'itemPaddingVertical': itemPaddingVertical.toJson(),
    'itemHoverBackground': itemHoverBackground.toJson(),
    'itemHoverForeground': itemHoverForeground.toJson(),
  };

  factory DropdownStyleSpec.fromJson(Map<String, dynamic> json) {
    return DropdownStyleSpec(
      triggerButton: ButtonStyleSpec.fromJson(
        json['triggerButton'] as Map<String, dynamic>,
      ),
      menuBackground: ColorToken.fromJson(
        json['menuBackground'] as Map<String, dynamic>,
      ),
      menuBorder: ColorToken.fromJson(
        json['menuBorder'] as Map<String, dynamic>,
      ),
      menuBorderRadius: Dimension.fromJson(
        json['menuBorderRadius'] as Map<String, dynamic>,
      ),
      menuPadding: Dimension.fromJson(
        json['menuPadding'] as Map<String, dynamic>,
      ),
      itemPaddingHorizontal: Dimension.fromJson(
        json['itemPaddingHorizontal'] as Map<String, dynamic>,
      ),
      itemPaddingVertical: Dimension.fromJson(
        json['itemPaddingVertical'] as Map<String, dynamic>,
      ),
      itemHoverBackground: ColorToken.fromJson(
        json['itemHoverBackground'] as Map<String, dynamic>,
      ),
      itemHoverForeground: ColorToken.fromJson(
        json['itemHoverForeground'] as Map<String, dynamic>,
      ),
    );
  }
}

class DropdownComponent extends DesignComponent {
  @override
  final String name = 'Dropdown';
  @override
  final List<ComponentVariation<DropdownStyleSpec>> variations;

  DropdownComponent({required this.variations});

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'variations': variations.map((v) => v.toJson()).toList(),
  };

  factory DropdownComponent.fromJson(Map<String, dynamic> json) {
    final list = (json['variations'] as List)
        .map(
          (v) => ComponentVariation<DropdownStyleSpec>(
            name: v['name'] as String,
            stateStyles: (v['stateStyles'] as Map<String, dynamic>).map(
              (k, val) => MapEntry(
                k,
                DropdownStyleSpec.fromJson(val as Map<String, dynamic>),
              ),
            ),
          ),
        )
        .toList();
    return DropdownComponent(variations: list);
  }
}

// 3. Text Input Style Spec
class TextInputStyleSpec implements ComponentStyleSpec {
  final ColorToken backgroundColor;
  final ColorToken foregroundColor;
  final ColorToken borderColor;
  final Dimension borderWidth;
  final Dimension borderRadius;
  final Dimension paddingHorizontal;
  final Dimension paddingVertical;
  final Dimension fontSize;
  final ColorToken placeholderColor;

  const TextInputStyleSpec({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.paddingHorizontal,
    required this.paddingVertical,
    required this.fontSize,
    required this.placeholderColor,
  });

  TextInputStyleSpec copyWith({
    ColorToken? backgroundColor,
    ColorToken? foregroundColor,
    ColorToken? borderColor,
    Dimension? borderWidth,
    Dimension? borderRadius,
    Dimension? paddingHorizontal,
    Dimension? paddingVertical,
    Dimension? fontSize,
    ColorToken? placeholderColor,
  }) {
    return TextInputStyleSpec(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      paddingHorizontal: paddingHorizontal ?? this.paddingHorizontal,
      paddingVertical: paddingVertical ?? this.paddingVertical,
      fontSize: fontSize ?? this.fontSize,
      placeholderColor: placeholderColor ?? this.placeholderColor,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'backgroundColor': backgroundColor.toJson(),
    'foregroundColor': foregroundColor.toJson(),
    'borderColor': borderColor.toJson(),
    'borderWidth': borderWidth.toJson(),
    'borderRadius': borderRadius.toJson(),
    'paddingHorizontal': paddingHorizontal.toJson(),
    'paddingVertical': paddingVertical.toJson(),
    'fontSize': fontSize.toJson(),
    'placeholderColor': placeholderColor.toJson(),
  };

  factory TextInputStyleSpec.fromJson(Map<String, dynamic> json) {
    return TextInputStyleSpec(
      backgroundColor: ColorToken.fromJson(
        json['backgroundColor'] as Map<String, dynamic>,
      ),
      foregroundColor: ColorToken.fromJson(
        json['foregroundColor'] as Map<String, dynamic>,
      ),
      borderColor: ColorToken.fromJson(
        json['borderColor'] as Map<String, dynamic>,
      ),
      borderWidth: Dimension.fromJson(
        json['borderWidth'] as Map<String, dynamic>,
      ),
      borderRadius: Dimension.fromJson(
        json['borderRadius'] as Map<String, dynamic>,
      ),
      paddingHorizontal: Dimension.fromJson(
        json['paddingHorizontal'] as Map<String, dynamic>,
      ),
      paddingVertical: Dimension.fromJson(
        json['paddingVertical'] as Map<String, dynamic>,
      ),
      fontSize: Dimension.fromJson(json['fontSize'] as Map<String, dynamic>),
      placeholderColor: ColorToken.fromJson(
        json['placeholderColor'] as Map<String, dynamic>,
      ),
    );
  }
}

class TextInputComponent extends DesignComponent {
  @override
  final String name = 'Text Input';
  @override
  final List<ComponentVariation<TextInputStyleSpec>> variations;

  TextInputComponent({required this.variations});

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'variations': variations.map((v) => v.toJson()).toList(),
  };

  factory TextInputComponent.fromJson(Map<String, dynamic> json) {
    final list = (json['variations'] as List)
        .map(
          (v) => ComponentVariation<TextInputStyleSpec>(
            name: v['name'] as String,
            stateStyles: (v['stateStyles'] as Map<String, dynamic>).map(
              (k, val) => MapEntry(
                k,
                TextInputStyleSpec.fromJson(val as Map<String, dynamic>),
              ),
            ),
          ),
        )
        .toList();
    return TextInputComponent(variations: list);
  }
}

// 4. Textarea Component (inherits TextInputStyleSpec as requested)
class TextareaComponent extends DesignComponent {
  @override
  final String name = 'Textarea';
  @override
  final List<ComponentVariation<TextInputStyleSpec>> variations;

  TextareaComponent({required this.variations});

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'variations': variations.map((v) => v.toJson()).toList(),
  };

  factory TextareaComponent.fromJson(Map<String, dynamic> json) {
    final list = (json['variations'] as List)
        .map(
          (v) => ComponentVariation<TextInputStyleSpec>(
            name: v['name'] as String,
            stateStyles: (v['stateStyles'] as Map<String, dynamic>).map(
              (k, val) => MapEntry(
                k,
                TextInputStyleSpec.fromJson(val as Map<String, dynamic>),
              ),
            ),
          ),
        )
        .toList();
    return TextareaComponent(variations: list);
  }
}

// 5. Checkbox Style Spec (and Radio)
class CheckboxStyleSpec implements ComponentStyleSpec {
  final Dimension size;
  final Dimension borderWidth;
  final ColorToken borderColor;
  final ColorToken backgroundColorUnchecked;
  final ColorToken backgroundColorChecked;
  final ColorToken indicatorColor;
  final Dimension borderRadius; // Checkbox only, Radio is circular

  const CheckboxStyleSpec({
    required this.size,
    required this.borderWidth,
    required this.borderColor,
    required this.backgroundColorUnchecked,
    required this.backgroundColorChecked,
    required this.indicatorColor,
    required this.borderRadius,
  });

  CheckboxStyleSpec copyWith({
    Dimension? size,
    Dimension? borderWidth,
    ColorToken? borderColor,
    ColorToken? backgroundColorUnchecked,
    ColorToken? backgroundColorChecked,
    ColorToken? indicatorColor,
    Dimension? borderRadius,
  }) {
    return CheckboxStyleSpec(
      size: size ?? this.size,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      backgroundColorUnchecked:
          backgroundColorUnchecked ?? this.backgroundColorUnchecked,
      backgroundColorChecked:
          backgroundColorChecked ?? this.backgroundColorChecked,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'size': size.toJson(),
    'borderWidth': borderWidth.toJson(),
    'borderColor': borderColor.toJson(),
    'backgroundColorUnchecked': backgroundColorUnchecked.toJson(),
    'backgroundColorChecked': backgroundColorChecked.toJson(),
    'indicatorColor': indicatorColor.toJson(),
    'borderRadius': borderRadius.toJson(),
  };

  factory CheckboxStyleSpec.fromJson(Map<String, dynamic> json) {
    return CheckboxStyleSpec(
      size: Dimension.fromJson(json['size'] as Map<String, dynamic>),
      borderWidth: Dimension.fromJson(
        json['borderWidth'] as Map<String, dynamic>,
      ),
      borderColor: ColorToken.fromJson(
        json['borderColor'] as Map<String, dynamic>,
      ),
      backgroundColorUnchecked: ColorToken.fromJson(
        json['backgroundColorUnchecked'] as Map<String, dynamic>,
      ),
      backgroundColorChecked: ColorToken.fromJson(
        json['backgroundColorChecked'] as Map<String, dynamic>,
      ),
      indicatorColor: ColorToken.fromJson(
        json['indicatorColor'] as Map<String, dynamic>,
      ),
      borderRadius: Dimension.fromJson(
        json['borderRadius'] as Map<String, dynamic>,
      ),
    );
  }
}

class CheckboxComponent extends DesignComponent {
  @override
  final String name = 'Checkbox';
  @override
  final List<ComponentVariation<CheckboxStyleSpec>> variations;

  CheckboxComponent({required this.variations});

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'variations': variations.map((v) => v.toJson()).toList(),
  };

  factory CheckboxComponent.fromJson(Map<String, dynamic> json) {
    final list = (json['variations'] as List)
        .map(
          (v) => ComponentVariation<CheckboxStyleSpec>(
            name: v['name'] as String,
            stateStyles: (v['stateStyles'] as Map<String, dynamic>).map(
              (k, val) => MapEntry(
                k,
                CheckboxStyleSpec.fromJson(val as Map<String, dynamic>),
              ),
            ),
          ),
        )
        .toList();
    return CheckboxComponent(variations: list);
  }
}

class RadioComponent extends DesignComponent {
  @override
  final String name = 'Radio';
  @override
  final List<ComponentVariation<CheckboxStyleSpec>> variations;

  RadioComponent({required this.variations});

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'variations': variations.map((v) => v.toJson()).toList(),
  };

  factory RadioComponent.fromJson(Map<String, dynamic> json) {
    final list = (json['variations'] as List)
        .map(
          (v) => ComponentVariation<CheckboxStyleSpec>(
            name: v['name'] as String,
            stateStyles: (v['stateStyles'] as Map<String, dynamic>).map(
              (k, val) => MapEntry(
                k,
                CheckboxStyleSpec.fromJson(val as Map<String, dynamic>),
              ),
            ),
          ),
        )
        .toList();
    return RadioComponent(variations: list);
  }
}

// 6. Slider Style Spec
class SliderStyleSpec implements ComponentStyleSpec {
  final Dimension trackHeight;
  final ColorToken trackColorInactive;
  final ColorToken trackColorActive;
  final Dimension thumbSize;
  final ColorToken thumbColor;

  const SliderStyleSpec({
    required this.trackHeight,
    required this.trackColorInactive,
    required this.trackColorActive,
    required this.thumbSize,
    required this.thumbColor,
  });

  SliderStyleSpec copyWith({
    Dimension? trackHeight,
    ColorToken? trackColorInactive,
    ColorToken? trackColorActive,
    Dimension? thumbSize,
    ColorToken? thumbColor,
  }) {
    return SliderStyleSpec(
      trackHeight: trackHeight ?? this.trackHeight,
      trackColorInactive: trackColorInactive ?? this.trackColorInactive,
      trackColorActive: trackColorActive ?? this.trackColorActive,
      thumbSize: thumbSize ?? this.thumbSize,
      thumbColor: thumbColor ?? this.thumbColor,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'trackHeight': trackHeight.toJson(),
    'trackColorInactive': trackColorInactive.toJson(),
    'trackColorActive': trackColorActive.toJson(),
    'thumbSize': thumbSize.toJson(),
    'thumbColor': thumbColor.toJson(),
  };

  factory SliderStyleSpec.fromJson(Map<String, dynamic> json) {
    return SliderStyleSpec(
      trackHeight: Dimension.fromJson(
        json['trackHeight'] as Map<String, dynamic>,
      ),
      trackColorInactive: ColorToken.fromJson(
        json['trackColorInactive'] as Map<String, dynamic>,
      ),
      trackColorActive: ColorToken.fromJson(
        json['trackColorActive'] as Map<String, dynamic>,
      ),
      thumbSize: Dimension.fromJson(json['thumbSize'] as Map<String, dynamic>),
      thumbColor: ColorToken.fromJson(
        json['thumbColor'] as Map<String, dynamic>,
      ),
    );
  }
}

class SliderComponent extends DesignComponent {
  @override
  final String name = 'Slider';
  @override
  final List<ComponentVariation<SliderStyleSpec>> variations;

  SliderComponent({required this.variations});

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'variations': variations.map((v) => v.toJson()).toList(),
  };

  factory SliderComponent.fromJson(Map<String, dynamic> json) {
    final list = (json['variations'] as List)
        .map(
          (v) => ComponentVariation<SliderStyleSpec>(
            name: v['name'] as String,
            stateStyles: (v['stateStyles'] as Map<String, dynamic>).map(
              (k, val) => MapEntry(
                k,
                SliderStyleSpec.fromJson(val as Map<String, dynamic>),
              ),
            ),
          ),
        )
        .toList();
    return SliderComponent(variations: list);
  }
}

// 7. Toggle Style Spec
class ToggleStyleSpec implements ComponentStyleSpec {
  final Dimension width;
  final Dimension height;
  final ColorToken trackColorOff;
  final ColorToken trackColorOn;
  final ColorToken thumbColor;
  final Dimension thumbSize;

  const ToggleStyleSpec({
    required this.width,
    required this.height,
    required this.trackColorOff,
    required this.trackColorOn,
    required this.thumbColor,
    required this.thumbSize,
  });

  ToggleStyleSpec copyWith({
    Dimension? width,
    Dimension? height,
    ColorToken? trackColorOff,
    ColorToken? trackColorOn,
    ColorToken? thumbColor,
    Dimension? thumbSize,
  }) {
    return ToggleStyleSpec(
      width: width ?? this.width,
      height: height ?? this.height,
      trackColorOff: trackColorOff ?? this.trackColorOff,
      trackColorOn: trackColorOn ?? this.trackColorOn,
      thumbColor: thumbColor ?? this.thumbColor,
      thumbSize: thumbSize ?? this.thumbSize,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'width': width.toJson(),
    'height': height.toJson(),
    'trackColorOff': trackColorOff.toJson(),
    'trackColorOn': trackColorOn.toJson(),
    'thumbColor': thumbColor.toJson(),
    'thumbSize': thumbSize.toJson(),
  };

  factory ToggleStyleSpec.fromJson(Map<String, dynamic> json) {
    return ToggleStyleSpec(
      width: Dimension.fromJson(json['width'] as Map<String, dynamic>),
      height: Dimension.fromJson(json['height'] as Map<String, dynamic>),
      trackColorOff: ColorToken.fromJson(
        json['trackColorOff'] as Map<String, dynamic>,
      ),
      trackColorOn: ColorToken.fromJson(
        json['trackColorOn'] as Map<String, dynamic>,
      ),
      thumbColor: ColorToken.fromJson(
        json['thumbColor'] as Map<String, dynamic>,
      ),
      thumbSize: Dimension.fromJson(json['thumbSize'] as Map<String, dynamic>),
    );
  }
}

class ToggleComponent extends DesignComponent {
  @override
  final String name = 'Toggle';
  @override
  final List<ComponentVariation<ToggleStyleSpec>> variations;

  ToggleComponent({required this.variations});

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'variations': variations.map((v) => v.toJson()).toList(),
  };

  factory ToggleComponent.fromJson(Map<String, dynamic> json) {
    final list = (json['variations'] as List)
        .map(
          (v) => ComponentVariation<ToggleStyleSpec>(
            name: v['name'] as String,
            stateStyles: (v['stateStyles'] as Map<String, dynamic>).map(
              (k, val) => MapEntry(
                k,
                ToggleStyleSpec.fromJson(val as Map<String, dynamic>),
              ),
            ),
          ),
        )
        .toList();
    return ToggleComponent(variations: list);
  }
}

// Global factory helper to parse any DesignComponent from Json
DesignComponent parseDesignComponent(Map<String, dynamic> json) {
  final name = json['name'] as String;
  switch (name) {
    case 'Button':
      return ButtonComponent.fromJson(json);
    case 'Dropdown':
      return DropdownComponent.fromJson(json);
    case 'Text Input':
      return TextInputComponent.fromJson(json);
    case 'Textarea':
      return TextareaComponent.fromJson(json);
    case 'Checkbox':
      return CheckboxComponent.fromJson(json);
    case 'Radio':
      return RadioComponent.fromJson(json);
    case 'Slider':
      return SliderComponent.fromJson(json);
    case 'Toggle':
      return ToggleComponent.fromJson(json);
    default:
      throw Exception('Unknown component type: $name');
  }
}
