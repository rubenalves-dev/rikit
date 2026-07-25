import 'package:flutter/material.dart';
import 'package:rikit/features/design_system/domain/color_token.dart';
import 'package:rikit/features/design_system/domain/component_models.dart';
import 'package:rikit/features/design_system/domain/dimension.dart';
import 'package:rikit/features/design_system/presentation/controllers/design_system_controller.dart';
import 'package:rikit/features/design_system/presentation/widgets/color_resolver.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class ButtonEditor extends StatefulWidget {
  const ButtonEditor({required this.controller, super.key});
  final DesignSystemController controller;

  @override
  State<ButtonEditor> createState() => _ButtonEditorState();
}

class _ButtonEditorState extends State<ButtonEditor> {
  int selectedVariationIndex = 0;
  String selectedStateKey = 'idle'; // 'idle', 'hovered', 'pressed', 'disabled'
  bool isHoveringPreview = false;
  bool isPressingPreview = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final buttonComp =
        state.components.firstWhere((c) => c.name == 'Button')
            as ButtonComponent;

    // Safety check for indices
    if (selectedVariationIndex >= buttonComp.variations.length) {
      selectedVariationIndex = 0;
    }

    final variation = buttonComp.variations[selectedVariationIndex];
    final activeStyle =
        variation.stateStyles[selectedStateKey] ??
        variation.stateStyles['idle']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Variation management header
        _buildVariationHeader(buttonComp),
        const SizedBox(height: 18),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Editor inputs
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
                            const Text(
                              'Styling Specifications',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            _buildStateSelector(),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildColorInputs(activeStyle),
                        const SizedBox(height: 18),
                        _buildDimensionInputs(activeStyle),
                        const SizedBox(height: 18),
                        _buildTypographyInputs(activeStyle),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Right: Live Interactive Preview
              Expanded(flex: 4, child: _buildPreviewPanel(variation)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVariationHeader(ButtonComponent comp) {
    final variation = comp.variations[selectedVariationIndex];
    final isDefault = variation.name == 'Default';
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Text(
              'Variation:',
              style: TextStyle(
                color: RikitColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            DropdownButton<int>(
              value: selectedVariationIndex,
              dropdownColor: RikitColors.surfaceRaised,
              underline: const SizedBox.shrink(),
              items: List.generate(comp.variations.length, (i) {
                return DropdownMenuItem(
                  value: i,
                  child: Text(comp.variations[i].name),
                );
              }),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedVariationIndex = val;
                  });
                }
              },
            ),
            const SizedBox(width: 16),
            if (!isDefault) ...[
              Expanded(
                child: TextFormField(
                  initialValue: variation.name,
                  decoration: const InputDecoration(
                    hintText: 'Rename Variation',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  onFieldSubmitted: (newVal) {
                    if (newVal.isNotEmpty) {
                      widget.controller.removeComponentVariation(
                        'Button',
                        selectedVariationIndex,
                      );
                      widget.controller.addComponentVariation('Button', newVal);
                      setState(() {
                        selectedVariationIndex = comp.variations.length;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  widget.controller.removeComponentVariation(
                    'Button',
                    selectedVariationIndex,
                  );
                  setState(() {
                    selectedVariationIndex = 0;
                  });
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
            if (isDefault) const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _showAddVariationDialog(),
              icon: const Icon(Icons.add, size: 14),
              label: const Text(
                'Add Variation',
                style: TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: RikitColors.primary,
              ),
            ),
          ],
        ),
      ),
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
        style: const TextStyle(
          color: RikitColors.text,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        items: const [
          DropdownMenuItem(value: 'idle', child: Text('Idle State')),
          DropdownMenuItem(value: 'hovered', child: Text('Hovered State')),
          DropdownMenuItem(value: 'pressed', child: Text('Pressed State')),
          DropdownMenuItem(value: 'disabled', child: Text('Disabled State')),
        ],
        onChanged: (val) {
          if (val != null) {
            setState(() => selectedStateKey = val);
          }
        },
      ),
    );
  }

  Widget _buildColorInputs(ButtonStyleSpec activeStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Colors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: RikitColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.backgroundColor.value,
                decoration: const InputDecoration(
                  labelText: 'Background Color Token / Hex',
                ),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#')
                      ? ColorToken.static(val)
                      : ColorToken.theme(val);
                  widget.controller.updateButtonStyle(
                    selectedVariationIndex,
                    selectedStateKey,
                    activeStyle.copyWith(backgroundColor: token),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.foregroundColor.value,
                decoration: const InputDecoration(
                  labelText: 'Foreground Color Token / Hex',
                ),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#')
                      ? ColorToken.static(val)
                      : ColorToken.theme(val);
                  widget.controller.updateButtonStyle(
                    selectedVariationIndex,
                    selectedStateKey,
                    activeStyle.copyWith(foregroundColor: token),
                  );
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
                decoration: const InputDecoration(
                  labelText: 'Border Color Token / Hex',
                ),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#')
                      ? ColorToken.static(val)
                      : ColorToken.theme(val);
                  widget.controller.updateButtonStyle(
                    selectedVariationIndex,
                    selectedStateKey,
                    activeStyle.copyWith(borderColor: token),
                  );
                },
              ),
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _buildDimensionInputs(ButtonStyleSpec activeStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dimensions & Layout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: RikitColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.paddingHorizontal.value.toString(),
                decoration: const InputDecoration(
                  labelText: 'Padding Horizontal',
                ),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 12.0;
                  widget.controller.updateButtonStyle(
                    selectedVariationIndex,
                    selectedStateKey,
                    activeStyle.copyWith(
                      paddingHorizontal: Dimension(
                        d,
                        activeStyle.paddingHorizontal.unit,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: activeStyle.paddingVertical.value.toString(),
                decoration: const InputDecoration(
                  labelText: 'Padding Vertical',
                ),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 8.0;
                  widget.controller.updateButtonStyle(
                    selectedVariationIndex,
                    selectedStateKey,
                    activeStyle.copyWith(
                      paddingVertical: Dimension(
                        d,
                        activeStyle.paddingVertical.unit,
                      ),
                    ),
                  );
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
                initialValue: activeStyle.borderRadius.value.toString(),
                decoration: const InputDecoration(labelText: 'Border Radius'),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 6.0;
                  widget.controller.updateButtonStyle(
                    selectedVariationIndex,
                    selectedStateKey,
                    activeStyle.copyWith(
                      borderRadius: Dimension(d, activeStyle.borderRadius.unit),
                    ),
                  );
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
                  widget.controller.updateButtonStyle(
                    selectedVariationIndex,
                    selectedStateKey,
                    activeStyle.copyWith(
                      borderWidth: Dimension(d, activeStyle.borderWidth.unit),
                    ),
                  );
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
                initialValue: activeStyle.gap.value.toString(),
                decoration: const InputDecoration(labelText: 'Gap (Icon/Text)'),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 6.0;
                  widget.controller.updateButtonStyle(
                    selectedVariationIndex,
                    selectedStateKey,
                    activeStyle.copyWith(
                      gap: Dimension(d, activeStyle.gap.unit),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _buildTypographyInputs(ButtonStyleSpec activeStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Typography',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: RikitColors.primary,
          ),
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
                  widget.controller.updateButtonStyle(
                    selectedVariationIndex,
                    selectedStateKey,
                    activeStyle.copyWith(
                      fontSize: Dimension(d, activeStyle.fontSize.unit),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: activeStyle.textTransform,
                decoration: const InputDecoration(labelText: 'Text Transform'),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('None')),
                  DropdownMenuItem(
                    value: 'uppercase',
                    child: Text('UPPERCASE'),
                  ),
                  DropdownMenuItem(
                    value: 'lowercase',
                    child: Text('lowercase'),
                  ),
                  DropdownMenuItem(
                    value: 'capitalize',
                    child: Text('Capitalize'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    widget.controller.updateButtonStyle(
                      selectedVariationIndex,
                      selectedStateKey,
                      activeStyle.copyWith(textTransform: val),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewPanel(ComponentVariation<ButtonStyleSpec> variation) {
    final spec = widget.controller.state;

    // Resolve visual state spec based on active interactive simulation state
    final activeState = selectedStateKey == 'disabled'
        ? 'disabled'
        : isPressingPreview
        ? 'pressed'
        : isHoveringPreview
        ? 'hovered'
        : selectedStateKey; // lock to selected state if not actively simulating

    final resolvedStyle =
        variation.stateStyles[activeState] ?? variation.stateStyles['idle']!;

    final bgColor = resolveColorToken(resolvedStyle.backgroundColor, spec);
    final fgColor = resolveColorToken(resolvedStyle.foregroundColor, spec);
    final borderColor = resolveColorToken(resolvedStyle.borderColor, spec);
    final borderRadius = resolvedStyle.borderRadius.value;
    final borderWidth = resolvedStyle.borderWidth.value;
    final gap = resolvedStyle.gap.value;
    final paddingH = resolvedStyle.paddingHorizontal.value;
    final paddingV = resolvedStyle.paddingVertical.value;
    final fontSize = resolvedStyle.fontSize.value;

    String transformText(String raw) {
      switch (resolvedStyle.textTransform) {
        case 'uppercase':
          return raw.toUpperCase();
        case 'lowercase':
          return raw.toLowerCase();
        case 'capitalize':
          if (raw.isEmpty) return raw;
          return raw
              .split(' ')
              .map(
                (word) => word.isNotEmpty
                    ? '${word[0].toUpperCase()}${word.substring(1)}'
                    : '',
              )
              .join(' ');
        default:
          return raw;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const Text(
              'Interactive Preview',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: RikitColors.text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hover and click on the button below to test its state transitions.',
              style: TextStyle(color: RikitColors.textMuted, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            // Hover/Click simulator
            MouseRegion(
              onEnter: (_) => setState(() => isHoveringPreview = true),
              onExit: (_) => setState(() {
                isHoveringPreview = false;
                isPressingPreview = false;
              }),
              child: GestureDetector(
                onTapDown: (_) => setState(() => isPressingPreview = true),
                onTapUp: (_) => setState(() => isPressingPreview = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(
                    horizontal: paddingH,
                    vertical: paddingV,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(color: borderColor, width: borderWidth),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: fontSize + 2,
                        color: fgColor,
                      ),
                      SizedBox(width: gap),
                      Text(
                        transformText('Action Button'),
                        style: TextStyle(
                          color: fgColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: gap),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: fontSize + 2,
                        color: fgColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Display resolved colors for debug
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: RikitColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDebugColorRow('Resolved BG', bgColor),
                  const SizedBox(height: 6),
                  _buildDebugColorRow('Resolved FG', fgColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugColorRow(String label, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: RikitColors.textMuted),
        ),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              colorToHex(color),
              style: const TextStyle(fontFamily: 'Monospace', fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddVariationDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: RikitColors.surfaceRaised,
          title: const Text('Add Component Variation'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Variation Name (e.g. Ghost, Outline)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: RikitColors.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  widget.controller.addComponentVariation('Button', name);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: RikitColors.primary,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
