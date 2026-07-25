import 'package:flutter/material.dart';
import 'package:rikit/features/json/presentation/dtos/json_tool_view_dto.dart';

class JsonToolController extends ChangeNotifier {
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
}
