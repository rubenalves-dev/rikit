import 'package:rikit/features/json/domain/json_formatting_results.dart';
import 'package:rikit/features/json/presentation/dtos/json_tool_view_dto.dart';

class JsonFormatResultMapper {
  const JsonFormatResultMapper();

  JsonToolViewDto map({
    required JsonFormattingResult result,
    required JsonToolViewDto currentView,
  }) {
    return switch (result) {
      JsonFormattingSucceeded(
        :final formattedJson,
        :final inputBytes,
        :final outputBytes,
      ) =>
        JsonToolViewDto(
          input: currentView.input,
          output: formattedJson,
          status: JsonToolViewStatus.succeeded,
          indentSpaces: currentView.indentSpaces,
          sortObjectKeys: currentView.sortObjectKeys,
          normalizeNumbers: currentView.normalizeNumbers,
          normalizeStrings: currentView.normalizeStrings,
          inputBytes: inputBytes,
          outputBytes: outputBytes,
        ),

      JsonFormattingFailed(:final message, :final offset) => JsonToolViewDto(
        input: currentView.input,
        output: '',
        status: JsonToolViewStatus.failed,
        indentSpaces: currentView.indentSpaces,
        sortObjectKeys: currentView.sortObjectKeys,
        normalizeNumbers: currentView.normalizeNumbers,
        normalizeStrings: currentView.normalizeStrings,
        inputBytes: currentView.inputBytes,
        outputBytes: 0,
        message: message,
        errorOffset: offset,
      ),

      JsonInputRejected(:final reason) => JsonToolViewDto(
        input: currentView.input,
        output: '',
        status: JsonToolViewStatus.rejected,
        indentSpaces: currentView.indentSpaces,
        sortObjectKeys: currentView.sortObjectKeys,
        normalizeNumbers: currentView.normalizeNumbers,
        normalizeStrings: currentView.normalizeStrings,
        inputBytes: currentView.inputBytes,
        outputBytes: 0,
        message: reason,
      ),

      JsonOutputRejected(:final reason) => JsonToolViewDto(
        input: currentView.input,
        output: '',
        status: JsonToolViewStatus.rejected,
        indentSpaces: currentView.indentSpaces,
        sortObjectKeys: currentView.sortObjectKeys,
        normalizeNumbers: currentView.normalizeNumbers,
        normalizeStrings: currentView.normalizeStrings,
        inputBytes: currentView.inputBytes,
        outputBytes: 0,
        message: reason,
      ),
    };
  }
}
