import 'package:flutter/material.dart';
import 'package:rikit/features/design_system/domain/dimension.dart';
import 'package:rikit/features/design_system/domain/typography_settings.dart';
import 'package:rikit/features/design_system/presentation/controllers/design_system_controller.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class TypographyEditor extends StatelessWidget {
  const TypographyEditor({
    required this.controller,
    required this.systemFonts,
    super.key,
  });

  final DesignSystemController controller;
  final List<String> systemFonts;

  @override
  Widget build(BuildContext context) {
    final ty = controller.state.typography;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Typography Style Editor',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          _buildGroupCard(
            context: context,
            title: 'Headings Group (H1, H2, H3)',
            isGrouped: ty.groupHeadings,
            onGroupToggled: controller.toggleGroupHeadings,
            styles: [
              _StyleItem('H1', ty.h1, 'h1'),
              _StyleItem('H2', ty.h2, 'h2'),
              _StyleItem('H3', ty.h3, 'h3'),
            ],
          ),
          const SizedBox(height: 24),
          _buildGroupCard(
            context: context,
            title: 'Bodies Group (Normal, Small)',
            isGrouped: ty.groupBodies,
            onGroupToggled: controller.toggleGroupBodies,
            styles: [
              _StyleItem('Body Normal', ty.bodyNormal, 'bodyNormal'),
              _StyleItem('Body Small', ty.bodySmall, 'bodySmall'),
            ],
          ),
          const SizedBox(height: 24),
          _buildGroupCard(
            context: context,
            title: 'Body Infos Group (Normal, Small)',
            isGrouped: ty.groupInfos,
            onGroupToggled: controller.toggleGroupInfos,
            styles: [
              _StyleItem('Info Normal', ty.infoNormal, 'infoNormal'),
              _StyleItem('Info Small', ty.infoSmall, 'infoSmall'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard({
    required BuildContext context,
    required String title,
    required bool isGrouped,
    required ValueChanged<bool> onGroupToggled,
    required List<_StyleItem> styles,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Edit as Group',
                      style: TextStyle(
                        color: RikitColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Switch(
                      value: isGrouped,
                      onChanged: onGroupToggled,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (isGrouped)
              _buildEditorRow(
                context: context,
                label: 'All Styles in Group',
                spec: styles.first.spec,
                onChanged: (newSpec) {
                  // Propagate to the representative style (the controller handles group distribution)
                  controller.updateTypographyStyle(
                    styles.first.key,
                    fontFamily: newSpec.fontFamily,
                    fontSize: newSpec.fontSize,
                    letterSpacing: newSpec.letterSpacing,
                  );
                },
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: styles.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = styles[index];
                  return _buildEditorRow(
                    context: context,
                    label: item.name,
                    spec: item.spec,
                    onChanged: (newSpec) {
                      controller.updateTypographyStyle(
                        item.key,
                        fontFamily: newSpec.fontFamily,
                        fontSize: newSpec.fontSize,
                        letterSpacing: newSpec.letterSpacing,
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorRow({
    required BuildContext context,
    required String label,
    required TextStyleSpec spec,
    required ValueChanged<TextStyleSpec> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: RikitColors.text,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: DropdownButtonFormField<String>(
                initialValue: systemFonts.contains(spec.fontFamily)
                    ? spec.fontFamily
                    : systemFonts.first,
                decoration: const InputDecoration(labelText: 'Font Family'),
                items: systemFonts.map((font) {
                  return DropdownMenuItem(
                    value: font,
                    child: Text(
                      font,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (newFont) {
                  if (newFont != null) {
                    onChanged(spec.copyWith(fontFamily: newFont));
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: spec.fontSize.value.toString(),
                decoration: const InputDecoration(labelText: 'Size'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onFieldSubmitted: (val) {
                  final double? parsed = double.tryParse(val);
                  if (parsed != null) {
                    onChanged(
                      spec.copyWith(
                        fontSize: Dimension(parsed, spec.fontSize.unit),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<DimensionUnit>(
                initialValue: spec.fontSize.unit,
                decoration: const InputDecoration(labelText: 'Unit'),
                items: [DimensionUnit.px, DimensionUnit.rem, DimensionUnit.em]
                    .map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit.name),
                      );
                    })
                    .toList(),
                onChanged: (newUnit) {
                  if (newUnit != null) {
                    onChanged(
                      spec.copyWith(
                        fontSize: Dimension(spec.fontSize.value, newUnit),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: TextFormField(
                initialValue: spec.letterSpacing.value.toString(),
                decoration: const InputDecoration(labelText: 'Letter Spacing'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onFieldSubmitted: (val) {
                  final double? parsed = double.tryParse(val);
                  if (parsed != null) {
                    onChanged(
                      spec.copyWith(
                        letterSpacing: Dimension(
                          parsed,
                          spec.letterSpacing.unit,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Live typography text preview
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: RikitColors.surfaceRaised,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: RikitColors.borderSubtle),
          ),
          child: Text(
            'Preview: The quick brown fox jumps over the lazy dog.',
            style: TextStyle(
              fontFamily: spec.fontFamily,
              fontSize: spec.fontSize.unit == DimensionUnit.px
                  ? spec.fontSize.value
                  : 14.0, // scale for system visual preview in flutter
              letterSpacing: spec.letterSpacing.value,
              color: RikitColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

class _StyleItem {
  final String name;
  final TextStyleSpec spec;
  final String key;

  const _StyleItem(this.name, this.spec, this.key);
}
