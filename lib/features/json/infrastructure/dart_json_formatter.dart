import 'dart:convert';

import 'package:rikit/features/json/domain/json_formatter.dart';
import 'package:rikit/features/json/domain/json_formatting_options.dart';
import 'package:rikit/features/json/domain/json_formatting_results.dart';

final class DartJsonFormatter implements JsonFormatter {
  @override
  JsonFormattingResult format({
    required String input,
    required JsonFormattingOptions options,
    required int maximumOutputBytes,
  }) {
    try {
      final node = _JsonParser(input).parse();
      final renderer = _JsonRenderer(
        options: options,
        maximumOutputBytes: maximumOutputBytes,
      );
      final formatted = renderer.render(node);
      return JsonFormattingSucceeded(
        formattedJson: formatted,
        inputBytes: utf8.encode(input).length,
        outputBytes: utf8.encode(formatted).length,
      );
    } on _OutputLimitExceeded catch (error) {
      return JsonOutputRejected(
        reason: options.normalizeNumbers
            ? 'Output is too large. Disable number normalization or reduce the input.'
            : 'Formatted output exceeds the byte limit.',
        maximumBytes: maximumOutputBytes,
        actualBytes: error.actualBytes,
      );
    } on FormatException catch (error) {
      return JsonFormattingFailed(
        message: error.message,
        offset: error.offset,
        length: _diagnosticLength(input, error),
      );
    }
  }

  int _diagnosticLength(String input, FormatException error) {
    final offset = error.offset;
    if (offset == null || offset < 0 || offset >= input.length) return 0;
    if (!error.message.startsWith('Duplicate object key') ||
        input.codeUnitAt(offset) != 0x22) {
      return 1;
    }
    var escaped = false;
    for (var index = offset + 1; index < input.length; index++) {
      final unit = input.codeUnitAt(index);
      if (unit == 0x22 && !escaped) return index - offset + 1;
      if (unit == 0x5C && !escaped) {
        escaped = true;
      } else {
        escaped = false;
      }
    }
    return 1;
  }
}

sealed class _JsonNode {
  const _JsonNode();
}

final class _JsonObject extends _JsonNode {
  const _JsonObject(this.entries);

  final List<_JsonEntry> entries;
}

final class _JsonEntry {
  const _JsonEntry(this.key, this.value);

  final _JsonString key;
  final _JsonNode value;
}

final class _JsonArray extends _JsonNode {
  const _JsonArray(this.values);

  final List<_JsonNode> values;
}

final class _JsonString extends _JsonNode {
  const _JsonString(this.raw, this.value);

  final String raw;
  final String value;
}

final class _JsonNumber extends _JsonNode {
  const _JsonNumber(this.raw);

  final String raw;
}

final class _JsonLiteral extends _JsonNode {
  const _JsonLiteral(this.raw);

  final String raw;
}

final class _JsonParser {
  _JsonParser(this.source);

  final String source;
  int _offset = 0;

  _JsonNode parse() {
    _skipWhitespace();
    final value = _parseValue();
    _skipWhitespace();
    if (_offset != source.length) {
      _fail('Unexpected content after the JSON value.');
    }
    return value;
  }

  _JsonNode _parseValue() {
    if (_offset >= source.length) {
      _fail('Expected a JSON value.');
    }
    return switch (source.codeUnitAt(_offset)) {
      0x7B => _parseObject(),
      0x5B => _parseArray(),
      0x22 => _parseString(),
      0x74 => _parseLiteral('true'),
      0x66 => _parseLiteral('false'),
      0x6E => _parseLiteral('null'),
      _ => _parseNumber(),
    };
  }

  _JsonObject _parseObject() {
    _offset++;
    _skipWhitespace();
    if (_consumeIf(0x7D)) {
      return const _JsonObject([]);
    }

    final entries = <_JsonEntry>[];
    final keys = <String>{};
    while (true) {
      if (!_isCurrent(0x22)) {
        _fail('Object keys must be JSON strings.');
      }
      final keyOffset = _offset;
      final key = _parseString();
      if (!keys.add(key.value)) {
        throw FormatException(
          'Duplicate object key "${key.value}".',
          source,
          keyOffset,
        );
      }
      _skipWhitespace();
      if (!_consumeIf(0x3A)) {
        _fail('Expected ":" after the object key.');
      }
      _skipWhitespace();
      entries.add(_JsonEntry(key, _parseValue()));
      _skipWhitespace();
      if (_consumeIf(0x7D)) {
        return _JsonObject(entries);
      }
      if (!_consumeIf(0x2C)) {
        _fail('Expected "," or "}" in the object.');
      }
      _skipWhitespace();
    }
  }

