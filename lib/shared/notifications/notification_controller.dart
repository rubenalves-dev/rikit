import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rikit/shared/logging/domain/log_entry.dart';
import 'package:rikit/shared/notifications/notification_message.dart';

final class NotificationController extends ChangeNotifier {
  NotificationController({this.dismissAfter = const Duration(seconds: 6)});

  final Duration dismissAfter;
  final List<NotificationMessage> _messages = [];
  final Map<int, Timer> _timers = {};
  var _nextId = 0;
  bool _expanded = false;

  List<NotificationMessage> get messages => List.unmodifiable(_messages);
  bool get expanded => _expanded;

  int show({
    required LogSeverity severity,
    required String title,
    required String body,
    NotificationAction? action,
    String? actionLabel,
  }) {
    final message = NotificationMessage(
      id: _nextId++,
      severity: severity,
      title: title,
      body: body,
      action: action,
      actionLabel: actionLabel,
    );
    _messages.insert(0, message);
    _schedule(message.id);
    notifyListeners();
    return message.id;
  }

  void clearAction(int id) {
    final index = _messages.indexWhere((message) => message.id == id);
    if (index < 0 || _messages[index].action == null) return;
    _messages[index] = _messages[index].copyWith(clearAction: true);
    notifyListeners();
  }

  void pause(int id) => _timers.remove(id)?.cancel();

  void resume(int id) {
    if (_messages.any((message) => message.id == id) && !_expanded) {
      _schedule(id);
    }
  }

  void remove(int id) {
    _timers.remove(id)?.cancel();
    _messages.removeWhere((message) => message.id == id);
    if (_messages.length <= 2) _expanded = false;
    notifyListeners();
  }

  void setExpanded(bool value) {
    _expanded = value;
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    if (!value) {
      for (final message in _messages) {
        _schedule(message.id);
      }
    }
    notifyListeners();
  }

  void _schedule(int id) {
    _timers.remove(id)?.cancel();
    _timers[id] = Timer(dismissAfter, () => remove(id));
  }

  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}
