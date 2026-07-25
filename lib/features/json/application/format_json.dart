import 'package:rikit/features/json/domain/json_formatter.dart';
import 'package:rikit/features/json/domain/json_formatting_options.dart';
import 'package:rikit/features/json/domain/json_formatting_results.dart';
import 'package:rikit/features/json/domain/json_input_policy.dart';

class FormatJson {
  const FormatJson({
    required this.formatter,
    required this.inputPolicy,
    required this.maximumOutputBytes,
  });

  final JsonFormatter formatter;
  final JsonInputPolicy inputPolicy;
  final int maximumOutputBytes;

  JsonFormattingResult call({
    required String input,
    required JsonFormattingOptions options,
  }) {
    final decision = inputPolicy.evaluate(input);
    return switch (decision) {
      JsonInputAllowed() => formatter.format(
        input: input,
        options: options,
        maximumOutputBytes: maximumOutputBytes,
      ),
      JsonInputDenied(:final reason, :final actualBytes) => JsonInputRejected(
        reason: reason,
        maximumBytes: inputPolicy.maxInputBytes,
        actualBytes: actualBytes,
      ),
    };
  }
}
