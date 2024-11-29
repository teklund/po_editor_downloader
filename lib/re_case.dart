class ReCase {
  ReCase(String text) {
    originalText = text;
    _words = _groupIntoWords(text);
  }

  late String originalText;
  late List<String> _words;

  final RegExp _upperAlphaRegex = RegExp('[A-Z]');
  final symbolSet = {' ', '.', '/', '_', r'\', '-'};

  List<String> _groupIntoWords(String text) {
    final sb = StringBuffer();
    final words = <String>[];
    final isAllCaps = text.toUpperCase() == text;

    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      final nextChar = i + 1 == text.length ? null : text[i + 1];

      if (symbolSet.contains(char)) {
        continue;
      }

      sb.write(char);

      final isEndOfWord =
          nextChar == null || (_upperAlphaRegex.hasMatch(nextChar) && !isAllCaps) || symbolSet.contains(nextChar);

      if (isEndOfWord) {
        words.add(sb.toString());
        sb.clear();
      }
    }

    return words;
  }

  String toCamelCase() {
    final words = _words.map(_upperCaseFirstLetter).toList();

    if (_words.isNotEmpty) {
      words[0] = words[0].toLowerCase();
    }

    return words.join();
  }

  String _upperCaseFirstLetter(String word) => '${word.substring(0, 1).toUpperCase()}'
      '${word.substring(1).toLowerCase()}';
}
