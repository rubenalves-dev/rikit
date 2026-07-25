import 'package:rikit/features/json/domain/json_formatter.dart';
import 'package:rikit/features/json/domain/json_formatting_results.dart';
import 'package:rikit/features/json/domain/json_input_policy.dart';

class FormatJson {
  final JsonFormatter _formatter;
  final JsonInputPolicy _inputPolicy;

  const FormatJson({required this._formatter, required this._inputPolicy});

  JsonFormattingResult call({
    required String input,
    required JsonFormattingOptions options,
  }) {
    final decision = _inputPolicy.evaluate(input);
    return switch (decision) {
      JsonInputAllowed() => _formatter.format(input: input, options: options),
      JsonInputDenied(:final reason) => JsonInputRejected(reason: reason, maximumBytes: _inputPolicy.maxInputBytes),
    }
  }
}