  _JsonArray _parseArray() {
    _offset++;
    _skipWhitespace();
    if (_consumeIf(0x5D)) {
      return const _JsonArray([]);
    }

    final values = <_JsonNode>[];
    while (true) {
      values.add(_parseValue());
      _skipWhitespace();
      if (_consumeIf(0x5D)) {
        return _JsonArray(values);
      }
      if (!_consumeIf(0x2C)) {
        _fail('Expected "," or "]" in the array.');
      }
      _skipWhitespace();
    }
  }

  _JsonString _parseString() {
    final start = _offset++;
    while (_offset < source.length) {
      final unit = source.codeUnitAt(_offset++);
      if (unit == 0x22) {
        final raw = source.substring(start, _offset);
        try {
          return _JsonString(raw, jsonDecode(raw) as String);
        } on FormatException catch (error) {
          throw FormatException(
            error.message,
            source,
            start + (error.offset ?? 0),
          );
        }
      }
      if (unit < 0x20) {
        _fail('Control characters must be escaped in JSON strings.');
      }
      if (unit == 0x5C) {
        if (_offset >= source.length) {
          _fail('Unterminated escape sequence.');
        }
        final escaped = source.codeUnitAt(_offset++);
        if (escaped == 0x75) {
          for (var count = 0; count < 4; count++) {
            if (_offset >= source.length ||
                !_isHex(source.codeUnitAt(_offset++))) {
              _fail('Invalid Unicode escape sequence.');
            }
          }
        } else if (!const {
          0x22,
          0x5C,
          0x2F,
          0x62,
          0x66,
          0x6E,
          0x72,
          0x74,
        }.contains(escaped)) {
          _fail('Invalid JSON escape sequence.');
        }
      }
    }
    throw FormatException('Unterminated JSON string.', source, start);
  }

  _JsonLiteral _parseLiteral(String literal) {
    final start = _offset;
    if (!source.startsWith(literal, _offset)) {
      _fail('Invalid JSON value.');
    }
    _offset += literal.length;
    return _JsonLiteral(source.substring(start, _offset));
  }

  _JsonNumber _parseNumber() {
    final start = _offset;
    _consumeIf(0x2D);
    if (_consumeIf(0x30)) {
      if (_offset < source.length && _isDigit(source.codeUnitAt(_offset))) {
        _fail('Leading zeros are not allowed in JSON numbers.');
      }
    } else {
      if (_offset >= source.length ||
          !_isOneToNine(source.codeUnitAt(_offset))) {
        _fail('Expected a JSON value.');
      }
      while (_offset < source.length && _isDigit(source.codeUnitAt(_offset))) {
        _offset++;
      }
    }
    if (_consumeIf(0x2E)) {
      if (_offset >= source.length || !_isDigit(source.codeUnitAt(_offset))) {
        _fail('A decimal point must be followed by digits.');
      }
      while (_offset < source.length && _isDigit(source.codeUnitAt(_offset))) {
        _offset++;
      }
    }
    if (_offset < source.length &&
        (source.codeUnitAt(_offset) == 0x65 ||
            source.codeUnitAt(_offset) == 0x45)) {
      _offset++;
      if (_offset < source.length &&
          (source.codeUnitAt(_offset) == 0x2B ||
              source.codeUnitAt(_offset) == 0x2D)) {
        _offset++;
      }
      if (_offset >= source.length || !_isDigit(source.codeUnitAt(_offset))) {
        _fail('An exponent must contain digits.');
      }
      while (_offset < source.length && _isDigit(source.codeUnitAt(_offset))) {
        _offset++;
      }
    }
    return _JsonNumber(source.substring(start, _offset));
  }

  void _skipWhitespace() {
    while (_offset < source.length &&
        const {0x20, 0x09, 0x0A, 0x0D}.contains(source.codeUnitAt(_offset))) {
      _offset++;
    }
  }

  bool _consumeIf(int unit) {
    if (_isCurrent(unit)) {
      _offset++;
      return true;
    }
    return false;
  }

  bool _isCurrent(int unit) =>
      _offset < source.length && source.codeUnitAt(_offset) == unit;

  Never _fail(String message) =>
      throw FormatException(message, source, _offset);

  static bool _isDigit(int unit) => unit >= 0x30 && unit <= 0x39;
  static bool _isOneToNine(int unit) => unit >= 0x31 && unit <= 0x39;
  static bool _isHex(int unit) =>
      _isDigit(unit) ||
      (unit >= 0x41 && unit <= 0x46) ||
      (unit >= 0x61 && unit <= 0x66);
}

