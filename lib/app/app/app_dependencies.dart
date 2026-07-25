import 'package:rikit/features/json/application/format_json.dart';
import 'package:rikit/features/json/domain/json_formatter.dart';
import 'package:rikit/features/json/domain/json_input_policy.dart';
import 'package:rikit/features/json/infrastructure/dart_json_formatter.dart';

class AppDependencies {
  final JsonFormatter jsonFormatter;
  final FormatJson formatJson;

  const AppDependencies._({
    required this.jsonFormatter,
    required this.formatJson,
  });

  factory AppDependencies.create() {
    final JsonFormatter jsonFormatter = DartJsonFormatter();

    final FormatJson formatJson = FormatJson(
      formatter: jsonFormatter,
      inputPolicy: const JsonInputPolicy(maxInputBytes: 2 * 1024 * 1024),
    );

    return AppDependencies._(
      jsonFormatter: jsonFormatter,
      formatJson: formatJson,
    );
  }
}
