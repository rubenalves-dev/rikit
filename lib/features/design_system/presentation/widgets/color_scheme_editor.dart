import 'package:flutter/material.dart';
import 'package:rikit/features/design_system/domain/color_row.dart';
import 'package:rikit/features/design_system/domain/color_token.dart';
import 'package:rikit/features/design_system/presentation/controllers/design_system_controller.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class ColorSchemeEditor extends StatelessWidget {
  const ColorSchemeEditor({required this.controller, super.key});
  final DesignSystemController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Color Schemes',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddColorDialog(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Custom Color'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RikitColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.colorRows.length,
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final row = state.colorRows[index];
              return _ColorRowCard(
                row: row,
                index: index,
                onUpdateBase: (color) =>
                    controller.updateColorRowBase(index, color),
                onRename: row.isRemovable
                    ? (name) => controller.renameColorRow(index, name)
                    : null,
                onDelete: row.isRemovable
                    ? () => controller.removeColorRow(index)
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddColorDialog(BuildContext context) {
    final nameController = TextEditingController();
    var pickedColor = RikitColors.primary;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: RikitColors.surfaceRaised,
              title: const Text('Add Custom Color Row'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Color Key Name (e.g. brand, success)',
                      hintText: 'e.g. brand',
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Select starting color:',
                    style: TextStyle(
                      color: RikitColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                          Colors.red,
                          Colors.orange,
                          Colors.amber,
                          Colors.green,
                          Colors.teal,
                          Colors.blue,
                          Colors.indigo,
                          Colors.purple,
                          Colors.pink,
                          Colors.grey,
                        ].map((color) {
                          final isSelected = pickedColor == color;
                          return GestureDetector(
                            onTap: () => setState(() => pickedColor = color),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.white,
                                        width: 2.5,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
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
                      controller.addColorRow(name, pickedColor);
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
      },
    );
  }
}

class _ColorRowCard extends StatelessWidget {
  const _ColorRowCard({
    required this.row,
    required this.index,
    required this.onUpdateBase,
    this.onRename,
    this.onDelete,
  });

  final ColorRow row;
  final int index;
  final ValueChanged<Color> onUpdateBase;
  final ValueChanged<String>? onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: onRename != null
                      ? TextFormField(
                          initialValue: row.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: RikitColors.primary,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          onFieldSubmitted: onRename,
                        )
                      : Text(
                          row.name.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: RikitColors.text,
                          ),
                        ),
                ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _BaseColorPickerBlock(
                  color: row.baseColor,
                  onColorChanged: onUpdateBase,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: row.shades.entries.map((entry) {
                        final shade = entry.key;
                        final color = entry.value;
                        final isBase = shade == 500;
                        final fontColor = color.computeLuminance() > 0.179
                            ? Colors.black
                            : Colors.white;

                        return Tooltip(
                          message: '${row.name}-$shade: ${colorToHex(color)}',
                          child: Container(
                            width: 58,
                            height: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(6),
                              border: isBase
                                  ? Border.all(
                                      color: RikitColors.text,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      shade.toString(),
                                      style: TextStyle(
                                        color: fontColor.withAlpha(204),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'A',
                                      style: TextStyle(
                                        color: fontColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isBase)
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BaseColorPickerBlock extends StatelessWidget {
  const _BaseColorPickerBlock({
    required this.color,
    required this.onColorChanged,
  });

  final Color color;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    final hexString = colorToHex(color);
    return InkWell(
      onTap: () => _showColorPickerDialog(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: RikitColors.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: RikitColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white24),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              hexString,
              style: const TextStyle(
                fontFamily: 'Monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    final hexController = TextEditingController(text: colorToHex(color));
    var activeColor = color;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: RikitColors.surfaceRaised,
              title: const Text('Edit Base Color'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: hexController,
                    decoration: const InputDecoration(
                      labelText: 'Hex Color Code',
                      hintText: '#FF0000',
                    ),
                    onChanged: (val) {
                      try {
                        final parsed = hexToColor(val);
                        setState(() => activeColor = parsed);
                      } catch (_) {}
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Predefined Palette:',
                    style: TextStyle(
                      color: RikitColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        [
                          const Color(0xFFEF4444), // Red
                          const Color(0xFFF97316), // Orange
                          const Color(0xFFF59E0B), // Amber
                          const Color(0xFF10B981), // Emerald
                          const Color(0xFF06B6D4), // Cyan
                          const Color(0xFF3B82F6), // Blue
                          const Color(0xFF6366F1), // Indigo
                          const Color(0xFF8B5CF6), // Violet
                          const Color(0xFFEC4899), // Pink
                          const Color(0xFF0F172A), // Slate
                        ].map((col) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                activeColor = col;
                                hexController.text = colorToHex(col);
                              });
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: col,
                                shape: BoxShape.circle,
                                border: activeColor == col
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
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
                    onColorChanged(activeColor);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RikitColors.primary,
                  ),
                  child: const Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
