abstract interface class JsonFormatter {
  JsonFormattingResult format({
    required String input,
    required JsonFormattingOptions options,
  });
}
