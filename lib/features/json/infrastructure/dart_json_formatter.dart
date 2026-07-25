import 'dart:convert';

import 'package:rikit/features/json/domain/json_formatter.dart';
import 'package:rikit/features/json/domain/json_formatting_results.dart';

final class DartJsonFormatter implements JsonFormatter {
  @override
  format({required String input, required options}) {
    try {
      final dynamic decoded = jsonDecode(input);

      final normalized = options.sortObjectKeys
          ? _sortRecursively(decoded)
          : decoded;

      final formatted = JsonEncoder.withIndent(
        options.indent.characters,
      ).convert(normalized);

      return JsonFormattingSucceeded(
        formattedJson: formatted,
        inputBytes: utf8.encode(input).length,
        outputBytes: utf8.encode(formatted).length,
      );
    } on FormatException catch (error) {
      return JsonFormattingFailed(message: error.message, offset: error.offset);
    }
  }

  dynamic _sortRecursively(dynamic value) {
    return switch (value) {
      Map<String, dynamic>() => Map.fromEntries(
        value.entries
            .map((entry) => MapEntry(entry.key, _sortRecursively(entry.value)))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      ),

      List<dynamic>() => value.map(_sortRecursively).toList(),

      _ => value,
    };
  }
}
