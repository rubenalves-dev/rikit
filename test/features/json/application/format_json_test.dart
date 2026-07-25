import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/features/json/application/format_json.dart';
import 'package:rikit/features/json/domain/json_formatter.dart';
import 'package:rikit/features/json/domain/json_formatting_options.dart';
import 'package:rikit/features/json/domain/json_formatting_results.dart';
import 'package:rikit/features/json/domain/json_input_policy.dart';

void main() {
  group('FormatJson', () {
    late _RecordingFormatter formatter;
    late FormatJson formatJson;

    setUp(() {
      formatter = _RecordingFormatter();
      formatJson = FormatJson(
        formatter: formatter,
        inputPolicy: const JsonInputPolicy(maxInputBytes: 8),
        maximumOutputBytes: 16,
      );
    });

    test('delegates allowed input and output limit to the formatter', () {
      const options = JsonFormattingOptions(sortObjectKeys: true);

      final result = formatJson(input: '{}', options: options);

      expect(result, isA<JsonFormattingSucceeded>());
      expect(formatter.input, '{}');
      expect(formatter.options, same(options));
      expect(formatter.maximumOutputBytes, 16);
    });

    test('rejects empty input without invoking the formatter', () {
      final result = formatJson(
        input: ' ',
        options: const JsonFormattingOptions(),
      );

      expect(result, isA<JsonInputRejected>());
      expect(formatter.input, isNull);
    });

    test('reports actual and maximum bytes for oversized input', () {
      final result = formatJson(
        input: '"1234567"',
        options: const JsonFormattingOptions(),
      );

      expect(result, isA<JsonInputRejected>());
      final rejection = result as JsonInputRejected;
      expect(rejection.actualBytes, 9);
      expect(rejection.maximumBytes, 8);
    });
  });
}

final class _RecordingFormatter implements JsonFormatter {
  String? input;
  JsonFormattingOptions? options;
  int? maximumOutputBytes;

  @override
  JsonFormattingResult format({
    required String input,
    required JsonFormattingOptions options,
    required int maximumOutputBytes,
  }) {
    this.input = input;
    this.options = options;
    this.maximumOutputBytes = maximumOutputBytes;
    return const JsonFormattingSucceeded(
      formattedJson: '{}',
      inputBytes: 2,
      outputBytes: 2,
    );
  }
}
