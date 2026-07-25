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
      return JsonInputDenied('Input exceeds the $maxInputBytes-byte limit.');
    }
    return const JsonInputAllowed(inputBytes: bytes);
  }
}
