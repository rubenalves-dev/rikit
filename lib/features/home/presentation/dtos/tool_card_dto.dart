import 'package:flutter/material.dart';

final class ToolCardDto {
  const ToolCardDto({
    required this.name,
    required this.description,
    required this.route,
    required this.icon,
  });

  final String name;
  final String description;
  final String route;
  final IconData icon;
}
