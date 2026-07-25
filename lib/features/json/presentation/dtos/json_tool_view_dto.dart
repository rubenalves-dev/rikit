class JsonToolViewDto {
  const JsonToolViewDto({
    required this.input,
    required this.output,
    required this.status,
    required this.indentSpaces,
    required this.sortObjectKeys,
    required this.inputBytes,
    required this.outputBytes,
    this.message,
    this.errorOffset,
  });

  bool get isWorking => stattus == JsonToolViewStatus.working;
  bool get canSubmit => input.trim().isNotEmpty && !isWorking;
  bool get hasOutput => output.isNotEmpty;

  factory JsonToolViewDto.initial() {
    return const JsonToolViewDto(
      input: '',
      output: '',
      status: JsonToolViewStatus.idle,
      indentSpaces: 2,
      sortObjectKeys: false,
      inputBytes: 0,
      outputBytes: 0,
    );
  }
}