final class _JsonRenderer {
  _JsonRenderer({required this.options, required this.maximumOutputBytes});

  final JsonFormattingOptions options;
  final int maximumOutputBytes;
  final StringBuffer _buffer = StringBuffer();
  int _bytes = 0;

  String render(_JsonNode node) {
    _writeNode(node, 0);
    return _buffer.toString();
  }

  void _writeNode(_JsonNode node, int depth) {
    switch (node) {
      case _JsonObject():
        _writeObject(node, depth);
      case _JsonArray():
        _writeArray(node, depth);
      case _JsonString():
        _write(options.normalizeStrings ? jsonEncode(node.value) : node.raw);
      case _JsonNumber():
        _write(
          options.normalizeNumbers
              ? _normalizeNumber(node.raw, maximumOutputBytes - _bytes)
              : node.raw,
        );
      case _JsonLiteral():
        _write(node.raw);
    }
  }

  void _writeObject(_JsonObject object, int depth) {
    if (object.entries.isEmpty) {
      _write('{}');
      return;
    }
    final entries = [...object.entries];
    if (options.sortObjectKeys) {
      entries.sort(
        (left, right) => _compareKeys(left.key.value, right.key.value),
      );
    }
    _write('{\n');
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      _write(options.indent.characters * (depth + 1));
      _write(
        options.normalizeStrings ? jsonEncode(entry.key.value) : entry.key.raw,
      );
      _write(': ');
      _writeNode(entry.value, depth + 1);
      _write(index == entries.length - 1 ? '\n' : ',\n');
    }
    _write(options.indent.characters * depth);
    _write('}');
  }

  void _writeArray(_JsonArray array, int depth) {
    if (array.values.isEmpty) {
      _write('[]');
      return;
    }
    _write('[\n');
    for (var index = 0; index < array.values.length; index++) {
      _write(options.indent.characters * (depth + 1));
      _writeNode(array.values[index], depth + 1);
      _write(index == array.values.length - 1 ? '\n' : ',\n');
    }
    _write(options.indent.characters * depth);
    _write(']');
  }

  void _write(String value) {
    final newBytes = utf8.encode(value).length;
    _bytes += newBytes;
    if (_bytes > maximumOutputBytes) {
      throw _OutputLimitExceeded(_bytes);
    }
    _buffer.write(value);
  }
}

final class _OutputLimitExceeded implements Exception {
  const _OutputLimitExceeded(this.actualBytes);

  final int actualBytes;
}

final RegExp _numberPattern = RegExp(
  r'^-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?$',
);

String _normalizeNumber(String raw, int remainingBytes) {
  final match = RegExp(
    r'^(-?)(\d+)(?:\.(\d+))?(?:[eE]([+-]?\d+))?$',
  ).firstMatch(raw)!;
  final negative = match.group(1) == '-';
  final integer = match.group(2)!;
  final fraction = match.group(3) ?? '';
  final exponent = BigInt.parse(match.group(4) ?? '0');
  var digits = '$integer$fraction';
  final firstNonZero = digits.indexOf(RegExp('[1-9]'));
  if (firstNonZero == -1) {
    return '0';
  }
  digits = digits.substring(firstNonZero);
  final decimalPosition = BigInt.from(integer.length - firstNonZero) + exponent;
  final trailingZeros = decimalPosition - BigInt.from(digits.length);
  final estimatedLength = decimalPosition <= BigInt.zero
      ? BigInt.from((negative ? 1 : 0) + 2 + digits.length) - decimalPosition
      : BigInt.from((negative ? 1 : 0) + digits.length) +
            (trailingZeros > BigInt.zero ? trailingZeros : BigInt.zero);
  if (estimatedLength > BigInt.from(remainingBytes)) {
    throw _OutputLimitExceeded(estimatedLength.toInt());
  }

  String normalized;
  if (decimalPosition <= BigInt.zero) {
    normalized = '0.${'0' * (-decimalPosition).toInt()}$digits';
  } else if (decimalPosition >= BigInt.from(digits.length)) {
    normalized =
        '$digits${'0' * (decimalPosition - BigInt.from(digits.length)).toInt()}';
  } else {
    final split = decimalPosition.toInt();
    normalized = '${digits.substring(0, split)}.${digits.substring(split)}';
  }
  if (normalized.contains('.')) {
    normalized = normalized.replaceFirst(RegExp(r'0+$'), '');
    normalized = normalized.replaceFirst(RegExp(r'\.$'), '');
  }
  return negative ? '-$normalized' : normalized;
}

