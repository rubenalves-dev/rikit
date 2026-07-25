import 'package:flutter/material.dart';
import 'package:rikit/features/design_system/domain/color_row.dart';
import 'package:rikit/features/design_system/domain/component_models.dart';
import 'package:rikit/features/design_system/domain/design_system_state.dart';
import 'package:rikit/features/design_system/domain/dimension.dart';
import 'package:rikit/features/design_system/domain/global_tokens.dart';
import 'package:rikit/features/design_system/domain/typography_settings.dart';

class DesignSystemController extends ChangeNotifier {
  DesignSystemState _state;

  DesignSystemController({DesignSystemState? initialState})
    : _state = initialState ?? DesignSystemPresets.minimalist();

  DesignSystemState get state => _state;

  void applyPreset(DesignSystemState presetState) {
    _state = presetState;
    notifyListeners();
  }

  // --- Color Row Operations ---

  void updateColorRowBase(int index, Color newBase) {
    if (index < 0 || index >= _state.colorRows.length) return;
    final updated = List<ColorRow>.from(_state.colorRows);
    updated[index] = updated[index].copyWith(baseColor: newBase);
    _state = _state.copyWith(colorRows: updated);
    notifyListeners();
  }

  void addColorRow(String name, Color baseColor) {
    // Avoid duplicate names
    if (_state.colorRows.any(
      (row) => row.name.toLowerCase() == name.toLowerCase(),
    )) {
      return;
    }
    final updated = List<ColorRow>.from(_state.colorRows);
    updated.add(
      ColorRow.create(name: name, baseColor: baseColor, isRemovable: true),
    );
    _state = _state.copyWith(colorRows: updated);
    notifyListeners();
  }

  void removeColorRow(int index) {
    if (index < 0 || index >= _state.colorRows.length) {
      return;
    }
    if (!_state.colorRows[index].isRemovable) {
      return; // Core colors are protected
    }
    final updated = List<ColorRow>.from(_state.colorRows);
    updated.removeAt(index);
    _state = _state.copyWith(colorRows: updated);
    notifyListeners();
  }

  void renameColorRow(int index, String newName) {
    if (index < 0 || index >= _state.colorRows.length) {
      return;
    }
    if (!_state.colorRows[index].isRemovable) {
      return; // Core colors are protected
    }
    final updated = List<ColorRow>.from(_state.colorRows);
    updated[index] = updated[index].copyWith(name: newName);
    _state = _state.copyWith(colorRows: updated);
    notifyListeners();
  }

  // --- Global Token Scale Operations ---

  void addBorderRadiusToken(String key, Dimension value) {
    if (_state.globalTokens.borderRadiusScale.any((e) => e.key == key)) return;
    final updatedList = List<ScaleToken<Dimension>>.from(
      _state.globalTokens.borderRadiusScale,
    )..add(ScaleToken(key, value));
    _state = _state.copyWith(
      globalTokens: _state.globalTokens.copyWith(
        borderRadiusScale: updatedList,
      ),
    );
    notifyListeners();
  }

  void removeBorderRadiusToken(String key) {
    final updatedList = List<ScaleToken<Dimension>>.from(
      _state.globalTokens.borderRadiusScale,
    )..removeWhere((e) => e.key == key);
    _state = _state.copyWith(
      globalTokens: _state.globalTokens.copyWith(
        borderRadiusScale: updatedList,
      ),
    );
    notifyListeners();
  }

  void updateBorderRadiusToken(String key, Dimension value) {
    final updatedList = _state.globalTokens.borderRadiusScale.map((e) {
      if (e.key == key) return ScaleToken(key, value);
      return e;
    }).toList();
    _state = _state.copyWith(
      globalTokens: _state.globalTokens.copyWith(
        borderRadiusScale: updatedList,
      ),
    );
    notifyListeners();
  }

  void addSpacingToken(String key, Dimension value) {
    if (_state.globalTokens.spacingScale.any((e) => e.key == key)) return;
    final updatedList = List<ScaleToken<Dimension>>.from(
      _state.globalTokens.spacingScale,
    )..add(ScaleToken(key, value));
    _state = _state.copyWith(
      globalTokens: _state.globalTokens.copyWith(spacingScale: updatedList),
    );
    notifyListeners();
  }

