import 'package:flutter/material.dart';
import 'package:rikit/features/design_system/domain/color_token.dart';
import 'package:rikit/features/design_system/domain/component_models.dart';
import 'package:rikit/features/design_system/domain/dimension.dart';
import 'package:rikit/features/design_system/presentation/controllers/design_system_controller.dart';
import 'package:rikit/features/design_system/presentation/widgets/color_resolver.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class DropdownEditor extends StatefulWidget {
  const DropdownEditor({required this.controller, super.key});
  final DesignSystemController controller;

  @override
  State<DropdownEditor> createState() => _DropdownEditorState();
}

class _DropdownEditorState extends State<DropdownEditor> {
  int selectedVariationIndex = 0;
  String selectedStateKey = 'idle'; // 'idle', 'hovered', 'pressed', 'disabled'
  bool isMenuOpen = false;
  int hoveredItemIndex = -1;
  bool isHoveringTrigger = false;
  bool isPressingTrigger = false;
  String selectedOption = 'Select option';

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final dropdownComp =
        state.components.firstWhere((c) => c.name == 'Dropdown')
            as DropdownComponent;

    if (selectedVariationIndex >= dropdownComp.variations.length) {
      selectedVariationIndex = 0;
    }

    final variation = dropdownComp.variations[selectedVariationIndex];
    final activeStyle = variation.stateStyles['idle']!; // base dropdown spec
    final triggerStyle = activeStyle.triggerButton;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVariationHeader(dropdownComp),
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
                        const Text(
                          'Styling Specifications',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTriggerButtonSection(triggerStyle),
                        const SizedBox(height: 24),
                        _buildMenuSection(activeStyle),
                        const SizedBox(height: 24),
                        _buildMenuItemsSection(activeStyle),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Right: Live Popover Preview
              Expanded(flex: 4, child: _buildPreviewPanel(activeStyle)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVariationHeader(DropdownComponent comp) {
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
                        'Dropdown',
                        selectedVariationIndex,
                      );
                      widget.controller.addComponentVariation(
                        'Dropdown',
                        newVal,
                      );
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
                    'Dropdown',
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

  Widget _buildTriggerButtonSection(ButtonStyleSpec triggerStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trigger Button Styling',
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
                initialValue: triggerStyle.backgroundColor.value,
                decoration: const InputDecoration(
                  labelText: 'Background Color Token / Hex',
                ),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#')
                      ? ColorToken.static(val)
                      : ColorToken.theme(val);
                  _updateTriggerButton(
                    triggerStyle.copyWith(backgroundColor: token),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: triggerStyle.foregroundColor.value,
                decoration: const InputDecoration(
                  labelText: 'Foreground Color Token / Hex',
                ),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#')
                      ? ColorToken.static(val)
                      : ColorToken.theme(val);
                  _updateTriggerButton(
                    triggerStyle.copyWith(foregroundColor: token),
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
                initialValue: triggerStyle.borderRadius.value.toString(),
                decoration: const InputDecoration(labelText: 'Border Radius'),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 6.0;
                  _updateTriggerButton(
                    triggerStyle.copyWith(
                      borderRadius: Dimension(
                        d,
                        triggerStyle.borderRadius.unit,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: triggerStyle.fontSize.value.toString(),
                decoration: const InputDecoration(labelText: 'Font Size'),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 14.0;
                  _updateTriggerButton(
                    triggerStyle.copyWith(
                      fontSize: Dimension(d, triggerStyle.fontSize.unit),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuSection(DropdownStyleSpec spec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Popover Styling',
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
                initialValue: spec.menuBackground.value,
                decoration: const InputDecoration(
                  labelText: 'Menu Background Color Token / Hex',
                ),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#')
                      ? ColorToken.static(val)
                      : ColorToken.theme(val);
                  _updateDropdownSpec(spec.copyWith(menuBackground: token));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: spec.menuBorder.value,
                decoration: const InputDecoration(
                  labelText: 'Menu Border Color Token / Hex',
                ),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#')
                      ? ColorToken.static(val)
                      : ColorToken.theme(val);
                  _updateDropdownSpec(spec.copyWith(menuBorder: token));
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
                initialValue: spec.menuBorderRadius.value.toString(),
                decoration: const InputDecoration(
                  labelText: 'Menu Border Radius',
                ),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 8.0;
                  _updateDropdownSpec(
                    spec.copyWith(
                      menuBorderRadius: Dimension(
                        d,
                        spec.menuBorderRadius.unit,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: spec.menuPadding.value.toString(),
                decoration: const InputDecoration(
                  labelText: 'Menu Inner Padding',
                ),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 8.0;
                  _updateDropdownSpec(
                    spec.copyWith(
                      menuPadding: Dimension(d, spec.menuPadding.unit),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItemsSection(DropdownStyleSpec spec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Items Styling',
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
                initialValue: spec.itemPaddingHorizontal.value.toString(),
                decoration: const InputDecoration(
                  labelText: 'Item Horizontal Padding',
                ),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 12.0;
                  _updateDropdownSpec(
                    spec.copyWith(
                      itemPaddingHorizontal: Dimension(
                        d,
                        spec.itemPaddingHorizontal.unit,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: spec.itemPaddingVertical.value.toString(),
                decoration: const InputDecoration(
                  labelText: 'Item Vertical Padding',
                ),
                onFieldSubmitted: (val) {
                  final d = double.tryParse(val) ?? 8.0;
                  _updateDropdownSpec(
                    spec.copyWith(
                      itemPaddingVertical: Dimension(
                        d,
                        spec.itemPaddingVertical.unit,
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
                initialValue: spec.itemHoverBackground.value,
                decoration: const InputDecoration(
                  labelText: 'Item Hover Background Color Token / Hex',
                ),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#')
                      ? ColorToken.static(val)
                      : ColorToken.theme(val);
                  _updateDropdownSpec(
                    spec.copyWith(itemHoverBackground: token),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: spec.itemHoverForeground.value,
                decoration: const InputDecoration(
                  labelText: 'Item Hover Foreground Color Token / Hex',
                ),
                onFieldSubmitted: (val) {
                  final token = val.startsWith('#')
                      ? ColorToken.static(val)
                      : ColorToken.theme(val);
                  _updateDropdownSpec(
                    spec.copyWith(itemHoverForeground: token),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateTriggerButton(ButtonStyleSpec newTrigger) {
    final state = widget.controller.state;
    final dropdownComp =
        state.components.firstWhere((c) => c.name == 'Dropdown')
            as DropdownComponent;
    final variation = dropdownComp.variations[selectedVariationIndex];
    final activeStyle = variation.stateStyles['idle']!;
    widget.controller.updateDropdownStyle(
      selectedVariationIndex,
      'idle',
      activeStyle.copyWith(triggerButton: newTrigger),
    );
  }

  void _updateDropdownSpec(DropdownStyleSpec newSpec) {
    widget.controller.updateDropdownStyle(selectedVariationIndex, 'idle', newSpec);
  }

  Widget _buildPreviewPanel(DropdownStyleSpec spec) {
    final globalState = widget.controller.state;
    final trigger = spec.triggerButton;

    // Resolve Trigger styles
    var triggerBg = resolveColorToken(trigger.backgroundColor, globalState);
    var triggerFg = resolveColorToken(trigger.foregroundColor, globalState);
    var triggerBorder = resolveColorToken(trigger.borderColor, globalState);

    // Apply simulation highlights
    if (isPressingTrigger || isMenuOpen) {
      triggerBg = resolveColorToken(
        ColorToken.theme('primary-700'),
        globalState,
      );
    } else if (isHoveringTrigger) {
      triggerBg = resolveColorToken(
        ColorToken.theme('primary-600'),
        globalState,
      );
    }

    final menuBg = resolveColorToken(spec.menuBackground, globalState);
    final menuBorder = resolveColorToken(spec.menuBorder, globalState);
    final itemHoverBg = resolveColorToken(
      spec.itemHoverBackground,
      globalState,
    );
    final itemHoverFg = resolveColorToken(
      spec.itemHoverForeground,
      globalState,
    );

    final List<String> options = [
      'Option 1 (Main Action)',
      'Option 2 (Secondary)',
      'Option 3 (Destructive)',
    ];

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
              'Click the trigger button to view the dropdown popover menu.',
              style: TextStyle(color: RikitColors.textMuted, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trigger Button
                MouseRegion(
                  onEnter: (_) => setState(() => isHoveringTrigger = true),
                  onExit: (_) => setState(() => isHoveringTrigger = false),
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => isPressingTrigger = true),
                    onTapUp: (_) => setState(() {
                      isPressingTrigger = false;
                      isMenuOpen = !isMenuOpen;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: EdgeInsets.symmetric(
                        horizontal: trigger.paddingHorizontal.value,
                        vertical: trigger.paddingVertical.value,
                      ),
                      decoration: BoxDecoration(
                        color: triggerBg,
                        borderRadius: BorderRadius.circular(
                          trigger.borderRadius.value,
                        ),
                        border: Border.all(
                          color: triggerBorder,
                          width: trigger.borderWidth.value,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedOption,
                            style: TextStyle(
                              color: triggerFg,
                              fontSize: trigger.fontSize.value,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: trigger.gap.value),
                          Icon(
                            isMenuOpen
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: trigger.fontSize.value + 2,
                            color: triggerFg,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Dropdown Menu Popover (Simulated overlay inside card)
                if (isMenuOpen)
                  Container(
                    width: 200,
                    padding: EdgeInsets.all(spec.menuPadding.value),
                    decoration: BoxDecoration(
                      color: menuBg,
                      borderRadius: BorderRadius.circular(
                        spec.menuBorderRadius.value,
                      ),
                      border: Border.all(color: menuBorder, width: 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(options.length, (index) {
                        final isHovered = hoveredItemIndex == index;
                        final optionText = options[index];
                        final itemBg = isHovered
                            ? itemHoverBg
                            : Colors.transparent;
                        final itemFg = isHovered
                            ? itemHoverFg
                            : RikitColors.text;

                        return MouseRegion(
                          onEnter: (_) =>
                              setState(() => hoveredItemIndex = index),
                          onExit: (_) => setState(() => hoveredItemIndex = -1),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedOption = optionText;
                                isMenuOpen = false;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: spec.itemPaddingHorizontal.value,
                                vertical: spec.itemPaddingVertical.value,
                              ),
                              decoration: BoxDecoration(
                                color: itemBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                optionText,
                                style: TextStyle(
                                  color: itemFg,
                                  fontSize: 13,
                                  fontWeight: isHovered
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
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
                  widget.controller.addComponentVariation('Dropdown', name);
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
