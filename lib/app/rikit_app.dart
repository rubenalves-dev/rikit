import 'package:flutter/material.dart';
import 'package:rikit/app/app/app_dependencies.dart';
import 'package:rikit/app/router/app_router.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class RikitApp extends StatefulWidget {
  const RikitApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  State<RikitApp> createState() => _RikitAppState();
}

class _RikitAppState extends State<RikitApp> {
  late final router = createAppRouter(widget.dependencies);

  @override
  void dispose() {
    router.dispose();
    widget.dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rikit',
      debugShowCheckedModeBanner: false,
      theme: RikitTheme.dark(),
      routerConfig: router,
    );
  }
}
