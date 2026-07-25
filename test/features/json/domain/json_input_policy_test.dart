import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/features/json/domain/json_input_policy.dart';

void main() {
  group('JsonInputPolicy', () {
    const policy = JsonInputPolicy(maxInputBytes: 5);

    test('rejects empty and whitespace-only input', () {
      for (final input in ['', '  \n\t']) {
        final decision = policy.evaluate(input);
        expect(decision, isA<JsonInputDenied>());
        expect(
          (decision as JsonInputDenied).reason,
          'JSON input cannot be empty.',
        );
      }
    });

    test('allows input at the UTF-8 byte limit', () {
      final decision = policy.evaluate('"é"');

      expect(decision, isA<JsonInputAllowed>());
      expect((decision as JsonInputAllowed).inputBytes, 4);
    });

    test('rejects input beyond the UTF-8 byte limit', () {
      final decision = policy.evaluate('"éé"');

      expect(decision, isA<JsonInputDenied>());
      expect((decision as JsonInputDenied).actualBytes, 6);
    });
  });
}
