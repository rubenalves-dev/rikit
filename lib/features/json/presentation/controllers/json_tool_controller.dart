import 'dart:async';
import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:rikit/features/activity/domain/activity_models.dart';
import 'package:rikit/features/activity/domain/activity_repository.dart';
import 'package:rikit/features/json/application/format_json.dart';
import 'package:rikit/features/json/domain/json_formatting_options.dart';
import 'package:rikit/features/json/domain/json_formatting_results.dart';
import 'package:rikit/features/json/presentation/dtos/json_tool_view_dto.dart';
import 'package:rikit/features/json/presentation/mappers/json_format_result_mapper.dart';
import 'package:rikit/features/json/presentation/services/json_file_service.dart';
import 'package:rikit/shared/logging/application/application_logger.dart';
import 'package:rikit/shared/logging/domain/log_entry.dart';
import 'package:rikit/shared/notifications/notification_controller.dart';

class JsonToolController extends ChangeNotifier {
  JsonToolController({
    required this.formatJson,
    required this.logger,
    required this.notifications,
    required this.activityRepository,
    this.mapper = const JsonFormatResultMapper(),
    this.fileService = const JsonFileService(),
  });

  final FormatJson formatJson;
  final ApplicationLogger logger;
  final NotificationController notifications;
  final ActivityRepository activityRepository;
  final JsonFormatResultMapper mapper;
  final JsonFileService fileService;

  JsonToolViewDto _view = JsonToolViewDto.initial();
  JsonToolViewDto get view => _view;

  void updateInput(String input) {
    _view = _view.copyWith(
      input: input,
      output: '',
      status: JsonToolViewStatus.idle,
      inputBytes: 0,
      outputBytes: 0,
      clearFeedback: true,
    );
    notifyListeners();
  }

  void setIndent(int spaces) {
    _view = _view.copyWith(indentSpaces: spaces);
    notifyListeners();
  }

  void setSortObjectKeys(bool value) {
    _view = _view.copyWith(sortObjectKeys: value);
    notifyListeners();
  }

  void setNormalizeNumbers(bool value) {
    _view = _view.copyWith(normalizeNumbers: value);
    notifyListeners();
  }

  void setNormalizeStrings(bool value) {
    _view = _view.copyWith(normalizeStrings: value);
    notifyListeners();
  }

  void format() {
    if (!_view.canSubmit) return;
    _view = _view.copyWith(status: JsonToolViewStatus.working);
    notifyListeners();
    final result = formatJson(
      input: _view.input,
      options: JsonFormattingOptions(
        indent: _view.indentSpaces == 4
            ? JsonIndent.fourSpaces
            : JsonIndent.twoSpaces,
        sortObjectKeys: _view.sortObjectKeys,
        normalizeNumbers: _view.normalizeNumbers,
        normalizeStrings: _view.normalizeStrings,
      ),
    );
    _view = mapper.map(result: result, currentView: _view);
    _recordResult(result);
    notifyListeners();
  }

  void useOutputAsInput() {
    if (!_view.hasOutput) return;
    _view = _view.copyWith(
      input: _view.output,
      output: '',
      status: JsonToolViewStatus.idle,
      inputBytes: 0,
      outputBytes: 0,
      clearFeedback: true,
    );
    notifyListeners();
  }

  Future<void> openFile() async => _applyFileResult(await fileService.open());

  Future<void> loadDroppedFile(XFile file) async =>
      _applyFileResult(await fileService.load(file));

  Future<void> _applyFileResult(JsonFileLoadResult result) async {
    switch (result) {
      case JsonFileLoaded(:final content, :final name):
        _view = _view.copyWith(
          input: content,
          output: '',
          sourceName: name,
          status: JsonToolViewStatus.idle,
          inputBytes: 0,
          outputBytes: 0,
          clearFeedback: true,
        );
        notifyListeners();
      case JsonFileRejected(:final message):
        notifications.show(
          severity: LogSeverity.error,
          title: 'Could not open file',
          body: message,
        );
        logger.record(
          severity: LogSeverity.warning,
          tool: 'JSON Formatter',
          eventName: 'json.file.rejected',
          message: 'A JSON file was rejected by the input policy.',
        );
      case JsonFileCancelled():
        break;
    }
  }

