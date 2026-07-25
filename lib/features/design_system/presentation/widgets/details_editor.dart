import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rikit/features/design_system/presentation/controllers/design_system_controller.dart';
import 'package:rikit/features/design_system/presentation/services/design_system_exporter.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class DetailsEditor extends StatefulWidget {
  const DetailsEditor({required this.controller, super.key});
  final DesignSystemController controller;

  @override
  State<DetailsEditor> createState() => _DetailsEditorState();
}

class _DetailsEditorState extends State<DetailsEditor> {
  final _nameController = TextEditingController(text: 'Rikit Design System');
  final _versionController = TextEditingController(text: '1.0.0');
  final _authorController = TextEditingController(text: 'Developer');
  final _descController = TextEditingController(
    text: 'Custom developer workspace token specifications.',
  );

  String selectedFormat = 'CSS Variables';
  final _exporter = const DesignSystemExporter();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _versionController.addListener(() => setState(() {}));
    _authorController.addListener(() => setState(() {}));
    _descController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    _authorController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _getSnippet() {
    final state = widget.controller.state;
    final name = _nameController.text;
    final version = _versionController.text;
    final author = _authorController.text;

    switch (selectedFormat) {
      case 'CSS Variables':
        return _exporter.exportToCSS(state, name);
      case 'JSON':
        return _exporter.exportToJSON(state);
      case 'YAML':
        return _exporter.exportToYAML(state, name);
      case 'Plain Text':
        return _exporter.exportToTXT(state, name, version, author);
      default:
        return '';
    }
  }

  Future<void> _saveToFile() async {
    try {
      final snippet = _getSnippet();
      final slug = _nameController.text.toLowerCase().replaceAll(
        RegExp(r'\s+'),
        '-',
      );
      final ext = selectedFormat == 'CSS Variables'
          ? 'css'
          : selectedFormat == 'JSON'
          ? 'json'
          : selectedFormat == 'YAML'
          ? 'yaml'
          : 'txt';

      final dir = Directory('design-system-exports');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final file = File('${dir.path}/$slug.$ext');
      await file.writeAsString(snippet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: RikitColors.primary,
            content: Text(
              'Successfully exported design tokens to: ${file.path}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Failed to save export file: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final snippet = _getSnippet();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Configuration input fields
        Expanded(
          flex: 5,
          child: Card(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Design System Metadata',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: RikitColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Design System Name',
                      hintText: 'e.g. Corporate Identity',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _versionController,
                          decoration: const InputDecoration(
                            labelText: 'Version',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _authorController,
                          decoration: const InputDecoration(
                            labelText: 'Author',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Export Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: RikitColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedFormat,
                    decoration: const InputDecoration(
                      labelText: 'Output Format',
                    ),
                    dropdownColor: RikitColors.surfaceRaised,
                    items: ['CSS Variables', 'JSON', 'YAML', 'Plain Text'].map((
                      format,
                    ) {
                      return DropdownMenuItem(
                        value: format,
                        child: Text(format),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedFormat = val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: snippet));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied snippet to clipboard!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Copy to Clipboard'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RikitColors.surfaceRaised,
                            foregroundColor: RikitColors.primary,
                            side: const BorderSide(color: RikitColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveToFile,
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: const Text('Export File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RikitColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Right: Snippet Code Preview Box
        Expanded(
          flex: 5,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Output Snippet Preview',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: RikitColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: RikitColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: RikitColors.border),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          snippet,
                          style: const TextStyle(
                            fontFamily: 'Monospace',
                            fontSize: 12,
                            color: RikitColors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
