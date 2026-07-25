import 'package:flutter/material.dart';
import 'package:rikit/features/design_system/domain/color_token.dart';
import 'package:rikit/features/design_system/domain/dimension.dart';
import 'package:rikit/features/design_system/domain/global_tokens.dart';
import 'package:rikit/features/design_system/presentation/controllers/design_system_controller.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class GlobalTokensEditor extends StatelessWidget {
  const GlobalTokensEditor({required this.controller, super.key});
  final DesignSystemController controller;

  @override
  Widget build(BuildContext context) {
    final tokens = controller.state.globalTokens;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Global Scales',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          _buildBorderRadiusSection(context, tokens),
          const SizedBox(height: 28),
          _buildSpacingSection(context, tokens),
          const SizedBox(height: 28),
          _buildShadowsSection(context, tokens),
        ],
      ),
    );
  }

  Widget _buildBorderRadiusSection(BuildContext context, GlobalTokens tokens) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Border Radii Scale',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.addBorderRadiusToken(
                    'new-radius',
                    const Dimension.px(8),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 14),
                  label: const Text('Add Step', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RikitColors.surfaceRaised,
                    foregroundColor: RikitColors.primary,
                    side: const BorderSide(color: RikitColors.border),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tokens.borderRadiusScale.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final token = tokens.borderRadiusScale[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: token.key,
                          decoration: const InputDecoration(
                            labelText: 'Key (e.g. sm, lg)',
                          ),
                          onFieldSubmitted: (newKey) {
                            if (newKey.isNotEmpty && newKey != token.key) {
                              controller.removeBorderRadiusToken(token.key);
                              controller.addBorderRadiusToken(
                                newKey,
                                token.value,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: token.value.value.toString(),
                          decoration: const InputDecoration(labelText: 'Value'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onFieldSubmitted: (newVal) {
                            final double? parsedVal = double.tryParse(newVal);
                            if (parsedVal != null) {
                              controller.updateBorderRadiusToken(
                                token.key,
                                Dimension(parsedVal, token.value.unit),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<DimensionUnit>(
                          initialValue: token.value.unit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: DimensionUnit.values.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(
                                unit.name == 'none' ? 'raw' : unit.name,
                              ),
                            );
                          }).toList(),
                          onChanged: (newUnit) {
                            if (newUnit != null) {
                              controller.updateBorderRadiusToken(
                                token.key,
                                Dimension(token.value.value, newUnit),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () =>
                            controller.removeBorderRadiusToken(token.key),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpacingSection(BuildContext context, GlobalTokens tokens) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Spacing Scale',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.addSpacingToken(
                    'new-spacing',
                    const Dimension.px(12),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 14),
                  label: const Text('Add Step', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RikitColors.surfaceRaised,
                    foregroundColor: RikitColors.primary,
                    side: const BorderSide(color: RikitColors.border),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tokens.spacingScale.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final token = tokens.spacingScale[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: token.key,
                          decoration: const InputDecoration(labelText: 'Key'),
                          onFieldSubmitted: (newKey) {
                            if (newKey.isNotEmpty && newKey != token.key) {
                              controller.removeSpacingToken(token.key);
                              controller.addSpacingToken(newKey, token.value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: token.value.value.toString(),
                          decoration: const InputDecoration(labelText: 'Value'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onFieldSubmitted: (newVal) {
                            final double? parsedVal = double.tryParse(newVal);
                            if (parsedVal != null) {
                              controller.updateSpacingToken(
                                token.key,
                                Dimension(parsedVal, token.value.unit),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<DimensionUnit>(
                          initialValue: token.value.unit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: DimensionUnit.values.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(
                                unit.name == 'none' ? 'raw' : unit.name,
                              ),
                            );
                          }).toList(),
                          onChanged: (newUnit) {
                            if (newUnit != null) {
                              controller.updateSpacingToken(
                                token.key,
                                Dimension(token.value.value, newUnit),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () =>
                            controller.removeSpacingToken(token.key),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShadowsSection(BuildContext context, GlobalTokens tokens) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Shadows Scale',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.addShadowToken(
                    'new-shadow',
                    const ShadowValue(
                      color: ColorToken.static('#00000026'),
                      offsetX: 0,
                      offsetY: 4,
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 14),
                  label: const Text('Add Step', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RikitColors.surfaceRaised,
                    foregroundColor: RikitColors.primary,
                    side: const BorderSide(color: RikitColors.border),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tokens.shadowsScale.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final token = tokens.shadowsScale[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              initialValue: token.key,
                              decoration: const InputDecoration(
                                labelText: 'Key (e.g. sm, lg)',
                              ),
                              onFieldSubmitted: (newKey) {
                                if (newKey.isNotEmpty && newKey != token.key) {
                                  controller.removeShadowToken(token.key);
                                  controller.addShadowToken(
                                    newKey,
                                    token.value,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              initialValue: token.value.color.value,
                              decoration: const InputDecoration(
                                labelText: 'Shadow Color (Hex / Token)',
                              ),
                              onFieldSubmitted: (newColorVal) {
                                if (newColorVal.isNotEmpty) {
                                  final ColorToken colToken =
                                      newColorVal.startsWith('#')
                                      ? ColorToken.static(newColorVal)
                                      : ColorToken.theme(newColorVal);
                                  controller.updateShadowToken(
                                    token.key,
                                    ShadowValue(
                                      color: colToken,
                                      offsetX: token.value.offsetX,
                                      offsetY: token.value.offsetY,
                                      blurRadius: token.value.blurRadius,
                                      spreadRadius: token.value.spreadRadius,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () =>
                                controller.removeShadowToken(token.key),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: token.value.offsetX.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Offset X (px)',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onFieldSubmitted: (newVal) {
                                final double? parsedVal = double.tryParse(
                                  newVal,
                                );
                                if (parsedVal != null) {
                                  controller.updateShadowToken(
                                    token.key,
                                    ShadowValue(
                                      color: token.value.color,
                                      offsetX: parsedVal,
                                      offsetY: token.value.offsetY,
                                      blurRadius: token.value.blurRadius,
                                      spreadRadius: token.value.spreadRadius,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: token.value.offsetY.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Offset Y (px)',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onFieldSubmitted: (newVal) {
                                final double? parsedVal = double.tryParse(
                                  newVal,
                                );
                                if (parsedVal != null) {
                                  controller.updateShadowToken(
                                    token.key,
                                    ShadowValue(
                                      color: token.value.color,
                                      offsetX: token.value.offsetX,
                                      offsetY: parsedVal,
                                      blurRadius: token.value.blurRadius,
                                      spreadRadius: token.value.spreadRadius,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: token.value.blurRadius.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Blur (px)',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onFieldSubmitted: (newVal) {
                                final double? parsedVal = double.tryParse(
                                  newVal,
                                );
                                if (parsedVal != null) {
                                  controller.updateShadowToken(
                                    token.key,
                                    ShadowValue(
                                      color: token.value.color,
                                      offsetX: token.value.offsetX,
                                      offsetY: token.value.offsetY,
                                      blurRadius: parsedVal,
                                      spreadRadius: token.value.spreadRadius,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: token.value.spreadRadius.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Spread (px)',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onFieldSubmitted: (newVal) {
                                final double? parsedVal = double.tryParse(
                                  newVal,
                                );
                                if (parsedVal != null) {
                                  controller.updateShadowToken(
                                    token.key,
                                    ShadowValue(
                                      color: token.value.color,
                                      offsetX: token.value.offsetX,
                                      offsetY: token.value.offsetY,
                                      blurRadius: token.value.blurRadius,
                                      spreadRadius: parsedVal,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