  void removeSpacingToken(String key) {
    final updatedList = List<ScaleToken<Dimension>>.from(
      _state.globalTokens.spacingScale,
    )..removeWhere((e) => e.key == key);
    _state = _state.copyWith(
      globalTokens: _state.globalTokens.copyWith(spacingScale: updatedList),
    );
    notifyListeners();
  }

  void updateSpacingToken(String key, Dimension value) {
    final updatedList = _state.globalTokens.spacingScale.map((e) {
      if (e.key == key) return ScaleToken(key, value);
      return e;
    }).toList();
    _state = _state.copyWith(
      globalTokens: _state.globalTokens.copyWith(spacingScale: updatedList),
    );
    notifyListeners();
  }

  void addShadowToken(String key, ShadowValue value) {
    if (_state.globalTokens.shadowsScale.any((e) => e.key == key)) return;
    final updatedList = List<ScaleToken<ShadowValue>>.from(
      _state.globalTokens.shadowsScale,
    )..add(ScaleToken(key, value));
    _state = _state.copyWith(
      globalTokens: _state.globalTokens.copyWith(shadowsScale: updatedList),
    );
    notifyListeners();
  }

  void removeShadowToken(String key) {
    final updatedList = List<ScaleToken<ShadowValue>>.from(
      _state.globalTokens.shadowsScale,
    )..removeWhere((e) => e.key == key);
    _state = _state.copyWith(
      globalTokens: _state.globalTokens.copyWith(shadowsScale: updatedList),
    );
    notifyListeners();
  }

  void updateShadowToken(String key, ShadowValue value) {
    final updatedList = _state.globalTokens.shadowsScale.map((e) {
      if (e.key == key) return ScaleToken(key, value);
      return e;
    }).toList();
    _state = _state.copyWith(
      globalTokens: _state.globalTokens.copyWith(shadowsScale: updatedList),
    );
    notifyListeners();
  }

  // --- Typography Operations ---

  void toggleGroupHeadings(bool value) {
    _state = _state.copyWith(
      typography: _state.typography.copyWith(groupHeadings: value),
    );
    notifyListeners();
  }

  void toggleGroupBodies(bool value) {
    _state = _state.copyWith(
      typography: _state.typography.copyWith(groupBodies: value),
    );
    notifyListeners();
  }

  void toggleGroupInfos(bool value) {
    _state = _state.copyWith(
      typography: _state.typography.copyWith(groupInfos: value),
    );
    notifyListeners();
  }

  void updateTypographyStyle(
    String styleKey, {
    String? fontFamily,
    Dimension? fontSize,
    Dimension? letterSpacing,
  }) {
    var ty = _state.typography;

    TextStyleSpec updateSpec(TextStyleSpec spec) => spec.copyWith(
      fontFamily: fontFamily,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
    );

    // Propagate changes if grouping is enabled
    final isHeading = styleKey == 'h1' || styleKey == 'h2' || styleKey == 'h3';
    final isBody = styleKey == 'bodyNormal' || styleKey == 'bodySmall';
    final isInfo = styleKey == 'infoNormal' || styleKey == 'infoSmall';

    if (isHeading && ty.groupHeadings) {
      ty = ty.copyWith(
        h1: updateSpec(ty.h1),
        h2: updateSpec(ty.h2),
        h3: updateSpec(ty.h3),
      );
    } else if (isBody && ty.groupBodies) {
      ty = ty.copyWith(
        bodyNormal: updateSpec(ty.bodyNormal),
        bodySmall: updateSpec(ty.bodySmall),
      );
    } else if (isInfo && ty.groupInfos) {
      ty = ty.copyWith(
        infoNormal: updateSpec(ty.infoNormal),
        infoSmall: updateSpec(ty.infoSmall),
      );
    } else {
      // Individual edit
      switch (styleKey) {
        case 'h1':
          ty = ty.copyWith(h1: updateSpec(ty.h1));
          break;
        case 'h2':
          ty = ty.copyWith(h2: updateSpec(ty.h2));
          break;
        case 'h3':
          ty = ty.copyWith(h3: updateSpec(ty.h3));
          break;
        case 'bodyNormal':
          ty = ty.copyWith(bodyNormal: updateSpec(ty.bodyNormal));
          break;
        case 'bodySmall':
          ty = ty.copyWith(bodySmall: updateSpec(ty.bodySmall));
          break;
        case 'infoNormal':
          ty = ty.copyWith(infoNormal: updateSpec(ty.infoNormal));
          break;
        case 'infoSmall':
          ty = ty.copyWith(infoSmall: updateSpec(ty.infoSmall));
          break;
      }
    }

    _state = _state.copyWith(typography: ty);
    notifyListeners();
  }

