import 'package:flutter/widgets.dart';
import 'package:rikit/app/app/app_dependencies.dart';
import 'package:rikit/app/rikit_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RikitApp(dependencies: await AppDependencies.create()));
}
