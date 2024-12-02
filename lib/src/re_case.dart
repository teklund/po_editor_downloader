/// A utility class for converting text between different casing styles,
/// such as camel case, snake case, etc.
class ReCase {
  /// Creates a new `ReCase` instance with the given `originalText`.
  ///
  /// The `originalText` is the text that will be converted.
  ReCase(this.originalText) {
    _words = _groupIntoWords(originalText);
  }

  /// The original text that was passed to the constructor.
  final String originalText;

  /// A list of words extracted from the original text.
  late List<String> _words;

  final RegExp _upperAlphaRegex = RegExp('[A-Z]');
  final _symbolSet = {' ', '.', '/', '_', r'\', '-'};

  /// Groups the characters in the given `text` into words.
  ///
  /// Words are separated by spaces, symbols, or uppercase letters
  /// (unless the entire text is in uppercase).
  List<String> _groupIntoWords(String text) {
    final sb = StringBuffer();
    final words = <String>[];
    final isAllCaps = text.toUpperCase() == text;

    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      final nextChar = i + 1 == text.length ? null : text[i + 1];

      if (_symbolSet.contains(char)) {
        continue;
      }

      sb.write(char);

      final isEndOfWord = nextChar == null ||
          (_upperAlphaRegex.hasMatch(nextChar) && !isAllCaps) ||
          _symbolSet.contains(nextChar);

      if (isEndOfWord) {
        words.add(sb.toString());
        sb.clear();
      }
    }

    return words;
  }

  /// Converts the original text to camel case.
  ///
  /// For example, `'hello world'` would be converted to `'helloWorld'`.
  String toCamelCase() {
    final words = _words.map(_upperCaseFirstLetter).toList();

    if (_words.isNotEmpty) {
      words[0] = words[0].toLowerCase();
    }

    return words.join();
  }

  /// Converts the first letter of the given `word` to uppercase and the
  /// remaining letters to lowercase.
  ///
  /// For example, `'hello'` would be converted to `'Hello'`.
  String _upperCaseFirstLetter(String word) =>
      '${word.substring(0, 1).toUpperCase()}'
      '${word.substring(1).toLowerCase()}';
}