  // --- Polymorphic Component and Variation Operations ---

  void addComponentVariation(String componentName, String variationName) {
    final compIndex = _state.components.indexWhere(
      (c) => c.name == componentName,
    );
    if (compIndex == -1) {
      return;
    }

    final updatedComps = List<DesignComponent>.from(_state.components);
    final comp = updatedComps[compIndex];

    if (comp is ButtonComponent) {
      final defaultVar = comp.variations.firstWhere(
        (v) => v.name == 'Default',
        orElse: () => comp.variations.first,
      );
      final newVar = ComponentVariation<ButtonStyleSpec>(
        name: variationName,
        stateStyles: Map<String, ButtonStyleSpec>.from(defaultVar.stateStyles),
      );
      updatedComps[compIndex] = ButtonComponent(
        variations: List.from(comp.variations)..add(newVar),
      );
    } else if (comp is DropdownComponent) {
      final defaultVar = comp.variations.firstWhere(
        (v) => v.name == 'Default',
        orElse: () => comp.variations.first,
      );
      final newVar = ComponentVariation<DropdownStyleSpec>(
        name: variationName,
        stateStyles: Map<String, DropdownStyleSpec>.from(
          defaultVar.stateStyles,
        ),
      );
      updatedComps[compIndex] = DropdownComponent(
        variations: List.from(comp.variations)..add(newVar),
      );
    } else if (comp is TextInputComponent) {
      final defaultVar = comp.variations.firstWhere(
        (v) => v.name == 'Default',
        orElse: () => comp.variations.first,
      );
      final newVar = ComponentVariation<TextInputStyleSpec>(
        name: variationName,
        stateStyles: Map<String, TextInputStyleSpec>.from(
          defaultVar.stateStyles,
        ),
      );
      updatedComps[compIndex] = TextInputComponent(
        variations: List.from(comp.variations)..add(newVar),
      );
    } else if (comp is TextareaComponent) {
      final defaultVar = comp.variations.firstWhere(
        (v) => v.name == 'Default',
        orElse: () => comp.variations.first,
      );
      final newVar = ComponentVariation<TextInputStyleSpec>(
        name: variationName,
        stateStyles: Map<String, TextInputStyleSpec>.from(
          defaultVar.stateStyles,
        ),
      );
      updatedComps[compIndex] = TextareaComponent(
        variations: List.from(comp.variations)..add(newVar),
      );
    } else if (comp is CheckboxComponent) {
      final defaultVar = comp.variations.firstWhere(
        (v) => v.name == 'Default',
        orElse: () => comp.variations.first,
      );
      final newVar = ComponentVariation<CheckboxStyleSpec>(
        name: variationName,
        stateStyles: Map<String, CheckboxStyleSpec>.from(
          defaultVar.stateStyles,
        ),
      );
      updatedComps[compIndex] = CheckboxComponent(
        variations: List.from(comp.variations)..add(newVar),
      );
    } else if (comp is RadioComponent) {
      final defaultVar = comp.variations.firstWhere(
        (v) => v.name == 'Default',
        orElse: () => comp.variations.first,
      );
      final newVar = ComponentVariation<CheckboxStyleSpec>(
        name: variationName,
        stateStyles: Map<String, CheckboxStyleSpec>.from(
          defaultVar.stateStyles,
        ),
      );
      updatedComps[compIndex] = RadioComponent(
        variations: List.from(comp.variations)..add(newVar),
      );
    } else if (comp is SliderComponent) {
      final defaultVar = comp.variations.firstWhere(
        (v) => v.name == 'Default',
        orElse: () => comp.variations.first,
      );
      final newVar = ComponentVariation<SliderStyleSpec>(
        name: variationName,
        stateStyles: Map<String, SliderStyleSpec>.from(defaultVar.stateStyles),
      );
      updatedComps[compIndex] = SliderComponent(
        variations: List.from(comp.variations)..add(newVar),
      );
    } else if (comp is ToggleComponent) {
      final defaultVar = comp.variations.firstWhere(
        (v) => v.name == 'Default',
        orElse: () => comp.variations.first,
      );
      final newVar = ComponentVariation<ToggleStyleSpec>(
        name: variationName,
        stateStyles: Map<String, ToggleStyleSpec>.from(defaultVar.stateStyles),
      );
      updatedComps[compIndex] = ToggleComponent(
        variations: List.from(comp.variations)..add(newVar),
      );
    }

    _state = _state.copyWith(components: updatedComps);
    notifyListeners();
  }

