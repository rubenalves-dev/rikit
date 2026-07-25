enum JsonIndent {
  twoSpaces('  ', '2 spaces'),
  fourSpaces('    ', '4 spaces');

  const JsonIndent(this.characters, this.label);

  final String characters;
  final String label;
}
