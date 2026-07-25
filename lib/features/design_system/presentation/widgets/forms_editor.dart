import 'package:flutter/material.dart';
import 'package:rikit/features/design_system/domain/color_token.dart';
import 'package:rikit/features/design_system/domain/component_models.dart';
import 'package:rikit/features/design_system/domain/dimension.dart';
import 'package:rikit/features/design_system/presentation/controllers/design_system_controller.dart';
import 'package:rikit/features/design_system/presentation/widgets/color_resolver.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class FormsEditor extends StatefulWidget {
  const FormsEditor({required this.controller, super.key});
  final DesignSystemController controller;

  @override
  State<FormsEditor> createState() => _FormsEditorState();
}

class _FormsEditorState extends State<FormsEditor> with SingleTickerProviderStateMixin {
  late TabController _subTabController;
  final List<String> _subTabs = ['Text Input', 'Textarea', 'Checkbox', 'Radio', 'Slider', 'Toggle'];

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: _subTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub tabs navigation
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: RikitColors.borderSubtle)),
          ),
          child: TabBar(
            controller: _subTabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: RikitColors.primary,
            labelColor: RikitColors.text,
            unselectedLabelColor: RikitColors.textMuted,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            tabs: _subTabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _TextInputEditor(controller: widget.controller, isTextarea: false),
              _TextInputEditor(controller: widget.controller, isTextarea: true),
              _CheckboxRadioEditor(controller: widget.controller, isRadio: false),
              _CheckboxRadioEditor(controller: widget.controller, isRadio: true),
              _SliderEditor(controller: widget.controller),
              _ToggleEditor(controller: widget.controller),
            ],
          ),
        ),
      ],
    );
  }
}

// TEXT INPUT & TEXTAREA EDITOR
class _TextInputEditor extends StatefulWidget {
  const _TextInputEditor({required this.controller, required this.isTextarea});
  final DesignSystemController controller;
  final bool isTextarea;

  @override
  State<_TextInputEditor> createState() => _TextInputEditorState();
}

class _TextInputEditorState extends State<_TextInputEditor> {
  int selectedVariationIndex = 0;
  String selectedStateKey = 'idle'; // 'idle', 'hovered', 'focused', 'disabled'
  bool isHovered = false;
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final compName = widget.isTextarea ? 'Textarea' : 'Text Input';
    final inputComp = state.components.firstWhere((c) => c.name == compName) as TextInputComponent;

    if (selectedVariationIndex >= inputComp.variations.length) {
      selectedVariationIndex = 0;
    }