int _compareKeys(String left, String right) {
  if (_numberPattern.hasMatch(left) && _numberPattern.hasMatch(right)) {
    return _compareNumericKeys(left, right);
  }
  final leftRunes = left.runes.toList();
  final rightRunes = right.runes.toList();
  var leftIndex = 0;
  var rightIndex = 0;
  while (leftIndex < leftRunes.length && rightIndex < rightRunes.length) {
    final leftRune = leftRunes[leftIndex];
    final rightRune = rightRunes[rightIndex];
    final leftDigit = leftRune >= 0x30 && leftRune <= 0x39;
    final rightDigit = rightRune >= 0x30 && rightRune <= 0x39;
    if (leftDigit && rightDigit) {
      final leftStart = leftIndex;
      final rightStart = rightIndex;
      while (leftIndex < leftRunes.length &&
          leftRunes[leftIndex] >= 0x30 &&
          leftRunes[leftIndex] <= 0x39) {
        leftIndex++;
      }
      while (rightIndex < rightRunes.length &&
          rightRunes[rightIndex] >= 0x30 &&
          rightRunes[rightIndex] <= 0x39) {
        rightIndex++;
      }
      final leftDigits = String.fromCharCodes(
        leftRunes.sublist(leftStart, leftIndex),
      );
      final rightDigits = String.fromCharCodes(
        rightRunes.sublist(rightStart, rightIndex),
      );
      final numberComparison = BigInt.parse(
        leftDigits,
      ).compareTo(BigInt.parse(rightDigits));
      if (numberComparison != 0) {
        return numberComparison;
      }
      final lengthComparison = leftDigits.length.compareTo(rightDigits.length);
      if (lengthComparison != 0) {
        return lengthComparison;
      }
      continue;
    }
    final categoryComparison = _runeCategory(
      leftRune,
    ).compareTo(_runeCategory(rightRune));
    if (categoryComparison != 0) {
      return categoryComparison;
    }
    final runeComparison = leftRune.compareTo(rightRune);
    if (runeComparison != 0) {
      return runeComparison;
    }
    leftIndex++;
    rightIndex++;
  }
  return leftRunes.length.compareTo(rightRunes.length);
}

int _runeCategory(int rune) {
  final character = String.fromCharCode(rune);
  if (rune >= 0x30 && rune <= 0x39) {
    return 3;
  }
  if (character.toLowerCase() == character.toUpperCase()) {
    return 0;
  }
  return character == character.toLowerCase() ? 1 : 2;
}

int _compareNumericKeys(String left, String right) {
  final leftNumber = _ComparableDecimal.parse(left);
  final rightNumber = _ComparableDecimal.parse(right);
  if (leftNumber.negative != rightNumber.negative) {
    return leftNumber.negative ? -1 : 1;
  }
  var comparison = leftNumber.decimalPosition.compareTo(
    rightNumber.decimalPosition,
  );
  if (comparison == 0) {
    final length = leftNumber.digits.length > rightNumber.digits.length
        ? leftNumber.digits.length
        : rightNumber.digits.length;
    for (var index = 0; index < length; index++) {
      final leftDigit = index < leftNumber.digits.length
          ? leftNumber.digits.codeUnitAt(index)
          : 0x30;
      final rightDigit = index < rightNumber.digits.length
          ? rightNumber.digits.codeUnitAt(index)
          : 0x30;
      comparison = leftDigit.compareTo(rightDigit);
      if (comparison != 0) {
        break;
      }
    }
  }
  return leftNumber.negative ? -comparison : comparison;
}

final class _ComparableDecimal {
  const _ComparableDecimal({
    required this.negative,
    required this.digits,
    required this.decimalPosition,
  });

  factory _ComparableDecimal.parse(String raw) {
    final match = RegExp(
      r'^(-?)(\d+)(?:\.(\d+))?(?:[eE]([+-]?\d+))?$',
    ).firstMatch(raw)!;
    final integer = match.group(2)!;
    final combined = '$integer${match.group(3) ?? ''}';
    final firstNonZero = combined.indexOf(RegExp('[1-9]'));
    if (firstNonZero == -1) {
      return _ComparableDecimal(
        negative: false,
        digits: '0',
        decimalPosition: BigInt.zero,
      );
    }
    return _ComparableDecimal(
      negative: match.group(1) == '-',
      digits: combined.substring(firstNonZero),
      decimalPosition:
          BigInt.from(integer.length - firstNonZero) +
          BigInt.parse(match.group(4) ?? '0'),
    );
  }

  final bool negative;
  final String digits;
  final BigInt decimalPosition;
}
