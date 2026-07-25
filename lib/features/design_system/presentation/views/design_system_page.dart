import 'package:flutter/material.dart';
import 'package:rikit/features/design_system/domain/design_system_state.dart';
import 'package:rikit/features/design_system/presentation/controllers/design_system_controller.dart';
import 'package:rikit/features/design_system/presentation/services/system_fonts_service.dart';
import 'package:rikit/features/design_system/presentation/widgets/color_scheme_editor.dart';
import 'package:rikit/features/design_system/presentation/widgets/global_tokens_editor.dart';
import 'package:rikit/features/design_system/presentation/widgets/typography_editor.dart';
import 'package:rikit/shared/presentation/page_header.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class DesignSystemPage extends StatefulWidget {
  const DesignSystemPage({required this.controller, super.key});
  final DesignSystemController controller;

  @override
  State<DesignSystemPage> createState() => _DesignSystemPageState();
}

class _JsonPagePlaceholder extends StatelessWidget {
  const _JsonPagePlaceholder({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.handyman_rounded,
                size: 48,
                color: RikitColors.textMuted,
              ),
              const SizedBox(height: 16),
              Text(
                '$title Editor',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Interactive preview and state overrides are coming in the next module.',
                style: TextStyle(color: RikitColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesignSystemPageState extends State<DesignSystemPage> {
  List<String> systemFonts = [];
  bool loadingFonts = true;

  @override
  void initState() {
    super.initState();
    _loadFonts();
  }

  Future<void> _loadFonts() async {
    const service = SystemFontsService();
    final list = await service.loadSystemFonts();
    if (mounted) {
      setState(() {
        systemFonts = list;
        loadingFonts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return DefaultTabController(
          length: 7,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 30, 32, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    eyebrow: 'Developer tools',
                    title: 'Design System Creator',
                    description:
                        'Build typography, colors, global tokens scales, and preview components locally.',
                    trailing: _PresetSelector(
                      onPresetSelected: (presetName) {
                        switch (presetName) {
                          case 'Minimalist':
                            widget.controller.applyPreset(
                              DesignSystemPresets.minimalist(),
                            );
                            break;
                          case 'Sharp':
                            widget.controller.applyPreset(
                              DesignSystemPresets.sharp(),
                            );
                            break;
                          case 'Full Rounded':
                            widget.controller.applyPreset(
                              DesignSystemPresets.fullRounded(),
                            );
                            break;
                          case 'Compact':
                            widget.controller.applyPreset(
                              DesignSystemPresets.compact(),
                            );
                            break;
                          case 'Spacious':
                            widget.controller.applyPreset(
                              DesignSystemPresets.spacious(),
                            );
                            break;
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  const TabBar(
                    isScrollable: true,
                    indicatorColor: RikitColors.primary,
                    labelColor: RikitColors.text,
                    unselectedLabelColor: RikitColors.textMuted,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: 'Colors'),
                      Tab(text: 'Globals'),
                      Tab(text: 'Typography'),
                      Tab(text: 'Button'),
                      Tab(text: 'Dropdown'),
                      Tab(text: 'Forms'),
                      Tab(text: 'Details & Finish'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ColorSchemeEditor(controller: widget.controller),
                        GlobalTokensEditor(controller: widget.controller),
                        loadingFonts
                            ? const Center(child: CircularProgressIndicator())
                            : TypographyEditor(
                                controller: widget.controller,
                                systemFonts: systemFonts,
                              ),
                        const _JsonPagePlaceholder(title: 'Button'),
                        const _JsonPagePlaceholder(title: 'Dropdown'),
                        const _JsonPagePlaceholder(title: 'Forms'),
                        const _JsonPagePlaceholder(title: 'Details & Finish'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PresetSelector extends StatelessWidget {
  const _PresetSelector({required this.onPresetSelected});
  final ValueChanged<String> onPresetSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 11),
      decoration: BoxDecoration(
        color: RikitColors.surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: RikitColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.palette_outlined,
            size: 14,
            color: RikitColors.primary,
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: 'Minimalist',
            underline: const SizedBox.shrink(),
            icon: const Icon(
              Icons.arrow_drop_down_rounded,
              size: 24,
              color: RikitColors.textMuted,
            ),
            style: const TextStyle(
              color: RikitColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            dropdownColor: RikitColors.surfaceRaised,
            items:
                [
                  'Minimalist',
                  'Sharp',
                  'Full Rounded',
                  'Compact',
                  'Spacious',
                ].map((preset) {
                  return DropdownMenuItem(value: preset, child: Text(preset));
                }).toList(),
            onChanged: (val) {
              if (val != null) {
                onPresetSelected(val);
              }
            },
          ),
        ],
      ),
    );
  }
}
