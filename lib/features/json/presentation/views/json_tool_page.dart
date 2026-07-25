import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rikit/features/json/presentation/controllers/json_tool_controller.dart';
import 'package:rikit/shared/presentation/page_header.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class JsonToolPage extends StatefulWidget {
  const JsonToolPage({required this.controller, super.key});
  final JsonToolController controller;

  @override
  State<JsonToolPage> createState() => _JsonToolPageState();
}

class _JsonToolPageState extends State<JsonToolPage> {
  late final TextEditingController inputController;
  bool dragging = false;

  @override
  void initState() {
    super.initState();
    inputController = TextEditingController(text: widget.controller.view.input);
    widget.controller.addListener(_synchronizeInput);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_synchronizeInput);
    inputController.dispose();
    super.dispose();
  }

  void _synchronizeInput() {
    final input = widget.controller.view.input;
    if (inputController.text != input) {
      inputController.value = TextEditingValue(
        text: input,
        selection: TextSelection.collapsed(offset: input.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final view = widget.controller.view;
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.enter, meta: true):
                widget.controller.format,
            const SingleActivator(LogicalKeyboardKey.enter, control: true):
                widget.controller.format,
          },
          child: Focus(
            autofocus: true,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 30, 32, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeader(
                      eyebrow: 'Developer tools',
                      title: 'JSON Formatter',
                      description:
                          'Format and validate locally. Your JSON never leaves this device.',
                      trailing: _PrimaryButton(
                        enabled: view.canSubmit,
                        onPressed: widget.controller.format,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _OptionsBar(controller: widget.controller),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final stacked = constraints.maxWidth < 920;
                          final input = _EditorPanel(
                            key: const ValueKey('json-input-panel'),
                            title: 'Input',
                            subtitle: view.sourceName ?? 'UTF-8 JSON',
                            actions: [
                              _EditorAction(
                                tooltip: 'Open JSON file',
                                icon: Icons.folder_open_rounded,
                                onPressed: widget.controller.openFile,
                              ),
                            ],
                            child: DropTarget(
                              onDragEntered: (_) =>
                                  setState(() => dragging = true),
                              onDragExited: (_) =>
                                  setState(() => dragging = false),
                              onDragDone: (details) {
                                setState(() => dragging = false);
                                if (details.files.length == 1) {
                                  widget.controller.loadDroppedFile(
                                    details.files.single,
                                  );
                                }
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  TextField(
                                    key: const ValueKey('json-input'),
                                    controller: inputController,
                                    onChanged: widget.controller.updateInput,
                                    expands: true,
                                    minLines: null,
                                    maxLines: null,
                                    textAlignVertical: TextAlignVertical.top,
                                    style: _codeStyle,
                                    decoration: const InputDecoration(
                                      hintText:
                                          'Paste JSON, type here, or drop a .json file…',
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      filled: false,
                                      contentPadding: EdgeInsets.all(18),
                                    ),
                                  ),
                                  if (dragging) const _DropOverlay(),
                                ],
                              ),
                            ),
                          );
                          final output = _EditorPanel(
                            key: const ValueKey('json-output-panel'),
                            title: 'Output',
                            subtitle: view.hasOutput
                                ? '${view.outputBytes} bytes'
                                : 'Read only',
                            actions: [
                              _EditorAction(
                                tooltip: 'Copy output',
                                icon: Icons.copy_rounded,
                                enabled: view.hasOutput,
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: view.output),
                                  );
                                  widget.controller.confirmCopied();
                                },
                              ),
                              _EditorAction(
                                tooltip: 'Download output',
                                icon: Icons.download_rounded,
                                enabled: view.hasOutput,
                                onPressed: widget.controller.saveOutput,
                              ),
                              _EditorAction(
                                tooltip: 'Use output as input',
                                icon: Icons.keyboard_return_rounded,
                                enabled: view.hasOutput,
                                onPressed: widget.controller.useOutputAsInput,
                              ),
                            ],
                            child: view.hasOutput
                                ? SingleChildScrollView(
                                    padding: const EdgeInsets.all(18),
                                    child: SelectableText(
                                      view.output,
                                      key: const ValueKey('json-output'),
                                      style: _codeStyle,
                                    ),
                                  )
                                : const _EmptyOutput(),
                          );
                          return stacked
                              ? Column(
                                  children: [
                                    Expanded(child: input),
                                    const SizedBox(height: 14),
                                    Expanded(child: output),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(child: input),
                                    const SizedBox(width: 14),
                                    Expanded(child: output),
                                  ],
                                );
                        },
                      ),
                    ),
                    if (view.message != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        view.message!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: RikitColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

const _codeStyle = TextStyle(
  color: RikitColors.text,
  fontFamily: 'monospace',
  fontSize: 13,
  height: 1.55,
);

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.enabled, required this.onPressed});
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    key: const ValueKey('format-json'),
    onPressed: enabled ? onPressed : null,
    icon: const Icon(Icons.auto_fix_high_rounded, size: 17),
    label: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Format JSON'),
        SizedBox(width: 10),
        Text('⌘↵', style: TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    ),
  );
}

class _OptionsBar extends StatelessWidget {
  const _OptionsBar({required this.controller});
  final JsonToolController controller;

  @override
  Widget build(BuildContext context) {
    final view = controller.view;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: RikitColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RikitColors.borderSubtle),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'INDENT',
            style: TextStyle(
              color: RikitColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: .8,
            ),
          ),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 2, label: Text('2 spaces')),
              ButtonSegment(value: 4, label: Text('4 spaces')),
            ],
            selected: {view.indentSpaces},
            onSelectionChanged: (value) => controller.setIndent(value.single),
            showSelectedIcon: false,
          ),
          const SizedBox(width: 8),
          _OptionChip(
            label: 'Sort keys',
            selected: view.sortObjectKeys,
            onSelected: controller.setSortObjectKeys,
          ),
          _OptionChip(
            label: 'Normalize numbers',
            selected: view.normalizeNumbers,
            onSelected: controller.setNormalizeNumbers,
          ),
          _OptionChip(
            label: 'Normalize strings',
            selected: view.normalizeStrings,
            onSelected: controller.setNormalizeStrings,
          ),
        ],
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) => FilterChip(
    label: Text(label),
    selected: selected,
    onSelected: onSelected,
    showCheckmark: false,
  );
}

class _EditorPanel extends StatelessWidget {
  const _EditorPanel({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.child,
    super.key,
  });
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: RikitColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: RikitColors.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Container(
          height: 46,
          padding: const EdgeInsets.only(left: 15, right: 7),
          decoration: const BoxDecoration(
            color: RikitColors.surfaceRaised,
            border: Border(bottom: BorderSide(color: RikitColors.borderSubtle)),
          ),
          child: Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 9),
              Text(subtitle, style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              ...actions,
            ],
          ),
        ),
        Expanded(child: child),
      ],
    ),
  );
}

class _EditorAction extends StatelessWidget {
  const _EditorAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.enabled = true,
  });
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: enabled ? onPressed : null,
    icon: Icon(icon, size: 17),
  );
}

class _DropOverlay extends StatelessWidget {
  const _DropOverlay();

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('drop-overlay'),
    color: RikitColors.primary.withValues(alpha: .12),
    alignment: Alignment.center,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: RikitColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RikitColors.primary),
      ),
      child: const Text('Drop one .json file'),
    ),
  );
}

class _EmptyOutput extends StatelessWidget {
  const _EmptyOutput();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.arrow_outward_rounded,
          size: 25,
          color: RikitColors.textMuted,
        ),
        const SizedBox(height: 9),
        Text(
          'Formatted JSON appears here',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}
