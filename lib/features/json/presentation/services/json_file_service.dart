import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;

sealed class JsonFileLoadResult {
  const JsonFileLoadResult();
}

final class JsonFileLoaded extends JsonFileLoadResult {
  const JsonFileLoaded({required this.content, required this.name});
  final String content;
  final String name;
}

final class JsonFileCancelled extends JsonFileLoadResult {
  const JsonFileCancelled();
}

final class JsonFileRejected extends JsonFileLoadResult {
  const JsonFileRejected(this.message);
  final String message;
}

class JsonFileService {
  const JsonFileService({this.maximumBytes = 2 * 1024 * 1024});

  final int maximumBytes;

  static const _jsonType = XTypeGroup(
    label: 'JSON',
    extensions: ['json'],
    mimeTypes: ['application/json'],
  );

  Future<JsonFileLoadResult> open() async {
    final file = await openFile(acceptedTypeGroups: const [_jsonType]);
    return file == null ? const JsonFileCancelled() : load(file);
  }

  Future<JsonFileLoadResult> load(XFile file) async {
    if (path.extension(file.name).toLowerCase() != '.json') {
      return const JsonFileRejected('Choose a .json file.');
    }
    final bytes = await file.readAsBytes();
    return decode(bytes: bytes, name: file.name);
  }

  JsonFileLoadResult decode({required Uint8List bytes, required String name}) {
    if (bytes.length > maximumBytes) {
      return JsonFileRejected('File exceeds the $maximumBytes-byte limit.');
    }
    try {
      var content = const Utf8Decoder(allowMalformed: false).convert(bytes);
      if (content.startsWith('\uFEFF')) {
        content = content.substring(1);
      }
      return JsonFileLoaded(content: content, name: name);
    } on FormatException {
      return const JsonFileRejected('File must use valid UTF-8 encoding.');
    }
  }

  Future<bool> save({
    required String content,
    required String suggestedName,
  }) async {
    final location = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: const [_jsonType],
    );
    if (location == null) return false;
    await XFile.fromData(
      utf8.encode(content),
      mimeType: 'application/json',
      name: suggestedName,
    ).saveTo(location.path);
    return true;
  }
}