  void removeComponentVariation(String componentName, int variationIndex) {
    final compIndex = _state.components.indexWhere(
      (c) => c.name == componentName,
    );
    if (compIndex == -1) {
      return;
    }

    final updatedComps = List<DesignComponent>.from(_state.components);
    final comp = updatedComps[compIndex];

    if (variationIndex <= 0 || variationIndex >= comp.variations.length) {
      return; // Cannot delete 'Default' / out of bounds
    }

    if (comp is ButtonComponent) {
      updatedComps[compIndex] = ButtonComponent(
        variations: List.from(comp.variations)..removeAt(variationIndex),
      );
    } else if (comp is DropdownComponent) {
      updatedComps[compIndex] = DropdownComponent(
        variations: List.from(comp.variations)..removeAt(variationIndex),
      );
    } else if (comp is TextInputComponent) {
      updatedComps[compIndex] = TextInputComponent(
        variations: List.from(comp.variations)..removeAt(variationIndex),
      );
    } else if (comp is TextareaComponent) {
      updatedComps[compIndex] = TextareaComponent(
        variations: List.from(comp.variations)..removeAt(variationIndex),
      );
    } else if (comp is CheckboxComponent) {
      updatedComps[compIndex] = CheckboxComponent(
        variations: List.from(comp.variations)..removeAt(variationIndex),
      );
    } else if (comp is RadioComponent) {
      updatedComps[compIndex] = RadioComponent(
        variations: List.from(comp.variations)..removeAt(variationIndex),
      );
    } else if (comp is SliderComponent) {
      updatedComps[compIndex] = SliderComponent(
        variations: List.from(comp.variations)..removeAt(variationIndex),
      );
    } else if (comp is ToggleComponent) {
      updatedComps[compIndex] = ToggleComponent(
        variations: List.from(comp.variations)..removeAt(variationIndex),
      );
    }

    _state = _state.copyWith(components: updatedComps);
    notifyListeners();
  }

  // --- Specific Style Specification Updaters ---

