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
  final int length;

  const JsonFormattingFailed({
    required this.message,
    this.offset,
    this.length = 0,
  });
}

final class JsonInputRejected extends JsonFormattingResult {
  final String reason;
  final int maximumBytes;
  final int actualBytes;

  const JsonInputRejected({
    required this.reason,
    required this.maximumBytes,
    required this.actualBytes,
  });
}

final class JsonOutputRejected extends JsonFormattingResult {
  final String reason;
  final int maximumBytes;
  final int? actualBytes;

  const JsonOutputRejected({
    required this.reason,
    required this.maximumBytes,
    this.actualBytes,
  });
}
