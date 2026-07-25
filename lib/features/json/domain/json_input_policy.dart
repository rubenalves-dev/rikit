import 'dart:convert';

class JsonInputPolicy {
  final int maxInputBytes;

  const JsonInputPolicy({required this.maxInputBytes});

  JsonInputPolicyDecision evaluate(String input) {
    if (input.trim().isEmpty) {
      return const JsonInputDenied('JSON input cannot be empty.');
    }

    final bytes = utf8.encode(input).length;
    if (bytes > maxInputBytes) {
      return JsonInputDenied(
        'Input exceeds the $maxInputBytes-byte limit.',
        actualBytes: bytes,
      );
    }
    return JsonInputAllowed(inputBytes: bytes);
  }
}

sealed class JsonInputPolicyDecision {
  const JsonInputPolicyDecision();
}

final class JsonInputAllowed extends JsonInputPolicyDecision {
  const JsonInputAllowed({required this.inputBytes});

  final int inputBytes;
}

final class JsonInputDenied extends JsonInputPolicyDecision {
  const JsonInputDenied(this.reason, {this.actualBytes = 0});

  final String reason;
  final int actualBytes;
}