  void _updateComponentStyle<T extends ComponentStyleSpec>(
    String componentName,
    int variationIndex,
    String stateKey,
    T Function(T old) updater,
  ) {
    final compIndex = _state.components.indexWhere(
      (c) => c.name == componentName,
    );
    if (compIndex == -1) return;

    final updatedComps = List<DesignComponent>.from(_state.components);
    final comp = updatedComps[compIndex];

    if (variationIndex < 0 || variationIndex >= comp.variations.length) return;
    final variation = comp.variations[variationIndex] as ComponentVariation<T>;

    final oldStyle = variation.stateStyles[stateKey];
    if (oldStyle == null) return;

    final newStyle = updater(oldStyle);
    final updatedStyles = Map<String, T>.from(variation.stateStyles)
      ..[stateKey] = newStyle;

    final updatedVariation = variation.copyWith(stateStyles: updatedStyles);
    final updatedVars = List<ComponentVariation<T>>.from(
      comp.variations as Iterable<ComponentVariation<T>>,
    )..[variationIndex] = updatedVariation;

    if (comp is ButtonComponent) {
      updatedComps[compIndex] = ButtonComponent(
        variations: updatedVars as List<ComponentVariation<ButtonStyleSpec>>,
      );
    } else if (comp is DropdownComponent) {
      updatedComps[compIndex] = DropdownComponent(
        variations: updatedVars as List<ComponentVariation<DropdownStyleSpec>>,
      );
    } else if (comp is TextInputComponent) {
      updatedComps[compIndex] = TextInputComponent(
        variations: updatedVars as List<ComponentVariation<TextInputStyleSpec>>,
      );
    } else if (comp is TextareaComponent) {
      updatedComps[compIndex] = TextareaComponent(
        variations: updatedVars as List<ComponentVariation<TextInputStyleSpec>>,
      );
    } else if (comp is CheckboxComponent) {
      updatedComps[compIndex] = CheckboxComponent(
        variations: updatedVars as List<ComponentVariation<CheckboxStyleSpec>>,
      );
    } else if (comp is RadioComponent) {
      updatedComps[compIndex] = RadioComponent(
        variations: updatedVars as List<ComponentVariation<CheckboxStyleSpec>>,
      );
    } else if (comp is SliderComponent) {
      updatedComps[compIndex] = SliderComponent(
        variations: updatedVars as List<ComponentVariation<SliderStyleSpec>>,
      );
    } else if (comp is ToggleComponent) {
      updatedComps[compIndex] = ToggleComponent(
        variations: updatedVars as List<ComponentVariation<ToggleStyleSpec>>,
      );
    }

    _state = _state.copyWith(components: updatedComps);
    notifyListeners();
  }

  void updateButtonStyle(
    int variationIndex,
    String stateKey,
    ButtonStyleSpec newSpec,
  ) {
    _updateComponentStyle<ButtonStyleSpec>(
      'Button',
      variationIndex,
      stateKey,
      (_) => newSpec,
    );
  }

  void updateDropdownStyle(
    int variationIndex,
    String stateKey,
    DropdownStyleSpec newSpec,
  ) {
    _updateComponentStyle<DropdownStyleSpec>(
      'Dropdown',
      variationIndex,
      stateKey,
      (_) => newSpec,
    );
  }

  void updateTextInputStyle(
    int variationIndex,
    String stateKey,
    TextInputStyleSpec newSpec,
  ) {
    _updateComponentStyle<TextInputStyleSpec>(
      'Text Input',
      variationIndex,
      stateKey,
      (_) => newSpec,
    );
  }

  void updateTextareaStyle(
    int variationIndex,
    String stateKey,
    TextInputStyleSpec newSpec,
  ) {
    _updateComponentStyle<TextInputStyleSpec>(
      'Textarea',
      variationIndex,
      stateKey,
      (_) => newSpec,
    );
  }

  void updateCheckboxStyle(
    int variationIndex,
    String stateKey,
    CheckboxStyleSpec newSpec,
  ) {
    _updateComponentStyle<CheckboxStyleSpec>(
      'Checkbox',
      variationIndex,
      stateKey,
      (_) => newSpec,
    );
  }

  void updateRadioStyle(
    int variationIndex,
    String stateKey,
    CheckboxStyleSpec newSpec,
  ) {
    _updateComponentStyle<CheckboxStyleSpec>(
      'Radio',
      variationIndex,
      stateKey,
      (_) => newSpec,
    );
  }

  void updateSliderStyle(
    int variationIndex,
    String stateKey,
    SliderStyleSpec newSpec,
  ) {
    _updateComponentStyle<SliderStyleSpec>(
      'Slider',
      variationIndex,
      stateKey,
      (_) => newSpec,
    );
  }

  void updateToggleStyle(
    int variationIndex,
    String stateKey,
    ToggleStyleSpec newSpec,
  ) {
    _updateComponentStyle<ToggleStyleSpec>(
      'Toggle',
      variationIndex,
      stateKey,
      (_) => newSpec,
    );
  }
}
