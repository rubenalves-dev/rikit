sealed class JsonFormattingResult {
  const JsonFormattingResult();
}

final class JsonFormattingSucceeded extends JsonFormattingResult {
  final String formattedJson;
  final int inputBytes;
  final int outputBytes;

  const JsonFormattingSucceeded({
    required this.formattedJson,
    required this.inputBytes,
    required this.outputBytes,
  });
}

final class JsonFormattingFailed extends JsonFormattingResult {
  final String message;
  final int? offset;

  const JsonFormattingFailed({required this.message, this.offset});
}

final class JsonInputRejected extends JsonFormattingResult {
  final String? reason;
  final int? maximumBytes;

  const JsonInputRejected({this.reason, this.maximumBytes});
}
