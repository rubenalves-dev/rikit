import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/app/app/app_dependencies.dart';
import 'package:rikit/features/json/presentation/dtos/json_tool_view_dto.dart';
import 'package:rikit/features/json/presentation/services/json_file_service.dart';

void main() {
  late AppDependencies dependencies;

  setUp(() => dependencies = AppDependencies.forTest());
  tearDown(() => dependencies.dispose());

  test('formats with defaults and publishes a successful readonly result', () {
    final controller = dependencies.jsonToolController;
    controller.updateInput('{"value":1.0}');

    controller.format();

    expect(controller.view.status, JsonToolViewStatus.succeeded);
    expect(controller.view.output, '{\n  "value": 1.0\n}');
    expect(controller.view.normalizeStrings, isTrue);
    expect(dependencies.notifications.messages, isEmpty);
    expect(
      dependencies.activityRepository
          .summary(
            from: DateTime.now().toUtc().subtract(const Duration(days: 1)),
            through: DateTime.now().toUtc(),
          )
          .successes,
      1,
    );
  });

  test('applies indentation, sorting, and normalization options', () {
    final controller = dependencies.jsonToolController;
    controller
      ..updateInput('{"b":1.0,"a":"\\u0061"}')
      ..setIndent(4)
      ..setSortObjectKeys(true)
      ..setNormalizeNumbers(true)
      ..setNormalizeStrings(false)
      ..format();

    expect(controller.view.output, '{\n    "a": "\\u0061",\n    "b": 1\n}');
  });

  test('reports a compact located duplicate-key notification', () {
    final controller = dependencies.jsonToolController;
    controller
      ..updateInput('{\n"a": 1,\n"a": 2\n}')
      ..format();

    expect(controller.view.status, JsonToolViewStatus.failed);
    final notification = dependencies.notifications.messages.single;
    expect(notification.title, 'Invalid JSON');
    expect(notification.body, contains('Duplicate object key "a"'));
    expect(notification.body, contains('line 3'));
  });

  test('moves output back to input without formatting again', () {
    final controller = dependencies.jsonToolController;
    controller
      ..updateInput('{"a":1}')
      ..format();
    final output = controller.view.output;

    controller.useOutputAsInput();

    expect(controller.view.input, output);
    expect(controller.view.output, isEmpty);
    expect(controller.view.status, JsonToolViewStatus.idle);
  });

  test('file decoder accepts UTF-8 BOM and rejects malformed UTF-8', () {
    const service = JsonFileService(maximumBytes: 100);
    final loaded = service.decode(
      bytes: Uint8List.fromList([0xEF, 0xBB, 0xBF, 0x7B, 0x7D]),
      name: 'data.json',
    );
    final rejected = service.decode(
      bytes: Uint8List.fromList([0xC3, 0x28]),
      name: 'data.json',
    );

    expect((loaded as JsonFileLoaded).content, '{}');
    expect(rejected, isA<JsonFileRejected>());
    expect((rejected as JsonFileRejected).message, contains('UTF-8'));
  });

  test('file decoder enforces the same input byte limit', () {
    const service = JsonFileService(maximumBytes: 2);

    final result = service.decode(
      bytes: Uint8List.fromList([1, 2, 3]),
      name: 'data.json',
    );

    expect(result, isA<JsonFileRejected>());
    expect((result as JsonFileRejected).message, contains('2-byte limit'));
  });
}
