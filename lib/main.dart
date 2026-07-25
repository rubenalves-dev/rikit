import 'package:flutter/widgets.dart';
import 'package:rikit/app/app/app_dependencies.dart';
import 'package:rikit/app/rikit_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RikitApp(dependencies: AppDependencies.create()));
}