  Future<void> saveOutput() async {
    if (!_view.hasOutput) return;
    final source = _view.sourceName;
    final suggested = source == null
        ? 'formatted.json'
        : '${source.substring(0, source.length - 5)}.formatted.json';
    final saved = await fileService.save(
      content: _view.output,
      suggestedName: suggested,
    );
    if (saved) {
      notifications.show(
        severity: LogSeverity.information,
        title: 'File saved',
        body: 'Formatted JSON was written to the selected location.',
      );
    }
  }

  void confirmCopied() {
    notifications.show(
      severity: LogSeverity.information,
      title: 'Copied to clipboard',
      body: 'Formatted JSON is ready to paste.',
    );
  }

  void _recordResult(JsonFormattingResult result) {
    switch (result) {
      case JsonFormattingSucceeded(:final inputBytes, :final outputBytes):
        activityRepository.record(
          timestamp: DateTime.now().toUtc(),
          tool: 'JSON Formatter',
          outcome: ToolRunOutcome.succeeded,
          inputBytes: inputBytes,
          outputBytes: outputBytes,
        );
        logger.record(
          severity: LogSeverity.information,
          tool: 'JSON Formatter',
          eventName: 'json.format.succeeded',
          message: 'JSON formatting completed successfully.',
        );
      case JsonFormattingFailed(:final message, :final offset):
        activityRepository.record(
          timestamp: DateTime.now().toUtc(),
          tool: 'JSON Formatter',
          outcome: ToolRunOutcome.validationFailed,
          inputBytes: utf8.encode(_view.input).length,
          outputBytes: 0,
        );
        final location = _lineAndColumn(_view.input, offset);
        final body = message.startsWith('Duplicate object key')
            ? '${message.replaceFirst(RegExp(r'\.$'), '')}'
                  '${location == null ? '.' : ' at line ${location.$1}, column ${location.$2}.'}'
            : location == null
            ? 'The input is not valid JSON.'
            : 'Check line ${location.$1}, column ${location.$2}.';
        notifications.show(
          severity: LogSeverity.error,
          title: 'Invalid JSON',
          body: body,
        );
        logger.record(
          severity: LogSeverity.error,
          tool: 'JSON Formatter',
          eventName: 'json.format.failed',
          message: location == null
              ? 'JSON validation failed.'
              : 'JSON validation failed at line ${location.$1}, column ${location.$2}.',
        );
      case JsonInputRejected(:final reason, :final actualBytes):
        activityRepository.record(
          timestamp: DateTime.now().toUtc(),
          tool: 'JSON Formatter',
          outcome: ToolRunOutcome.policyRejected,
          inputBytes: actualBytes,
          outputBytes: 0,
        );
        notifications.show(
          severity: LogSeverity.error,
          title: 'Input rejected',
          body: reason,
        );
      case JsonOutputRejected(:final reason):
        activityRepository.record(
          timestamp: DateTime.now().toUtc(),
          tool: 'JSON Formatter',
          outcome: ToolRunOutcome.policyRejected,
          inputBytes: utf8.encode(_view.input).length,
          outputBytes: 0,
        );
        notifications.show(
          severity: LogSeverity.error,
          title: 'Output rejected',
          body: reason,
        );
    }
  }

  (int, int)? _lineAndColumn(String input, int? offset) {
    if (offset == null || offset < 0 || offset > input.length) return null;
    var line = 1;
    var column = 1;
    for (var index = 0; index < offset; index++) {
      if (input.codeUnitAt(index) == 0x0A) {
        line++;
        column = 1;
      } else {
        column++;
      }
    }
    return (line, column);
  }
}
