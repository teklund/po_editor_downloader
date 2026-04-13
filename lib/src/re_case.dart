import 'package:po_editor_downloader/src/naming_convention.dart';

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
  final RegExp _alphanumericRegex = RegExp('[a-zA-Z0-9]');

  /// Groups the characters in the given `text` into words.
  ///
  /// Words are separated by any non-alphanumeric characters or uppercase
  /// letters (unless the entire text is in uppercase).
  /// Non-alphanumeric characters are stripped from the output.
  List<String> _groupIntoWords(String text) {
    final sb = StringBuffer();
    final words = <String>[];
    final isAllCaps = text.toUpperCase() == text;

    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      final nextChar = i + 1 == text.length ? null : text[i + 1];

      if (!_alphanumericRegex.hasMatch(char)) {
        continue;
      }

      sb.write(char);

      final isEndOfWord = nextChar == null ||
          (_upperAlphaRegex.hasMatch(nextChar) && !isAllCaps) ||
          !_alphanumericRegex.hasMatch(nextChar);

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

  /// Converts the original text to PascalCase (upper camel case).
  ///
  /// For example, `'hello world'` would be converted to `'HelloWorld'`.
  String toPascalCase() => _words.map(_upperCaseFirstLetter).join();

  /// Converts the original text to snake_case.
  ///
  /// For example, `'hello world'` would be converted to `'hello_world'`.
  String toSnakeCase() => _words.map((w) => w.toLowerCase()).join('_');

  /// Converts the original text to CONSTANT_CASE (screaming snake case).
  ///
  /// For example, `'hello world'` would be converted to `'HELLO_WORLD'`.
  String toConstantCase() => _words.map((w) => w.toUpperCase()).join('_');

  /// Converts the original text to kebab-case (dash case).
  ///
  /// For example, `'hello world'` would be converted to `'hello-world'`.
  String toKebabCase() => _words.map((w) => w.toLowerCase()).join('-');

  /// Converts the original text to dot.case.
  ///
  /// For example, `'hello world'` would be converted to `'hello.world'`.
  String toDotCase() => _words.map((w) => w.toLowerCase()).join('.');

  /// Converts the original text to Title Case.
  ///
  /// For example, `'hello world'` would be converted to `'Hello World'`.
  String toTitleCase() => _words.map(_upperCaseFirstLetter).join(' ');

  /// Converts the original text to path/case.
  ///
  /// For example, `'hello world'` would be converted to `'hello/world'`.
  String toPathCase() => _words.map((w) => w.toLowerCase()).join('/');

  /// Converts the original text to the specified [NamingConvention].
  String convertTo(NamingConvention convention) {
    switch (convention) {
      case NamingConvention.camelCase:
        return toCamelCase();
      case NamingConvention.pascalCase:
        return toPascalCase();
      case NamingConvention.snakeCase:
        return toSnakeCase();
      case NamingConvention.constantCase:
        return toConstantCase();
      case NamingConvention.kebabCase:
        return toKebabCase();
      case NamingConvention.dotCase:
        return toDotCase();
      case NamingConvention.titleCase:
        return toTitleCase();
      case NamingConvention.pathCase:
        return toPathCase();
    }
  }

  /// Detects the [NamingConvention] of the [originalText].
  ///
  /// Returns `null` if the text is empty or cannot be classified
  /// (e.g. a single word with no casing cues).
  ///
  /// Detection rules (evaluated in order):
  /// - Contains `_` and is all uppercase → [NamingConvention.constantCase]
  /// - Contains `_` and is all lowercase → [NamingConvention.snakeCase]
  /// - Contains `-` and is all lowercase → [NamingConvention.kebabCase]
  /// - Contains `.` → [NamingConvention.dotCase]
  /// - Contains `/` → [NamingConvention.pathCase]
  /// - Contains ` ` and each word is capitalized → [NamingConvention.titleCase]
  /// - Starts with uppercase and has no separators → [NamingConvention.pascalCase]
  /// - Starts with lowercase and has internal uppercase → [NamingConvention.camelCase]
  /// - Single lowercase word → [NamingConvention.camelCase]
  NamingConvention? detectConvention() {
    if (originalText.isEmpty) return null;

    final text = originalText.trim();
    if (text.isEmpty) return null;

    final hasUnderscore = text.contains('_');
    final hasDash = text.contains('-');
    final hasDot = text.contains('.');
    final hasSlash = text.contains('/');
    final hasSpace = text.contains(' ');
    final isAllUpper = text == text.toUpperCase() && text != text.toLowerCase();
    final isAllLower = text == text.toLowerCase();

    // Separator-based detection (most reliable)
    if (hasUnderscore && isAllUpper) return NamingConvention.constantCase;
    if (hasUnderscore && isAllLower) return NamingConvention.snakeCase;
    if (hasDash && isAllLower) return NamingConvention.kebabCase;
    if (hasDot && isAllLower) return NamingConvention.dotCase;
    if (hasSlash && isAllLower) return NamingConvention.pathCase;

    if (hasSpace) {
      final words = text.split(RegExp(r'\s+'));
      final isTitleCase = words.every(
        (w) =>
            w.isNotEmpty &&
            w[0] == w[0].toUpperCase() &&
            w.substring(1) == w.substring(1).toLowerCase(),
      );
      if (isTitleCase) return NamingConvention.titleCase;
    }

    // No separators — determine by casing
    final hasUpperCase = _upperAlphaRegex.hasMatch(text);
    if (hasUpperCase &&
        text[0] == text[0].toUpperCase() &&
        text[0] != text[0].toLowerCase()) {
      return NamingConvention.pascalCase;
    }
    if (text[0] == text[0].toLowerCase()) {
      return NamingConvention.camelCase;
    }

    return null;
  }

  /// Converts the first letter of the given `word` to uppercase and the
  /// remaining letters to lowercase.
  ///
  /// For example, `'hello'` would be converted to `'Hello'`.
  String _upperCaseFirstLetter(String word) =>
      '${word.substring(0, 1).toUpperCase()}'
      '${word.substring(1).toLowerCase()}';
}
