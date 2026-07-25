import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/features/json/domain/json_formatting_options.dart';
import 'package:rikit/features/json/domain/json_formatting_results.dart';
import 'package:rikit/features/json/infrastructure/dart_json_formatter.dart';

void main() {
  group('DartJsonFormatter', () {
    final formatter = DartJsonFormatter();

    JsonFormattingResult format(
      String input, {
      JsonFormattingOptions options = const JsonFormattingOptions(),
      int maximumOutputBytes = 1024,
    }) {
      return formatter.format(
        input: input,
        options: options,
        maximumOutputBytes: maximumOutputBytes,
      );
    }

    test('formats every valid primitive root value', () {
      for (final input in ['null', 'true', 'false', '42', '"hello"']) {
        final result = format(input);

        expect(result, isA<JsonFormattingSucceeded>(), reason: input);
        expect(
          (result as JsonFormattingSucceeded).formattedJson,
          input,
          reason: input,
        );
      }
    });

    test('formats nested objects and arrays with selected indentation', () {
      final result = format(
        '{"items":[{"ok":true},null]}',
        options: const JsonFormattingOptions(indent: JsonIndent.fourSpaces),
      );

      expect(
        (result as JsonFormattingSucceeded).formattedJson,
        '{\n'
        '    "items": [\n'
        '        {\n'
        '            "ok": true\n'
        '        },\n'
        '        null\n'
        '    ]\n'
        '}',
      );
    });

    test('rejects duplicate decoded keys at every object level', () {
      for (final input in ['{"a":1,"a":2}', '{"nested":{"a":1,"\\u0061":2}}']) {
        final result = format(input);

        expect(result, isA<JsonFormattingFailed>());
        expect(
          (result as JsonFormattingFailed).message,
          contains('Duplicate object key "a"'),
        );
        expect(result.offset, isNotNull);
      }
    });

    test('preserves exact number spelling by default', () {
      final result = format('[1.0,-0,1e3,123456789012345678901234567890]');

      expect(
        (result as JsonFormattingSucceeded).formattedJson,
        '[\n'
        '  1.0,\n'
        '  -0,\n'
        '  1e3,\n'
        '  123456789012345678901234567890\n'
        ']',
      );
    });

    test('normalizes numbers without losing value or precision', () {
      final result = format(
        '[1.0,-0,1.2300,1e3,1.25e-3,123456789012345678901234567890]',
        options: const JsonFormattingOptions(normalizeNumbers: true),
      );

      expect(
        (result as JsonFormattingSucceeded).formattedJson,
        '[\n'
        '  1,\n'
        '  0,\n'
        '  1.23,\n'
        '  1000,\n'
        '  0.00125,\n'
        '  123456789012345678901234567890\n'
        ']',
      );
    });

    test('normalizes string keys and values by default', () {
      final result = format('{"\\u0061":"\\/"}');

      expect(
        (result as JsonFormattingSucceeded).formattedJson,
        '{\n  "a": "/"\n}',
      );
    });

    test('can preserve exact string tokens for keys and values', () {
      final result = format(
        '{"\\u0061":"\\/"}',
        options: const JsonFormattingOptions(normalizeStrings: false),
      );

      expect(
        (result as JsonFormattingSucceeded).formattedJson,
        '{\n  "\\u0061": "\\/"\n}',
      );
    });

    test('recursively sorts keys with category and natural ordering', () {
      final result = format(
        '{"10":0,"2":0,"A":0,"a":0,"_":0,'
        '"nested":{"item10":0,"item2":0},'
        '"array":[{"b":0,"a":0}]}',
        options: const JsonFormattingOptions(sortObjectKeys: true),
      );
      final output = (result as JsonFormattingSucceeded).formattedJson;

      expect(output.indexOf('"_"'), lessThan(output.indexOf('"a"')));
      expect(output.indexOf('"a"'), lessThan(output.indexOf('"A"')));
      expect(output.indexOf('"2"'), lessThan(output.indexOf('"10"')));
      expect(output.indexOf('"item2"'), lessThan(output.indexOf('"item10"')));
      expect(output.lastIndexOf('"a"'), lessThan(output.lastIndexOf('"b"')));
    });

    test('returns a located failure for malformed JSON', () {
      final result = format('{\n  "a":\n}');

      expect(result, isA<JsonFormattingFailed>());
      expect((result as JsonFormattingFailed).offset, isNotNull);
      expect(result.message, isNotEmpty);
    });

    test('rejects formatted output beyond the byte limit', () {
      final result = format(
        '1e1000',
        options: const JsonFormattingOptions(normalizeNumbers: true),
        maximumOutputBytes: 100,
      );

      expect(result, isA<JsonOutputRejected>());
      expect((result as JsonOutputRejected).maximumBytes, 100);
    });
  });
}
