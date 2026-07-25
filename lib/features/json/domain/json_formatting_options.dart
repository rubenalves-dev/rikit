enum JsonIndent {
  twoSpaces('  ', '2 spaces'),
  fourSpaces('    ', '4 spaces');

  const JsonIndent(this.characters, this.label);

  final String characters;
  final String label;
}

final class JsonFormattingOptions {
  const JsonFormattingOptions({
    this.indent = JsonIndent.twoSpaces,
    this.sortObjectKeys = false,
    this.normalizeNumbers = false,
    this.normalizeStrings = true,
  });

  final JsonIndent indent;
  final bool sortObjectKeys;
  final bool normalizeNumbers;
  final bool normalizeStrings;
}
