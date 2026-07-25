import 'package:flutter/material.dart';
import 'package:rikit/features/json/application/format_json.dart';
import 'package:rikit/shared/presentation/page_header.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class JsonToolPage extends StatelessWidget {
  const JsonToolPage({required this.formatJson, super.key});

  final FormatJson formatJson;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              eyebrow: 'Developer tools',
              title: 'JSON Formatter',
              description:
                  'Validate and format JSON without your data leaving this device.',
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Card(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          color: const Color(0x18FF4D5E),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.data_object_rounded,
                          color: RikitColors.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Formatter workspace is next',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'The parser is ready. The focused editor arrives in issue #6.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
