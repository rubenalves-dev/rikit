import 'package:rikit/features/json/domain/json_formatting_options.dart';
import 'package:rikit/features/json/domain/json_formatting_results.dart';

abstract interface class JsonFormatter {
  JsonFormattingResult format({
    required String input,
    required JsonFormattingOptions options,
    required int maximumOutputBytes,
  });
}
