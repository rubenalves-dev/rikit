import 'package:flutter/material.dart';
import 'package:rikit/shared/presentation/page_header.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    required this.title,
    required this.description,
    required this.icon,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              eyebrow: 'Rikit',
              title: title,
              description: description,
            ),
            const Spacer(),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: RikitColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: RikitColors.border),
                ),
                child: Icon(icon, color: RikitColors.primary, size: 36),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
