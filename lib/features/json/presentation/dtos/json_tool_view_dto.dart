enum JsonToolViewStatus { idle, working, succeeded, failed, rejected }

final class JsonToolViewDto {
  const JsonToolViewDto({
    required this.input,
    required this.output,
    required this.status,
    required this.indentSpaces,
    required this.sortObjectKeys,
    required this.normalizeNumbers,
    required this.normalizeStrings,
    required this.inputBytes,
    required this.outputBytes,
    this.message,
    this.errorOffset,
  });

  final String input;
  final String output;
  final JsonToolViewStatus status;
  final int indentSpaces;
  final bool sortObjectKeys;
  final bool normalizeNumbers;
  final bool normalizeStrings;
  final int inputBytes;
  final int outputBytes;
  final String? message;
  final int? errorOffset;

  bool get isWorking => status == JsonToolViewStatus.working;
  bool get canSubmit => input.trim().isNotEmpty && !isWorking;
  bool get hasOutput => output.isNotEmpty;

  factory JsonToolViewDto.initial() {
    return const JsonToolViewDto(
      input: '',
      output: '',
      status: JsonToolViewStatus.idle,
      indentSpaces: 2,
      sortObjectKeys: false,
      normalizeNumbers: false,
      normalizeStrings: true,
      inputBytes: 0,
      outputBytes: 0,
    );
  }

  JsonToolViewDto copyWith({
    String? input,
    String? output,
    JsonToolViewStatus? status,
    int? indentSpaces,
    bool? sortObjectKeys,
    bool? normalizeNumbers,
    bool? normalizeStrings,
    int? inputBytes,
    int? outputBytes,
    String? message,
    int? errorOffset,
    bool clearFeedback = false,
  }) {
    return JsonToolViewDto(
      input: input ?? this.input,
      output: output ?? this.output,
      status: status ?? this.status,
      indentSpaces: indentSpaces ?? this.indentSpaces,
      sortObjectKeys: sortObjectKeys ?? this.sortObjectKeys,
      normalizeNumbers: normalizeNumbers ?? this.normalizeNumbers,
      normalizeStrings: normalizeStrings ?? this.normalizeStrings,
      inputBytes: inputBytes ?? this.inputBytes,
      outputBytes: outputBytes ?? this.outputBytes,
      message: clearFeedback ? null : message ?? this.message,
      errorOffset: clearFeedback ? null : errorOffset ?? this.errorOffset,
    );
  }
}
