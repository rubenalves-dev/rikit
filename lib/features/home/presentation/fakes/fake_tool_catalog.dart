import 'package:flutter/material.dart';
import 'package:rikit/app/router/app_routes.dart';
import 'package:rikit/features/home/presentation/dtos/tool_card_dto.dart';

abstract final class FakeToolCatalog {
  static const tools = [
    ToolCardDto(
      name: 'JSON Formatter',
      description:
          'Format, validate, normalize, and recursively sort JSON safely.',
      route: AppRoutes.jsonFormatter,
      icon: Icons.data_object_rounded,
    ),
    ToolCardDto(
      name: 'Design System',
      description:
          'Create color palettes, global scales, typography settings, and export to CSS/JSON/YAML.',
      route: AppRoutes.designSystem,
      icon: Icons.palette_rounded,
    ),
  ];
}