    final variation = inputComp.variations[selectedVariationIndex];
    final activeStyle = variation.stateStyles[selectedStateKey] ?? variation.stateStyles['idle']!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left settings
        Expanded(
          flex: 6,
          child: Card(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.isTextarea ? 'Textarea' : 'Text Input'} Styling',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      _buildStateSelector(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildColorInputs(activeStyle),
                  const SizedBox(height: 16),
                  _buildDimensionInputs(activeStyle),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Right interactive preview
        Expanded(
          flex: 4,
          child: _buildPreviewPanel(variation),
        ),
      ],
    );
  }

  Widget _buildStateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: RikitColors.surfaceRaised,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: RikitColors.border),
      ),
      child: DropdownButton<String>(
        value: selectedStateKey,
        dropdownColor: RikitColors.surfaceRaised,
        underline: const SizedBox.shrink(),
        style: const TextStyle(color: RikitColors.text, fontSize: 12, fontWeight: FontWeight.bold),
        items: const [
          DropdownMenuItem(value: 'idle', child: Text('Idle')),
          DropdownMenuItem(value: 'hovered', child: Text('Hovered')),
          DropdownMenuItem(value: 'focused', child: Text('Focused')),
          DropdownMenuItem(value: 'disabled', child: Text('Disabled')),
        ],
        onChanged: (val) {
          if (val != null) {
            setState(() => selectedStateKey = val);
          }
        },
      ),
    );
  }

  Widget _buildColorInputs(TextInputStyleSpec activeStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Colors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: RikitColors.primary)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.backgroundColor.value,
                decoration: const InputDecoration(labelText: 'Background Color Token / Hex'),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#') ? ColorToken.static(val) : ColorToken.theme(val);
                  _updateStyle(activeStyle.copyWith(backgroundColor: token));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.foregroundColor.value,
                decoration: const InputDecoration(labelText: 'Text Color Token / Hex'),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#') ? ColorToken.static(val) : ColorToken.theme(val);
                  _updateStyle(activeStyle.copyWith(foregroundColor: token));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.borderColor.value,
                decoration: const InputDecoration(labelText: 'Border Color Token / Hex'),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#') ? ColorToken.static(val) : ColorToken.theme(val);
                  _updateStyle(activeStyle.copyWith(borderColor: token));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.placeholderColor.value,
                decoration: const InputDecoration(labelText: 'Placeholder Color Token / Hex'),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#') ? ColorToken.static(val) : ColorToken.theme(val);
                  _updateStyle(activeStyle.copyWith(placeholderColor: token));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDimensionInputs(TextInputStyleSpec activeStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dimensions & Layout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: RikitColors.primary)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.borderRadius.value.toString(),
                decoration: const InputDecoration(labelText: 'Border Radius'),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 6.0;
                  _updateStyle(activeStyle.copyWith(borderRadius: Dimension(d, activeStyle.borderRadius.unit)));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.borderWidth.value.toString(),
                decoration: const InputDecoration(labelText: 'Border Width'),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 1.0;
                  _updateStyle(activeStyle.copyWith(borderWidth: Dimension(d, activeStyle.borderWidth.unit)));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.fontSize.value.toString(),
                decoration: const InputDecoration(labelText: 'Font Size'),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 14.0;
                  _updateStyle(activeStyle.copyWith(fontSize: Dimension(d, activeStyle.fontSize.unit)));
                },
              ),
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  void _updateStyle(TextInputStyleSpec newStyle) {
    if (widget.isTextarea) {
      widget.controller.updateTextareaStyle(selectedVariationIndex, selectedStateKey, newStyle);
    } else {
      widget.controller.updateTextInputStyle(selectedVariationIndex, selectedStateKey, newStyle);
    }
  }

  Widget _buildPreviewPanel(ComponentVariation<TextInputStyleSpec> variation) {
    final globalState = widget.controller.state;
    final activeState = selectedStateKey == 'disabled'
        ? 'disabled'
        : isFocused
            ? 'focused'
            : isHovered
                ? 'hovered'
                : selectedStateKey;

    final resolved = variation.stateStyles[activeState] ?? variation.stateStyles['idle']!;

    final bgColor = resolveColorToken(resolved.backgroundColor, globalState);
    final borderColor = resolveColorToken(resolved.borderColor, globalState);
    final textColor = resolveColorToken(resolved.foregroundColor, globalState);
    final placeholderColor = resolveColorToken(resolved.placeholderColor, globalState);
    final borderRadius = resolved.borderRadius.value;
    final borderWidth = resolved.borderWidth.value;
    final fontSize = resolved.fontSize.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const Text('Interactive Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              'Click to focus and type in the ${widget.isTextarea ? 'textarea' : 'text input'}.',
              style: const TextStyle(color: RikitColors.textMuted, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            MouseRegion(
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: Focus(
                onFocusChange: (f) => setState(() => isFocused = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(color: borderColor, width: borderWidth),
                  ),
                  child: widget.isTextarea
                      ? SizedBox(
                          height: 100,
                          child: TextField(
                            enabled: selectedStateKey != 'disabled',
                            maxLines: 5,
                            style: TextStyle(color: textColor, fontSize: fontSize),
                            decoration: InputDecoration.collapsed(
                              hintText: 'Enter multi-line text...',
                              hintStyle: TextStyle(color: placeholderColor, fontSize: fontSize),
                            ),
                          ),
                        )
                      : TextField(
                          enabled: selectedStateKey != 'disabled',
                          style: TextStyle(color: textColor, fontSize: fontSize),
                          decoration: InputDecoration.collapsed(
                            hintText: 'Enter text here...',
                            hintStyle: TextStyle(color: placeholderColor, fontSize: fontSize),
                          ),
                        ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// CHECKBOX & RADIO EDITOR
class _CheckboxRadioEditor extends StatefulWidget {
  const _CheckboxRadioEditor({required this.controller, required this.isRadio});
  final DesignSystemController controller;
  final bool isRadio;

  @override
  State<_CheckboxRadioEditor> createState() => _CheckboxRadioEditorState();
}

class _CheckboxRadioEditorState extends State<_CheckboxRadioEditor> {
  int selectedVariationIndex = 0;
  String selectedStateKey = 'uncheckedIdle'; // 'uncheckedIdle', 'uncheckedHovered', 'checkedIdle', 'checkedHovered', 'disabled'
  bool isChecked = false;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final compName = widget.isRadio ? 'Radio' : 'Checkbox';
    final comp = state.components.firstWhere((c) => c.name == compName) as CheckboxComponent;

    if (selectedVariationIndex >= comp.variations.length) {
      selectedVariationIndex = 0;
    }

    final variation = comp.variations[selectedVariationIndex];
    final activeStyle = variation.stateStyles[selectedStateKey] ?? variation.stateStyles['uncheckedIdle']!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left inputs
        Expanded(
          flex: 6,
          child: Card(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.isRadio ? 'Radio' : 'Checkbox'} Styling',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      _buildStateSelector(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildColorInputs(activeStyle),
                  const SizedBox(height: 16),
                  _buildDimensionInputs(activeStyle),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Right preview
        Expanded(
          flex: 4,
          child: _buildPreviewPanel(variation),
        ),
      ],
    );
  }

  Widget _buildStateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: RikitColors.surfaceRaised,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: RikitColors.border),
      ),
      child: DropdownButton<String>(
        value: selectedStateKey,
        dropdownColor: RikitColors.surfaceRaised,
        underline: const SizedBox.shrink(),
        style: const TextStyle(color: RikitColors.text, fontSize: 12, fontWeight: FontWeight.bold),
        items: const [
          DropdownMenuItem(value: 'uncheckedIdle', child: Text('Unchecked Idle')),
          DropdownMenuItem(value: 'uncheckedHovered', child: Text('Unchecked Hovered')),
          DropdownMenuItem(value: 'checkedIdle', child: Text('Checked Idle')),
          DropdownMenuItem(value: 'checkedHovered', child: Text('Checked Hovered')),
          DropdownMenuItem(value: 'disabled', child: Text('Disabled')),
        ],
        onChanged: (val) {
          if (val != null) {
            setState(() => selectedStateKey = val);
          }
        },
      ),
    );
  }

  Widget _buildColorInputs(CheckboxStyleSpec activeStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Colors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: RikitColors.primary)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.backgroundColorUnchecked.value,
                decoration: const InputDecoration(labelText: 'Unchecked BG Color Token / Hex'),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#') ? ColorToken.static(val) : ColorToken.theme(val);
                  _updateStyle(activeStyle.copyWith(backgroundColorUnchecked: token));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.backgroundColorChecked.value,
                decoration: const InputDecoration(labelText: 'Checked BG Color Token / Hex'),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#') ? ColorToken.static(val) : ColorToken.theme(val);
                  _updateStyle(activeStyle.copyWith(backgroundColorChecked: token));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.borderColor.value,
                decoration: const InputDecoration(labelText: 'Border Color Token / Hex'),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#') ? ColorToken.static(val) : ColorToken.theme(val);
                  _updateStyle(activeStyle.copyWith(borderColor: token));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.indicatorColor.value,
                decoration: const InputDecoration(labelText: 'Checkmark/Dot Indicator Color'),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#') ? ColorToken.static(val) : ColorToken.theme(val);
                  _updateStyle(activeStyle.copyWith(indicatorColor: token));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDimensionInputs(CheckboxStyleSpec activeStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dimensions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: RikitColors.primary)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.size.value.toString(),
                decoration: const InputDecoration(labelText: 'Size (Width & Height)'),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 16.0;
                  _updateStyle(activeStyle.copyWith(size: Dimension(d, activeStyle.size.unit)));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.borderRadius.value.toString(),
                decoration: const InputDecoration(labelText: 'Border Radius'),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 4.0;
                  _updateStyle(activeStyle.copyWith(borderRadius: Dimension(d, activeStyle.borderRadius.unit)));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateStyle(CheckboxStyleSpec newStyle) {
    if (widget.isRadio) {
      widget.controller.updateRadioStyle(selectedVariationIndex, selectedStateKey, newStyle);
    } else {
      widget.controller.updateCheckboxStyle(selectedVariationIndex, selectedStateKey, newStyle);
    }
  }

  Widget _buildPreviewPanel(ComponentVariation<CheckboxStyleSpec> variation) {
    final globalState = widget.controller.state;

    // Resolve visual state based on interactive simulation
    final activeState = selectedStateKey == 'disabled'
        ? 'disabled'
        : isChecked
            ? (isHovered ? 'checkedHovered' : 'checkedIdle')
            : (isHovered ? 'uncheckedHovered' : 'uncheckedIdle');

    final resolved = variation.stateStyles[activeState] ?? variation.stateStyles['uncheckedIdle']!;

    final bgColor = resolveColorToken(
      isChecked ? resolved.backgroundColorChecked : resolved.backgroundColorUnchecked,
      globalState,
    );
    final borderColor = resolveColorToken(resolved.borderColor, globalState);
    final indicatorColor = resolveColorToken(resolved.indicatorColor, globalState);
    final double boxSize = resolved.size.value;
    final double radius = resolved.borderRadius.value;
    final double borderWidth = resolved.borderWidth.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const Text('Interactive Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            const Text(
              'Click the element to toggle its state.',
              style: TextStyle(color: RikitColors.textMuted, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            GestureDetector(
              onTap: selectedStateKey == 'disabled'
                  ? null
                  : () => setState(() => isChecked = !isChecked),
              child: MouseRegion(
                onEnter: (_) => setState(() => isHovered = true),
                onExit: (_) => setState(() => isHovered = false),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: boxSize,
                      height: boxSize,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(color: borderColor, width: borderWidth),
                      ),
                      alignment: Alignment.center,
                      child: isChecked
                          ? (widget.isRadio
                              ? Container(
                                  width: boxSize / 2,
                                  height: boxSize / 2,
                                  decoration: BoxDecoration(color: indicatorColor, shape: BoxShape.circle),
                                )
                              : Icon(Icons.check_rounded, size: boxSize - 2, color: indicatorColor))
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Label Option', style: TextStyle(color: RikitColors.text, fontSize: 14)),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// SLIDER EDITOR
class _SliderEditor extends StatefulWidget {
  const _SliderEditor({required this.controller});
  final DesignSystemController controller;

  @override
  State<_SliderEditor> createState() => _SliderEditorState();
}

class _SliderEditorState extends State<_SliderEditor> {
  int selectedVariationIndex = 0;
  String selectedStateKey = 'idle'; // 'idle', 'hovered', 'dragging', 'disabled'
  double sliderValue = 0.5;
  bool isDragging = false;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final comp = state.components.firstWhere((c) => c.name == 'Slider') as SliderComponent;

    if (selectedVariationIndex >= comp.variations.length) {
      selectedVariationIndex = 0;
    }

    final variation = comp.variations[selectedVariationIndex];
    final activeStyle = variation.stateStyles[selectedStateKey] ?? variation.stateStyles['idle']!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left inputs
        Expanded(
          flex: 6,
          child: Card(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Slider Track & Thumb Styling', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      _buildStateSelector(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildColorInputs(activeStyle),
                  const SizedBox(height: 16),
                  _buildDimensionInputs(activeStyle),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Right preview
        Expanded(
          flex: 4,
          child: _buildPreviewPanel(variation),
        ),
      ],
    );
  }

  Widget _buildStateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: RikitColors.surfaceRaised,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: RikitColors.border),
      ),
      child: DropdownButton<String>(
        value: selectedStateKey,
        dropdownColor: RikitColors.surfaceRaised,
        underline: const SizedBox.shrink(),
        style: const TextStyle(color: RikitColors.text, fontSize: 12, fontWeight: FontWeight.bold),
        items: const [
          DropdownMenuItem(value: 'idle', child: Text('Idle')),
          DropdownMenuItem(value: 'hovered', child: Text('Hovered')),
          DropdownMenuItem(value: 'dragging', child: Text('Dragging')),
          DropdownMenuItem(value: 'disabled', child: Text('Disabled')),
        ],
        onChanged: (val) {
          if (val != null) {
            setState(() => selectedStateKey = val);
          }
        },
      ),
    );
  }

  Widget _buildColorInputs(SliderStyleSpec activeStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Colors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: RikitColors.primary)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.thumbColor.value,
                decoration: const InputDecoration(labelText: 'Thumb Color Token / Hex'),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#') ? ColorToken.static(val) : ColorToken.theme(val);
                  _updateStyle(activeStyle.copyWith(thumbColor: token));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.trackColorActive.value,
                decoration: const InputDecoration(labelText: 'Active Track Color Token / Hex'),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#') ? ColorToken.static(val) : ColorToken.theme(val);
                  _updateStyle(activeStyle.copyWith(trackColorActive: token));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.trackColorInactive.value,
                decoration: const InputDecoration(labelText: 'Inactive Track Color Token / Hex'),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#') ? ColorToken.static(val) : ColorToken.theme(val);
                  _updateStyle(activeStyle.copyWith(trackColorInactive: token));
                },
              ),
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _buildDimensionInputs(SliderStyleSpec activeStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dimensions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: RikitColors.primary)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.thumbSize.value.toString(),
                decoration: const InputDecoration(labelText: 'Thumb Diameter'),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 16.0;
                  _updateStyle(activeStyle.copyWith(thumbSize: Dimension(d, activeStyle.thumbSize.unit)));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.trackHeight.value.toString(),
                decoration: const InputDecoration(labelText: 'Track Height'),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 4.0;
                  _updateStyle(activeStyle.copyWith(trackHeight: Dimension(d, activeStyle.trackHeight.unit)));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateStyle(SliderStyleSpec newStyle) {
    widget.controller.updateSliderStyle(selectedVariationIndex, selectedStateKey, newStyle);
  }

  Widget _buildPreviewPanel(ComponentVariation<SliderStyleSpec> variation) {
    final globalState = widget.controller.state;

    final activeState = selectedStateKey == 'disabled'
        ? 'disabled'
        : isDragging
            ? 'dragging'
            : isHovered
                ? 'hovered'
                : selectedStateKey;

    final resolved = variation.stateStyles[activeState] ?? variation.stateStyles['idle']!;

    final thumbColor = resolveColorToken(resolved.thumbColor, globalState);
    final activeTrackColor = resolveColorToken(resolved.trackColorActive, globalState);
    final inactiveTrackColor = resolveColorToken(resolved.trackColorInactive, globalState);
    final double thumbSize = resolved.thumbSize.value;
    final double trackHeight = resolved.trackHeight.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const Text('Interactive Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            const Text(
              'Drag the slider thumb to modify the value.',
              style: TextStyle(color: RikitColors.textMuted, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            MouseRegion(
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onPanStart: selectedStateKey == 'disabled'
                            ? null
                            : (_) => setState(() => isDragging = true),
                        onPanEnd: (_) => setState(() => isDragging = false),
                        onPanUpdate: selectedStateKey == 'disabled'
                            ? null
                            : (details) {
                                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                                final localX = renderBox.globalToLocal(details.globalPosition).dx;
                                final width = renderBox.size.width - 64;
                                final newValue = (localX / width).clamp(0.0, 1.0);
                                setState(() => sliderValue = newValue);
                              },
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            // Inactive track
                            Container(
                              height: trackHeight,
                              decoration: BoxDecoration(
                                color: inactiveTrackColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            // Active track
                            FractionallySizedBox(
                              widthFactor: sliderValue,
                              child: Container(
                                height: trackHeight,
                                decoration: BoxDecoration(
                                  color: activeTrackColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            // Thumb
                            Positioned(
                              left: sliderValue * 150, // simple scale mapping for UI preview
                              child: Container(
                                width: thumbSize,
                                height: thumbSize,
                                decoration: BoxDecoration(
                                  color: thumbColor,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '${(sliderValue * 100).round()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// TOGGLE EDITOR
class _ToggleEditor extends StatefulWidget {
  const _ToggleEditor({required this.controller});
  final DesignSystemController controller;

  @override
  State<_ToggleEditor> createState() => _ToggleEditorState();
}

class _ToggleEditorState extends State<_ToggleEditor> {
  int selectedVariationIndex = 0;
  String selectedStateKey = 'offIdle'; // 'offIdle', 'offHovered', 'onIdle', 'onHovered', 'disabled'
  bool isToggleOn = false;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final comp = state.components.firstWhere((c) => c.name == 'Toggle') as ToggleComponent;

    if (selectedVariationIndex >= comp.variations.length) {
      selectedVariationIndex = 0;
    }

    final variation = comp.variations[selectedVariationIndex];
    final activeStyle = variation.stateStyles[selectedStateKey] ?? variation.stateStyles['offIdle']!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left inputs
        Expanded(
          flex: 6,
          child: Card(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Toggle Switch Styling', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      _buildStateSelector(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildColorInputs(activeStyle),
                  const SizedBox(height: 16),
                  _buildDimensionInputs(activeStyle),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Right preview
        Expanded(
          flex: 4,
          child: _buildPreviewPanel(variation),
        ),
      ],
    );
  }

  Widget _buildStateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: RikitColors.surfaceRaised,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: RikitColors.border),
      ),
      child: DropdownButton<String>(
        value: selectedStateKey,
        dropdownColor: RikitColors.surfaceRaised,
        underline: const SizedBox.shrink(),
        style: const TextStyle(color: RikitColors.text, fontSize: 12, fontWeight: FontWeight.bold),
        items: const [
          DropdownMenuItem(value: 'offIdle', child: Text('Off Idle')),
          DropdownMenuItem(value: 'offHovered', child: Text('Off Hovered')),
          DropdownMenuItem(value: 'onIdle', child: Text('On Idle')),
          DropdownMenuItem(value: 'onHovered', child: Text('On Hovered')),
          DropdownMenuItem(value: 'disabled', child: Text('Disabled')),
        ],
        onChanged: (val) {
          if (val != null) {
            setState(() => selectedStateKey = val);
          }
        },
      ),
    );
  }

  Widget _buildColorInputs(ToggleStyleSpec activeStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Colors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: RikitColors.primary)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.thumbColor.value,
                decoration: const InputDecoration(labelText: 'Thumb Circle Color'),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#') ? ColorToken.static(val) : ColorToken.theme(val);
                  _updateStyle(activeStyle.copyWith(thumbColor: token));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.trackColorOn.value,
                decoration: const InputDecoration(labelText: 'Track Color (On)'),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#') ? ColorToken.static(val) : ColorToken.theme(val);
                  _updateStyle(activeStyle.copyWith(trackColorOn: token));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.trackColorOff.value,
                decoration: const InputDecoration(labelText: 'Track Color (Off)'),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#') ? ColorToken.static(val) : ColorToken.theme(val);
                  _updateStyle(activeStyle.copyWith(trackColorOff: token));
                },
              ),
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _buildDimensionInputs(ToggleStyleSpec activeStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dimensions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: RikitColors.primary)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.width.value.toString(),
                decoration: const InputDecoration(labelText: 'Width'),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 44.0;
                  _updateStyle(activeStyle.copyWith(width: Dimension(d, activeStyle.width.unit)));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.height.value.toString(),
                decoration: const InputDecoration(labelText: 'Height'),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 24.0;
                  _updateStyle(activeStyle.copyWith(height: Dimension(d, activeStyle.height.unit)));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.thumbSize.value.toString(),
                decoration: const InputDecoration(labelText: 'Thumb Size'),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 16.0;
                  _updateStyle(activeStyle.copyWith(thumbSize: Dimension(d, activeStyle.thumbSize.unit)));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateStyle(ToggleStyleSpec newStyle) {
    widget.controller.updateToggleStyle(selectedVariationIndex, selectedStateKey, newStyle);
  }

  Widget _buildPreviewPanel(ComponentVariation<ToggleStyleSpec> variation) {
    final globalState = widget.controller.state;

    final activeState = selectedStateKey == 'disabled'
        ? 'disabled'
        : isToggleOn
            ? (isHovered ? 'onHovered' : 'onIdle')
            : (isHovered ? 'offHovered' : 'offIdle');

    final resolved = variation.stateStyles[activeState] ?? variation.stateStyles['offIdle']!;

    final thumbColor = resolveColorToken(resolved.thumbColor, globalState);
    final trackColor = resolveColorToken(
      isToggleOn ? resolved.trackColorOn : resolved.trackColorOff,
      globalState,
    );
    final double width = resolved.width.value;
    final double height = resolved.height.value;
    final double thumbDiameter = resolved.thumbSize.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const Text('Interactive Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            const Text(
              'Click the switch to toggle it on/off.',
              style: TextStyle(color: RikitColors.textMuted, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            GestureDetector(
              onTap: selectedStateKey == 'disabled'
                  ? null
                  : () => setState(() => isToggleOn = !isToggleOn),
              child: MouseRegion(
                onEnter: (_) => setState(() => isHovered = true),
                onExit: (_) => setState(() => isHovered = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: width,
                  height: height,
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                  alignment: isToggleOn ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: thumbDiameter,
                    height: thumbDiameter,
                    decoration: BoxDecoration(
                      color: thumbColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
